class ChatModel {
  final String id;
  final String sessionId;
  final String? userId;
  final String role; // 'user' or 'assistant'
  final String message;
  final bool isAI;
  final DateTime createdAt;

  ChatModel({
    required this.id,
    required this.sessionId,
    this.userId,
    required this.role,
    required this.message,
    this.isAI = false,
    required this.createdAt,
  });

  bool get isFromUser => role == 'user';

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      id: json['id']?.toString() ?? '',
      sessionId: json['session_id']?.toString() ?? '',
      userId: json['user_id']?.toString(),
      role: json['role']?.toString() ?? 'assistant',
      message: json['message']?.toString() ?? '',
      isAI: json['is_ai'] == true,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'session_id': sessionId,
      'user_id': userId,
      'role': role,
      'message': message,
      'is_ai': isAI,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
