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

/// آخر نص طُلب نطقه.
String? lastSpoken;

void mockPlatform() {
  SharedPreferences.setMockInitialValues({});
  lastSpoken = null;
  // محاكاة قناة النطق حتى لا تفشل الاختبارات.
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(const MethodChannel('flutter_tts'), (
        call,
      ) async {
        if (call.method == 'speak') lastSpoken = call.arguments as String;
        return 1;
      });
}

/// زر «التالي» (أو «إنهاء» في آخر صفحة).
Finder nextButton() => find.byWidgetPredicate(
  (w) => w is Tooltip && (w.message == 'التالي' || w.message == 'إنهاء'),
);

/// مؤشر النتيجة يحمل وصفًا نصيًا (النتيجة والأسئلة المتبقية).
Finder scoreLabel(String text) => find.byWidgetPredicate(
  (w) => w is Semantics && (w.properties.label ?? '').contains(text),
);

/// يعرض [home] على شاشة جوال بعرض ٣٦٠ (أو [size] بالبكسل الفعلي).
Future<AppState> pumpScreen(
  WidgetTester tester,
  Widget home, {
  Size size = const Size(1080, 2340),
}) async {
  tester.view.physicalSize = size;
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
