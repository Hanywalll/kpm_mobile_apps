import 'package:dio/dio.dart';
import '../core/api/api_client.dart';
import '../core/api/api_endpoints.dart';

class AIService {
  final ApiClient _apiClient;

  AIService(this._apiClient);

  Future<String> askAITutor(String message, {String? imageBase64}) async {
    try {
      final response = await _apiClient.dio.post(
        ApiEndpoints.aiChat,
        data: {
          'message': message,
          if (imageBase64 != null) 'image': imageBase64,
        },
      );
      return response.data['data']['reply'] ?? 'Tidak ada tanggapan AI.';
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Gagal menghubungi AI Tutor';
    }
  }
}
