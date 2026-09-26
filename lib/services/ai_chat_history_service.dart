import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AIChatSession {
  final String id;
  String title;
  final DateTime createdAt;
  DateTime updatedAt;
  List<Map<String, dynamic>> messages;

  AIChatSession({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    required this.messages,
  });

  factory AIChatSession.createNew({String? initialTitle}) {
    final now = DateTime.now();
    return AIChatSession(
      id: 'session_${now.millisecondsSinceEpoch}',
      title: initialTitle ?? 'Percakapan Baru',
      createdAt: now,
      updatedAt: now,
      messages: [
        {
          'sender': 'ai',
          'text': 'Halo! Saya AI Tutor KPM Academy 🤖✨. Ada soal matematika, fisika, kimia, atau materi MNR yang ingin kita bahas bersama hari ini?',
          'timestamp': now.toIso8601String(),
        }
      ],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
    'messages': messages,
  };

  factory AIChatSession.fromJson(Map<String, dynamic> json) {
    return AIChatSession(
      id: json['id']?.toString() ?? 'session_${DateTime.now().millisecondsSinceEpoch}',
      title: json['title']?.toString() ?? 'Percakapan',
      createdAt: json['created_at'] != null
          ? (DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now())
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? (DateTime.tryParse(json['updated_at'].toString()) ?? DateTime.now())
          : DateTime.now(),
      messages: (json['messages'] as List?)
              ?.map((e) => Map<String, dynamic>.from(e as Map))
              .toList() ??
          [],
    );
  }
}

class AIChatHistoryService {
  static const String _storageKey = 'kpm_ai_chat_sessions_v1';
  static const String _activeSessionKey = 'kpm_ai_active_session_id';

  /// Fetch all saved chat sessions, newest first
  static Future<List<AIChatSession>> getSessions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? rawJson = prefs.getString(_storageKey);
      if (rawJson == null || rawJson.isEmpty) {
        return [];
      }
      final List decoded = jsonDecode(rawJson);
      final list = decoded
          .map((item) => AIChatSession.fromJson(Map<String, dynamic>.from(item)))
          .toList();
      list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      return list;
    } catch (_) {
      return [];
    }
  }

  /// Save or update a session
  static Future<void> saveSession(AIChatSession session) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessions = await getSessions();
      final index = sessions.indexWhere((s) => s.id == session.id);

      if (index >= 0) {
        sessions[index] = session;
      } else {
        sessions.insert(0, session);
      }

      final encoded = jsonEncode(sessions.map((s) => s.toJson()).toList());
      await prefs.setString(_storageKey, encoded);
      await prefs.setString(_activeSessionKey, session.id);
    } catch (_) {}
  }

  /// Get active session or create initial one
  static Future<AIChatSession> getActiveOrCreateSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final activeId = prefs.getString(_activeSessionKey);
      final sessions = await getSessions();

      if (activeId != null) {
        final found = sessions.where((s) => s.id == activeId).firstOrNull;
        if (found != null) {
          return found;
        }
      }

      if (sessions.isNotEmpty) {
        return sessions.first;
      }

      // Create new session
      final newSession = AIChatSession.createNew();
      await saveSession(newSession);
      return newSession;
    } catch (_) {
      return AIChatSession.createNew();
    }
  }

  /// Delete a single session
  static Future<void> deleteSession(String sessionId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessions = await getSessions();
      sessions.removeWhere((s) => s.id == sessionId);
      final encoded = jsonEncode(sessions.map((s) => s.toJson()).toList());
      await prefs.setString(_storageKey, encoded);

      final activeId = prefs.getString(_activeSessionKey);
      if (activeId == sessionId) {
        if (sessions.isNotEmpty) {
          await prefs.setString(_activeSessionKey, sessions.first.id);
        } else {
          await prefs.remove(_activeSessionKey);
        }
      }
    } catch (_) {}
  }

  /// Clear all sessions
  static Future<void> clearAllSessions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_storageKey);
      await prefs.remove(_activeSessionKey);
    } catch (_) {}
  }
}
