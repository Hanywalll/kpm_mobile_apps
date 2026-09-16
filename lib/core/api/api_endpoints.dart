class ApiEndpoints {
  static const String baseUrl = 'http://10.0.2.2:8080/api/v1';

  // Auth
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String googleLogin = '/auth/google';
  static const String profile = '/auth/profile';

  // Packages & Orders
  static const String packages = '/packages';
  static String packageDetail(String id) => '/packages/$id';
  static const String createOrder = '/orders/create';
  static const String activateEnrollKey = '/enroll-key/activate';

  // Practice & CBT
  static String practiceStart(String id) => '/practice/start/$id';
  static String practiceSubmit(String id) => '/practice/submit/$id';
  static const String practiceHistory = '/practice/history';
  static String practiceReview(String id) => '/practice/$id/review';

  // Videos
  static const String videos = '/videos';

  // AI Tutor
  static const String aiChat = '/ai-tutor/chat';
}
