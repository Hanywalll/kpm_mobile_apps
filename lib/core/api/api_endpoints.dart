import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiEndpoints {
  // Production base URL
  static const String prodBaseUrl = 'https://backend-api.kpmacademic.io/api/v1';

  // Toggle for local development vs production
  // Set to true to always use live server https://backend-api.kpmacademic.io
  static const bool useProductionApi = true;

  // Base URL resolution
  static String get baseUrl {
    if (useProductionApi) {
      return prodBaseUrl;
    }
    if (kIsWeb) {
      return 'http://localhost:3000/api/v1';
    }
    try {
      if (Platform.isAndroid) {
        return 'http://10.0.2.2:3000/api/v1';
      }
    } catch (_) {}
    return 'http://localhost:3000/api/v1';
  }

  // Health
  static const String health = '/health';

  // Auth
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String googleLogin = '/auth/google';
  static const String refreshToken = '/auth/refresh-token';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String logout = '/auth/logout';

  // Profile
  static const String profile = '/profile';
  static const String changePassword = '/profile/change-password';

  // Dashboard
  static const String dashboard = '/dashboard';

  // Notifications
  static const String notifications = '/notifications';
  static const String unreadNotificationsCount = '/notifications/unread-count';
  static String markNotificationRead(String id) => '/notifications/$id/read';
  static const String markAllNotificationsRead = '/notifications/read-all';

  // Packages & Orders
  static const String packages = '/packages';
  static String packageDetail(String id) => '/packages/$id';
  static const String orders = '/orders';
  static String orderDetail(String id) => '/orders/$id';
  static const String orderStatus = '/orders/status';
  static String simulatePayOrder(String id) => '/orders/$id/pay';
  static String checkMidtransOrder(String id) => '/orders/$id/check-midtrans';

  // Practice & CBT
  static const String practiceStart = '/practice/start';
  static const String practiceSubmit = '/practice/submit';
  static const String practiceHistory = '/practice/history';
  static const String practiceStatistics = '/practice/statistics';
  static String practiceDetail(String id) => '/practice/$id';

  // Videos
  static const String videos = '/videos';
  static String videoDetail(String id) => '/videos/$id';
  static String videoOrder(String id) => '/videos/$id/order';
  static String simulateVideoPay(String videoId, String orderId) => '/videos/$videoId/pay/$orderId';

  // Testimonials
  static const String testimonials = '/testimonials';
  static const String myTestimonial = '/testimonials/my';

  // Contact & Support
  static const String contactForm = '/kontak-form';
  static const String supportSubmit = '/support/submit';

  // Chat / AI Assistant
  static const String chatSend = '/chat/send';
  static const String chatHistory = '/chat/history';
}
