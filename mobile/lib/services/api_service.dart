import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'storage_service.dart';

class ApiService {
  static final StorageService _storage = StorageService();
  static const Duration _timeout = Duration(seconds: 60); // Increased for Render cold starts

  static Future<Map<String, String>> _getHeaders() async {
    final token = await _storage.getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static String _handleError(dynamic error) {
    if (error is SocketException) {
      return 'No internet connection';
    } else if (error is HttpException) {
      return 'Server error occurred';
    } else if (error is FormatException) {
      return 'Invalid response format';
    } else if (error.toString().contains('timeout')) {
      return 'Connection timeout';
    } else if (error.toString().contains('Connection refused')) {
      return 'Cannot connect to server';
    }
    return error.toString().replaceAll('Exception: ', '');
  }

  static Future<Map<String, dynamic>> post(
    String url,
    Map<String, dynamic> body,
  ) async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .post(
            Uri.parse(url),
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(_timeout);

      return _handleResponse(response);
    } catch (e) {
      throw Exception(_handleError(e));
    }
  }

  static Future<Map<String, dynamic>> get(String url) async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .get(
            Uri.parse(url),
            headers: headers,
          )
          .timeout(_timeout);

      return _handleResponse(response);
    } catch (e) {
      throw Exception(_handleError(e));
    }
  }

  static Future<Map<String, dynamic>> put(
    String url,
    Map<String, dynamic> body,
  ) async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .put(
            Uri.parse(url),
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(_timeout);

      return _handleResponse(response);
    } catch (e) {
      throw Exception(_handleError(e));
    }
  }

  static Future<Map<String, dynamic>> patch(
    String url,
    Map<String, dynamic> body,
  ) async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .patch(
            Uri.parse(url),
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(_timeout);

      return _handleResponse(response);
    } catch (e) {
      throw Exception(_handleError(e));
    }
  }

  static Future<void> delete(String url) async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .delete(
            Uri.parse(url),
            headers: headers,
          )
          .timeout(_timeout);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['error'] ?? 'Request failed');
      }
    } catch (e) {
      throw Exception(_handleError(e));
    }
  }

  static Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return {};
      return jsonDecode(response.body);
    } else {
      try {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['error'] ?? 'Request failed');
      } catch (_) {
        throw Exception('Request failed with status ${response.statusCode}');
      }
    }
  }
}
