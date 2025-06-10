// File: lib/services/api_services.dart - Updated with missing methods
import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Base URL - sesuaikan dengan setup Laravel Anda
  static const String baseUrl = 'http://10.0.2.2:8000/api';
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

  // HTTP Helper Method - TAMBAHAN UNTUK FORM KUIS
  static Future<ApiResponse> makeRequest({
    required String method,
    required String url,
    Map<String, dynamic>? body,
    bool requiresAuth = false,
  }) async {
    return await _makeRequest(
      method: method,
      url: url,
      body: body,
      requiresAuth: requiresAuth,
    );
  }

  // Private HTTP Helper Method
  static Future<ApiResponse> _makeRequest({
    required String method,
    required String url,
    Map<String, dynamic>? body,
    bool requiresAuth = false,
  }) async {
    try {
      print('Making request to: $baseUrl$url');

      final uri = Uri.parse('$baseUrl$url');
      final requestHeaders = requiresAuth ? await headersWithAuth : headers;

      print('Request headers: $requestHeaders');
      print('Request body: $body');

      http.Response response;

      switch (method.toUpperCase()) {
        case 'GET':
          response = await http
              .get(uri, headers: requestHeaders)
              .timeout(timeoutDuration);
          break;
        case 'POST':
          response = await http
              .post(
                uri,
                headers: requestHeaders,
                body: body != null ? jsonEncode(body) : null,
              )
              .timeout(timeoutDuration);
          break;
        case 'PUT':
          response = await http
              .put(
                uri,
                headers: requestHeaders,
                body: body != null ? jsonEncode(body) : null,
              )
              .timeout(timeoutDuration);
          break;
        case 'DELETE':
          response = await http
              .delete(uri, headers: requestHeaders)
              .timeout(timeoutDuration);
          break;
        default:
          throw Exception('Unsupported HTTP method: $method');
      }

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      final responseData =
          response.body.isNotEmpty ? jsonDecode(response.body) : {};

      return ApiResponse(
        success: response.statusCode >= 200 && response.statusCode < 300,
        message: responseData['message'] ?? 'Request completed',
        data: responseData,
        statusCode: response.statusCode,
      );
    } on TimeoutException catch (e) {
      print('TimeoutException: $e');
      return ApiResponse(
        success: false,
        message: 'Koneksi timeout. Periksa koneksi internet dan server.',
        statusCode: 0,
      );
    } on SocketException catch (e) {
      print('SocketException: $e');
      return ApiResponse(
        success: false,
        message:
            'Tidak dapat terhubung ke server. Pastikan server Laravel berjalan di $baseUrl',
        statusCode: 0,
      );
    } on HttpException catch (e) {
      print('HttpException: $e');
      return ApiResponse(
        success: false,
        message: 'Terjadi kesalahan pada server',
        statusCode: 0,
      );
    } on FormatException catch (e) {
      print('FormatException: $e');
      return ApiResponse(
        success: false,
        message: 'Format response dari server tidak valid',
        statusCode: 0,
      );
    } catch (e) {
      print('General Exception: $e');
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
    try {
      await _makeRequest(
        method: 'POST',
        url: '/logout',
        requiresAuth: true,
      );
    } catch (_) {
      // Abaikan error, tetap hapus data lokal
    }
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_type');
    await prefs.remove('user_data');
    return ApiResponse(success: true, message: 'Logged out', statusCode: 200);
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
    final endpoint =
        userType == 'admin' ? '/admin/materi/$id' : '/user/materi/$id';

    return await _makeRequest(
      method: 'GET',
      url: endpoint,
      requiresAuth: true,
    );
  }

  static Future<ApiResponse> tambahMateri(Map<String, dynamic> materiData) async {
    return await _makeRequest(
      method: 'POST',
      url: '/admin/materi',
      body: materiData,
      requiresAuth: true,
    );
  }

  static Future<ApiResponse> updateMateri(int id, Map<String, dynamic> materiData) async {
    return await _makeRequest(
      method: 'PUT',
      url: '/admin/materi/$id',
      body: materiData,
      requiresAuth: true,
    );
  }

  static Future<ApiResponse> hapusMateri(int id) async {
    return await _makeRequest(
      method: 'DELETE',
      url: '/admin/materi/$id',
      requiresAuth: true,
    );
  }

  // Soal Methods
  static Future<ApiResponse> getSoal() async {
    return await _makeRequest(
      method: 'GET',
      url: '/admin/soal',
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

  static Future<ApiResponse> addSoal(Map<String, dynamic> soalData) async {
    return await _makeRequest(
      method: 'POST',
      url: '/admin/soal',
      body: soalData,
      requiresAuth: true,
    );
  }

  static Future<ApiResponse> updateSoal(String id, Map<String, dynamic> soalData) async {
    return await _makeRequest(
      method: 'PUT',
      url: '/admin/soal/$id',
      body: soalData,
      requiresAuth: true,
    );
  }

  static Future<ApiResponse> deleteSoal(String id) async {
    return await _makeRequest(
      method: 'DELETE',
      url: '/admin/soal/$id',
      requiresAuth: true,
    );
  }

  // Kuis Methods - DIPERBAIKI UNTUK CRUD LENGKAP
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

  static Future<ApiResponse> tambahKuis(Map<String, dynamic> kuisData) async {
    return await _makeRequest(
      method: 'POST',
      url: '/admin/kuis',
      body: kuisData,
      requiresAuth: true,
    );
  }

  static Future<ApiResponse> updateKuis(int id, Map<String, dynamic> kuisData) async {
    return await _makeRequest(
      method: 'PUT',
      url: '/admin/kuis/$id',
      body: kuisData,
      requiresAuth: true,
    );
  }

  static Future<ApiResponse> hapusKuis(int id) async {
    return await _makeRequest(
      method: 'DELETE',
      url: '/admin/kuis/$id',
      requiresAuth: true,
    );
  }

  // Kuis Soal Management - TAMBAHAN UNTUK CRUD KUIS
  static Future<ApiResponse> addSoalToKuis(int kuisId, List<int> soalIds) async {
    return await _makeRequest(
      method: 'POST',
      url: '/admin/kuis/$kuisId/soal',
      body: {'soal_ids': soalIds},
      requiresAuth: true,
    );
  }

  static Future<ApiResponse> removeSoalFromKuis(int kuisId, int soalId) async {
    return await _makeRequest(
      method: 'DELETE',
      url: '/admin/kuis/$kuisId/soal/$soalId',
      requiresAuth: true,
    );
  }

  // User Quiz Methods
  static Future<ApiResponse> getKuisUser() async {
    return await _makeRequest(
      method: 'GET',
      url: '/user/kuis',
      requiresAuth: true,
    );
  }

  static Future<ApiResponse> getKuisUserById(int id) async {
    return await _makeRequest(
      method: 'GET',
      url: '/user/kuis/$id',
      requiresAuth: true,
    );
  }

  static Future<ApiResponse> startQuiz(int kuisId) async {
    return await _makeRequest(
      method: 'POST',
      url: '/user/kuis/$kuisId/start',
      requiresAuth: true,
    );
  }

  static Future<ApiResponse> submitAnswer({
    required int kuisId,
    required int soalId,
    required String jawabanUser,
  }) async {
    return await _makeRequest(
      method: 'POST',
      url: '/user/kuis/$kuisId/submit',
      body: {
        'soal_id': soalId,
        'jawaban_user': jawabanUser,
      },
      requiresAuth: true,
    );
  }

  static Future<ApiResponse> getQuizResult(int kuisId) async {
    return await _makeRequest(
      method: 'GET',
      url: '/user/kuis/$kuisId/result',
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
    try {
      final token = await getToken();
      final userType = await getUserType();
      return token != null && token.isNotEmpty && userType != null;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> isAdmin() async {
    try {
      final userType = await getUserType();
      final isLoggedIn = await ApiService.isLoggedIn();
      return isLoggedIn && userType == 'admin';
    } catch (e) {
      return false;
    }
  }

  static Future<bool> isUser() async {
    try {
      final userType = await getUserType();
      final isLoggedIn = await ApiService.isLoggedIn();
      return isLoggedIn && userType == 'user';
    } catch (e) {
      return false;
    }
  }

  static Future<void> clearAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (e) {
      print('Error clearing data: $e');
    }
  }

  // Test connection to backend
  static Future<bool> testConnection() async {
    try {
      print('Testing connection to: $baseUrl');

      final response = await http
          .get(
            Uri.parse('$baseUrl/../'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 5));

      print('Test connection status: ${response.statusCode}');
      return response.statusCode == 200 || response.statusCode == 404;
    } catch (e) {
      print('Test connection error: $e');
      return false;
    }
  }

  // Helper methods
  static bool isValidJawaban(String jawaban) {
    return ['A', 'B', 'C', 'D'].contains(jawaban.toUpperCase());
  }

  static String formatSkor(dynamic skor) {
    if (skor == null) return '0';
    if (skor is String) {
      return skor;
    }
    if (skor is num) {
      return skor.toStringAsFixed(1);
    }
    return skor.toString();
  }

  // TAMBAHAN METHODS UNTUK SUPPORT KUIS CRUD
  static Future<List<Map<String, dynamic>>> getKuisList() async {
    final response = await getKuis();
    if (response.success && response.data != null) {
      final List<dynamic> data = response.data['data'] ?? [];
      return data.cast<Map<String, dynamic>>();
    }
    return [];
  }

  static Future<List<Map<String, dynamic>>> getSoalList() async {
    final response = await getSoal();
    if (response.success && response.data != null) {
      final List<dynamic> data = response.data['data'] ?? [];
      return data.cast<Map<String, dynamic>>();
    }
    return [];
  }

  static Future<String?> uploadImage(File imageFile) async {
    try {
      final uri = Uri.parse('$baseUrl/upload');
      final request = http.MultipartRequest('POST', uri);
      
      // Add headers
      final authHeaders = await headersWithAuth;
      request.headers.addAll(authHeaders);
      
      request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));
      
      final response = await request.send();
      if (response.statusCode == 200) {
        final respStr = await response.stream.bytesToString();
        final data = jsonDecode(respStr);
        return data['url'];
      }
      return null;
    } catch (e) {
      print('Upload image error: $e');
      return null;
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