import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/payment_usecases.dart';
import 'payment_event.dart';
import 'payment_state.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  final CreatePaymentUseCase _createPayment;
  final GetPaymentByBookingUseCase _getPaymentByBooking;
  final GetPaymentByIdUseCase _getPaymentById;
  final SimulatePaymentSuccessUseCase _simulateSuccess;
  final InitiatePayOSUseCase _initiatePayOS;
  final InitiateMoMoUseCase _initiateMoMo;
  final RefundPaymentUseCase _refundPayment;
  final GetOwnerEarningsUseCase _getOwnerEarnings;

  PaymentBloc({
    required CreatePaymentUseCase createPayment,
    required GetPaymentByBookingUseCase getPaymentByBooking,
    required GetPaymentByIdUseCase getPaymentById,
    required SimulatePaymentSuccessUseCase simulateSuccess,
    required InitiatePayOSUseCase initiatePayOS,
    required InitiateMoMoUseCase initiateMoMo,
    required RefundPaymentUseCase refundPayment,
    required GetOwnerEarningsUseCase getOwnerEarnings,
  }) : _createPayment = createPayment,
       _getPaymentByBooking = getPaymentByBooking,
       _getPaymentById = getPaymentById,
       _simulateSuccess = simulateSuccess,
       _initiatePayOS = initiatePayOS,
       _initiateMoMo = initiateMoMo,
       _refundPayment = refundPayment,
       _getOwnerEarnings = getOwnerEarnings,
       super(const PaymentInitial()) {
    on<CreatePaymentEvent>(_onCreatePayment);
    on<LoadPaymentByBookingEvent>(_onLoadPaymentByBooking);
    on<GetPaymentByIdEvent>(_onGetPaymentById);
    on<SimulatePaymentSuccessEvent>(_onSimulateSuccess);
    on<InitiatePayOSEvent>(_onInitiatePayOS);
    on<InitiateMoMoEvent>(_onInitiateMoMo);
    on<RefundPaymentEvent>(_onRefundPayment);
    on<ResetPaymentStateEvent>(_onReset);
    on<LoadOwnerEarningsEvent>(_onLoadOwnerEarnings);
  }

  Future<void> _onCreatePayment(
    CreatePaymentEvent event,
    Emitter<PaymentState> emit,
  ) async {
    emit(const PaymentLoading());
    final result = await _createPayment(
      CreatePaymentParams(bookingId: event.bookingId, method: event.method),
    );
    result.fold(
      (failure) => emit(PaymentFailure(failure.message)),
      (payment) => emit(PaymentCreated(payment)),
    );
  }

  Future<void> _onLoadPaymentByBooking(
    LoadPaymentByBookingEvent event,
    Emitter<PaymentState> emit,
  ) async {
    emit(const PaymentLoading());
    final result = await _getPaymentByBooking(
      GetPaymentByBookingParams(event.bookingId),
    );
    result.fold(
      (failure) => emit(PaymentFailure(failure.message)),
      (payment) => payment != null
          ? emit(PaymentLoaded(payment))
          : emit(const NoPaymentFound()),
    );
  }

  Future<void> _onSimulateSuccess(
    SimulatePaymentSuccessEvent event,
    Emitter<PaymentState> emit,
  ) async {
    emit(const PaymentLoading());
    final result = await _simulateSuccess(
      SimulatePaymentSuccessParams(event.paymentId),
    );
    result.fold(
      (failure) => emit(PaymentFailure(failure.message)),
      (payment) => emit(PaymentSuccess(payment, 'Thanh toán thành công!')),
    );
  }

  Future<void> _onInitiatePayOS(
    InitiatePayOSEvent event,
    Emitter<PaymentState> emit,
  ) async {
    emit(const PaymentLoading());
    final result = await _initiatePayOS(InitiatePayOSParams(event.paymentId));
    result.fold(
      (failure) => emit(PaymentFailure(failure.message)),
      (data) => emit(
        PaymentUrlGenerated(
          paymentUrl: data['checkoutUrl'] ?? '',
          qrCode: data['qrCode'],
        ),
      ),
    );
  }

  Future<void> _onInitiateMoMo(
    InitiateMoMoEvent event,
    Emitter<PaymentState> emit,
  ) async {
    emit(const PaymentLoading());
    final result = await _initiateMoMo(InitiateMoMoParams(event.paymentId));
    result.fold(
      (failure) => emit(PaymentFailure(failure.message)),
      (data) => emit(
        PaymentUrlGenerated(
          paymentUrl: data['paymentUrl'] ?? '',
          deeplink: data['deeplink'],
        ),
      ),
    );
  }

  Future<void> _onGetPaymentById(
    GetPaymentByIdEvent event,
    Emitter<PaymentState> emit,
  ) async {
    emit(const PaymentLoading());
    final result = await _getPaymentById(GetPaymentByIdParams(event.paymentId));
    result.fold(
      (failure) => emit(PaymentFailure(failure.message)),
      (payment) => emit(PaymentLoaded(payment)),
    );
  }

  Future<void> _onRefundPayment(
    RefundPaymentEvent event,
    Emitter<PaymentState> emit,
  ) async {
    emit(const PaymentLoading());
    final result = await _refundPayment(
      RefundPaymentParams(paymentId: event.paymentId, otp: event.otp),
    );
    result.fold(
      (failure) => emit(PaymentFailure(failure.message)),
      (payment) => emit(PaymentRefunded(payment)),
    );
  }

  void _onReset(ResetPaymentStateEvent event, Emitter<PaymentState> emit) {
    emit(const PaymentInitial());
  }

  Future<void> _onLoadOwnerEarnings(
    LoadOwnerEarningsEvent event,
    Emitter<PaymentState> emit,
  ) async {
    emit(const PaymentLoading());
    final result = await _getOwnerEarnings(const NoParams());
    result.fold(
      (failure) => emit(PaymentFailure(failure.message)),
      (earnings) => emit(OwnerEarningsLoaded(earnings)),
    );
  }
}
