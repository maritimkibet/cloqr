import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../config/api_config.dart';
import 'storage_service.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  IO.Socket? _socket;
  final StorageService _storage = StorageService();
  bool _isConnecting = false;
  bool _isConnected = false;

  bool get isConnected => _isConnected;

  Future<void> connect() async {
    if (_isConnecting || _isConnected) return;
    
    _isConnecting = true;
    final token = await _storage.getToken();
    
    if (token == null) {
      print('⚠️ Cannot connect socket: No token available');
      _isConnecting = false;
      return;
    }
    
    try {
      _socket = IO.io(
        ApiConfig.socketUrl,
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .setAuth({'token': token})
            .enableReconnection()
            .setReconnectionAttempts(5)
            .setReconnectionDelay(1000)
            .build(),
      );

      _socket?.connect();

      _socket?.onConnect((_) {
        print('✅ Socket connected');
        _isConnected = true;
        _isConnecting = false;
      });

      _socket?.onDisconnect((_) {
        print('❌ Socket disconnected');
        _isConnected = false;
      });

      _socket?.onConnectError((error) {
        print('Socket connection error: $error');
        _isConnected = false;
        _isConnecting = false;
      });

      _socket?.onError((error) {
        print('Socket error: $error');
      });
    } catch (e) {
      print('Failed to initialize socket: $e');
      _isConnecting = false;
    }
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
  }

  void joinChat(String chatId) {
    _socket?.emit('join_chat', chatId);
  }

  void sendMessage(Map<String, dynamic> data) {
    _socket?.emit('send_message', data);
  }

  void onNewMessage(Function(dynamic) callback) {
    _socket?.on('new_message', callback);
  }

  void onScreenshotAlert(Function(dynamic) callback) {
    _socket?.on('screenshot_alert', callback);
  }

  void reportScreenshot(String chatId) {
    _socket?.emit('screenshot_detected', {'chatId': chatId});
  }

  void joinRoom(String roomId) {
    _socket?.emit('join_room', roomId);
  }

  void sendRoomMessage(Map<String, dynamic> data) {
    _socket?.emit('room_message', data);
  }

  void onRoomMessage(Function(dynamic) callback) {
    _socket?.on('room_message', callback);
  }

  void typing(String chatId) {
    _socket?.emit('typing', chatId);
  }

  void onUserTyping(Function(dynamic) callback) {
    _socket?.on('user_typing', callback);
  }
}
