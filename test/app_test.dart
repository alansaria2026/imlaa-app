import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imlaa/app_state.dart';
import 'package:imlaa/screens/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers/harness.dart';

void main() {
  setUpAll(loadAppFonts);
  setUp(mockPlatform);

  testWidgets('مسار التعلّم: فتح المحطة الحالية والتنقل والعودة', (t) async {
    final state = await pumpScreen(t, const HomeScreen());
    expect(find.text('إملائي'), findsOneWidget);
    expect(find.text('٠ من ٦ محطات'), findsOneWidget);

    // محطة مقفلة تُظهر تلميحًا ولا تُفتح.
    await t.tap(find.text('أمثلة'));
    await t.pump();
    expect(find.textContaining('أكمل المحطات السابقة'), findsOneWidget);
    await t.pumpAndSettle(const Duration(seconds: 5));

    await t.tap(find.text('ابدأ'));
    await t.pumpAndSettle();
    expect(find.text('عنوان الدرس'), findsOneWidget);
    expect(find.textContaining('الصفحة ١ من ٦'), findsOneWidget);

    // ص ١ ← ص ٢ ← ص ٣
    await t.tap(find.text('التالي'));
    await t.pumpAndSettle();
    expect(find.text('أضف (الـ) أو احذفها'), findsOneWidget);
    await t.tap(find.text('التالي'));
    await t.pumpAndSettle();
    expect(find.text('أضف (الـ) إلى الكلمة واكتب الناتج'), findsOneWidget);

    // لا يمكن التقدم قبل الإجابة.
    await t.tap(find.text('التالي'));
    await t.pump();
    expect(find.textContaining('أجب عن جميع الفقرات'), findsOneWidget);
    await t.pumpAndSettle(const Duration(seconds: 3));

    // نافذة القاعدة.
    await t.tap(find.byIcon(Icons.menu_book_rounded));
    await t.pumpAndSettle();
    expect(find.text('الحروف الشمسية'), findsWidgets);
    await t.tapAt(const Offset(20, 20));
    await t.pumpAndSettle();

    // العودة للرئيسية: أُنجزت محطتان وصارت «أضف (الـ)» الحالية.
    await t.tap(find.byTooltip('الصفحة الرئيسية'));
    await t.pumpAndSettle();
    expect(state.isPageDone('lam', 0), isTrue);
    expect(state.isPageDone('lam', 1), isTrue);
    expect(find.text('٢ من ٦ محطات'), findsOneWidget);
  });

  testWidgets('تبويبا الإنجازات والإعدادات', (t) async {
    await pumpScreen(t, const HomeScreen());
    await t.tap(find.text('إنجازاتي'));
    await t.pumpAndSettle();
    expect(find.text('الشارات'), findsOneWidget);
    expect(find.text('بطل اللام'), findsOneWidget);

    await t.tap(find.text('الإعدادات').last);
    await t.pumpAndSettle();
    expect(find.text('سرعة النطق'), findsOneWidget);
    expect(find.text('جرّب الصوت'), findsOneWidget);
  });

  group('الأيام المتتالية', () {
    tearDown(() => AppState.clock = DateTime.now);

    test('تزيد يومًا بيوم وتنقطع بعد يوم فائت', () async {
      SharedPreferences.setMockInitialValues({});
      var now = DateTime(2026, 10, 1, 9);
      AppState.clock = () => now;
      final state = await AppState.load();
      expect(state.streak, 0);

      state.addPoints(10);
      state.addPoints(10); // نفس اليوم
      expect(state.streak, 1);

      now = DateTime(2026, 10, 2, 20);
      state.addPoints(5);
      expect(state.streak, 2);
      expect(state.learnedToday, isTrue);

      now = DateTime(2026, 10, 3, 8); // لم يتعلّم بعد اليوم
      expect(state.streak, 2);
      expect(state.learnedToday, isFalse);

      now = DateTime(2026, 10, 5, 8); // فاته يوم كامل
      expect(state.streak, 0);
      state.addPoints(5);
      expect(state.streak, 1);
    });
  });
}
