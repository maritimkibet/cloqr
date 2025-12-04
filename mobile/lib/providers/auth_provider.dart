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
      _setLoading(false);
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
      _setLoading(false);
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
    required String avatar,
    String? qrCode,
    String? password,
    bool emailVerified = false,
  }) async {
    _setLoading(true);

    try {
      final response = await ApiService.post(ApiConfig.register, {
        'email': email,
        'username': username,
        'campus': campus,
        'avatar': avatar,
        if (qrCode != null) 'qrCode': qrCode,
        if (password != null) 'password': password,
        'emailVerified': emailVerified,
      });

      await _storage.saveToken(response['token']);
      _user = User.fromJson(response['user']);
      await _storage.saveUser(response['user']);

      _setLoading(false);
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

      await _storage.saveToken(response['token']);
      _user = User.fromJson(response['user']);
      await _storage.saveUser(response['user']);

      _setLoading(false);
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
      _setLoading(false);
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
