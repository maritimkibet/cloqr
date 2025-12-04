import 'package:flutter/material.dart';
import '../models/message_model.dart';
import '../services/api_service.dart';
import '../services/socket_service.dart';
import '../config/api_config.dart';

class ChatProvider with ChangeNotifier {
  List<Chat> _chats = [];
  Map<String, List<Message>> _messages = {};
  bool _isLoading = false;

  List<Chat> get chats => _chats;
  Map<String, List<Message>> get messages => _messages;
  bool get isLoading => _isLoading;

  final SocketService _socket = SocketService();

  Future<void> initialize() async {
    await _socket.connect();
    _setupSocketListeners();
  }

  void _setupSocketListeners() {
    _socket.onNewMessage((data) {
      final message = Message.fromJson(data);
      if (_messages.containsKey(message.chatId)) {
        _messages[message.chatId]!.add(message);
        notifyListeners();
      }
    });

    _socket.onScreenshotAlert((data) {
      // Handle screenshot alert
      notifyListeners();
    });
  }

  Future<void> fetchChats() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.get(ApiConfig.chats);
      _chats = (response['chats'] as List)
          .map((chat) => Chat.fromJson(chat))
          .toList();
    } catch (e) {
      print('Error fetching chats: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMessages(String chatId) async {
    try {
      final response = await ApiService.get('${ApiConfig.chats}/$chatId/messages');
      _messages[chatId] = (response['messages'] as List)
          .map((msg) => Message.fromJson(msg))
          .toList();
      notifyListeners();
    } catch (e) {
      print('Error fetching messages: $e');
    }
  }

  void sendMessage(String chatId, String content, {String type = 'text'}) {
    _socket.sendMessage({
      'chatId': chatId,
      'content': content,
      'type': type,
    });
  }

  void joinChat(String chatId) {
    _socket.joinChat(chatId);
  }

  void reportScreenshot(String chatId) {
    _socket.reportScreenshot(chatId);
  }

  Future<String> createChat(String type, List<String> members, {String? name}) async {
    try {
      final response = await ApiService.post(ApiConfig.createChat, {
        'type': type,
        'members': members,
        'name': name,
      });
      await fetchChats();
      return response['chatId'];
    } catch (e) {
      rethrow;
    }
  }
}
