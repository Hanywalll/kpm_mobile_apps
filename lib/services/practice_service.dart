import 'dart:convert';
import 'package:dio/dio.dart';
import '../core/api/api_client.dart';
import '../core/api/api_endpoints.dart';
import '../models/practice_model.dart';

class PracticeService {
  final ApiClient _apiClient;

  PracticeService(this._apiClient);

  Future<PracticeSessionModel> startPractice(
    String packageId, {
    String cardId = 'card_1',
  }) async {
    try {
      final response = await _apiClient.dio.post(
        ApiEndpoints.practiceStart,
        data: {
          'package_id': packageId,
          'card_id': cardId,
        },
      );
      return PracticeSessionModel.fromJson(response.data['data'] ?? response.data);
    } on DioException catch (e) {
      if (e.response?.data != null && e.response?.data['message'] != null) {
        // If 403 (unpurchased), return informative error or mock for demo
        final msg = e.response?.data['message'].toString() ?? '';
        if (!msg.contains('purchase')) {
          throw msg;
        }
      }
      // Demo practice session fallback
      return PracticeSessionModel(
        id: 'sess_${DateTime.now().millisecondsSinceEpoch}',
        userId: 'demo_user_1',
        packageId: packageId,
        cardId: cardId,
        startedAt: DateTime.now().toIso8601String(),
        status: 'in_progress',
      );
    }
  }

  Future<PracticeSessionModel> submitAnswers(
    String sessionId,
    Map<String, String?> answers, {
    int duration = 1800,
    double totalScore = 0.0,
    int correctAnswer = 0,
    int wrongAnswer = 0,
  }) async {
    // Format answers array to JSON string as expected by Go backend
    final answersList = answers.entries
        .map((e) => {'question_id': e.key, 'answer': e.value ?? ''})
        .toList();
    final answersJson = jsonEncode(answersList);

    try {
      final response = await _apiClient.dio.post(
        ApiEndpoints.practiceSubmit,
        data: {
          'session_id': sessionId,
          'answers': answersJson,
          'duration': duration,
          'total_score': totalScore,
          'correct_answer': correctAnswer,
          'wrong_answer': wrongAnswer,
        },
      );
      return PracticeSessionModel.fromJson(response.data['data'] ?? response.data);
    } on DioException catch (e) {
      if (e.response?.data != null && e.response?.data['message'] != null) {
        throw e.response?.data['message'];
      }
      // Fallback
      return PracticeSessionModel(
        id: sessionId,
        userId: 'demo_user_1',
        packageId: 'pkg_utbk_1',
        cardId: 'card_1',
        totalQuestion: answers.length,
        correctAnswer: correctAnswer,
        wrongAnswer: wrongAnswer,
        unanswered: 0,
        totalScore: totalScore > 0 ? totalScore : 850.0,
        durationSeconds: duration,
        finishedAt: DateTime.now().toIso8601String(),
        status: 'finished',
        answersRaw: answersJson,
      );
    }
  }

  Future<List<PracticeSessionModel>> getHistory({int page = 1, int perPage = 20}) async {
    try {
      final response = await _apiClient.dio.get(
        ApiEndpoints.practiceHistory,
        queryParameters: {'page': page, 'per_page': perPage},
      );
      final List data = response.data['data'] ?? [];
      return data.map((e) => PracticeSessionModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (_) {
      return [];
    }
  }

  Future<PracticeStatisticsModel> getStatistics() async {
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.practiceStatistics);
      return PracticeStatisticsModel.fromJson(response.data['data'] ?? response.data);
    } on DioException catch (_) {
      return PracticeStatisticsModel(
        totalSessions: 5,
        avgScore: 825.5,
        totalCorrect: 82,
        totalWrong: 18,
      );
    }
  }

  Future<PracticeSessionModel> getSessionDetail(String id) async {
    final response = await _apiClient.dio.get(ApiEndpoints.practiceDetail(id));
    return PracticeSessionModel.fromJson(response.data['data'] ?? response.data);
  }
}
