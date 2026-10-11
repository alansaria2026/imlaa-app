import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imlaa/data/bi_lesson.dart';
import 'package:imlaa/data/lam_lesson.dart';
import 'package:imlaa/data/li_lesson.dart';
import 'package:imlaa/data/review_lesson.dart';
import 'package:imlaa/lesson/lam_lesson_pages.dart';
import 'package:imlaa/lesson/lesson_screen.dart';
import 'package:imlaa/lesson/pages/picture_page.dart';

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

/// النصوص الظاهرة، دون سطر المثال المحلول.
List<String> _visibleTexts(WidgetTester t) {
  final example = t
      .widgetList<Text>(
        find.descendant(
          of: find.byKey(const ValueKey('example')),
          matching: find.byType(Text),
        ),
      )
      .toSet();
  return t
      .widgetList<Text>(find.byType(Text))
      .where((w) => !example.contains(w))
      .map((w) => w.textSpan?.toPlainText() ?? w.data ?? '')
      .toList();
}

/// «التالي» يصحّح الإجابات قبل إكمال الصفحة.
Future<void> _submit(WidgetTester t) async {
  await t.pumpAndSettle();
  await t.tap(nextButton());
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

    // الجملة مسموعة فقط ولا تُعرض قبل الإجابة.
    expect(find.textContaining('( '), findsNothing);
    for (var i = 0; i < challengeSentences.length; i++) {
      final s = challengeSentences.firstWhere((c) => c.spoken == lastSpoken);
      // الإجابة مقبولة مع التشكيل أيضًا.
      await t.enterText(find.byType(TextField).at(0), s.moon);
      await t.enterText(find.byType(TextField).at(1), s.sun);
      await _submit(t);
      await _settle(t);
    }
    expect(find.text('أحسنت! أنهيت هذا التمرين'), findsOneWidget);
    expect(state.points, 10 + 9 * 20);
    // صفحة واحدة فهي الأخيرة: زر مكتوب عليه «إنهاء».
    expect(find.text('إنهاء'), findsOneWidget);
    expect(find.text('اسمع الجملة واكتب منها ما يلي'), findsNothing);
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
      // صورة الملعب مرسومة، وبقية الصور رموز تعبيرية.
      final item = find.byType(FootballPitch).evaluate().isNotEmpty
          ? pictureItems.firstWhere((p) => p.drawn)
          : pictureItems.firstWhere(
              (p) =>
                  p.emoji ==
                  _visibleText(t, (s) => pictureItems.any((p) => p.emoji == s)),
            );
      answered.add(item.answer);
      await type(item.answer);
      await _settle(t);
    }
    // الدب أعيد إلى آخر الطابور.
    expect(answered.last, 'الدب');
    expect(find.text('أحسنت! أنهيت هذا التمرين'), findsOneWidget);
    // يختفي السؤال بعد الإنهاء.
    expect(find.text('اكتب اسم ما تراه في الصورة'), findsNothing);
  });

  testWidgets('حذف (الـ): أي خطأ يعيد الكلمات بترتيب جديد', (t) async {
    final state = await pumpScreen(t, _single(5));
    final fields = find.byType(TextField);
    List<String> group() =>
        _visibleTexts(t).where(removeAlWords.contains).toList();
    String answer(String w) => w.substring(2);

    // سؤالان في كل شاشة.
    expect(fields, findsNWidgets(2));
    final first = group();
    await t.enterText(fields.at(0), 'خطأ');
    await t.enterText(fields.at(1), answer(first[1]));
    await _submit(t);
    expect(find.textContaining('لا يُسمح بالخطأ'), findsOneWidget);
    expect(scoreLabel('النتيجة ٩٠٪'), findsOneWidget);
    await t.pump(const Duration(milliseconds: 3600));
    await t.pumpAndSettle();
    expect(scoreLabel('بقيت ٩ أسئلة'), findsOneWidget);

    final seen = <String>[];
    // ٩ كلمات: أربع شاشات بكلمتين ثم شاشة بكلمة.
    for (var round = 0; round < 5; round++) {
      final words = group();
      expect(words.length, round < 4 ? 2 : 1);
      seen.addAll(words);
      for (var i = 0; i < words.length; i++) {
        await t.enterText(fields.at(i), answer(words[i]));
      }
      await _submit(t);
      await _settle(t);
    }
    expect(seen.toSet(), removeAlWords.toSet());
    expect(scoreLabel('لم يبقَ شيء'), findsOneWidget);
    expect(state.points, 81); // ٩ × ١٠ × ٩٠٪
  });

  testWidgets('إضافة (الـ): أي خطأ يعيد الكلمات بترتيب جديد', (t) async {
    final state = await pumpScreen(t, _single(2));
    final fields = find.byType(TextField);
    // الكلمات الظاهرة في المجموعة الحالية بترتيبها.
    List<String> group() =>
        _visibleTexts(t).where(addAlWordBank.contains).toList();

    // «التالي» قبل الإجابة عن السؤالين لا يُحتسب خطأ.
    await t.enterText(fields.at(0), 'ال${group()[0]}');
    await _submit(t);
    expect(find.textContaining('أجب عن جميع الأسئلة'), findsOneWidget);
    await _settle(t);

    final before = group();
    await t.enterText(fields.at(0), 'ال${before[0]}');
    await t.enterText(fields.at(1), 'خطأ');
    await _submit(t);
    expect(find.textContaining('لا يُسمح بالخطأ'), findsOneWidget);
    expect(scoreLabel('النتيجة ٩٠٪'), findsOneWidget);
    await t.pump(const Duration(milliseconds: 3600));
    await t.pumpAndSettle();
    // أعيدت جميع الكلمات من البداية.
    expect(scoreLabel('بقي ١٢ سؤالًا'), findsOneWidget);

    for (var round = 0; round < 6; round++) {
      final words = group();
      expect(words.length, 2);
      for (var i = 0; i < 2; i++) {
        await t.enterText(fields.at(i), 'ال${words[i]}');
      }
      await _submit(t);
      await _settle(t);
    }
    expect(scoreLabel('لم يبقَ شيء'), findsOneWidget);
    expect(state.points, 108); // ١٢ × ١٠ × ٩٠٪
  });

  testWidgets('أضف (لِـ): عشر كلمات بلا خطأ', (t) async {
    final state = await pumpScreen(t, _single(6));
    final fields = find.byType(TextField);
    List<String> group() =>
        _visibleTexts(t).where(liWordBank.contains).toList();
    for (var round = 0; round < 5; round++) {
      final words = group();
      expect(words.length, 2);
      for (var i = 0; i < 2; i++) {
        await t.enterText(fields.at(i), liForm(words[i]));
      }
      await _submit(t);
      await _settle(t);
    }
    expect(scoreLabel('لم يبقَ شيء'), findsOneWidget);
    expect(state.points, 100);
  });

  testWidgets('احذف (لِـ): للحن − لِـ = اللحن', (t) async {
    await pumpScreen(t, _single(7));
    final fields = find.byType(TextField);
    final byLi = {for (final w in liWordBank) liForm(w): w};
    List<String> group() => _visibleTexts(t).where(byLi.containsKey).toList();
    for (var round = 0; round < 5; round++) {
      final words = group();
      expect(words.length, 2);
      for (var i = 0; i < 2; i++) {
        await t.enterText(fields.at(i), byLi[words[i]]!);
      }
      await _submit(t);
      await _settle(t);
    }
    expect(scoreLabel('لم يبقَ شيء'), findsOneWidget);
  });

  testWidgets('الرجوع للقاعدة يغيّر كلمات (لِـ)', (t) async {
    await pumpScreen(t, _single(6));
    List<String> group() =>
        _visibleTexts(t).where(liWordBank.contains).toList();
    final seen = <String>{};
    for (var i = 0; i < 4; i++) {
      seen.addAll(group());
      await t.tap(find.byTooltip('القائمة'));
      await t.pumpAndSettle();
      await t.tap(find.text('القاعدة').last);
      await t.pumpAndSettle();
      expect(find.text('نبدأ الاسم بكتابة لامين فقط'), findsOneWidget);
      expect(find.text('مثال'), findsWidgets);
      await t.tapAt(const Offset(20, 20));
      await t.pumpAndSettle();
    }
    // كلمات جديدة في كل مرة (عشوائية، فيكفي أن تتغير مرة على الأقل).
    expect(seen.length, greaterThan(2));
  });

  testWidgets('أضف (بـ): خطأ ثم عشر كلمات', (t) async {
    await pumpScreen(t, _single(9));
    final fields = find.byType(TextField);
    List<String> group() =>
        _visibleTexts(t).where(biWordBank.contains).toList();
    for (var round = 0; round < 5; round++) {
      final words = group();
      expect(words.length, 2);
      // إجابة خاطئة شائعة: حذف الألف كما في لام الجر.
      if (round == 0) {
        await t.enterText(fields.at(0), 'بل${words[0].substring(2)}');
        await t.enterText(fields.at(1), biForm(words[1]));
        await _submit(t);
        expect(find.textContaining('لا يُسمح بالخطأ'), findsOneWidget);
        await t.pump(const Duration(milliseconds: 3600));
        await t.pumpAndSettle();
        continue;
      }
      for (var i = 0; i < 2; i++) {
        await t.enterText(fields.at(i), biForm(words[i]));
      }
      await _submit(t);
      await _settle(t);
    }
    // بعد الخطأ أعيدت الكلمات: يكفي أن نُكمل الباقي.
    while (scoreLabel('لم يبقَ شيء').evaluate().isEmpty) {
      final words = group();
      for (var i = 0; i < words.length; i++) {
        await t.enterText(fields.at(i), biForm(words[i]));
      }
      await _submit(t);
      await _settle(t);
    }
  });

  testWidgets('احذف (بـ): تبقى (ال) كما هي', (t) async {
    await pumpScreen(t, _single(10));
    final fields = find.byType(TextField);
    final byBi = {for (final w in biWordBank) biForm(w): w};
    for (var round = 0; round < 5; round++) {
      final words = _visibleTexts(t).where(byBi.containsKey).toList();
      expect(words.length, 2);
      for (var i = 0; i < 2; i++) {
        await t.enterText(fields.at(i), byBi[words[i]]!);
      }
      await _submit(t);
      await _settle(t);
    }
    expect(scoreLabel('لم يبقَ شيء'), findsOneWidget);
  });

  Future<void> typeLetters(WidgetTester t, String word) async {
    for (final l in word.split('')) {
      await t.tap(find.text(l).last);
      await t.pump();
    }
  }

  for (final (page, prep) in [(8, Prep.li), (11, Prep.bi)]) {
    testWidgets('استماع ${prep.name}: كلمات وجمل بحرف واحد', (t) async {
      await pumpScreen(t, _single(page));
      final bySpoken = {
        for (final w in prep == Prep.li ? liWordBank : biWordBank)
          prep.spoken(w): prep.form(w),
        for (final s in prepSentences)
          if (s.prep == prep) s.spoken: s.answer,
      };

      // «إدخال» قبل إكمال الكلمة لا يُحتسب.
      await t.tap(find.text('إدخال'));
      await t.pump();
      expect(find.textContaining('أكمل كتابة الكلمة'), findsOneWidget);
      await _settle(t);

      final first = bySpoken[lastSpoken]!;
      await typeLetters(t, 'ل' * first.length);
      await t.tap(find.text('إدخال'));
      await t.pump();
      expect(find.textContaining('سيعاد هذا السؤال'), findsOneWidget);
      await _settle(t);

      var sentences = 0;
      for (var i = 0; i < 10; i++) {
        if (find.textContaining('………').evaluate().isNotEmpty) sentences++;
        await typeLetters(t, bySpoken[lastSpoken]!);
        await _submit(t);
        await _settle(t);
      }
      expect(sentences, 5);
      expect(find.text('أحسنت! أنهيت هذا التمرين'), findsOneWidget);
    });
  }
}
