import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/api/api_client.dart';
import 'core/theme/app_theme.dart';

import 'services/ai_service.dart';
import 'services/auth_service.dart';
import 'services/dashboard_service.dart';
import 'services/notification_service.dart';
import 'services/package_service.dart';
import 'services/practice_service.dart';
import 'services/support_service.dart';
import 'services/video_service.dart';

import 'providers/auth_provider.dart';
import 'providers/package_provider.dart';
import 'providers/practice_provider.dart';
import 'providers/theme_provider.dart';

import 'screens/ai_tutor/chat_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/cart/cart_screen.dart';
import 'screens/checkout/checkout_screen.dart';
import 'screens/checkout/midtrans_payment_screen.dart';
import 'screens/checkout/payment_receipt_screen.dart';
import 'screens/enroll/enroll_key_screen.dart';
import 'screens/features/all_features_screen.dart';
import 'screens/live_class/live_class_screen.dart';
import 'screens/main_navigation_screen.dart';
import 'screens/notification/notification_screen.dart';
import 'screens/orders/order_history_screen.dart';
import 'screens/packages/package_detail_screen.dart';
import 'screens/packages/package_list_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/search/search_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/tryout/exam_screen.dart';
import 'screens/tryout/pretest_screen.dart';
import 'screens/tryout/result_screen.dart';
import 'screens/tryout/review_screen.dart';
import 'screens/video/video_list_screen.dart';
import 'screens/video/video_player_screen.dart';
import 'screens/voucher/claim_voucher_screen.dart';
import 'services/local_notification_service.dart';

import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await initializeDateFormatting('id_ID', null);
    await LocalNotificationService.init();
  } catch (_) {}
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
    final dashboardService = DashboardService(client);
    final notificationService = NotificationService(client);
    final supportService = SupportService(client);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider(authService)..initAuth()),
        ChangeNotifierProvider(create: (_) => PackageProvider(packageService)..fetchPackages()),
        ChangeNotifierProvider(create: (_) => PracticeProvider(practiceService)),
        Provider.value(value: packageService),
        Provider.value(value: videoService),
        Provider.value(value: aiService),
        Provider.value(value: dashboardService),
        Provider.value(value: notificationService),
        Provider.value(value: supportService),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'KPM Academy',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            initialRoute: '/splash',
            routes: {
              '/splash': (context) => const SplashScreen(),
              '/login': (context) => const LoginScreen(),
              '/register': (context) => const RegisterScreen(),
              '/home': (context) => const MainNavigationScreen(),
              '/package_list': (context) => const PackageListScreen(),
              '/package_detail': (context) => const PackageDetailScreen(),
              '/cart': (context) => const CartScreen(),
              '/checkout': (context) => const CheckoutScreen(),
              '/midtrans_payment': (context) => const MidtransPaymentScreen(),
              '/receipt': (context) => const PaymentReceiptScreen(),
              '/pretest': (context) => const PretestScreen(),
              '/exam': (context) => const ExamScreen(),
              '/result': (context) => const ResultScreen(),
              '/review': (context) => const ReviewScreen(),
              '/video_list': (context) => const VideoListScreen(),
              '/video_player': (context) => const VideoPlayerScreen(),
              '/live_class': (context) => const LiveClassScreen(),
              '/order_history': (context) => const OrderHistoryScreen(),
              '/claim_voucher': (context) => const ClaimVoucherScreen(),
              '/ai_chat': (context) => const ChatScreen(),
              '/enroll_key': (context) => const ClaimVoucherScreen(),
              '/all_features': (context) => const AllFeaturesScreen(),
              '/search': (context) => const SearchScreen(),
              '/profile': (context) => const ProfileScreen(),
              '/notification': (context) => const NotificationScreen(),
              '/settings': (context) => const SettingsScreen(),
            },
          );
        },
      ),
    );
  }
}
