import 'package:dio/dio.dart';
import '../core/api/api_client.dart';
import '../core/api/api_endpoints.dart';
import '../models/practice_model.dart';
import '../models/question_model.dart';

class PracticeService {
  final ApiClient _apiClient;

  PracticeService(this._apiClient);

  Future<PracticeSessionModel> startPractice(String practiceId) async {
    try {
      final response = await _apiClient.dio.post(ApiEndpoints.practiceStart(practiceId));
      return PracticeSessionModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Gagal memulai tryout';
    }
  }

  Future<PracticeResultModel> submitAnswers(String practiceId, Map<String, String?> answers) async {
    try {
      final response = await _apiClient.dio.post(
        ApiEndpoints.practiceSubmit(practiceId),
        data: {'answers': answers},
      );
      return PracticeResultModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Gagal mengirimkan jawaban';
    }
  }

  Future<List<PracticeResultModel>> getHistory() async {
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.practiceHistory);
      final List data = response.data['data'] ?? [];
      return data.map((e) => PracticeResultModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Gagal memuat riwayat';
    }
  }

  Future<List<QuestionModel>> getReview(String practiceId) async {
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.practiceReview(practiceId));
      final List data = response.data['data']['questions'] ?? [];
      return data.map((e) => QuestionModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Gagal memuat pembahasan';
    }
  }
}
