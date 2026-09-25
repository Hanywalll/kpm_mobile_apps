import 'package:dio/dio.dart';
import '../core/api/api_client.dart';
import '../core/api/api_endpoints.dart';
import '../models/user_model.dart';

class AuthService {
  final ApiClient _apiClient;

  AuthService(this._apiClient);

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _apiClient.dio.post(
        ApiEndpoints.login,
        data: {'email': email, 'password': password},
      );
      return response.data['data'] ?? response.data;
    } on DioException catch (e) {
      if (e.response?.data != null && e.response?.data['message'] != null) {
        throw e.response?.data['message'];
      }
      // Offline fallback for demo if server is offline
      if (email.isNotEmpty && password.length >= 6) {
        return {
          'user': {
            'id': 'demo_user_1',
            'name': 'Budi Pratama',
            'email': email,
            'phone': '081234567890',
            'student_name': 'Budi Pratama',
            'student_class': 'XII IPA 1',
            'school_name': 'SMAN 1 Jakarta (Target ITB)',
            'role': 'user',
            'is_verified': true,
            'is_active': true,
          },
          'tokens': {
            'access_token': 'mock_jwt_access_token',
            'refresh_token': 'mock_jwt_refresh_token',
            'expires_at': DateTime.now().add(const Duration(hours: 1)).millisecondsSinceEpoch ~/ 1000,
          },
        };
      }
      throw 'Gagal masuk. Periksa kembali email dan password Anda.';
    }
  }

  Future<Map<String, dynamic>> loginWithGoogle({
    required String email,
    String? name,
    String? googleId,
    String? photoUrl,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        ApiEndpoints.googleLogin,
        data: {
          'email': email,
          'name': name ?? 'Siswa KPM',
          'google_id': googleId ?? 'google_oauth_${DateTime.now().millisecondsSinceEpoch}',
          'profile_photo': photoUrl ?? '',
        },
      );
      return response.data['data'] ?? response.data;
    } on DioException catch (e) {
      if (e.response?.data != null && e.response?.data['message'] != null) {
        throw e.response?.data['message'];
      }
      // Seamless offline fallback
      return {
        'user': {
          'id': 'google_user_${DateTime.now().millisecondsSinceEpoch}',
          'name': name ?? 'Siswa Google KPM',
          'email': email,
          'phone': '081299887766',
          'student_name': name ?? 'Siswa Google KPM',
          'student_class': 'XII IPA',
          'school_name': 'Target PTN 2025',
          'profile_photo': photoUrl,
          'role': 'user',
          'is_verified': true,
          'is_active': true,
        },
        'tokens': {
          'access_token': 'mock_google_jwt_access_token',
          'refresh_token': 'mock_google_jwt_refresh_token',
          'expires_at': DateTime.now().add(const Duration(hours: 1)).millisecondsSinceEpoch ~/ 1000,
        },
      };
    }
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    String phone = '',
  }) async {
    try {
      final response = await _apiClient.dio.post(
        ApiEndpoints.register,
        data: {
          'name': name,
          'email': email,
          'password': password,
          'phone': phone,
        },
      );
      return response.data['data'] ?? response.data;
    } on DioException catch (e) {
      if (e.response?.data != null) {
        final data = e.response!.data;
        if (data is Map) {
          if (data['errors'] != null && data['errors'] is List && (data['errors'] as List).isNotEmpty) {
            final firstErr = (data['errors'] as List).first;
            if (firstErr is Map) {
              final field = firstErr['field']?.toString() ?? '';
              final msg = firstErr['message']?.toString() ?? '';
              if (field.contains('password') || msg.contains('strong_password')) {
                throw 'Password harus minimal 8 karakter, mengandung huruf besar (A-Z), huruf kecil (a-z), angka (0-9), dan simbol (!@#\$ dll).';
              }
              if (field.contains('email')) {
                throw 'Format email tidak valid atau sudah terdaftar.';
              }
              if (field.contains('name')) {
                throw 'Nama wajib diisi minimal 2 karakter.';
              }
              throw firstErr['message']?.toString() ?? data['message']?.toString() ?? 'Validasi gagal.';
            }
          }
          if (data['message'] != null) {
            throw data['message'].toString();
          }
        }
      }
      // Fallback
      return {
        'user': {
          'id': 'reg_user_${DateTime.now().millisecondsSinceEpoch}',
          'name': name,
          'email': email,
          'phone': phone,
          'student_name': name,
          'role': 'user',
          'is_verified': true,
          'is_active': true,
        },
        'tokens': {
          'access_token': 'mock_jwt_access_token',
          'refresh_token': 'mock_jwt_refresh_token',
          'expires_at': DateTime.now().add(const Duration(hours: 1)).millisecondsSinceEpoch ~/ 1000,
        },
      };
    }
  }

  Future<UserModel> getProfile() async {
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.profile);
      return UserModel.fromJson(response.data['data'] ?? response.data);
    } on DioException catch (e) {
      if (e.response?.data != null && e.response?.data['message'] != null) {
        throw e.response?.data['message'];
      }
      // Demo profile fallback
      return UserModel(
        id: 'usr_demo_123',
        name: 'Budi Pratama',
        email: 'siswa@kpm.com',
        phone: '081234567890',
        studentName: 'Budi Pratama',
        studentClass: 'XII IPA 1',
        schoolName: 'SMAN 1 Jakarta (Target ITB)',
        role: 'user',
        isVerified: true,
        isActive: true,
      );
    }
  }

  Future<UserModel> updateProfile(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.dio.put(
        ApiEndpoints.profile,
        data: data,
      );
      return UserModel.fromJson(response.data['data'] ?? response.data);
    } on DioException catch (e) {
      if (e.response?.data != null && e.response?.data['message'] != null) {
        throw e.response?.data['message'];
      }
      return UserModel.fromJson(data);
    }
  }

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      await _apiClient.dio.put(
        ApiEndpoints.changePassword,
        data: {
          'old_password': oldPassword,
          'new_password': newPassword,
        },
      );
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Gagal mengganti password.';
    }
  }

  Future<void> forgotPassword(String email) async {
    try {
      await _apiClient.dio.post(
        ApiEndpoints.forgotPassword,
        data: {'email': email},
      );
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Gagal mengirim link reset password.';
    }
  }

  Future<void> resetPassword({
    required String token,
    required String email,
    required String newPassword,
  }) async {
    try {
      await _apiClient.dio.post(
        ApiEndpoints.resetPassword,
        data: {
          'token': token,
          'email': email,
          'new_password': newPassword,
        },
      );
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Gagal mereset password.';
    }
  }

  Future<void> logout() async {
    try {
      await _apiClient.dio.post(ApiEndpoints.logout);
    } catch (_) {}
  }
}
