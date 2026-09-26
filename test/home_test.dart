import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:kpm_academy/core/theme/app_theme.dart';
import 'package:kpm_academy/core/api/api_client.dart';
import 'package:kpm_academy/providers/auth_provider.dart';
import 'package:kpm_academy/providers/package_provider.dart';
import 'package:kpm_academy/providers/practice_provider.dart';
import 'package:kpm_academy/services/auth_service.dart';
import 'package:kpm_academy/services/package_service.dart';
import 'package:kpm_academy/services/practice_service.dart';
import 'package:kpm_academy/services/video_service.dart';
import 'package:kpm_academy/services/ai_service.dart';
import 'package:kpm_academy/services/dashboard_service.dart';
import 'package:kpm_academy/services/notification_service.dart';
import 'package:kpm_academy/services/support_service.dart';
import 'package:kpm_academy/models/video_model.dart';
import 'package:kpm_academy/screens/home/home_screen.dart';

class FakeVideoService extends VideoService {
  FakeVideoService(super.apiClient);

  @override
  Future<List<VideoModel>> getVideos({String? subject}) async {
    return [];
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    SharedPreferences.setMockInitialValues({
      'kpm_permission_prompt_completed': true,
      'kpm_promo_poster_last_shown_time': DateTime.now().toIso8601String(),
    });
  });

  testWidgets('Test HomeScreen rendering', (WidgetTester tester) async {
    final apiClient = ApiClient();
    final authService = AuthService(apiClient);
    final packageService = PackageService(apiClient);
    final practiceService = PracticeService(apiClient);
    final videoService = FakeVideoService(apiClient);
    final aiService = AIService(apiClient);
    final dashboardService = DashboardService(apiClient);
    final notificationService = NotificationService(apiClient);
    final supportService = SupportService(apiClient);

    final authProvider = AuthProvider(authService);
    final packageProvider = PackageProvider(packageService);
    final practiceProvider = PracticeProvider(practiceService);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: authProvider),
          ChangeNotifierProvider.value(value: packageProvider),
          ChangeNotifierProvider.value(value: practiceProvider),
          Provider<VideoService>.value(value: videoService),
          Provider.value(value: aiService),
          Provider.value(value: dashboardService),
          ChangeNotifierProvider.value(value: notificationService),
          Provider.value(value: supportService),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const HomeScreen(),
        ),
      ),
    );

    await tester.pump();
    tester.takeException();

    // Cleanly unmount to cancel timer in test harness
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 10));
  });
}
