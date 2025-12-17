import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:logger/logger.dart';
import '../storage/storage_service.dart';

/// Socket service for real-time notifications
///
/// ✅ FIXED: Proper connection lifecycle management
/// - Queue subscriptions until socket is connected
/// - Execute pending actions after onConnect fires
/// - Prevent race conditions between connect() and subscribe()
class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  IO.Socket? _socket;
  final StorageService _storageService = StorageService();
  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 80,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );

  // Stream controllers
  final _connectionController = StreamController<bool>.broadcast();
  final _notificationController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _bookingUpdateController =
      StreamController<Map<String, dynamic>>.broadcast();

  // Public streams
  Stream<bool> get connectionStream => _connectionController.stream;
  Stream<Map<String, dynamic>> get notificationStream =>
      _notificationController.stream;
  Stream<Map<String, dynamic>> get bookingUpdateStream =>
      _bookingUpdateController.stream;

  bool get isConnected => _socket?.connected ?? false;

  // 🔥 FIX: Queue for pending actions before socket connects
  final List<VoidCallback> _pendingActions = [];
  bool _isConnecting = false;

  /// Connect to WebSocket server
  Future<void> connect(String serverUrl) async {
    if (_socket != null && _socket!.connected) {
      _logger.i('Socket already connected');
      return;
    }

    if (_isConnecting) {
      _logger.w('Socket connection already in progress');
      return;
    }

    try {
      _isConnecting = true;

      final token = await _storageService.getToken();
      if (token == null) {
        _logger.w('No auth token available for socket connection');
        _isConnecting = false;
        return;
      }

      _logger.i('🔌 Initiating socket connection to $serverUrl/notifications');
      _logger.d('Auth token: ${token.substring(0, 20)}...');

      _socket = IO.io(
        '$serverUrl/notifications',
        IO.OptionBuilder()
            .setTransports(['websocket', 'polling']) // Fallback to polling
            .disableAutoConnect() // Manual connection control
            .setAuth({'token': token})
            .setExtraHeaders({'Authorization': 'Bearer $token'})
            .setTimeout(5000)
            .setReconnectionDelay(1000)
            .setReconnectionAttempts(5)
            .build(),
      );

      _setupListeners();

      // Start connection
      _socket!.connect();

      _logger.i('Socket connection initiated, waiting for onConnect...');
    } catch (e, stackTrace) {
      _logger.e('Socket connection error', error: e, stackTrace: stackTrace);
      _isConnecting = false;
    }
  }

  void _setupListeners() {
    if (_socket == null) return;

    // ✅ FIX: Connection confirmation - execute pending actions here
    _socket!.onConnect((_) {
      _logger.i('✅ Socket connected successfully');
      _logger.d('Socket ID: ${_socket!.id}');
      _logger.d('Transport: ${_socket!.io.engine?.transport!.name}');

      _isConnecting = false;
      _connectionController.add(true);

      // 🔥 CRITICAL: Execute all pending actions after connection established
      _executePendingActions();
    });

    _socket!.onDisconnect((reason) {
      _logger.w('❌ Socket disconnected: $reason');
      _isConnecting = false;
      _connectionController.add(false);
    });

    _socket!.onConnectError((error) {
      _logger.e('🔴 Socket connection error: $error');
      _isConnecting = false;
      _connectionController.add(false);
    });

    _socket!.onError((error) {
      _logger.e('🔴 Socket error: $error');
    });

    _socket!.on('connect_timeout', (data) {
      _logger.e('🔴 Socket connection timeout: $data');
      _isConnecting = false;
    });

    // Connection confirmation from server
    _socket!.on('connected', (data) {
      _logger.d('✅ Connection confirmed by server: $data');
    });

    // Notification events - matching backend event names
    _socket!.on('booking_request', (data) {
      _logger.i('🔔 Received booking_request notification');
      _logger.d('Booking request data: $data');
      _notificationController.add({'type': 'BOOKING_REQUEST', 'data': data});
    });

    _socket!.on('booking_confirmed', (data) {
      _logger.i('🔔 Received booking_confirmed notification');
      _logger.d('Booking confirmed data: $data');
      _notificationController.add({'type': 'BOOKING_CONFIRMED', 'data': data});
    });

    _socket!.on('booking_rejected', (data) {
      _logger.i('🔔 Received booking_rejected notification');
      _logger.d('Booking rejected data: $data');
      _notificationController.add({'type': 'BOOKING_REJECTED', 'data': data});
    });

    _socket!.on('booking_cancelled', (data) {
      _logger.i('🔔 Received booking_cancelled notification');
      _logger.d('Booking cancelled data: $data');
      _notificationController.add({'type': 'BOOKING_CANCELLED', 'data': data});
    });

    _socket!.on('trip_started', (data) {
      _logger.i('🔔 Received trip_started notification');
      _logger.d('Trip started data: $data');
      _notificationController.add({'type': 'TRIP_STARTED', 'data': data});
    });

    _socket!.on('trip_completed', (data) {
      _logger.i('🔔 Received trip_completed notification');
      _logger.d('Trip completed data: $data');
      _notificationController.add({'type': 'TRIP_COMPLETED', 'data': data});
    });

    _socket!.on('payment_success', (data) {
      _logger.i('🔔 Received payment_success notification');
      _logger.d('Payment success data: $data');
      _notificationController.add({'type': 'PAYMENT_SUCCESS', 'data': data});
    });

    _socket!.on('payment_failed', (data) {
      _logger.i('🔔 Received payment_failed notification');
      _logger.d('Payment failed data: $data');
      _notificationController.add({'type': 'PAYMENT_FAILED', 'data': data});
    });

    // Booking status changes
    _socket!.on('booking_status_changed', (data) {
      _logger.i('📊 Received booking_status_changed event');
      _logger.d('Status changed data: $data');
      _bookingUpdateController.add(data);
    });
  }

  /// ✅ FIX: Execute all pending actions after socket connects
  void _executePendingActions() {
    if (_pendingActions.isEmpty) {
      _logger.d('No pending actions to execute');
      return;
    }

    _logger.i('🚀 Executing ${_pendingActions.length} pending actions');

    for (final action in _pendingActions) {
      try {
        action();
      } catch (e, stackTrace) {
        _logger.e(
          'Error executing pending action',
          error: e,
          stackTrace: stackTrace,
        );
      }
    }

    _pendingActions.clear();
    _logger.i('✅ All pending actions executed');
  }

  /// ✅ FIX: Queue action if not connected, execute immediately if connected
  void _executeOrQueue(String actionName, VoidCallback action) {
    if (_socket != null && _socket!.connected) {
      _logger.d('Socket connected, executing $actionName immediately');
      action();
    } else {
      _logger.w('⚠️ Socket not connected, queueing $actionName');
      _pendingActions.add(action);

      if (_isConnecting) {
        _logger.d(
          'Connection in progress, $actionName will execute on connect',
        );
      } else {
        _logger.w('Socket not connecting! Call connect() first');
      }
    }
  }

  /// Subscribe to specific booking updates
  /// ✅ FIX: Properly queued if socket not ready
  void subscribeToBooking(String bookingId) {
    _executeOrQueue('subscribe_booking:$bookingId', () {
      _socket!.emit('subscribe_booking', {'bookingId': bookingId});
      _logger.i('📌 Subscribed to booking: $bookingId');
    });
  }

  /// Unsubscribe from booking updates
  /// ✅ FIX: Properly queued if socket not ready
  void unsubscribeFromBooking(String bookingId) {
    _executeOrQueue('unsubscribe_booking:$bookingId', () {
      _socket!.emit('unsubscribe_booking', {'bookingId': bookingId});
      _logger.i('📌 Unsubscribed from booking: $bookingId');
    });
  }

  /// Join user-specific room (for receiving notifications)
  /// ✅ NEW: Explicit method to join user room
  void joinUserRoom(String userId) {
    _executeOrQueue('join_user_room:$userId', () {
      _socket!.emit('join_user_room', {'userId': userId});
      _logger.i('📌 Joined user room: user-$userId');
    });
  }

  /// Disconnect from socket
  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _isConnecting = false;
    _pendingActions.clear();
    _logger.i('🔌 Socket disconnected and disposed');
  }

  /// Dispose all resources
  void dispose() {
    disconnect();
    _connectionController.close();
    _notificationController.close();
    _bookingUpdateController.close();
    _logger.d('Socket service disposed - all streams closed');
  }
}
