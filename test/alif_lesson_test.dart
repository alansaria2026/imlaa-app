import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imlaa/data/alif_lesson.dart';
import 'package:imlaa/lesson/alif_lesson_pages.dart';
import 'package:imlaa/lesson/alif_rule_content.dart';
import 'package:imlaa/lesson/lesson_complete_screen.dart';
import 'package:imlaa/lesson/lesson_screen.dart';
import 'package:imlaa/lesson/lessons.dart';
import 'package:imlaa/lesson/pages/listen_write_page.dart';
import 'package:imlaa/lesson/pages/quiz_page.dart';
import 'package:imlaa/services/speech_texts.dart';
import 'package:imlaa/utils/arabic.dart';
import 'package:imlaa/widgets/letter_boxes.dart';

import 'helpers/harness.dart';

void main() {
  group('محتوى درس الألف اللينة', () {
    test('صورة الألف في الأسماء الثلاثية توافق القاعدة', () {
      for (final w in triliteralWords) {
        expect(w.word.characters.length, 3, reason: w.word);
        expect(w.word.endsWith('ى'), w.maqsura, reason: w.word);
        // المضموم أوله والمكسور أوله بالمقصورة دائمًا.
        if (w.vowel != FirstVowel.fath) expect(w.maqsura, isTrue);
      }
    });

    test('الأسماء غير الثلاثية: المقصورة إلا الأعجمي وما قبل ألفه ياء', () {
      for (final w in longMaqsuraWords) {
        expect(w.characters.length, greaterThan(3), reason: w);
        expect(w.endsWith('ى'), isTrue, reason: w);
        expect(longAnswersOf(w), contains('ألف مقصورة'));
      }
      for (final w in [...longYaWords, ...foreignWords]) {
        expect(w.endsWith('ا'), isTrue, reason: w);
        expect(longAnswersOf(w), contains('ألف ممدودة'));
      }
      for (final w in longYaWords) {
        expect(w[w.length - 2], 'ي', reason: w);
      }
    });

    test('«قرى»: أربع إجابات صحيحة كما في الكتاب', () {
      expect(fourAnswersOf(triliteral('قرى')), {
        'اسم',
        'ثلاثي',
        'أوله مضموم',
        'ألف مقصورة',
      });
      expect(longAnswersOf('سلوى'), {
        'اسم',
        'أكثر من ثلاثة حروف',
        'عربي',
        'ألف مقصورة',
      });
      for (final o in [...fourAnswerOptions, ...longOptions]) {
        expect(o, isNotEmpty);
      }
    });

    test('«أربع إجابات»: ثلاث جولات في كل جولة أربعة أمثلة إجاباتها واحدة', () {
      expect(fourAnswerGroups.length, 3);
      for (final (g, group) in fourAnswerGroups.indexed) {
        expect(group.length, 4);
        final answers = fourAnswersOf(triliteral(group.first.word));
        for (final (i, s) in group.indexed) {
          expect(fourAnswersOf(triliteral(s.word)), answers, reason: s.word);
          expect(fourAnswerSpare[g][i].word, s.word);
        }
      }
      expect(fourAnswerGroups.first.first.word, 'قرى');
    });

    test('كل جملة فيها كلمتها مرة واحدة، والكلمة تُكتب باللوحة', () {
      for (final s in [
        ...triliteralSentences,
        ...triliteralSpareSentences,
        ...pairSentences,
        ...fourAnswerSentences,
        ...longListenSentences,
        ...longListenSpare,
      ]) {
        final words = stripDiacritics(s.spoken).split(' ');
        expect(words.where((w) => w == s.word).length, 1, reason: s.spoken);
        expect(ArabicKeyboard.canType(s.word), isTrue, reason: s.word);
      }
    });

    test('كل نصوص الدرس المنطوقة في قائمة التسجيلات', () {
      final texts = allSpeechTexts();
      for (final s in [
        alifRuleSpeech,
        triliteralRuleSpeech,
        longRuleSpeech,
        for (final s in [...fourAnswerSentences, ...longListenSentences])
          s.spoken,
      ]) {
        expect(texts, contains(s));
      }
    });

    test('الدرس الرابع في المسار باثنتي عشرة محطة', () {
      expect(lessons.map((l) => l.id).last, alifLessonId);
      expect(lessonById(alifLessonId).unit, 4);
      expect(buildAlifLessonPages().length, 12);
    });
  });

  group('درس الألف اللينة في التطبيق', () {
    setUpAll(loadAppFonts);
    setUp(mockPlatform);

    testWidgets('الدرس كاملًا من القاعدة إلى «إنهاء» مع خطأ', (t) async {
      final pages = buildAlifLessonPages(Random(3));
      final state = await pumpScreen(
        t,
        LessonScreen(lessonId: 'qa', title: alifLessonTitle, pages: pages),
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

      Future<void> tapIn(Finder f) async {
        await t.ensureVisible(f);
        await t.pumpAndSettle();
        await t.tap(f);
        await t.pump();
      }

      var mistakes = 0;
      final answerOf = {
        for (final s in [...longListenSentences, ...longListenSpare])
          s.spoken: s.word,
      };
      for (var i = 0; i < pages.length; i++) {
        await t.pumpAndSettle();
        if (inPage(find.byType(QuizPage)).evaluate().isNotEmpty) {
          var guard = 0;
          while (!done(i)) {
            expect(++guard, lessThan(30), reason: 'الصفحة ${i + 1}');
            final round = t
                .state<QuizPageState>(inPage(find.byType(QuizPage)))
                .currentRound;
            final wrong = mistakes == 0;
            for (final (k, item) in round.items.indexed) {
              final picks = wrong && k == 0
                  ? [item.options.firstWhere((o) => !item.answers.contains(o))]
                  : item.answers;
              for (final a in picks) {
                await tapIn(inPage(find.byKey(ValueKey('q$k-$a'))).last);
              }
            }
            await tapIn(inPage(find.text('إدخال')).last);
            await settle();
            if (wrong) {
              mistakes++;
              await t.tapAt(const Offset(20, 20));
              await t.pumpAndSettle();
            }
          }
        } else if (inPage(find.byType(ListenWritePage)).evaluate().isNotEmpty) {
          var guard = 0;
          while (!done(i)) {
            expect(++guard, lessThan(20));
            for (final l in answerOf[lastSpoken]!.split('')) {
              await tapIn(inPage(find.text(l)).last);
            }
            await tapIn(inPage(find.text('إدخال')));
            await settle();
          }
        }
        expect(
          done(i) || !pages[i].needsCompletion,
          isTrue,
          reason: '${i + 1}',
        );
        if (i < pages.length - 1) {
          await t.tap(nextButton());
          await t.pump();
        }
      }
      expect(mistakes, 1);
      await t.tap(find.text('إنهاء'));
      await t.pumpAndSettle();
      expect(find.byType(LessonCompleteScreen), findsOneWidget);
    });

    testWidgets('«إدخال» ظاهر دون تمرير في كل تمرين على جوال عرضه ٣٦٠', (
      t,
    ) async {
      final n = buildAlifLessonPages(Random(0)).length;
      for (var i = 0; i < n; i++) {
        await pumpScreen(
          t,
          LessonScreen(
            key: ValueKey(i),
            lessonId: 'qa',
            title: alifLessonTitle,
            pages: buildAlifLessonPages(Random(i)),
            initialPage: i,
          ),
        );
        if (find.byType(QuizPage).evaluate().isEmpty &&
            find.byType(ListenWritePage).evaluate().isEmpty) {
          continue;
        }
        final enter = find.text('إدخال').hitTestable();
        expect(enter, findsOneWidget, reason: 'الصفحة ${i + 1}');
        expect(
          t.getRect(enter).bottom,
          lessThan(t.getRect(nextButton()).top),
          reason: 'الصفحة ${i + 1}: «إدخال» تحت أزرار التنقل',
        );
      }
    });

    testWidgets('قاعدة «غير الثلاثية» داخل الصفحة دون تمرير', (t) async {
      final pages = buildAlifLessonPages(Random(0));
      await pumpScreen(
        t,
        LessonScreen(
          lessonId: 'qa',
          title: alifLessonTitle,
          pages: pages,
          initialPage: pages.indexWhere((p) => p.title == 'غير الثلاثية'),
        ),
      );
      // لا «إضاءة» في الصفحة، وآخر أمثلتها فوق أزرار التنقل.
      expect(find.byKey(const ValueKey('alif-light')), findsNothing);
      final last = find.textContaining('مثل').last.hitTestable();
      expect(t.getRect(last).bottom, lessThan(t.getRect(nextButton()).top));
    });

    testWidgets('قاعدة «الاسم الثلاثي» داخل الصفحة دون تمرير', (t) async {
      final pages = buildAlifLessonPages(Random(0));
      await pumpScreen(
        t,
        LessonScreen(
          lessonId: 'qa',
          title: alifLessonTitle,
          pages: pages,
          initialPage: pages.indexWhere((p) => p.title == 'الاسم الثلاثي'),
        ),
      );
      final last = find.textContaining('فَتَيان').last.hitTestable();
      expect(t.getRect(last).bottom, lessThan(t.getRect(nextButton()).top));
    });

    testWidgets('«إضاءة» في نافذة القاعدة تعرض الأسماء الشاذة و«يحيى»', (
      t,
    ) async {
      final i = buildAlifLessonPages(
        Random(0),
      ).indexWhere((p) => p.title == 'غير الثلاثية');
      await pumpScreen(
        t,
        LessonScreen(
          lessonId: 'qa',
          title: alifLessonTitle,
          pages: buildAlifLessonPages(Random(0)),
          initialPage: i,
        ),
      );
      await t.tap(find.byTooltip('القائمة'));
      await t.pumpAndSettle();
      await t.tap(find.text('القاعدة').last);
      await t.pumpAndSettle();
      await t.ensureVisible(find.byKey(const ValueKey('alif-light')));
      await t.tap(find.byKey(const ValueKey('alif-light')));
      await t.pumpAndSettle();
      expect(find.text('موسى'), findsOneWidget);
      expect(find.textContaining('يحيى'), findsWidgets);
    });

    testWidgets('زر «إغلاق» يغلق نافذة القاعدة', (t) async {
      final pages = buildAlifLessonPages(Random(0));
      await pumpScreen(
        t,
        LessonScreen(
          lessonId: 'qa',
          title: alifLessonTitle,
          pages: pages,
          initialPage: pages.indexWhere((p) => p.title == 'اختر الإجابة'),
        ),
      );
      await t.tap(find.byTooltip('القائمة'));
      await t.pumpAndSettle();
      await t.tap(find.text('القاعدة').last);
      await t.pumpAndSettle();
      final close = find.byKey(const ValueKey('rule-close'));
      expect(close, findsOneWidget);
      // في الركن الأيسر من النافذة.
      expect(t.getCenter(close).dx, lessThan(100));
      await t.tap(close);
      await t.pumpAndSettle();
      expect(close, findsNothing);
    });

    for (final (i, remember) in [
      (0, TriliteralRemember),
      (1, LongNounRemember),
    ]) {
      testWidgets('الخطأ في «أكمل القاعدة» يعرض القاعدة المحفوظة $remember', (
        t,
      ) async {
        final pages = buildAlifLessonPages(Random(0));
        final page = [
          for (final (k, p) in pages.indexed)
            if (p.title == 'أكمل القاعدة') k,
        ][i];
        await pumpScreen(
          t,
          LessonScreen(
            lessonId: 'qa',
            title: alifLessonTitle,
            pages: pages,
            initialPage: page,
          ),
        );
        final round = t
            .state<QuizPageState>(find.byType(QuizPage))
            .currentRound;
        for (final (k, item) in round.items.indexed) {
          final a = item.options.firstWhere((o) => !item.answers.contains(o));
          await t.tap(find.byKey(ValueKey('q$k-$a')).last);
          await t.pump();
        }
        await t.tap(find.text('إدخال'));
        await t.pump(const Duration(milliseconds: 3600));
        await t.pumpAndSettle();
        expect(find.byType(remember), findsOneWidget);
        expect(find.byType(TriliteralRule), findsNothing);
        expect(find.byType(LongNounRule), findsNothing);
      });
    }

    for (final title in ['احفظ القاعدتين', 'احفظ القاعدة']) {
      testWidgets('«ابدأ الامتحان» في «$title» ينتقل إلى «أكمل القاعدة»', (
        t,
      ) async {
        final pages = buildAlifLessonPages(Random(0));
        final i = pages.indexWhere((p) => p.title == title);
        await pumpScreen(
          t,
          LessonScreen(
            lessonId: 'qa',
            title: alifLessonTitle,
            pages: pages,
            initialPage: i,
          ),
        );
        await t.tap(find.text('ابدأ الامتحان'));
        await t.pumpAndSettle();
        expect(pages[i + 1].title, 'أكمل القاعدة');
        expect(find.text('اختر الإجابة الصحيحة').hitTestable(), findsOneWidget);
      });
    }
  });
}
