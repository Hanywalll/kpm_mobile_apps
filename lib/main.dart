import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/api/api_client.dart';
import 'core/theme/app_theme.dart';

import 'services/ai_service.dart';
import 'services/auth_service.dart';
import 'services/package_service.dart';
import 'services/practice_service.dart';
import 'services/video_service.dart';

import 'providers/auth_provider.dart';
import 'providers/package_provider.dart';
import 'providers/practice_provider.dart';

import 'screens/ai_tutor/chat_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/checkout/checkout_screen.dart';
import 'screens/enroll/enroll_key_screen.dart';
import 'screens/main_navigation_screen.dart';
import 'screens/notification/notification_screen.dart';
import 'screens/packages/package_detail_screen.dart';
import 'screens/packages/package_list_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/tryout/exam_screen.dart';
import 'screens/tryout/pretest_screen.dart';
import 'screens/tryout/result_screen.dart';
import 'screens/tryout/review_screen.dart';
import 'screens/video/video_list_screen.dart';
import 'screens/video/video_player_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const KPMApp());
}

class KPMApp extends StatelessWidget {
  final ApiClient? apiClient;

  const KPMApp({super.key, this.apiClient});

  @override
  Widget build(BuildContext context) {
    final client = apiClient ?? ApiClient();
    final authService = AuthService(client);
    final packageService = PackageService(client);
    final practiceService = PracticeService(client);
    final videoService = VideoService(client);
    final aiService = AIService(client);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(authService)..initAuth()),
        ChangeNotifierProvider(create: (_) => PackageProvider(packageService)),
        ChangeNotifierProvider(create: (_) => PracticeProvider(practiceService)),
        Provider.value(value: videoService),
        Provider.value(value: aiService),
      ],
      child: MaterialApp(
        title: 'KPM Academy',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: '/home',
        routes: {
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/home': (context) => const MainNavigationScreen(),
          '/package_list': (context) => const PackageListScreen(),
          '/package_detail': (context) => const PackageDetailScreen(),
          '/checkout': (context) => const CheckoutScreen(),
          '/pretest': (context) => const PretestScreen(),
          '/exam': (context) => const ExamScreen(),
          '/result': (context) => const ResultScreen(),
          '/review': (context) => const ReviewScreen(),
          '/video_list': (context) => const VideoListScreen(),
          '/video_player': (context) => const VideoPlayerScreen(),
          '/ai_chat': (context) => const ChatScreen(),
          '/enroll_key': (context) => const EnrollKeyScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/notification': (context) => const NotificationScreen(),
          '/settings': (context) => const SettingsScreen(),
        },
      ),
    );
  }
}
