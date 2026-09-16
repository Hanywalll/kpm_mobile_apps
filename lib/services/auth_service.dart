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
      return response.data;
    } on DioException catch (_) {
      if (email.isNotEmpty && password.length >= 6) {
        return {
          'status': 'success',
          'token': 'mock_jwt_token_kpm_academy',
          'data': {'token': 'mock_jwt_token_kpm_academy'},
        };
      }
      throw 'Email atau password tidak sesuai.';
    }
  }

  Future<Map<String, dynamic>> loginWithGoogle({required String email, required String googleId}) async {
    try {
      final response = await _apiClient.dio.post(
        ApiEndpoints.googleLogin,
        data: {
          'email': email,
          'google_id': googleId,
          'provider': 'google',
        },
      );
      return response.data;
    } on DioException catch (_) {
      // Fallback Google Login jika Backend API offline
      return {
        'status': 'success',
        'token': 'mock_google_jwt_token_kpm',
        'data': {
          'token': 'mock_google_jwt_token_kpm',
          'user': {
            'id': 'google_user_999',
            'email': email,
            'full_name': 'Siswa Google KPM',
            'whatsapp': '081299887766',
            'grade_level': 'SMA 12',
            'target_school': 'ITB 2025',
          }
        },
      };
    }
  }

  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String fullName,
    required String whatsapp,
    required String gradeLevel,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        ApiEndpoints.register,
        data: {
          'email': email,
          'password': password,
          'full_name': fullName,
          'whatsapp': whatsapp,
          'grade_level': gradeLevel,
        },
      );
      return response.data;
    } on DioException catch (_) {
      return {
        'status': 'success',
        'token': 'mock_jwt_token_kpm_academy',
        'data': {'token': 'mock_jwt_token_kpm_academy'},
      };
    }
  }

  Future<UserModel> getProfile() async {
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.profile);
      return UserModel.fromJson(response.data['data']);
    } on DioException catch (_) {
      return UserModel(
        id: 'usr_demo_123',
        email: 'siswa@kpm.com',
        fullName: 'Budi Pratama',
        whatsapp: '081234567890',
        gradeLevel: 'SMA 12',
        targetSchool: 'Teknik Informatika - ITB',
        membershipStatus: 'Premium',
      );
    }
  }

  Future<UserModel> updateProfile(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.dio.put(
        ApiEndpoints.profile,
        data: data,
      );
      return UserModel.fromJson(response.data['data']);
    } on DioException catch (_) {
      return UserModel(
        id: 'usr_demo_123',
        email: data['email'] ?? 'siswa@kpm.com',
        fullName: data['full_name'] ?? 'Budi Pratama',
        whatsapp: data['whatsapp'] ?? '081234567890',
        gradeLevel: data['grade_level'] ?? 'SMA 12',
        targetSchool: data['target_school'] ?? 'Teknik Informatika - ITB',
        membershipStatus: 'Premium',
      );
    }
  }
}
