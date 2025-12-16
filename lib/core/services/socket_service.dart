import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../storage/storage_service.dart';

/// Socket service for real-time notifications
class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  IO.Socket? _socket;
  final StorageService _storageService = StorageService();

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

  /// Connect to WebSocket server
  Future<void> connect(String serverUrl) async {
    if (_socket != null && _socket!.connected) {
      print('Socket already connected');
      return;
    }

    try {
      final token = await _storageService.getToken();
      if (token == null) {
        print('No auth token available');
        return;
      }

      _socket = IO.io(
        '$serverUrl/notifications',
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .disableAutoConnect()
            .setAuth({'token': token})
            .setExtraHeaders({'Authorization': 'Bearer $token'})
            .build(),
      );

      _setupListeners();
      _socket!.connect();

      print('Socket connecting to $serverUrl/notifications');
    } catch (e) {
      print('Socket connection error: $e');
    }
  }

  void _setupListeners() {
    if (_socket == null) return;

    // Connection events
    _socket!.onConnect((_) {
      print('Socket connected');
      _connectionController.add(true);
    });

    _socket!.onDisconnect((_) {
      print('Socket disconnected');
      _connectionController.add(false);
    });

    _socket!.onConnectError((error) {
      print('Socket connection error: $error');
      _connectionController.add(false);
    });

    _socket!.onError((error) {
      print('Socket error: $error');
    });

    // Connection confirmation
    _socket!.on('connected', (data) {
      print('Connection confirmed: $data');
    });

    // Notification events
    _socket!.on('booking_request', (data) {
      print('Received booking_request: $data');
      _notificationController.add({'type': 'booking_request', 'data': data});
    });

    _socket!.on('booking_confirmed', (data) {
      print('Received booking_confirmed: $data');
      _notificationController.add({'type': 'booking_confirmed', 'data': data});
    });

    _socket!.on('booking_rejected', (data) {
      print('Received booking_rejected: $data');
      _notificationController.add({'type': 'booking_rejected', 'data': data});
    });

    _socket!.on('booking_cancelled', (data) {
      print('Received booking_cancelled: $data');
      _notificationController.add({'type': 'booking_cancelled', 'data': data});
    });

    // Booking status changes
    _socket!.on('booking_status_changed', (data) {
      print('Received booking_status_changed: $data');
      _bookingUpdateController.add(data);
    });
  }

  /// Subscribe to specific booking updates
  void subscribeToBooking(String bookingId) {
    if (_socket != null && _socket!.connected) {
      _socket!.emit('subscribe_booking', {'bookingId': bookingId});
      print('Subscribed to booking: $bookingId');
    }
  }

  /// Unsubscribe from booking updates
  void unsubscribeFromBooking(String bookingId) {
    if (_socket != null && _socket!.connected) {
      _socket!.emit('unsubscribe_booking', {'bookingId': bookingId});
      print('Unsubscribed from booking: $bookingId');
    }
  }

  /// Disconnect from socket
  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    print('Socket disconnected');
  }

  /// Dispose all resources
  void dispose() {
    disconnect();
    _connectionController.close();
    _notificationController.close();
    _bookingUpdateController.close();
  }
}
