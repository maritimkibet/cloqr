import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../config/api_config.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  Profile? _profile;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  Profile? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  final StorageService _storage = StorageService();

  Future<void> sendOTP(String email) async {
    _setLoading(true);

    try {
      await ApiService.post(ApiConfig.sendOtp, {'email': email});
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
      rethrow;
    }
  }

  Future<String> verifyOTP(String email, String otp) async {
    _setLoading(true);

    try {
      final response = await ApiService.post(
        ApiConfig.verifyOtp,
        {'email': email, 'otp': otp},
      );
      _isLoading = false;
      notifyListeners();
      return response['emailHash'];
    } catch (e) {
      _setError(e.toString());
      rethrow;
    }
  }

  Future<void> register({
    required String email,
    required String username,
    required String campus,
    String? avatar,
    String? qrCode,
    String? password,
    bool emailVerified = false,
  }) async {
    _setLoading(true);

    try {
      final finalPassword = password ?? 'auto_${DateTime.now().millisecondsSinceEpoch}_${email.hashCode}';
      
      final response = await ApiService.post(ApiConfig.register, {
        'email': email,
        'username': username,
        'campus': campus,
        if (avatar != null) 'avatar': avatar,
        if (qrCode != null) 'qrCode': qrCode,
        'password': finalPassword,
        'emailVerified': emailVerified,
      });

      await Future.wait([
        _storage.saveToken(response['token']),
        _storage.saveUser(response['user']),
      ]);
      
      _user = User.fromJson(response['user']);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
      rethrow;
    }
  }

  Future<void> login(String email, {String? password}) async {
    _setLoading(true);

    try {
      final response = await ApiService.post(ApiConfig.login, {
        'email': email,
        if (password != null) 'password': password,
      });

      await Future.wait([
        _storage.saveToken(response['token']),
        _storage.saveUser(response['user']),
      ]);
      
      _user = User.fromJson(response['user']);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
      rethrow;
    }
  }

  Future<void> loadUser() async {
    final userData = await _storage.getUser();
    if (userData != null) {
      _user = User.fromJson(userData);
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _storage.clearAll();
    _user = null;
    _profile = null;
    notifyListeners();
  }

  Future<void> setupPin(String pin) async {
    try {
      await ApiService.post(ApiConfig.setupPin, {'pin': pin});
      await _storage.savePin(pin);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateProfile(Map<String, dynamic> profileData) async {
    _setLoading(true);

    try {
      await ApiService.put(ApiConfig.profile, profileData);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
      rethrow;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    _error = null;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    _isLoading = false;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
