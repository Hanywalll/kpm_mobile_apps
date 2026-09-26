import 'dart:convert';
import 'package_model.dart';

class PracticeSessionModel {
  final String id;
  final String userId;
  final String packageId;
  final String? orderId;
  final String cardId;
  final int totalQuestion;
  final int correctAnswer;
  final int wrongAnswer;
  final int unanswered;
  final double totalScore;
  final int durationSeconds;
  final String? startedAt;
  final String? finishedAt;
  final String status;
  final String? answersRaw;
  final PackageModel? package;

  PracticeSessionModel({
    required this.id,
    required this.userId,
    required this.packageId,
    this.orderId,
    required this.cardId,
    this.totalQuestion = 0,
    this.correctAnswer = 0,
    this.wrongAnswer = 0,
    this.unanswered = 0,
    this.totalScore = 0.0,
    this.durationSeconds = 0,
    this.startedAt,
    this.finishedAt,
    this.status = 'in_progress',
    this.answersRaw,
    this.package,
  });

  // UI convenience aliases
  String get title => package?.title ?? 'Sesi Latihan Ujian';
  double get score => totalScore;
  int get correctCount => correctAnswer;
  int get wrongCount => wrongAnswer;
  int get totalCount => totalQuestion > 0 ? totalQuestion : (correctAnswer + wrongAnswer + unanswered);
  bool get isFinished => status == 'finished';

  Map<String, String> get parsedAnswers {
    if (answersRaw == null || answersRaw!.isEmpty) return {};
    try {
      final decoded = jsonDecode(answersRaw!);
      if (decoded is List) {
        final Map<String, String> map = {};
        for (final item in decoded) {
          if (item is Map) {
            final qId = item['question_id']?.toString();
            final ans = item['answer']?.toString();
            if (qId != null && ans != null) {
              map[qId] = ans;
            }
          }
        }
        return map;
      } else if (decoded is Map) {
        return decoded.map((k, v) => MapEntry(k.toString(), v.toString()));
      }
    } catch (_) {}
    return {};
  }

  factory PracticeSessionModel.fromJson(Map<String, dynamic> json) {
    return PracticeSessionModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? json['userId']?.toString() ?? '',
      packageId: json['package_id']?.toString() ?? json['packageId']?.toString() ?? '',
      orderId: json['order_id']?.toString() ?? json['orderId']?.toString(),
      cardId: json['card_id']?.toString() ?? json['cardId']?.toString() ?? 'card_1',
      totalQuestion: (json['total_question'] as num?)?.toInt() ??
          (json['totalQuestion'] as num?)?.toInt() ??
          0,
      correctAnswer: (json['correct_answer'] as num?)?.toInt() ??
          (json['correctAnswer'] as num?)?.toInt() ??
          0,
      wrongAnswer: (json['wrong_answer'] as num?)?.toInt() ??
          (json['wrongAnswer'] as num?)?.toInt() ??
          0,
      unanswered: (json['unanswered'] as num?)?.toInt() ?? 0,
      totalScore: (json['total_score'] as num?)?.toDouble() ??
          (json['totalScore'] as num?)?.toDouble() ??
          0.0,
      durationSeconds: (json['duration_seconds'] as num?)?.toInt() ??
          (json['durationSeconds'] as num?)?.toInt() ??
          0,
      startedAt: json['started_at']?.toString() ?? json['startedAt']?.toString(),
      finishedAt: json['finished_at']?.toString() ?? json['finishedAt']?.toString(),
      status: json['status']?.toString() ?? 'in_progress',
      answersRaw: json['answers'] is String
          ? json['answers']
          : (json['answers'] != null ? jsonEncode(json['answers']) : null),
      package: json['package'] != null ? PackageModel.fromJson(json['package']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'package_id': packageId,
      'order_id': orderId,
      'card_id': cardId,
      'total_question': totalQuestion,
      'correct_answer': correctAnswer,
      'wrong_answer': wrongAnswer,
      'unanswered': unanswered,
      'total_score': totalScore,
      'duration_seconds': durationSeconds,
      'started_at': startedAt,
      'finished_at': finishedAt,
      'status': status,
      'answers': answersRaw,
      if (package != null) 'package': package!.toJson(),
    };
  }
}

// User practice statistics summary from GET /practice/statistics
class PracticeStatisticsModel {
  final int totalSessions;
  final double avgScore;
  final int totalCorrect;
  final int totalWrong;

  PracticeStatisticsModel({
    this.totalSessions = 0,
    this.avgScore = 0.0,
    this.totalCorrect = 0,
    this.totalWrong = 0,
  });

  int get completedSessions => totalSessions;
  int get totalQuestions => totalCorrect + totalWrong;

  factory PracticeStatisticsModel.fromJson(Map<String, dynamic> json) {
    return PracticeStatisticsModel(
      totalSessions: (json['total_sessions'] as num?)?.toInt() ?? 0,
      avgScore: (json['avg_score'] as num?)?.toDouble() ?? 0.0,
      totalCorrect: (json['total_correct'] as num?)?.toInt() ?? 0,
      totalWrong: (json['total_wrong'] as num?)?.toInt() ?? 0,
    );
  }
}

// Alias for backward compatibility
typedef PracticeResultModel = PracticeSessionModel;
