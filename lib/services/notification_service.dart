import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/api/api_client.dart';
import '../core/api/api_endpoints.dart';
import '../models/notification_model.dart';

class NotificationService extends ChangeNotifier {
  final ApiClient _apiClient;
  static const String _storageKey = 'kpm_app_notifications_v2';
  List<NotificationModel> _items = [];
  bool _isLoading = false;

  NotificationService(this._apiClient);

  List<NotificationModel> get notifications => _items;
  bool get isLoading => _isLoading;
  int get unreadCount => _items.where((n) => !n.isRead).length;

  /// Fetch all notifications from local storage and backend, merging them seamlessly
  Future<List<NotificationModel>> getNotifications() async {
    _isLoading = true;
    notifyListeners();

    List<NotificationModel> localList = await _loadLocalNotifications();

    if (localList.isEmpty) {
      localList = _getInitialNotifications();
      await _saveLocalNotifications(localList);
    }

    try {
      final response = await _apiClient.dio.get(ApiEndpoints.notifications);
      final List data = response.data['data'] ?? [];
      final serverList = data.map((e) => NotificationModel.fromJson(e as Map<String, dynamic>)).toList();
      
      // Merge unique server items with local items
      for (final s in serverList) {
        if (!localList.any((l) => l.id == s.id)) {
          localList.insert(0, s);
        }
      }
      await _saveLocalNotifications(localList);
    } catch (_) {}

    _items = localList;
    _isLoading = false;
    notifyListeners();
    return _items;
  }

  /// Get count of unread notifications
  Future<int> getUnreadCount() async {
    if (_items.isEmpty) {
      await getNotifications();
    }
    return unreadCount;
  }

  /// Add a new notification (e.g. from study reminder or exam updates)
  Future<void> addNotification(NotificationModel notification) async {
    final list = await _loadLocalNotifications();
    list.removeWhere((item) => item.id == notification.id);
    list.insert(0, notification);
    await _saveLocalNotifications(list);
    _items = list;
    notifyListeners();
  }

  /// Mark a single notification as read
  Future<void> markRead(String id) async {
    final list = await _loadLocalNotifications();
    final index = list.indexWhere((n) => n.id == id);
    if (index >= 0) {
      list[index] = list[index].copyWith(readAt: DateTime.now().toIso8601String());
      await _saveLocalNotifications(list);
      _items = list;
      notifyListeners();
    }

    try {
      await _apiClient.dio.post(ApiEndpoints.markNotificationRead(id));
    } catch (_) {}
  }

  /// Mark ALL notifications as read (DOES NOT DELETE any notifications)
  Future<void> markAllRead() async {
    final list = await _loadLocalNotifications();
    final updatedList = list.map((n) {
      if (!n.isRead) {
        return n.copyWith(readAt: DateTime.now().toIso8601String());
      }
      return n;
    }).toList();

    await _saveLocalNotifications(updatedList);
    _items = updatedList;
    notifyListeners();

    try {
      await _apiClient.dio.post(ApiEndpoints.markAllNotificationsRead);
    } catch (_) {}
  }

  // --- Private Local Storage Helpers ---

  Future<List<NotificationModel>> _loadLocalNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? raw = prefs.getString(_storageKey);
      if (raw == null || raw.isEmpty) return [];

      final List decoded = jsonDecode(raw);
      return decoded.map((e) => NotificationModel.fromJson(Map<String, dynamic>.from(e))).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveLocalNotifications(List<NotificationModel> list) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(list.map((e) => e.toJson()).toList());
      await prefs.setString(_storageKey, encoded);
    } catch (_) {}
  }

  List<NotificationModel> _getInitialNotifications() {
    final now = DateTime.now();
    return [
      NotificationModel(
        id: 'notif_exam_1',
        userId: 'user_local',
        type: 'tryout',
        title: '📝 Paket Ujian Baru: Simulasi Ujian & Tryout Nasional 2025',
        message: 'Paket Ujian Online terbaru untuk persiapan SNBT dan Asesmen Nasional telah dibuka. Uji kemampuanmu sekarang!',
        createdAt: now.subtract(const Duration(minutes: 30)).toIso8601String(),
      ),
      NotificationModel(
        id: 'notif_exam_2',
        userId: 'user_local',
        type: 'tryout',
        title: '🏆 Paket Ujian Baru: Olimpiade Matematika Nalaria (MNR)',
        message: 'Paket latihan soal logika & penalaran MNR tingkat SD, SMP, SMA telah ditambahkan ke katalog paket belajar.',
        createdAt: now.subtract(const Duration(hours: 3)).toIso8601String(),
      ),
      NotificationModel(
        id: 'notif_live_1',
        userId: 'user_local',
        type: 'live',
        title: '🎥 Jadwal Live Class Interaktif KPM',
        message: 'Sesi bimbingan tatap muka online bersama Master Tutor KPM akan dimulai hari ini pukul 16:00 WIB.',
        createdAt: now.subtract(const Duration(hours: 6)).toIso8601String(),
      ),
      NotificationModel(
        id: 'notif_promo_1',
        userId: 'user_local',
        type: 'promo',
        title: '⚡ Diskon Spesial Paket Belajar s.d 70%',
        message: 'Gunakan kode promo KPMJUARA saat checkout untuk potongan harga ekstra seluruh paket belajar & ujian!',
        createdAt: now.subtract(const Duration(days: 1)).toIso8601String(),
      ),
    ];
  }
}
