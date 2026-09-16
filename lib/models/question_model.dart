class QuestionOption {
  final String key;
  final String text;

  QuestionOption({required this.key, required this.text});

  factory QuestionOption.fromJson(Map<String, dynamic> json) {
    return QuestionOption(
      key: json['key'] ?? '',
      text: json['text'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'key': key, 'text': text};
}

class QuestionModel {
  final String id;
  final String questionText;
  final String? imageUrl;
  final List<QuestionOption> options;
  final String? selectedAnswer;
  final String? correctAnswer;
  final String? explanation;
  final bool isFlagged;

  QuestionModel({
    required this.id,
    required this.questionText,
    this.imageUrl,
    required this.options,
    this.selectedAnswer,
    this.correctAnswer,
    this.explanation,
    this.isFlagged = false,
  });

  QuestionModel copyWith({
    String? selectedAnswer,
    bool? isFlagged,
  }) {
    return QuestionModel(
      id: id,
      questionText: questionText,
      imageUrl: imageUrl,
      options: options,
      selectedAnswer: selectedAnswer ?? this.selectedAnswer,
      correctAnswer: correctAnswer,
      explanation: explanation,
      isFlagged: isFlagged ?? this.isFlagged,
    );
  }

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['id'] ?? '',
      questionText: json['question_text'] ?? json['questionText'] ?? '',
      imageUrl: json['image_url'] ?? json['imageUrl'],
      options: (json['options'] as List<dynamic>?)
              ?.map((e) => QuestionOption.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      selectedAnswer: json['selected_answer'] ?? json['selectedAnswer'],
      correctAnswer: json['correct_answer'] ?? json['correctAnswer'],
      explanation: json['explanation'],
      isFlagged: json['is_flagged'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question_text': questionText,
      'image_url': imageUrl,
      'options': options.map((e) => e.toJson()).toList(),
      'selected_answer': selectedAnswer,
      'correct_answer': correctAnswer,
      'explanation': explanation,
      'is_flagged': isFlagged,
    };
  }
}
