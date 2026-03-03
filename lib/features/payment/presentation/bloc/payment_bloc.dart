import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/payment_usecases.dart';
import 'payment_event.dart';
import 'payment_state.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  final CreatePaymentUseCase _createPayment;
  final GetPaymentByBookingUseCase _getPaymentByBooking;
  final SimulatePaymentSuccessUseCase _simulateSuccess;
  final InitiatePayOSUseCase _initiatePayOS;
  final InitiateMoMoUseCase _initiateMoMo;

  PaymentBloc({
    required CreatePaymentUseCase createPayment,
    required GetPaymentByBookingUseCase getPaymentByBooking,
    required SimulatePaymentSuccessUseCase simulateSuccess,
    required InitiatePayOSUseCase initiatePayOS,
    required InitiateMoMoUseCase initiateMoMo,
  }) : _createPayment = createPayment,
       _getPaymentByBooking = getPaymentByBooking,
       _simulateSuccess = simulateSuccess,
       _initiatePayOS = initiatePayOS,
       _initiateMoMo = initiateMoMo,
       super(const PaymentInitial()) {
    on<CreatePaymentEvent>(_onCreatePayment);
    on<LoadPaymentByBookingEvent>(_onLoadPaymentByBooking);
    on<SimulatePaymentSuccessEvent>(_onSimulateSuccess);
    on<InitiatePayOSEvent>(_onInitiatePayOS);
    on<InitiateMoMoEvent>(_onInitiateMoMo);
    on<ResetPaymentStateEvent>(_onReset);
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
      (payment) =>
          payment != null ? emit(PaymentLoaded(payment)) : emit(const NoPaymentFound()),
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
      (data) => emit(PaymentUrlGenerated(
        paymentUrl: data['checkoutUrl'] ?? '',
        qrCode: data['qrCode'],
      )),
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

  void _onReset(ResetPaymentStateEvent event, Emitter<PaymentState> emit) {
    emit(const PaymentInitial());
  }
}
