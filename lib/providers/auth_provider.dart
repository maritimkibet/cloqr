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
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await ApiService.post(ApiConfig.sendOtp, {'email': email});
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<String> verifyOTP(String email, String otp) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.post(
        ApiConfig.verifyOtp,
        {'email': email, 'otp': otp},
      );
      _isLoading = false;
      notifyListeners();
      return response['emailHash'];
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
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
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.post(ApiConfig.register, {
        'email': email,
        'username': username,
        'campus': campus,
        'avatar': avatar,
        if (qrCode != null) 'qrCode': qrCode,
        if (password != null) 'password': password,
      });

      await _storage.saveToken(response['token']);
      _user = User.fromJson(response['user']);
      await _storage.saveUser(response['user']);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> login(String email, {String? password}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.post(ApiConfig.login, {
        'email': email,
        if (password != null) 'password': password,
      });

      await _storage.saveToken(response['token']);
      _user = User.fromJson(response['user']);
      await _storage.saveUser(response['user']);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
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
    _isLoading = true;
    notifyListeners();

    try {
      await ApiService.put(ApiConfig.profile, profileData);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }
}
