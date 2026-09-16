import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:kpm_academy/core/theme/app_theme.dart';
import 'package:kpm_academy/providers/auth_provider.dart';
import 'package:kpm_academy/services/auth_service.dart';
import 'package:kpm_academy/core/api/api_client.dart';
import 'package:kpm_academy/screens/home/home_screen.dart';

void main() {
  testWidgets('Test HomeScreen rendering', (WidgetTester tester) async {
    final apiClient = ApiClient();
    final authService = AuthService(apiClient);
    final authProvider = AuthProvider(authService);

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: authProvider,
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const HomeScreen(),
        ),
      ),
    );

    await tester.pump();
    expect(find.byType(HomeScreen), findsOneWidget);
  });
}
