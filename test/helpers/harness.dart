import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imlaa/app_state.dart';
import 'package:imlaa/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _loadFont(String family, List<String> files) async {
  final loader = FontLoader(family);
  for (final f in files) {
    final bytes = File('assets/fonts/$f').readAsBytesSync();
    loader.addFont(Future.value(ByteData.sublistView(bytes)));
  }
  await loader.load();
}

/// خطوط حقيقية لقياسات واقعية بدل خط الاختبار المربّع.
Future<void> loadAppFonts() async {
  await _loadFont('Tajawal', [
    'Tajawal-Regular.ttf',
    'Tajawal-Medium.ttf',
    'Tajawal-Bold.ttf',
    'Tajawal-ExtraBold.ttf',
  ]);
  await _loadFont('NotoNaskhArabic', [
    'NotoNaskhArabic-Regular.ttf',
    'NotoNaskhArabic-Bold.ttf',
  ]);
}

void mockPlatform() {
  SharedPreferences.setMockInitialValues({});
  // محاكاة قناة النطق حتى لا تفشل الاختبارات.
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
        const MethodChannel('flutter_tts'),
        (call) async => 1,
      );
}

/// يعرض [home] على شاشة جوال بعرض ٣٦٠.
Future<AppState> pumpScreen(WidgetTester tester, Widget home) async {
  tester.view.physicalSize = const Size(1080, 2340);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  // «تقليل الحركة» يوقف الحركات المتكررة (التميمة ونبض المحطة).
  tester.platformDispatcher.accessibilityFeaturesTestValue =
      const FakeAccessibilityFeatures(disableAnimations: true);
  addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
  final state = await AppState.load();
  await tester.pumpWidget(
    AppScope(
      state: state,
      child: MaterialApp(
        theme: AppTheme.light(),
        locale: const Locale('ar'),
        supportedLocales: const [Locale('ar')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        home: home,
      ),
    ),
  );
  await tester.pumpAndSettle();
  return state;
}
