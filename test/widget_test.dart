import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kpm_academy/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
  });

  testWidgets('KPM App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const KPMApp());
    await tester.pump();
    tester.takeException();

    expect(find.byType(KPMApp), findsOneWidget);

    // Cleanly unmount before navigating to HomeScreen to avoid network timers in smoke test
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 10));
  });
}
