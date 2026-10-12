import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imlaa/data/taa_lesson.dart';
import 'package:imlaa/lesson/lesson_complete_screen.dart';
import 'package:imlaa/lesson/lesson_screen.dart';
import 'package:imlaa/lesson/lessons.dart';
import 'package:imlaa/lesson/taa_lesson_pages.dart';
import 'package:imlaa/screens/home_screen.dart';
import 'package:imlaa/services/speech_texts.dart';
import 'package:imlaa/utils/arabic.dart';
import 'package:imlaa/widgets/letter_boxes.dart';

import 'helpers/harness.dart';

void main() {
  group('محتوى درس التاء', () {
    test('كل جملة فيها الكلمة الناقصة مرة واحدة وتنتهي بتاء', () {
      for (final s in [...taaSentences, ...taaSpareSentences]) {
        final words = normalizeAnswer(s.spoken).split(' ');
        expect(
          words.where((w) => w == normalizeAnswer(s.word)).length,
          1,
          reason: s.spoken,
        );
        expect(taaTypeOf(s.word), isNotNull, reason: s.word);
        expect(ArabicKeyboard.canType(s.word), isTrue, reason: s.word);
      }
    });

    test('جمل الكتاب العشر: أربع مفتوحة واثنتان جمع مؤنث وأربع مربوطة', () {
      final words = [for (final s in taaSentences) s.word];
      bool plural(String w) => w.endsWith('ات');
      expect(words.length, 10);
      expect(words.where((w) => taaTypeOf(w) == TaaType.marbuta).length, 4);
      expect(words.where(plural).length, 2);
      expect(
        words.where((w) => taaTypeOf(w) == TaaType.maftuha && !plural(w)),
        hasLength(4),
      );
    });

    test('كل زوج: تاء مربوطة وهاء، بالخيارين نفسيهما معكوسين', () {
      for (final (a, b) in taaChoicePairs) {
        final ends = {a.word.characters.last, b.word.characters.last};
        expect(ends, {'ة', 'ه'}, reason: a.word);
        expect(a.answer, b.wrong);
        expect(a.wrong, b.answer);
      }
    });

    test('خمسة أسئلة اختيار، والبديل هو الصورة الأخرى للكلمة', () {
      final (items, spare) = taaChoiceItems(Random(2));
      expect(items.length, 5);
      for (var i = 0; i < 5; i++) {
        expect(items[i].answer, spare[i].wrong);
      }
    });

    test('شرح الخطأ في الحرف الأخير فقط', () {
      expect(taaMistake('الجمعت', 'الجمعة'), contains('تاء مربوطة'));
      expect(taaMistake('الجمعه', 'الجمعة'), contains('وليست هاءً'));
      expect(taaMistake('السبة', 'السبت'), contains('تاء مفتوحة'));
      expect(taaMistake('السبه', 'السبت'), contains('تاء مفتوحة'));
      expect(taaMistake('الصبت', 'السبت'), isNull);
      expect(taaMistake('السبت', 'السبت'), isNull);
    });

    test('لكل كلمة اختيار صورة أخرى', () {
      for (final (a, b) in taaChoicePairs) {
        expect(taaChoicePartner(a), same(b));
        expect(taaChoicePartner(b), same(a));
      }
    });

    test('كل نصوص الدرس المنطوقة في قائمة التسجيلات', () {
      final texts = allSpeechTexts();
      for (final s in [...taaSentences, ...taaSpareSentences]) {
        expect(texts, contains(s.spoken));
      }
      for (final (a, b) in taaChoicePairs) {
        expect(texts, containsAll([a.spoken, b.spoken]));
      }
      for (final (_, spoken) in taaRuleWords) {
        expect(texts, contains(spoken));
      }
      expect(texts, containsAll([taaRuleSpeech, taaRuleSentence]));
    });

    test('درس التاء في المسار بعد درس اللام', () {
      expect(lessons.map((l) => l.id), ['lam', taaLessonId]);
      expect(lessonById(taaLessonId).build().length, 3);
    });
  });

  group('درس التاء كاملًا', () {
    setUpAll(loadAppFonts);
    setUp(mockPlatform);

    testWidgets('القاعدة ثم الاستماع ثم الاختيار، مع أخطاء', (t) async {
      final pages = buildTaaLessonPages(Random(1));
      final state = await pumpScreen(
        t,
        LessonScreen(lessonId: 'qa', title: taaLessonTitle, pages: pages),
      );

      Finder page() {
        final all = find.descendant(
          of: find.byType(PageView),
          matching: find.byType(SingleChildScrollView),
        );
        for (final e in all.evaluate()) {
          final box = e.renderObject! as RenderBox;
          if (box.localToGlobal(Offset.zero).dx.abs() < 1) {
            return find.byWidget(e.widget);
          }
        }
        throw StateError('لا صفحة ظاهرة');
      }

      Finder inPage(Finder f) => find.descendant(of: page(), matching: f);
      bool done(int i) => state.isPageDone('qa', i);

      Future<void> settle() async {
        await t.pump(const Duration(milliseconds: 3600));
        await t.pumpAndSettle();
      }

      Future<void> next() async {
        await t.pumpAndSettle();
        await t.tap(nextButton());
        await t.pump();
        await t.pumpAndSettle();
      }

      Future<void> type(String word) async {
        for (final l in word.split('')) {
          await t.tap(inPage(find.text(l)).last);
          await t.pump();
        }
        await t.tap(inPage(find.text('إدخال')));
        await t.pump();
      }

      // ١ القاعدة: المثال يُنطق بالضغط.
      expect(
        find.text('تعرّف على التاء المربوطة والتاء المفتوحة'),
        findsOneWidget,
      );
      await t.tap(find.byKey(const ValueKey('taa-sentence')));
      await t.pump();
      expect(lastSpoken, taaRuleSentence);
      await next();

      // ٢ اسمع واكتب: الخطأ يأتي بجملة جديدة.
      final answerOf = {
        for (final s in [...taaSentences, ...taaSpareSentences])
          s.spoken: s.word,
      };
      final firstSpoken = lastSpoken!;
      expect(answerOf, contains(firstSpoken));
      final wrong = answerOf[firstSpoken]!;
      // الحرف الأخير خطأ: تاء مفتوحة مكان المربوطة أو العكس.
      final last = wrong.endsWith('ة') ? 'ت' : 'ة';
      await type('${wrong.substring(0, wrong.length - 1)}$last');
      expect(find.textContaining('إليك جملة جديدة'), findsOneWidget);
      expect(find.textContaining('آخر الكلمة تاء'), findsOneWidget);
      await settle();
      expect(lastSpoken, isNot(firstSpoken));
      var guard = 0;
      while (!done(1)) {
        expect(++guard, lessThan(15));
        await type(answerOf[lastSpoken]!);
        await settle();
      }
      await next();

      // ٣ اختر الكلمة: الخطأ يأتي بالصورة الأخرى للكلمة.
      final choiceOf = {
        for (final (a, b) in taaChoicePairs) ...{a.word: a, b.word: b},
      };
      TaaChoice current() {
        final q = t.widget<Text>(
          inPage(find.byKey(const ValueKey('choice-question'))),
        );
        return choiceOf[q.textSpan!.toPlainText().split(' ').first]!;
      }

      final firstChoice = current();
      await t.tap(inPage(find.text(firstChoice.wrong)));
      await t.pump();
      expect(find.textContaining('تاء مربوطة (ة) أم هاء (ه)'), findsWidgets);
      await settle();
      guard = 0;
      final asked = <String>[];
      while (!done(2)) {
        expect(++guard, lessThan(10));
        final c = current();
        asked.add(c.word);
        await t.tap(inPage(find.text(c.answer)));
        await t.pump();
        expect(lastSpoken, c.spoken);
        await settle();
      }
      // السؤال الخاطئ لم يُعد، وجاءت مكانه صورته الأخرى في الآخر.
      final partner = taaChoicePairs
          .expand((p) => [p.$1, p.$2])
          .firstWhere((c) => c.answer == firstChoice.wrong);
      expect(asked, isNot(contains(firstChoice.word)));
      expect(asked.last, partner.word);
      expect(asked.length, 5);

      await t.tap(find.text('إنهاء'));
      await t.pumpAndSettle();
      expect(find.byType(LessonCompleteScreen), findsOneWidget);
      expect(state.lessonsCompleted, 1);
    });

    testWidgets('شاشة صغيرة وخط كبير: لا تجاوز في الصفحات والقاعدة', (t) async {
      t.platformDispatcher.textScaleFactorTestValue = 1.3;
      addTearDown(t.platformDispatcher.clearTextScaleFactorTestValue);
      for (var i = 0; i < 3; i++) {
        await pumpScreen(
          t,
          size: const Size(960, 1700), // ٣٢٠ × ٥٦٧
          LessonScreen(
            key: ValueKey(i),
            lessonId: 'qa',
            title: taaLessonTitle,
            pages: buildTaaLessonPages(Random(i)),
            initialPage: i,
          ),
        );
        // القاعدة من القائمة هي قاعدة التاء في كل صفحة.
        await t.tap(find.byTooltip('القائمة'));
        await t.pumpAndSettle();
        await t.tap(find.text('القاعدة').last);
        await t.pumpAndSettle();
        expect(
          find.text('كيف نفرّق بين التاء المربوطة والتاء المفتوحة؟'),
          findsWidgets,
        );
        expect(find.text('اللام القمرية'), findsNothing);
        await t.tapAt(const Offset(10, 10));
        await t.pumpAndSettle();
      }
      // مسار التعلّم والوحدة الثانية مفتوحة.
      final state = await pumpScreen(
        t,
        const HomeScreen(),
        size: const Size(960, 1700),
      );
      state.selectLesson(taaLessonId);
      await t.pumpAndSettle();
      expect(find.text('اختر الكلمة'), findsOneWidget);
      await t.drag(find.byType(CustomScrollView), const Offset(0, -600));
      await t.pumpAndSettle();
    });
  });
}
