import 'question_model.dart';

class PracticeSessionModel {
  final String id;
  final String title;
  final int durationMinutes;
  final int totalQuestions;
  final List<QuestionModel> questions;

  PracticeSessionModel({
    required this.id,
    required this.title,
    required this.durationMinutes,
    required this.totalQuestions,
    required this.questions,
  });

  factory PracticeSessionModel.fromJson(Map<String, dynamic> json) {
    return PracticeSessionModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      durationMinutes: json['duration_minutes'] ?? json['durationMinutes'] ?? 60,
      totalQuestions: json['total_questions'] ?? json['totalQuestions'] ?? 0,
      questions: (json['questions'] as List<dynamic>?)
              ?.map((e) => QuestionModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class PracticeResultModel {
  final String id;
  final String title;
  final double score;
  final int correctCount;
  final int wrongCount;
  final int unattemptedCount;
  final double accuracy;
  final DateTime dateSubmitted;

  PracticeResultModel({
    required this.id,
    required this.title,
    required this.score,
    required this.correctCount,
    required this.wrongCount,
    required this.unattemptedCount,
    required this.accuracy,
    required this.dateSubmitted,
  });

  factory PracticeResultModel.fromJson(Map<String, dynamic> json) {
    return PracticeResultModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      score: (json['score'] as num?)?.toDouble() ?? 0.0,
      correctCount: json['correct_count'] ?? json['correctCount'] ?? 0,
      wrongCount: json['wrong_count'] ?? json['wrongCount'] ?? 0,
      unattemptedCount: json['unattempted_count'] ?? json['unattemptedCount'] ?? 0,
      accuracy: (json['accuracy'] as num?)?.toDouble() ?? 0.0,
      dateSubmitted: json['date_submitted'] != null
          ? DateTime.parse(json['date_submitted'])
          : DateTime.now(),
    );
  }
}
