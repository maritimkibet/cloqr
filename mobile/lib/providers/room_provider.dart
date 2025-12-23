import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../config/api_config.dart';

class RoomProvider with ChangeNotifier {
  List<dynamic> _rooms = [];
  bool _isLoading = false;
  String? _error;

  List<dynamic> get rooms => _rooms;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchRooms() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.get(ApiConfig.rooms);
      _rooms = response['rooms'] ?? [];
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>?> createRoom({
    required String name,
    required String roomType,
    required int duration,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    print('🔵 RoomProvider: Creating room...');
    print('   URL: ${ApiConfig.createRoom}');
    print('   Data: name=$name, roomType=$roomType, duration=$duration');

    try {
      final response = await ApiService.post(
        ApiConfig.createRoom,
        {
          'name': name,
          'roomType': roomType,
          'duration': duration,
        },
      );

      print('✅ RoomProvider: Room created successfully');
      print('   Response: $response');

      await fetchRooms();
      return response;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      print('❌ RoomProvider: Error creating room: $_error');
      notifyListeners();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>?> joinRoom(String qrCode) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.post(
        ApiConfig.joinRoom,
        {'qrCode': qrCode},
      );

      await fetchRooms();
      return response;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> leaveRoom(String roomId) async {
    try {
      await ApiService.post(
        '${ApiConfig.rooms}/leave',
        {'roomId': roomId},
      );
      await fetchRooms();
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
    }
  }
}
