import 'package:fe_capstone_project/core/settings/app_preferences_controller.dart';
import 'package:fe_capstone_project/core/storage/storage_service.dart';
import 'package:fe_capstone_project/core/widgets/app_avatar.dart';
import 'package:fe_capstone_project/core/widgets/app_network_image.dart';
import 'package:fe_capstone_project/core/utils/vietnam_time.dart';
import 'package:fe_capstone_project/core/localization/notification_text_localizer.dart';
import 'package:fe_capstone_project/features/booking/data/models/booking_model.dart';
import 'package:fe_capstone_project/core/localization/app_localizations.dart';
import 'package:fe_capstone_project/features/booking/domain/entities/booking.dart';
import 'package:fe_capstone_project/features/auth/data/models/user_model.dart';
import 'package:fe_capstone_project/features/auth/domain/entities/user.dart';
import 'package:fe_capstone_project/features/booking/data/models/cancellation_refund_preview_model.dart';
import 'package:fe_capstone_project/features/financial/data/datasources/financial_remote_datasource.dart';
import 'package:fe_capstone_project/features/financial/data/models/financial_summary_model.dart';
import 'package:fe_capstone_project/features/financial/data/repositories/financial_repository_impl.dart';
import 'package:fe_capstone_project/features/financial/domain/entities/financial_summary.dart';
import 'package:fe_capstone_project/features/incident/data/datasources/incident_remote_datasource.dart';
import 'package:fe_capstone_project/features/incident/data/models/claim_summary_model.dart';
import 'package:fe_capstone_project/features/incident/data/models/incident_report_model.dart';
import 'package:fe_capstone_project/features/incident/data/repositories/incident_repository_impl.dart';
import 'package:fe_capstone_project/features/incident/domain/entities/claim_summary.dart';
import 'package:fe_capstone_project/features/incident/domain/entities/incident_report.dart';
import 'package:fe_capstone_project/features/renter/data/models/become_owner_response_model.dart';
import 'package:fe_capstone_project/features/review/data/models/review_model.dart';
import 'package:fe_capstone_project/features/review/domain/entities/review_entity.dart';
import 'package:fe_capstone_project/features/settings/data/privacy_remote_data_source.dart';
import 'package:fe_capstone_project/features/settings/presentation/pages/app_settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
  });

  testWidgets(
    'AppNetworkImage shows a placeholder when data saver is enabled',
    (tester) async {
      final preferences = AppPreferencesController(StorageService());
      await preferences.setDataSaverEnabled(true);

      await tester.pumpWidget(
        AppPreferencesScope(
          controller: preferences,
          child: const MaterialApp(
            home: Scaffold(
              body: AppNetworkImage(
                imageUrl: 'https://example.com/vehicle.jpg',
                width: 120,
                height: 80,
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.image_not_supported_outlined), findsOneWidget);
      expect(find.byType(Image), findsNothing);
    },
  );

  test('BookingEntity displays sub-hour durations in minutes', () {
    final now = DateTime.utc(2026, 5, 9, 8);
    final booking = BookingEntity(
      id: 'booking-id',
      renterId: 'renter-id',
      ownerId: 'owner-id',
      vehicleId: 'vehicle-id',
      status: BookingStatus.CONFIRMED,
      startTime: now,
      endTime: now.add(const Duration(minutes: 30)),
      totalPrice: 25000,
      deposit: 200000,
      createdAt: now,
      updatedAt: now,
    );

    expect(booking.durationInHours, 0);
    expect(booking.durationDisplayText, '30 phút');
  });

  test('BookingModel reads payment status from nested payment payload', () {
    final model = BookingModel.fromJson({
      'id': 'booking-id',
      'renterId': 'renter-id',
      'ownerId': 'owner-id',
      'vehicleId': 'vehicle-id',
      'status': 'CONFIRMED',
      'startTime': '2026-05-10T03:00:00.000Z',
      'endTime': '2026-05-10T04:00:00.000Z',
      'totalPrice': 25000,
      'deposit': 200000,
      'protectionPlan': 'PREMIUM',
      'protectionFee': 2500,
      'protectionDeductible': 500000,
      'protectionCoverageLimit': 30000000,
      'createdAt': '2026-05-09T03:00:00.000Z',
      'updatedAt': '2026-05-09T03:00:00.000Z',
      'vehicle': {'batteryLevel': 87},
      'payment': {'status': 'COMPLETED'},
    });

    final booking = model.toEntity();
    expect(booking.paymentStatus, 'COMPLETED');
    expect(booking.isPaymentCompleted, isTrue);
    expect(booking.vehicleBatteryLevel, 87);
    expect(booking.protectionPlan, 'PREMIUM');
    expect(booking.protectionFee, 2500);
    expect(booking.protectionDeductible, 500000);
    expect(booking.protectionCoverageLimit, 30000000);
  });

  test('BecomeOwnerResponseDto tolerates non-string and minimal payloads', () {
    final promoted = BecomeOwnerResponseDto.fromJson({
      'user': {
        'id': 123,
        'roles': ['RENTER', 'OWNER'],
      },
      'accessToken': 987,
      'message': 'ok',
    });

    expect(promoted.userId, '123');
    expect(promoted.roles, ['RENTER', 'OWNER']);
    expect(promoted.accessToken, '987');
    expect(promoted.message, 'ok');

    final alreadyOwner = BecomeOwnerResponseDto.fromJson({
      'message': 'User has been OWNER',
    });

    expect(alreadyOwner.userId, isEmpty);
    expect(alreadyOwner.roles, isEmpty);
    expect(alreadyOwner.accessToken, isEmpty);
    expect(alreadyOwner.message, 'User has been OWNER');
  });

  test('FinancialSummaryModel parses deposit and post-trip charges', () {
    final model = FinancialSummaryModel.fromJson({
      'bookingId': 'booking-id',
      'deposit': {
        'id': 'deposit-id',
        'bookingId': 'booking-id',
        'paymentId': 'payment-id',
        'status': 'PENDING_CHARGES',
        'heldAmount': 300000,
        'pendingChargeAmount': 25000,
        'capturedAmount': 0,
        'releasedAmount': 275000,
        'refundedAmount': 0,
        'notes': 'Pending post-trip review',
        'heldAt': '2026-05-23T03:00:00.000Z',
        'releaseDueAt': null,
        'releasedAt': null,
        'disputedAt': null,
        'createdAt': '2026-05-23T03:00:00.000Z',
        'updatedAt': '2026-05-23T04:00:00.000Z',
      },
      'charges': [
        {
          'id': 'charge-id',
          'bookingId': 'booking-id',
          'tripId': 'trip-id',
          'type': 'LOW_BATTERY',
          'status': 'PENDING_REVIEW',
          'source': 'SYSTEM',
          'amount': 25000,
          'quantity': 5,
          'unitPrice': 5000,
          'description': 'Returned battery 5% below minimum',
          'reviewedBy': null,
          'reviewedAt': null,
          'createdAt': '2026-05-23T04:00:00.000Z',
          'updatedAt': '2026-05-23T04:00:00.000Z',
        },
      ],
      'totalPendingCharges': 25000,
      'totalApprovedCharges': 0,
      'totalCapturedCharges': 0,
      'releasableDeposit': 275000,
    });

    final summary = model.toEntity();
    expect(summary.deposit?.status, DepositLedgerStatus.pendingCharges);
    expect(summary.charges.single.type, PostTripChargeType.lowBattery);
    expect(summary.charges.single.status, PostTripChargeStatus.pendingReview);
    expect(summary.releasableDeposit, 275000);
    expect(summary.hasFinancialActivity, isTrue);
  });

  test('CancellationRefundPreviewModel parses rental and deposit split', () {
    final model = CancellationRefundPreviewModel.fromJson({
      'bookingId': 'booking-id',
      'cancelledBy': 'RENTER',
      'cancellable': true,
      'hoursUntilStart': 12,
      'policyCode': 'RENTER_STANDARD_PARTIAL_REFUND',
      'rentalRefundRate': 0.5,
      'trustPenalty': 5,
      'rentalAmount': 100000,
      'protectionAmount': 10000,
      'depositAmount': 500000,
      'paidAmount': 610000,
      'refundableRentalAmount': 50000,
      'refundableProtectionAmount': 5000,
      'refundableDepositAmount': 500000,
      'refundAmount': 555000,
      'forfeitedRentalAmount': 50000,
      'forfeitedProtectionAmount': 5000,
      'forfeitedDepositAmount': 0,
      'forfeitedAmount': 55000,
      'isPaid': true,
      'paymentStatus': 'COMPLETED',
      'refundType': 'partial',
    });

    final preview = model.toEntity();
    expect(preview.policyDisplayText, 'Hoàn 50% tiền thuê');
    expect(preview.refundableProtectionAmount, 5000);
    expect(preview.refundableDepositAmount, 500000);
    expect(preview.refundAmount, 555000);
    expect(preview.forfeitedProtectionAmount, 5000);
    expect(preview.forfeitedAmount, 55000);
    expect(preview.trustPenalty, 5);
  });

  test(
    'FinancialRepositoryImpl maps manual charge type to API value',
    () async {
      final remoteDataSource = _FakeFinancialRemoteDataSource();
      final repository = FinancialRepositoryImpl(
        remoteDataSource: remoteDataSource,
      );

      final result = await repository.createManualPostTripCharge(
        bookingId: 'booking-id',
        type: PostTripChargeType.roadsideAssistance,
        amount: 75000,
        description: 'Roadside support fee',
        evidenceUrls: const ['https://example.com/evidence.jpg'],
      );

      expect(result.isRight(), isTrue);
      expect(remoteDataSource.lastBookingId, 'booking-id');
      expect(remoteDataSource.lastType, 'ROADSIDE_ASSISTANCE');
      expect(remoteDataSource.lastAmount, 75000);
      expect(remoteDataSource.lastDescription, 'Roadside support fee');
      expect(remoteDataSource.lastEvidenceUrls, [
        'https://example.com/evidence.jpg',
      ]);
    },
  );

  test('FinancialRepositoryImpl forwards renter charge disputes', () async {
    final remoteDataSource = _FakeFinancialRemoteDataSource();
    final repository = FinancialRepositoryImpl(
      remoteDataSource: remoteDataSource,
    );

    final result = await repository.disputePostTripCharge(
      chargeId: 'charge-id',
      reason: 'Damage existed before pickup',
      evidenceUrls: const ['https://example.com/check-in.jpg'],
    );

    expect(result.isRight(), isTrue);
    expect(remoteDataSource.lastDisputeChargeId, 'charge-id');
    expect(remoteDataSource.lastDisputeReason, 'Damage existed before pickup');
    expect(remoteDataSource.lastDisputeEvidenceUrls, [
      'https://example.com/check-in.jpg',
    ]);
  });

  test('IncidentReportModel parses backend evidence policy payload', () {
    final model = IncidentReportModel.fromJson({
      'id': 'incident-id',
      'bookingId': 'booking-id',
      'tripId': 'trip-id',
      'postTripChargeId': null,
      'reporterId': 'renter-id',
      'category': 'DAMAGE',
      'severity': 'HIGH',
      'status': 'UNDER_REVIEW',
      'description': 'Scratch found during checkout',
      'evidence': {
        'evidenceUrls': ['https://example.com/damage.jpg'],
        'handoverPhotos': [
          {'id': 'photo-1'},
          {'id': 'photo-2'},
        ],
      },
      'requiredEvidence': {'photoRequired': true, 'satisfied': true},
      'adminNotes': 'Checking handover photos',
      'reviewedAt': '2026-05-24T03:00:00.000Z',
      'resolvedAt': null,
      'createdAt': '2026-05-24T02:00:00.000Z',
      'updatedAt': '2026-05-24T03:00:00.000Z',
    });

    final incident = model.toEntity();
    expect(incident.category, IncidentCategory.damage);
    expect(incident.severity, IncidentSeverity.high);
    expect(incident.status, IncidentStatus.underReview);
    expect(incident.evidenceUrls, ['https://example.com/damage.jpg']);
    expect(incident.handoverPhotoCount, 2);
    expect(incident.photoRequired, isTrue);
    expect(incident.evidenceSatisfied, isTrue);
    expect(incident.isOpen, isTrue);
  });

  test('BookingClaimSummaryModel parses unified claim workflow payload', () {
    final model = BookingClaimSummaryModel.fromJson({
      'bookingId': 'booking-id',
      'status': 'AWAITING_DEPOSIT_DECISION',
      'statusLabel': 'Awaiting deposit decision',
      'claimCase': {
        'id': 'claim-case-id',
        'caseNumber': 'CLM-20260525-0001',
        'bookingId': 'booking-id',
        'status': 'PENDING_SECOND_REVIEW',
        'outcome': 'OWNER_CLAIM_APPROVED',
        'summary': 'Owner damage evidence accepted.',
        'firstDecision': 'OWNER_CLAIM_APPROVED',
        'firstReviewedAt': '2026-05-24T03:00:00.000Z',
        'secondDecision': null,
        'secondReviewedAt': null,
        'resolvedAt': null,
        'sla': {
          'status': 'AT_RISK',
          'stage': 'SECOND_REVIEW',
          'dueAt': '2026-05-24T15:00:00.000Z',
          'label': 'Second review due soon',
          'remainingMinutes': 75,
          'overdueMinutes': 0,
          'escalationLevel': 0,
        },
      },
      'totals': {
        'incidentCount': 1,
        'openIncidentCount': 0,
        'unresolvedIncidentCount': 1,
        'pendingChargeAmount': 120000,
        'approvedChargeAmount': 30000,
        'capturedChargeAmount': 0,
        'finalizedChargeAmount': 0,
        'heldDepositAmount': 500000,
        'releasableDepositAmount': 350000,
        'ownerPayoutAmount': 170000,
      },
      'blockers': [
        {
          'code': 'DEPOSIT_DECISION_PENDING',
          'label': 'Deposit ledger is DISPUTED',
          'count': 1,
          'blocksDepositRelease': true,
          'blocksOwnerPayout': true,
        },
      ],
      'nextActions': [
        {
          'actor': 'ADMIN',
          'action': 'Capture approved charges or waive them',
          'reason': '1 approved charge(s) are not finalized',
          'priority': 'HIGH',
        },
      ],
      'timeline': [
        {
          'type': 'INCIDENT_CREATED',
          'label': 'Incident filed: DAMAGE',
          'status': 'UNDER_REVIEW',
          'occurredAt': '2026-05-24T02:00:00.000Z',
          'sourceId': 'incident-id',
        },
      ],
      'incidents': [
        {
          'id': 'incident-id',
          'bookingId': 'booking-id',
          'reporterId': 'renter-id',
          'category': 'DAMAGE',
          'severity': 'HIGH',
          'status': 'UNDER_REVIEW',
          'description': 'Scratch found during checkout',
          'evidence': const {},
          'requiredEvidence': const {},
          'createdAt': '2026-05-24T02:00:00.000Z',
          'updatedAt': '2026-05-24T03:00:00.000Z',
        },
      ],
      'canReleaseDeposit': false,
      'canProcessPayout': false,
    });

    final summary = model.toEntity();
    expect(summary.status, ClaimWorkflowStatus.awaitingDepositDecision);
    expect(summary.claimCase?.caseNumber, 'CLM-20260525-0001');
    expect(summary.claimCase?.sla?.status, 'AT_RISK');
    expect(summary.claimCase?.sla?.remainingMinutes, 75);
    expect(summary.totals.releasableDepositAmount, 350000);
    expect(summary.blockers.single.code, 'DEPOSIT_DECISION_PENDING');
    expect(summary.nextActions.single.actor, 'ADMIN');
    expect(summary.timeline.single.type, 'INCIDENT_CREATED');
    expect(summary.incidents.single.category, IncidentCategory.damage);
    expect(summary.hasActiveClaim, isTrue);
  });

  test(
    'IncidentRepositoryImpl maps incident enums to backend values',
    () async {
      final remoteDataSource = _FakeIncidentRemoteDataSource();
      final repository = IncidentRepositoryImpl(
        remoteDataSource: remoteDataSource,
      );

      final result = await repository.createIncidentReport(
        bookingId: 'booking-id',
        category: IncidentCategory.vehicleMismatch,
        severity: IncidentSeverity.critical,
        description: 'Vehicle does not match listing photos',
        evidenceUrls: const ['https://example.com/mismatch.jpg'],
        handoverPhotoIds: const ['handover-photo-id'],
      );

      expect(result.isRight(), isTrue);
      expect(remoteDataSource.lastBookingId, 'booking-id');
      expect(remoteDataSource.lastCategory, 'VEHICLE_MISMATCH');
      expect(remoteDataSource.lastSeverity, 'CRITICAL');
      expect(
        remoteDataSource.lastDescription,
        'Vehicle does not match listing photos',
      );
      expect(remoteDataSource.lastEvidenceUrls, [
        'https://example.com/mismatch.jpg',
      ]);
      expect(remoteDataSource.lastHandoverPhotoIds, ['handover-photo-id']);
    },
  );

  test('IncidentRepositoryImpl returns booking claim summary', () async {
    final remoteDataSource = _FakeIncidentRemoteDataSource();
    final repository = IncidentRepositoryImpl(
      remoteDataSource: remoteDataSource,
    );

    final result = await repository.getBookingClaimSummary('booking-id');

    expect(result.isRight(), isTrue);
    result.fold((_) => fail('Expected claim summary'), (summary) {
      expect(summary.bookingId, 'booking-id');
      expect(summary.status, ClaimWorkflowStatus.open);
      expect(summary.incidents.single.description, 'Issue reported');
    });
    expect(remoteDataSource.lastBookingId, 'booking-id');
  });

  test('VietnamTime formats UTC API timestamps as GMT+7', () {
    final utcTime = DateTime.parse('2026-05-10T03:00:00.000Z');

    expect(VietnamTime.format(utcTime, 'dd/MM/yyyy HH:mm'), '10/05/2026 10:00');
    expect(
      VietnamTime.toApiIsoString(DateTime(2026, 5, 10, 10, 0)),
      '2026-05-10T10:00:00.000+07:00',
    );
  });

  test('ReviewModel reads reviewed booking id from nested trip payload', () {
    final model = ReviewModel.fromJson({
      'id': 'review-id',
      'userId': 'user-id',
      'vehicleId': 'vehicle-id',
      'tripId': 'trip-id',
      'rating': 5,
      'comment': 'Xe tốt',
      'createdAt': '2026-05-09T03:00:00.000Z',
      'updatedAt': '2026-05-09T03:00:00.000Z',
      'trip': {'bookingId': 'booking-id'},
    });

    expect(model.tripId, 'trip-id');
    expect(model.bookingId, 'booking-id');
    expect(model.toEntity().bookingId, 'booking-id');
  });

  test('TrustScoreBreakdownModel parses recent events and active warnings', () {
    final model = TrustScoreBreakdownModel.fromJson({
      'trustScore': 95,
      'breakdown': {
        'reviewsGiven': 4,
        'reviewsGivenBonus': 4,
        'avgRatingReceived': 4.5,
        'totalReviewsReceived': 8,
        'cancelledBookings': 1,
        'cancellationPenalty': -5,
        'rejectedBookings': 0,
        'rejectionPenalty': 0,
        'completedTrips': 5,
        'tripsWithIssues': 0,
        'violationPenalty': 0,
      },
      'recentEvents': [
        {
          'id': 'evt-1',
          'type': 'KYC_VERIFIED',
          'delta': 5,
          'scoreBefore': 100,
          'scoreAfter': 105,
          'reason': 'Identity document submitted during registration',
          'createdAt': '2026-05-15T10:00:00.000Z',
        },
        {
          'id': 'evt-2',
          'type': 'WARNING',
          'delta': 0,
          'scoreBefore': 105,
          'scoreAfter': 105,
          'reason': 'Late return warning',
          'createdAt': '2026-05-15T11:00:00.000Z',
        },
        {
          'id': 'evt-3',
          'type': 'BAD_REVIEW_RECEIVED',
          'delta': -3,
          'scoreBefore': 105,
          'scoreAfter': 102,
          'reason': 'Received a low rating',
          'createdAt': '2026-05-15T12:00:00.000Z',
        },
      ],
      'activeWarnings': [
        {
          'id': 'warn-1',
          'type': 'LATE_RETURN',
          'reason': 'Returned vehicle 45 minutes late',
          'createdAt': '2026-05-15T11:00:00.000Z',
          'expiresAt': '2026-06-14T11:00:00.000Z',
        },
      ],
    });

    final breakdown = model.entity;
    expect(breakdown.trustScore, 95);
    expect(breakdown.recentEvents, hasLength(3));
    expect(breakdown.recentEvents[0].type, TrustScoreEventType.kycVerified);
    expect(breakdown.recentEvents[0].isPositive, isTrue);
    expect(breakdown.recentEvents[1].type, TrustScoreEventType.warning);
    expect(breakdown.recentEvents[1].isWarning, isTrue);
    expect(
      breakdown.recentEvents[2].type,
      TrustScoreEventType.badReviewReceived,
    );
    expect(breakdown.recentEvents[2].isNegative, isTrue);

    expect(breakdown.activeWarnings, hasLength(1));
    expect(breakdown.activeWarnings.first.type, TrustScoreEventType.lateReturn);
    expect(breakdown.activeWarnings.first.penalizedAt, isNull);
  });

  test('TrustScoreBreakdownModel handles missing events/warnings fields', () {
    final model = TrustScoreBreakdownModel.fromJson({
      'trustScore': 100,
      'breakdown': {
        'reviewsGiven': 0,
        'reviewsGivenBonus': 0,
        'avgRatingReceived': null,
        'totalReviewsReceived': 0,
        'cancelledBookings': 0,
        'cancellationPenalty': 0,
        'rejectedBookings': 0,
        'rejectionPenalty': 0,
        'completedTrips': 0,
        'tripsWithIssues': 0,
        'violationPenalty': 0,
      },
    });

    expect(model.entity.recentEvents, isEmpty);
    expect(model.entity.activeWarnings, isEmpty);
  });

  test('User role checks handle multi-role and enum-like values', () {
    final now = DateTime.utc(2026, 5, 9);
    final user = UserEntity(
      id: 'user-id',
      email: 'owner@example.com',
      fullName: 'Owner',
      phone: '0900000000',
      roles: const ['renter', 'UserRole.OWNER', 'admin'],
      status: 'ACTIVE',
      trustScore: 100,
      createdAt: now,
      updatedAt: now,
    );

    expect(user.isRenter, isTrue);
    expect(user.isOwner, isTrue);
    expect(user.isAdmin, isTrue);

    final model = UserModel.fromJson({
      'id': 'user-id',
      'email': 'owner@example.com',
      'fullName': 'Owner',
      'phone': '0900000000',
      'roles': ['renter', 'UserRole.OWNER'],
      'status': 'ACTIVE',
      'trustScore': 100,
      'createdAt': '2026-05-09T03:00:00.000Z',
      'updatedAt': '2026-05-09T03:00:00.000Z',
    });

    expect(model.roles, ['RENTER', 'OWNER']);
    expect(model.toEntity().isOwner, isTrue);
  });

  test('NotificationTextLocalizer follows the selected app language', () {
    final vi = NotificationTextLocalizer.localize(
      type: 'BOOKING_REJECTED',
      title: 'Booking Rejected',
      message: 'Your booking request was rejected. Reason: Schedule conflict',
      locale: const Locale('vi'),
    );
    final en = NotificationTextLocalizer.localize(
      type: 'PAYMENT_SUCCESS',
      title: 'Đã nhận thanh toán',
      message: 'Bạn vừa nhận được 250.000 VND từ chuyến thuê xe.',
      locale: const Locale('en'),
    );
    final claim = NotificationTextLocalizer.localize(
      type: 'CLAIM_UPDATED',
      title: 'Hồ sơ claim đã có kết luận',
      message: 'Hồ sơ claim CLM-1 đã được chốt.',
      locale: const Locale('vi'),
    );

    expect(vi.title, 'Đặt xe bị từ chối');
    expect(vi.message, contains('Lý do: Schedule conflict'));
    expect(en.title, 'Payment received');
    expect(en.message, contains('250.000 VND'));
    expect(claim.title, 'Hồ sơ claim đã có kết luận');
    expect(claim.message, contains('CLM-1'));
  });

  testWidgets('AppAvatar does not load network images in data saver mode', (
    tester,
  ) async {
    final preferences = AppPreferencesController(StorageService());
    await preferences.setDataSaverEnabled(true);

    await tester.pumpWidget(
      AppPreferencesScope(
        controller: preferences,
        child: const MaterialApp(
          home: Scaffold(
            body: AppAvatar(
              imageUrl: 'https://example.com/avatar.jpg',
              fallbackText: 'Alice',
              size: 64,
            ),
          ),
        ),
      ),
    );

    expect(find.text('A'), findsOneWidget);
    expect(find.byType(Image), findsNothing);
  });

  testWidgets('AppSettingsPage exports data and creates deletion requests', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(900, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final preferences = AppPreferencesController(StorageService());
    await preferences.setLocale(const Locale('en'));
    final privacy = _FakePrivacyRemoteDataSource();

    await tester.pumpWidget(
      AppPreferencesScope(
        controller: preferences,
        child: MaterialApp(
          locale: preferences.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: AppSettingsPage(privacyRemoteDataSource: privacy),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No requests yet.'), findsOneWidget);

    await tester.ensureVisible(find.text('Export data'));
    await tester.tap(find.text('Export data'));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Data summary'), findsOneWidget);
    expect(find.text('Bookings'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);

    await tester.tap(find.text('Close'));
    await tester.pump(const Duration(milliseconds: 500));

    await tester.ensureVisible(find.text('Request account deletion'));
    await tester.tap(find.text('Request account deletion'));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tap(find.text('Confirm'));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Pending'), findsOneWidget);
    expect(privacy.deletionRequests, 1);
  });

  testWidgets('AppSettingsPage fits compact phone and tablet viewports', (
    tester,
  ) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final viewports = [
      const Size(320, 568),
      const Size(390, 844),
      const Size(768, 1024),
      const Size(1024, 1366),
    ];

    for (final viewport in viewports) {
      await tester.binding.setSurfaceSize(viewport);
      final preferences = AppPreferencesController(StorageService());
      await preferences.setLocale(const Locale('en'));

      await tester.pumpWidget(
        AppPreferencesScope(
          controller: preferences,
          child: MaterialApp(
            locale: preferences.locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: AppSettingsPage(
              privacyRemoteDataSource: _FakePrivacyRemoteDataSource(),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));

      expect(tester.takeException(), isNull);
      expect(find.text('App settings'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Export data'),
        200,
        maxScrolls: 20,
      );
      await tester.pump(const Duration(milliseconds: 200));
      expect(tester.takeException(), isNull);
      expect(find.text('Export data'), findsOneWidget);
    }
  });

  testWidgets('AppSettingsPage exposes accessibility labels for controls', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(900, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final semantics = tester.ensureSemantics();

    try {
      final preferences = AppPreferencesController(StorageService());
      await preferences.setLocale(const Locale('en'));

      await tester.pumpWidget(
        AppPreferencesScope(
          controller: preferences,
          child: MaterialApp(
            locale: preferences.locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: AppSettingsPage(
              privacyRemoteDataSource: _FakePrivacyRemoteDataSource(),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));

      await tester.scrollUntilVisible(
        find.byTooltip('Refresh'),
        200,
        maxScrolls: 20,
      );
      expect(find.byTooltip('Refresh'), findsOneWidget);
      expect(find.text('Export data'), findsOneWidget);
      expect(find.text('Request account deletion'), findsOneWidget);
    } finally {
      semantics.dispose();
    }
  });
}

class _FakePrivacyRemoteDataSource implements PrivacyRemoteDataSource {
  int deletionRequests = 0;

  @override
  Future<PrivacyExportResult> exportPersonalData() async {
    return PrivacyExportResult(
      generatedAt: DateTime(2026, 4, 29, 10, 30),
      user: {
        'bookingsAsRenter': [{}, {}],
        'bookingsAsOwner': [],
        'paymentsAsPayer': [{}],
        'paymentsAsReceiver': [],
        'trips': [{}],
        'reviews': [{}],
      },
    );
  }

  @override
  Future<List<PrivacyRequestItem>> getMyRequests() async => [];

  @override
  Future<PrivacyRequestItem> requestAccountDeletion() async {
    deletionRequests += 1;
    return PrivacyRequestItem(
      id: 'privacy-request-1',
      type: 'DELETE_ACCOUNT',
      status: 'PENDING',
      dueAt: DateTime(2026, 5, 2, 10, 30),
      createdAt: DateTime(2026, 4, 29, 10, 30),
      completedAt: null,
    );
  }
}

class _FakeFinancialRemoteDataSource implements FinancialRemoteDataSource {
  String? lastBookingId;
  String? lastType;
  double? lastAmount;
  String? lastDescription;
  List<String>? lastEvidenceUrls;
  String? lastDisputeChargeId;
  String? lastDisputeReason;
  List<String>? lastDisputeEvidenceUrls;

  @override
  Future<FinancialSummaryModel> getBookingFinancialSummary(String bookingId) {
    return Future.value(_emptySummary(bookingId));
  }

  @override
  Future<FinancialSummaryModel> createManualPostTripCharge({
    required String bookingId,
    required String type,
    required double amount,
    required String description,
    double? quantity,
    double? unitPrice,
    List<String>? evidenceUrls,
  }) {
    lastBookingId = bookingId;
    lastType = type;
    lastAmount = amount;
    lastDescription = description;
    lastEvidenceUrls = evidenceUrls;
    return Future.value(_emptySummary(bookingId));
  }

  @override
  Future<FinancialSummaryModel> disputePostTripCharge({
    required String chargeId,
    required String reason,
    List<String>? evidenceUrls,
  }) {
    lastDisputeChargeId = chargeId;
    lastDisputeReason = reason;
    lastDisputeEvidenceUrls = evidenceUrls;
    return Future.value(_emptySummary('booking-id'));
  }

  FinancialSummaryModel _emptySummary(String bookingId) {
    return FinancialSummaryModel(
      bookingId: bookingId,
      charges: const [],
      totalPendingCharges: 0,
      totalApprovedCharges: 0,
      totalCapturedCharges: 0,
      releasableDeposit: 0,
    );
  }
}

class _FakeIncidentRemoteDataSource implements IncidentRemoteDataSource {
  String? lastBookingId;
  String? lastCategory;
  String? lastSeverity;
  String? lastDescription;
  List<String>? lastEvidenceUrls;
  List<String>? lastHandoverPhotoIds;

  @override
  Future<List<IncidentReportModel>> getBookingIncidents(String bookingId) {
    return Future.value([_emptyIncident(bookingId)]);
  }

  @override
  Future<BookingClaimSummaryModel> getBookingClaimSummary(String bookingId) {
    lastBookingId = bookingId;
    return Future.value(
      BookingClaimSummaryModel(
        bookingId: bookingId,
        status: 'OPEN',
        statusLabel: 'Claim opened',
        totals: const ClaimSummaryTotalsModel(
          incidentCount: 1,
          openIncidentCount: 1,
          unresolvedIncidentCount: 1,
          pendingChargeAmount: 0,
          approvedChargeAmount: 0,
          capturedChargeAmount: 0,
          finalizedChargeAmount: 0,
          heldDepositAmount: 0,
          releasableDepositAmount: 0,
          ownerPayoutAmount: 0,
        ),
        blockers: const [],
        nextActions: const [],
        timeline: const [],
        incidents: [_emptyIncident(bookingId)],
        canReleaseDeposit: false,
        canProcessPayout: false,
      ),
    );
  }

  @override
  Future<IncidentReportModel> createIncidentReport({
    required String bookingId,
    String? tripId,
    String? postTripChargeId,
    required String category,
    required String severity,
    required String description,
    List<String>? evidenceUrls,
    List<String>? handoverPhotoIds,
  }) {
    lastBookingId = bookingId;
    lastCategory = category;
    lastSeverity = severity;
    lastDescription = description;
    lastEvidenceUrls = evidenceUrls;
    lastHandoverPhotoIds = handoverPhotoIds;
    return Future.value(_emptyIncident(bookingId));
  }

  IncidentReportModel _emptyIncident(String bookingId) {
    return IncidentReportModel(
      id: 'incident-id',
      bookingId: bookingId,
      reporterId: 'renter-id',
      category: 'MECHANICAL_ISSUE',
      severity: 'MEDIUM',
      status: 'OPEN',
      description: 'Issue reported',
      evidenceUrls: const [],
      handoverPhotoCount: 0,
      photoRequired: false,
      evidenceSatisfied: true,
      createdAt: DateTime(2026, 5, 24),
      updatedAt: DateTime(2026, 5, 24),
    );
  }
}
