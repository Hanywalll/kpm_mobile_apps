import 'package:dio/dio.dart';
import '../core/api/api_client.dart';
import '../core/api/api_endpoints.dart';
import '../models/notification_model.dart';

class NotificationService {
  final ApiClient _apiClient;

  NotificationService(this._apiClient);

  Future<List<NotificationModel>> getNotifications() async {
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.notifications);
      final List data = response.data['data'] ?? [];
      return data.map((e) => NotificationModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (_) {
      return _getDemoNotifications();
    }
  }

  Future<int> getUnreadCount() async {
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.unreadNotificationsCount);
      return (response.data['data']?['unread_count'] as num?)?.toInt() ?? 0;
    } on DioException catch (_) {
      return 2;
    }
  }

  Future<void> markRead(String id) async {
    try {
      await _apiClient.dio.post(ApiEndpoints.markNotificationRead(id));
    } catch (_) {}
  }

  Future<void> markAllRead() async {
    try {
      await _apiClient.dio.post(ApiEndpoints.markAllNotificationsRead);
    } catch (_) {}
  }

  List<NotificationModel> _getDemoNotifications() {
    return [
      NotificationModel(
        id: 'notif_1',
        userId: 'demo_user_1',
        type: 'tryout',
        title: '🎉 Tryout Akbar Nasional Dimulai!',
        message: 'Simulasi Tryout SNBT 2025 #1 sudah dibuka. Ayo uji kemampuanmu sekarang!',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
      ),
      NotificationModel(
        id: 'notif_2',
        userId: 'demo_user_1',
        type: 'promo',
        title: '⚡ Diskon Flash Sale 70% Paket Bimbel',
        message: 'Dapatkan akses 50x Tryout IRT dan konsultasi AI Tutor dengan harga spesial.',
        createdAt: DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
      ),
    ];
  }
}
