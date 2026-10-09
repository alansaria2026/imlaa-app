import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imlaa/data/lam_lesson.dart';
import 'package:imlaa/lesson/lam_lesson_pages.dart';
import 'package:imlaa/lesson/lesson_screen.dart';
import 'package:imlaa/utils/arabic.dart';

import 'helpers/harness.dart';

Widget _single(int page) => LessonScreen(
  lessonId: 't',
  title: lamLessonTitle,
  pages: [buildLamLessonPages()[page]],
);

String _visibleText(WidgetTester t, bool Function(String) where) => t
    .widgetList<Text>(find.byType(Text))
    .map((w) => w.textSpan?.toPlainText() ?? w.data ?? '')
    .firstWhere(where);

Future<void> _submit(WidgetTester t) async {
  // انتظار انتهاء تمرير الحقل المُركَّز قبل الوصول إلى الزر.
  await t.pumpAndSettle();
  await t.ensureVisible(find.text('إدخال'));
  await t.pumpAndSettle();
  await t.tap(find.text('إدخال'));
  await t.pump();
}

Future<void> _settle(WidgetTester t) async {
  await t.pump(const Duration(milliseconds: 1600));
  await t.pumpAndSettle();
}

void main() {
  setUpAll(loadAppFonts);
  setUp(mockPlatform);

  testWidgets('تحدي الجمل: خطأ ثم إكمال العشر', (t) async {
    final state = await pumpScreen(t, _single(5));

    await t.enterText(find.byType(TextField).first, 'كلمة');
    await t.tap(find.text('إدخال'));
    await t.pump();
    expect(find.text('هذه الكلمة ليست في الجملة'), findsOneWidget);
    expect(find.text('اكتب الكلمة'), findsOneWidget);
    await _settle(t);

    for (var i = 0; i < challengeSentences.length; i++) {
      final shown = _visibleText(t, (s) => s.startsWith('( '));
      final s = challengeSentences.firstWhere((c) => shown.contains(c.spoken));
      // الإجابة مقبولة مع التشكيل أيضًا.
      await t.enterText(find.byType(TextField).at(0), s.moon);
      await t.enterText(find.byType(TextField).at(1), s.sun);
      await t.tap(find.text('إدخال'));
      await _settle(t);
    }
    expect(find.text('أحسنت! صنّفت جميع الكلمات'), findsOneWidget);
    expect(state.points, 10 + 9 * 20);
  });

  testWidgets('الصور: خطأ يعيد السؤال ثم إكمال الثمانية', (t) async {
    await pumpScreen(t, _single(4));
    Future<void> type(String word) async {
      for (final l in word.split('')) {
        await t.tap(find.text(l).last);
        await t.pump();
      }
    }

    // إجابة خاطئة بنفس عدد الحروف.
    await type('الدد');
    expect(find.textContaining('سيعاد هذا السؤال'), findsOneWidget);
    await _settle(t);

    final answered = <String>[];
    for (var i = 0; i < pictureItems.length; i++) {
      final emoji = _visibleText(
        t,
        (s) => pictureItems.any((p) => p.emoji == s),
      );
      final item = pictureItems.firstWhere((p) => p.emoji == emoji);
      answered.add(item.answer);
      await type(item.answer);
      await _settle(t);
    }
    // الدب أعيد إلى آخر الطابور.
    expect(answered.last, 'الدب');
    expect(find.text('أحسنت! صنّفت جميع الكلمات'), findsOneWidget);
  });

  testWidgets('حذف (الـ): تمييز الخطأ ثم الإكمال', (t) async {
    await pumpScreen(t, _single(6));
    final fields = find.byType(TextField);
    expect(fields, findsNWidgets(removeAlWords.length));
    for (var i = 0; i < removeAlWords.length; i++) {
      await t.enterText(
        fields.at(i),
        i == 0 ? 'خطأ' : removeAlWords[i].substring(2),
      );
    }
    await _submit(t);
    expect(find.textContaining('صحّح المربعات'), findsOneWidget);
    await _settle(t);

    await t.enterText(fields.at(0), removeAlWords[0].substring(2));
    await _submit(t);
    expect(find.textContaining('أنهيت هذا التطبيق'), findsOneWidget);
    await _settle(t);
  });

  testWidgets('تصنيف اللام', (t) async {
    await pumpScreen(t, _single(3));
    for (var i = 0; i < 10; i++) {
      final word = _visibleText(
        t,
        (s) => s.startsWith('ال') && !s.contains(' '),
      );
      await t.tap(find.text(lamTypeOf(word).label).last);
      await _settle(t);
    }
    expect(find.text('أحسنت! صنّفت جميع الكلمات'), findsOneWidget);
  });
}
