import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imlaa/screens/home_screen.dart';

import 'helpers/harness.dart';

void main() {
  setUpAll(loadAppFonts);
  setUp(mockPlatform);

  testWidgets('الصفحة الرئيسية وفتح الدرس والتنقل', (tester) async {
    await pumpScreen(tester, const HomeScreen());
    expect(find.text('هيا نتعلم الإملاء'), findsOneWidget);

    await tester.tap(find.text('ابدأ الآن'));
    await tester.pumpAndSettle();
    expect(find.text('عنوان الدرس'), findsOneWidget);

    // ص ١ ← ص ٢ ← ص ٣
    await tester.tap(find.text('التالي'));
    await tester.pumpAndSettle();
    expect(find.text('أضف (الـ) أو احذفها'), findsOneWidget);
    await tester.tap(find.text('التالي'));
    await tester.pumpAndSettle();
    expect(find.text('أضف (الـ) إلى الكلمة واكتب الناتج'), findsOneWidget);

    // لا يمكن التقدم قبل الإجابة.
    await tester.tap(find.text('التالي'));
    await tester.pump();
    expect(find.textContaining('أجب عن جميع الفقرات'), findsOneWidget);
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // نافذة القاعدة.
    await tester.tap(find.byIcon(Icons.menu_book_rounded));
    await tester.pumpAndSettle();
    expect(find.text('الحروف الشمسية'), findsWidgets);
  });
}
