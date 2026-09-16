import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kpm_academy/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});

    // Mock MethodChannel untuk FlutterSecureStorage agar tidak MissingPluginException di IDE runner
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.it_o.com/flutter_secure_storage'),
      (MethodCall methodCall) async {
        if (methodCall.method == 'read') {
          return null;
        }
        return null;
      },
    );
  });

  testWidgets('KPM App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const KPMApp());
    await tester.pump(); // Pump frame pertama
    await tester.pump(const Duration(milliseconds: 500)); // Pump pending async timer/microtasks

    expect(find.byType(KPMApp), findsOneWidget);
  });
}
