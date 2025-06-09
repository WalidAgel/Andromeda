// File: lib/services/api_services.dart
import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Base URL - sesuaikan dengan setup Laravel Anda
  static const String baseUrl = 'http://10.0.2.2:8000/api';
  // Untuk Android Emulator: 'http://10.0.2.2:8000/api'
  // Untuk iOS Simulator: 'http://localhost:8000/api'
  // Untuk Physical Device: 'http://192.168.1.100:8000/api' (ganti dengan IP Anda)
  
  static const Duration timeoutDuration = Duration(seconds: 10);

  // Headers
  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static Future<Map<String, String>> get headersWithAuth async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Token Management
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_type');
    await prefs.remove('user_data');
  }

  static Future<void> saveUserType(String userType) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_type', userType);
  }

  static Future<String?> getUserType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_type');
  }

  static Future<void> saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', jsonEncode(userData));
  }

  static Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString('user_data');
    if (userDataString != null) {
      return jsonDecode(userDataString);
    }
    return null;
  }

  // HTTP Helper Method
  static Future<ApiResponse> _makeRequest({
    required String method,
    required String url,
    Map<String, dynamic>? body,
    bool requiresAuth = false,
  }) async {
    try {
      print('Making request to: $baseUrl$url'); // Debug print
      
      final uri = Uri.parse('$baseUrl$url');
      final requestHeaders = requiresAuth ? await headersWithAuth : headers;

      print('Request headers: $requestHeaders'); // Debug print
      print('Request body: $body'); // Debug print

      http.Response response;

      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(uri, headers: requestHeaders)
              .timeout(timeoutDuration);
          break;
        case 'POST':
          response = await http.post(
            uri,
            headers: requestHeaders,
            body: body != null ? jsonEncode(body) : null,
          ).timeout(timeoutDuration);
          break;
        case 'PUT':
          response = await http.put(
            uri,
            headers: requestHeaders,
            body: body != null ? jsonEncode(body) : null,
          ).timeout(timeoutDuration);
          break;
        case 'DELETE':
          response = await http.delete(uri, headers: requestHeaders)
              .timeout(timeoutDuration);
          break;
        default:
          throw Exception('Unsupported HTTP method: $method');
      }

      print('Response status: ${response.statusCode}'); // Debug print
      print('Response body: ${response.body}'); // Debug print

      final responseData = response.body.isNotEmpty 
          ? jsonDecode(response.body) 
          : {};

      return ApiResponse(
        success: response.statusCode >= 200 && response.statusCode < 300,
        message: responseData['message'] ?? 'Request completed',
        data: responseData,
        statusCode: response.statusCode,
      );
    } on TimeoutException catch (e) {
      print('TimeoutException: $e'); // Debug print
      return ApiResponse(
        success: false,
        message: 'Koneksi timeout. Periksa koneksi internet dan server.',
        statusCode: 0,
      );
    } on SocketException catch (e) {
      print('SocketException: $e'); // Debug print
      return ApiResponse(
        success: false,
        message: 'Tidak dapat terhubung ke server. Pastikan server Laravel berjalan di $baseUrl',
        statusCode: 0,
      );
    } on HttpException catch (e) {
      print('HttpException: $e'); // Debug print
      return ApiResponse(
        success: false,
        message: 'Terjadi kesalahan pada server',
        statusCode: 0,
      );
    } on FormatException catch (e) {
      print('FormatException: $e'); // Debug print
      return ApiResponse(
        success: false,
        message: 'Format response dari server tidak valid',
        statusCode: 0,
      );
    } catch (e) {
      print('General Exception: $e'); // Debug print
      return ApiResponse(
        success: false,
        message: 'Terjadi kesalahan: $e',
        statusCode: 0,
      );
    }
  }

  // Authentication Methods
  static Future<ApiResponse> loginAdmin({
    required String username,
    required String password,
  }) async {
    final response = await _makeRequest(
      method: 'POST',
      url: '/admin/login',
      body: {
        'username': username,
        'password': password,
      },
    );

    if (response.success && response.data != null) {
      final data = response.data as Map<String, dynamic>;
      if (data['token'] != null) {
        await saveToken(data['token']);
        await saveUserType('admin');
        if (data['user'] != null) {
          await saveUserData(data['user']);
        }
      }
    }

    return response;
  }

  static Future<ApiResponse> loginUser({
    required String username,
    required String password,
  }) async {
    final response = await _makeRequest(
      method: 'POST',
      url: '/user/login',
      body: {
        'username': username,
        'password': password,
      },
    );

    if (response.success && response.data != null) {
      final data = response.data as Map<String, dynamic>;
      if (data['token'] != null) {
        await saveToken(data['token']);
        await saveUserType('user');
        if (data['user'] != null) {
          await saveUserData(data['user']);
        }
      }
    }

    return response;
  }

  static Future<ApiResponse> registerUser({
    required String username,
    required String password,
    required String namaLengkap,
    String? email,
  }) async {
    final body = {
      'username': username,
      'password': password,
      'nama_lengkap': namaLengkap,
    };

    if (email != null && email.isNotEmpty) {
      body['email'] = email;
    }

    return await _makeRequest(
      method: 'POST',
      url: '/user/register',
      body: body,
    );
  }

  static Future<ApiResponse> logout() async {
    final response = await _makeRequest(
      method: 'POST',
      url: '/logout',
      requiresAuth: true,
    );

    // Remove local data regardless of response
    await removeToken();

    return response;
  }

  // Materi Methods
  static Future<ApiResponse> getMateri() async {
    final userType = await getUserType();
    final endpoint = userType == 'admin' ? '/admin/materi' : '/user/materi';
    
    return await _makeRequest(
      method: 'GET',
      url: endpoint,
      requiresAuth: true,
    );
  }

  static Future<ApiResponse> getMateriById(int id) async {
    final userType = await getUserType();
    final endpoint = userType == 'admin' ? '/admin/materi/$id' : '/user/materi/$id';
    
    return await _makeRequest(
      method: 'GET',
      url: endpoint,
      requiresAuth: true,
    );
  }

  // Soal Methods
  static Future<ApiResponse> getSoal() async {
    final userType = await getUserType();
    final endpoint = userType == 'admin' ? '/admin/soal' : '/admin/soal'; // User bisa lihat semua soal
    
    return await _makeRequest(
      method: 'GET',
      url: endpoint,
      requiresAuth: true,
    );
  }

  static Future<ApiResponse> getSoalById(int id) async {
    return await _makeRequest(
      method: 'GET',
      url: '/admin/soal/$id',
      requiresAuth: true,
    );
  }

  // Kuis Methods
  static Future<ApiResponse> getKuis() async {
    final userType = await getUserType();
    final endpoint = userType == 'admin' ? '/admin/kuis' : '/user/kuis';
    
    return await _makeRequest(
      method: 'GET',
      url: endpoint,
      requiresAuth: true,
    );
  }

  static Future<ApiResponse> getKuisById(int id) async {
    final userType = await getUserType();
    final endpoint = userType == 'admin' ? '/admin/kuis/$id' : '/user/kuis/$id';
    
    return await _makeRequest(
      method: 'GET',
      url: endpoint,
      requiresAuth: true,
    );
  }

  // User Profile Methods
  static Future<ApiResponse> getProfile() async {
    final userType = await getUserType();
    final endpoint = userType == 'admin' ? '/admin/profile' : '/user/profile';
    
    return await _makeRequest(
      method: 'GET',
      url: endpoint,
      requiresAuth: true,
    );
  }

  // Utility Methods
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  static Future<bool> isAdmin() async {
    final userType = await getUserType();
    return userType == 'admin';
  }

  static Future<bool> isUser() async {
    final userType = await getUserType();
    return userType == 'user';
  }

  // Test connection to backend
  static Future<bool> testConnection() async {
    try {
      print('Testing connection to: $baseUrl');
      
      final response = await http.get(
        Uri.parse('$baseUrl/../'),  // Test root Laravel endpoint
        headers: headers,
      ).timeout(const Duration(seconds: 5));
      
      print('Test connection status: ${response.statusCode}');
      return response.statusCode == 200 || response.statusCode == 404; // 404 is also OK for Laravel
    } catch (e) {
      print('Test connection error: $e');
      return false;
    }
  }
}

// Simple Response Model
class ApiResponse {
  final bool success;
  final String message;
  final dynamic data;
  final int statusCode;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    required this.statusCode,
  });

  @override
  String toString() {
    return 'ApiResponse(success: $success, message: $message, statusCode: $statusCode)';
  }
}