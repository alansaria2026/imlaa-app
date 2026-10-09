import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imlaa/data/lam_lesson.dart';
import 'package:imlaa/lesson/lam_lesson_pages.dart';
import 'package:imlaa/lesson/lesson_screen.dart';

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

List<String> _visibleTexts(WidgetTester t) => t
    .widgetList<Text>(find.byType(Text))
    .map((w) => w.textSpan?.toPlainText() ?? w.data ?? '')
    .toList();

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
    final state = await pumpScreen(t, _single(4));

    await t.enterText(find.byType(TextField).first, 'كلمة');
    await _submit(t);
    expect(find.text('هذه الكلمة ليست في الجملة'), findsOneWidget);
    expect(find.text('اكتب الكلمة'), findsOneWidget);
    await _settle(t);

    for (var i = 0; i < challengeSentences.length; i++) {
      final shown = _visibleText(t, (s) => s.startsWith('( '));
      final s = challengeSentences.firstWhere((c) => shown.contains(c.spoken));
      // الإجابة مقبولة مع التشكيل أيضًا.
      await t.enterText(find.byType(TextField).at(0), s.moon);
      await t.enterText(find.byType(TextField).at(1), s.sun);
      await _submit(t);
      await _settle(t);
    }
    expect(find.text('أحسنت! أنهيت هذا التمرين'), findsOneWidget);
    expect(state.points, 10 + 9 * 20);
  });

  testWidgets('الصور: خطأ يعيد السؤال ثم إكمال الثمانية', (t) async {
    await pumpScreen(t, _single(3));
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
    expect(find.text('أحسنت! أنهيت هذا التمرين'), findsOneWidget);
  });

  testWidgets('حذف (الـ): أي خطأ يعيد الكلمات بترتيب جديد', (t) async {
    final state = await pumpScreen(t, _single(5));
    final fields = find.byType(TextField);
    List<String> group() =>
        _visibleTexts(t).where(removeAlWords.contains).toList();
    String answer(String w) => w.substring(2);

    expect(fields, findsNWidgets(3));
    final first = group();
    await t.enterText(fields.at(0), 'خطأ');
    await t.enterText(fields.at(1), answer(first[1]));
    await t.enterText(fields.at(2), answer(first[2]));
    await _submit(t);
    expect(find.textContaining('لا يُسمح بالخطأ'), findsOneWidget);
    expect(find.textContaining('المستوى ٩٠٪'), findsOneWidget);
    await t.pump(const Duration(milliseconds: 2000));
    await t.pumpAndSettle();
    expect(find.textContaining('أنجزت ٠/٩'), findsOneWidget);

    final seen = <String>[];
    for (var round = 0; round < 3; round++) {
      final words = group();
      expect(words.length, 3);
      seen.addAll(words);
      for (var i = 0; i < 3; i++) {
        await t.enterText(fields.at(i), answer(words[i]));
      }
      await _submit(t);
      await _settle(t);
    }
    expect(seen.toSet(), removeAlWords.toSet());
    expect(find.textContaining('أنجزت ٩/٩'), findsOneWidget);
    expect(state.points, 81); // ٩ × ١٠ × ٩٠٪
  });

  testWidgets('إضافة (الـ): أي خطأ يعيد الكلمات بترتيب جديد', (t) async {
    final state = await pumpScreen(t, _single(2));
    final fields = find.byType(TextField);
    // الكلمات الظاهرة في المجموعة الحالية بترتيبها.
    List<String> group() =>
        _visibleTexts(t).where(addAlWordBank.contains).toList();

    // «إدخال» قبل الإجابة عن الأسئلة الثلاثة لا يُحتسب خطأ.
    await t.enterText(fields.at(0), 'ال${group()[0]}');
    await _submit(t);
    expect(find.textContaining('أجب عن جميع الأسئلة'), findsOneWidget);
    await _settle(t);

    final before = group();
    await t.enterText(fields.at(0), 'ال${before[0]}');
    await t.enterText(fields.at(1), 'خطأ');
    await t.enterText(fields.at(2), 'ال${before[2]}');
    await _submit(t);
    expect(find.textContaining('لا يُسمح بالخطأ'), findsOneWidget);
    expect(find.textContaining('المستوى ٩٠٪'), findsOneWidget);
    await t.pump(const Duration(milliseconds: 2000));
    await t.pumpAndSettle();
    // أعيدت جميع الكلمات من البداية.
    expect(find.textContaining('أنجزت ٠/١٢'), findsOneWidget);

    for (var round = 0; round < 4; round++) {
      final words = group();
      expect(words.length, 3);
      for (var i = 0; i < 3; i++) {
        await t.enterText(fields.at(i), 'ال${words[i]}');
      }
      await _submit(t);
      await _settle(t);
    }
    expect(find.textContaining('أنجزت ١٢/١٢'), findsOneWidget);
    expect(state.points, 108); // ١٢ × ١٠ × ٩٠٪
  });
}
