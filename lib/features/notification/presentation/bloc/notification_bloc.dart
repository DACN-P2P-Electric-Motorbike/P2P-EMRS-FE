import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/notification_usecases.dart';
import 'notification_event.dart';
import 'notification_state.dart';

/// Notification BLoC - handles notification state management
class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final GetNotificationsUseCase _getNotificationsUseCase;
  final GetUnreadCountUseCase _getUnreadCountUseCase;
  final MarkAsReadUseCase _markAsReadUseCase;
  final MarkAllAsReadUseCase _markAllAsReadUseCase;
  final DeleteNotificationUseCase _deleteNotificationUseCase;

  NotificationBloc({
    required GetNotificationsUseCase getNotificationsUseCase,
    required GetUnreadCountUseCase getUnreadCountUseCase,
    required MarkAsReadUseCase markAsReadUseCase,
    required MarkAllAsReadUseCase markAllAsReadUseCase,
    required DeleteNotificationUseCase deleteNotificationUseCase,
  }) : _getNotificationsUseCase = getNotificationsUseCase,
       _getUnreadCountUseCase = getUnreadCountUseCase,
       _markAsReadUseCase = markAsReadUseCase,
       _markAllAsReadUseCase = markAllAsReadUseCase,
       _deleteNotificationUseCase = deleteNotificationUseCase,
       super(const NotificationInitial()) {
    on<LoadNotificationsEvent>(_onLoadNotifications);
    on<GetUnreadCountEvent>(_onGetUnreadCount);
    on<MarkAsReadEvent>(_onMarkAsRead);
    on<MarkAllAsReadEvent>(_onMarkAllAsRead);
    on<DeleteNotificationEvent>(_onDeleteNotification);
    on<ResetNotificationStateEvent>(_onResetState);
  }

  Future<void> _onLoadNotifications(
    LoadNotificationsEvent event,
    Emitter<NotificationState> emit,
  ) async {
    emit(const NotificationLoading());

    final params = GetNotificationsParams(
      limit: event.limit ?? 50,
      offset: event.offset ?? 0,
    );

    final result = await _getNotificationsUseCase(params);

    // FIX: Use await with fold to ensure proper async handling
    await result.fold(
      (failure) async {
        emit(NotificationFailure(failure.message));
      },
      (notifications) async {
        // Also get unread count
        final countResult = await _getUnreadCountUseCase(const NoParams());
        final unreadCount = countResult.fold((_) => 0, (count) => count);

        // Check if emitter is still valid before emitting
        if (!emit.isDone) {
          emit(
            NotificationsLoaded(
              notifications: notifications,
              unreadCount: unreadCount,
            ),
          );
        }
      },
    );
  }

  Future<void> _onGetUnreadCount(
    GetUnreadCountEvent event,
    Emitter<NotificationState> emit,
  ) async {
    final result = await _getUnreadCountUseCase(const NoParams());

    result.fold(
      (failure) => emit(NotificationFailure(failure.message)),
      (count) => emit(UnreadCountLoaded(count)),
    );
  }

  Future<void> _onMarkAsRead(
    MarkAsReadEvent event,
    Emitter<NotificationState> emit,
  ) async {
    final params = MarkAsReadParams(event.notificationIds);
    final result = await _markAsReadUseCase(params);

    result.fold((failure) => emit(NotificationFailure(failure.message)), (_) {
      // Reload notifications
      add(const LoadNotificationsEvent());
    });
  }

  Future<void> _onMarkAllAsRead(
    MarkAllAsReadEvent event,
    Emitter<NotificationState> emit,
  ) async {
    final result = await _markAllAsReadUseCase(const NoParams());

    result.fold((failure) => emit(NotificationFailure(failure.message)), (_) {
      emit(const NotificationActionSuccess('Đã đánh dấu tất cả đã đọc'));
      // Reload notifications
      add(const LoadNotificationsEvent());
    });
  }

  Future<void> _onDeleteNotification(
    DeleteNotificationEvent event,
    Emitter<NotificationState> emit,
  ) async {
    final params = DeleteNotificationParams(event.notificationId);
    final result = await _deleteNotificationUseCase(params);

    result.fold((failure) => emit(NotificationFailure(failure.message)), (_) {
      emit(const NotificationActionSuccess('Đã xóa thông báo'));
      // Reload notifications
      add(const LoadNotificationsEvent());
    });
  }

  void _onResetState(
    ResetNotificationStateEvent event,
    Emitter<NotificationState> emit,
  ) {
    emit(const NotificationInitial());
  }
}
