import 'package:dartz/dartz.dart';
import 'package:fe_capstone_project/core/error/failures.dart';
import 'package:fe_capstone_project/features/review/domain/entities/review_entity.dart';
import 'package:fe_capstone_project/features/review/domain/repositories/review_repository.dart';
import 'package:fe_capstone_project/features/review/domain/usecases/review_usecases.dart';
import 'package:fe_capstone_project/features/review/presentation/bloc/review_bloc.dart';
import 'package:fe_capstone_project/features/review/presentation/pages/trust_score_page.dart';
import 'package:fe_capstone_project/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// ---------------------------------------------------------------------------
/// Test fixtures
/// ---------------------------------------------------------------------------

DateTime get _now => DateTime.utc(2026, 5, 16, 10);

TrustScoreEvent _event({
  String id = 'evt',
  TrustScoreEventType type = TrustScoreEventType.kycVerified,
  double delta = 5,
  double scoreBefore = 100,
  double scoreAfter = 105,
  String? reason,
  DateTime? createdAt,
}) {
  return TrustScoreEvent(
    id: id,
    type: type,
    delta: delta,
    scoreBefore: scoreBefore,
    scoreAfter: scoreAfter,
    reason: reason,
    createdAt: createdAt ?? _now,
  );
}

TrustScoreWarning _warning({
  String id = 'warn',
  TrustScoreEventType type = TrustScoreEventType.lateReturn,
  String? reason,
  DateTime? createdAt,
  DateTime? expiresAt,
  DateTime? penalizedAt,
}) {
  final created = createdAt ?? _now;
  return TrustScoreWarning(
    id: id,
    type: type,
    reason: reason,
    createdAt: created,
    expiresAt: expiresAt ?? created.add(const Duration(days: 30)),
    penalizedAt: penalizedAt,
  );
}

TrustScoreBreakdown _breakdown({
  int trustScore = 95,
  List<TrustScoreEvent> events = const [],
  List<TrustScoreWarning> warnings = const [],
}) {
  return TrustScoreBreakdown(
    trustScore: trustScore,
    reviewsGiven: 4,
    reviewsGivenBonus: 4,
    avgRatingReceived: 4.5,
    totalReviewsReceived: 8,
    cancelledBookings: 1,
    cancellationPenalty: -5,
    rejectedBookings: 0,
    rejectionPenalty: 0,
    completedTrips: 5,
    tripsWithIssues: 0,
    violationPenalty: 0,
    recentEvents: events,
    activeWarnings: warnings,
  );
}

/// Mounts `TrustScorePage` with a real `ReviewBloc` wired through the supplied
/// fake repository. Returns the repository so tests can inspect call counts.
Future<_FakeReviewRepository> _pumpTrustScorePage(
  WidgetTester tester, {
  TrustScoreBreakdown? breakdown,
  Failure? failure,
  Duration loadDelay = Duration.zero,
}) async {
  await tester.binding.setSurfaceSize(const Size(500, 1400));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  final repository = _FakeReviewRepository(
    breakdown: breakdown,
    failure: failure,
    loadDelay: loadDelay,
  );

  if (sl.isRegistered<ReviewBloc>()) {
    await sl.unregister<ReviewBloc>();
  }
  sl.registerFactory<ReviewBloc>(
    () => ReviewBloc(
      createReview: CreateReviewUseCase(repository),
      getVehicleReviews: GetVehicleReviewsUseCase(repository),
      getMyReviews: GetMyReviewsUseCase(repository),
      getTrustScore: GetTrustScoreBreakdownUseCase(repository),
    ),
  );

  await tester.pumpWidget(MaterialApp(home: const TrustScorePage()));
  return repository;
}

/// ---------------------------------------------------------------------------
/// Tests
/// ---------------------------------------------------------------------------

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() async {
    if (sl.isRegistered<ReviewBloc>()) {
      await sl.unregister<ReviewBloc>();
    }
  });

  // =========================================================================
  // Component tests — render isolated states of TrustScorePage
  // =========================================================================
  group('TrustScorePage component', () {
    testWidgets('renders gauge denominator on the 0–150 scale', (tester) async {
      await _pumpTrustScorePage(tester, breakdown: _breakdown(trustScore: 95));
      await tester.pumpAndSettle();

      expect(find.text('95'), findsOneWidget);
      expect(find.text('/150'), findsOneWidget);
      expect(find.text('Tốt'), findsOneWidget);
    });

    testWidgets('renders correct tier label for each score band', (
      tester,
    ) async {
      const cases = <int, String>{
        130: 'Xuất sắc',
        100: 'Tốt',
        80: 'Trung bình',
        50: 'Thấp',
        20: 'Rất thấp',
      };

      for (final entry in cases.entries) {
        await _pumpTrustScorePage(
          tester,
          breakdown: _breakdown(trustScore: entry.key),
        );
        await tester.pumpAndSettle();
        expect(
          find.text(entry.value),
          findsOneWidget,
          reason: 'score=${entry.key} should render label "${entry.value}"',
        );
        // Tear down between iterations to drop the previous bloc subscription.
        await tester.pumpWidget(const SizedBox.shrink());
        if (sl.isRegistered<ReviewBloc>()) {
          await sl.unregister<ReviewBloc>();
        }
      }
    });

    testWidgets('does not render warnings or events sections when empty', (
      tester,
    ) async {
      await _pumpTrustScorePage(tester, breakdown: _breakdown());
      await tester.pumpAndSettle();

      expect(find.textContaining('Cảnh báo đang theo dõi'), findsNothing);
      expect(find.text('Hoạt động gần đây'), findsNothing);
    });

    testWidgets('renders the active-warnings card with countdown', (
      tester,
    ) async {
      final inSevenDays = DateTime.now().add(const Duration(days: 7));
      await _pumpTrustScorePage(
        tester,
        breakdown: _breakdown(
          warnings: [
            _warning(
              reason: 'Returned vehicle 45 minutes late',
              expiresAt: inSevenDays,
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Cảnh báo đang theo dõi (1)'), findsOneWidget);
      expect(find.text('Trả xe trễ'), findsOneWidget);
      expect(find.text('Returned vehicle 45 minutes late'), findsOneWidget);
      expect(find.textContaining('Còn '), findsOneWidget);
    });

    testWidgets('renders the events timeline with delta badges', (
      tester,
    ) async {
      await _pumpTrustScorePage(
        tester,
        breakdown: _breakdown(
          events: [
            _event(
              id: 'evt-positive',
              type: TrustScoreEventType.kycVerified,
              delta: 5,
              reason: 'Identity submitted',
            ),
            _event(
              id: 'evt-warning',
              type: TrustScoreEventType.warning,
              delta: 0,
              reason: 'First late-return notice',
            ),
            _event(
              id: 'evt-negative',
              type: TrustScoreEventType.badReviewReceived,
              delta: -3,
              reason: 'Received a low rating',
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Hoạt động gần đây'), findsOneWidget);
      expect(find.text('3 sự kiện'), findsOneWidget);
      expect(find.text('Xác thực CCCD/CMND'), findsOneWidget);
      expect(find.text('Cảnh báo (chưa trừ điểm)'), findsOneWidget);
      expect(find.text('Nhận đánh giá xấu'), findsOneWidget);
      expect(find.text('+5'), findsOneWidget);
      expect(find.text('-3'), findsOneWidget);
      // The warning row shows "Cảnh báo" both as the event-type label and as
      // the delta badge text.
      expect(find.text('Cảnh báo'), findsWidgets);
    });

    testWidgets('shows loading indicator while bloc is fetching', (
      tester,
    ) async {
      await _pumpTrustScorePage(
        tester,
        breakdown: _breakdown(),
        loadDelay: const Duration(seconds: 1),
      );
      // Pump once so the page mounts, but don't settle (the future is pending).
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Drain the pending future so the test cleanly tears down.
      await tester.pumpAndSettle(const Duration(seconds: 2));
    });

    testWidgets('shows retry button on failure and re-dispatches load', (
      tester,
    ) async {
      final repo = await _pumpTrustScorePage(
        tester,
        failure: const ServerFailure(message: 'Server unavailable'),
      );
      await tester.pumpAndSettle();

      expect(find.text('Server unavailable'), findsOneWidget);
      expect(find.text('Thử lại'), findsOneWidget);
      expect(repo.trustScoreCalls, 1);

      await tester.tap(find.text('Thử lại'));
      await tester.pumpAndSettle();

      expect(repo.trustScoreCalls, 2);
    });
  });

  // =========================================================================
  // Integration tests — full flow including Vietnam-time formatted timestamps.
  // =========================================================================
  group('TrustScorePage integration', () {
    testWidgets('full pipeline renders warnings + events from repository', (
      tester,
    ) async {
      final repo = await _pumpTrustScorePage(
        tester,
        breakdown: _breakdown(
          trustScore: 88,
          events: [
            _event(
              id: 'evt-good',
              type: TrustScoreEventType.goodReviewReceived,
              delta: 1,
              reason: 'Received a good rating',
              // 2026-05-16 10:00 UTC → 17:00 GMT+7
              createdAt: DateTime.utc(2026, 5, 16, 10),
            ),
          ],
          warnings: [
            _warning(
              reason: 'Cancelled booking less than 24 hours before pickup',
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(repo.trustScoreCalls, 1);
      // Score display
      expect(find.text('88'), findsOneWidget);
      expect(find.text('Trung bình'), findsOneWidget);
      // Warning section
      expect(find.text('Cảnh báo đang theo dõi (1)'), findsOneWidget);
      expect(
        find.text('Cancelled booking less than 24 hours before pickup'),
        findsOneWidget,
      );
      // Events section
      expect(find.text('Hoạt động gần đây'), findsOneWidget);
      expect(find.text('1 sự kiện'), findsOneWidget);
      expect(find.text('Nhận đánh giá tốt'), findsOneWidget);
      expect(find.text('+1'), findsOneWidget);
      // Vietnam-time timestamp (UTC 10:00 → GMT+7 17:00)
      expect(find.text('17:00 16/05/2026'), findsOneWidget);
    });

    testWidgets('failure path surfaces error UI and retry triggers reload', (
      tester,
    ) async {
      final repo = await _pumpTrustScorePage(
        tester,
        failure: const ServerFailure(message: 'Internal server error'),
      );
      await tester.pumpAndSettle();

      expect(find.text('Internal server error'), findsOneWidget);
      expect(find.text('Thử lại'), findsOneWidget);

      await tester.tap(find.text('Thử lại'));
      await tester.pumpAndSettle();
      expect(repo.trustScoreCalls, 2);
    });
  });

  // =========================================================================
  // Regression tests — guard prior fixes so they don't silently break.
  // =========================================================================
  group('TrustScorePage regression', () {
    testWidgets('uses /150 scale and clamps gauge value at max', (
      tester,
    ) async {
      await _pumpTrustScorePage(tester, breakdown: _breakdown(trustScore: 150));
      await tester.pumpAndSettle();

      expect(find.text('150'), findsOneWidget);
      expect(find.text('/150'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('penalty deltas show as negative chips, not absolute numbers', (
      tester,
    ) async {
      await _pumpTrustScorePage(tester, breakdown: _breakdown());
      await tester.pumpAndSettle();

      // Cancelled bookings = 1 → cancellationPenalty = -5
      expect(find.text('-5'), findsOneWidget);
    });

    testWidgets('does not regress to /100 scale', (tester) async {
      await _pumpTrustScorePage(tester, breakdown: _breakdown(trustScore: 100));
      await tester.pumpAndSettle();

      expect(find.text('/100'), findsNothing);
      expect(find.text('/150'), findsOneWidget);
    });
  });
}

/// ---------------------------------------------------------------------------
/// Fake repository — drives the real ReviewBloc with configurable success or
/// failure, and counts trust-score calls so retry behavior can be asserted.
/// ---------------------------------------------------------------------------
class _FakeReviewRepository implements ReviewRepository {
  _FakeReviewRepository({
    this.breakdown,
    this.failure,
    this.loadDelay = Duration.zero,
  });

  final TrustScoreBreakdown? breakdown;
  final Failure? failure;
  final Duration loadDelay;
  int trustScoreCalls = 0;

  @override
  Future<Either<Failure, ReviewEntity>> createReview({
    required String vehicleId,
    required int rating,
    String? comment,
    String? bookingId,
  }) async => const Left(ServerFailure(message: 'not used'));

  @override
  Future<Either<Failure, List<ReviewEntity>>> getMyReviews() async =>
      const Right(<ReviewEntity>[]);

  @override
  Future<Either<Failure, TrustScoreBreakdown>> getTrustScoreBreakdown() async {
    trustScoreCalls += 1;
    if (loadDelay > Duration.zero) {
      await Future.delayed(loadDelay);
    }
    if (failure != null) return Left(failure!);
    if (breakdown != null) return Right(breakdown!);
    return const Left(ServerFailure(message: 'no fixture configured'));
  }

  @override
  Future<Either<Failure, List<ReviewEntity>>> getVehicleReviews(
    String vehicleId,
  ) async => const Right(<ReviewEntity>[]);

  @override
  Future<Either<Failure, BookingReviewStatus>> getBookingReviewStatus(
    String bookingId,
  ) async => const Left(ServerFailure(message: 'not used'));
}
