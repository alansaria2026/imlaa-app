import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imlaa/data/alif_verb_lesson.dart';
import 'package:imlaa/lesson/alif_verb_lesson_pages.dart';
import 'package:imlaa/lesson/lesson_complete_screen.dart';
import 'package:imlaa/lesson/lesson_screen.dart';
import 'package:imlaa/lesson/lessons.dart';
import 'package:imlaa/lesson/page_handle.dart';
import 'package:imlaa/lesson/pages/quiz_page.dart';
import 'package:imlaa/services/speech_texts.dart';
import 'package:imlaa/utils/arabic.dart';
import 'package:imlaa/widgets/letter_boxes.dart';

import 'helpers/harness.dart';

/// صفحات «اختر الإجابة» في الدرس بعناوين محطاتها.
Map<String, QuizPage> _quizPages() => {
  for (final spec in buildAlifVerbLessonPages(Random(1)))
    if (spec.builder(PageHandle()) case final QuizPage q) spec.title: q,
};

void main() {
  group('محتوى درس الألف اللّينة في الأفعال', () {
    test('تاء الفاعل تقلب الألف ياءً أو واوًا', () {
      expect(alifVerb('بكى').withTa, 'بكيت');
      expect(alifVerb('دعا').withTa, 'دعوت');
      expect(alifVerb('رأى').withTa, 'رأيت');
      expect(alifVerb('بكى').spokenTa, 'بَكَيْتُ');
      expect(alifVerb('دعا').spokenTa, 'دَعَوْتُ');
      expect(alifVerb('بكى').wrong, 'بكا');
      expect(alifVerb('دعا').wrong, 'دعى');
      for (final v in alifVerbs) {
        expect(v.word.characters.length, 3, reason: v.word);
        expect(stripDiacritics(v.spoken), v.word);
        expect(stripDiacritics(v.spokenTa), v.withTa);
        expect(ArabicKeyboard.canType(v.word), isTrue, reason: v.word);
        expect(ArabicKeyboard.canType(v.withTa), isTrue, reason: v.word);
      }
      expect(alifVerbs.map((v) => v.word).toSet().length, alifVerbs.length);
    });

    test('فعل كل جملة في أولها، وكل الأفعال معرّفة', () {
      for (final s in [
        verbExampleSentence,
        ...verbTableSentences,
        ...verbChoiceSentences,
      ]) {
        final words = stripDiacritics(s.spoken).split(' ');
        expect(words.first, s.verb, reason: s.spoken);
        expect(words.where((w) => w == s.verb).length, 1, reason: s.spoken);
        alifVerb(s.verb);
      }
      expect(verbTableSentences.length, 12);
      expect(verbChoiceSentences.length, 12);
      for (final (w, _) in addTaItems) {
        alifVerb(w);
      }
    });

    test('كل نصوص الدرس المنطوقة في قائمة التسجيلات', () {
      final texts = allSpeechTexts();
      for (final s in [
        verbRuleSpeech,
        verbExampleSpeech,
        for (final v in alifVerbs) ...[v.spoken, v.spokenTa],
        for (final s in [...verbTableSentences, ...verbChoiceSentences])
          s.spoken,
      ]) {
        expect(texts, contains(s));
      }
    });

    test('الدرس الخامس في المسار بتسع محطات، يبدأ بالقاعدة', () {
      expect(lessons.map((l) => l.id).elementAt(3), alifVerbLessonId);
      expect(lessonById(alifVerbLessonId).unit, 5);
      final pages = buildAlifVerbLessonPages();
      expect(pages.length, 9);
      expect(pages.first.title, 'القاعدة');
    });
  });

  group('أسئلة التمارين', () {
    final pages = _quizPages();

    test('كل إجابة صحيحة بين الخيارات', () {
      for (final MapEntry(key: name, value: page) in pages.entries) {
        for (var attempt = 0; attempt < 6; attempt++) {
          for (final r in page.build(Random(attempt), attempt)) {
            for (final item in r.items) {
              if (item.writes) continue;
              expect(item.options, containsAll(item.answers), reason: name);
              expect(item.answers.length, 1, reason: name);
            }
          }
        }
      }
    });

    test('أضف التاء: تسعة أفعال في ثلاث جولات بترتيب الكتاب', () {
      final first = pages['أضف التاء']!.build(Random(0), 0);
      expect(first.length, 3);
      expect(first.every((r) => r.items.length == 3), isTrue);
      expect(first.first.items.first.prompt, 'عوى + تاء الفاعل =');
      expect(first.first.items.first.answer, 'عويت');
      expect(first.first.items[1].answer, 'رأى');
      final again = pages['أضف التاء']!.build(Random(2), 1);
      expect(again.expand((r) => r.items).length, 9);
    });

    test('أكمل الجدول: ١٢ جملة، والفراغ ست مرات في الفعل', () {
      for (var a = 0; a < 4; a++) {
        final rounds = pages['أكمل الجدول']!.build(Random(a), a);
        expect(rounds.length, 12);
        final verbs = {for (final s in verbTableSentences) s.verb};
        expect(
          rounds.where((r) => verbs.contains(r.items.first.answer)).length,
          6,
        );
        for (final r in rounds) {
          expect(r.sentence, contains('……'));
          expect(r.items.length, 3);
        }
      }
    });

    test('اختر الكلمة: ثلاث جولات من أربع جمل', () {
      final rounds = pages['اختر الكلمة']!.build(Random(0), 0);
      expect(rounds.length, 3);
      expect(rounds.every((r) => r.items.length == 4), isTrue);
      expect(rounds.first.items.first.prompt, '…… العامل المنزل');
      expect(rounds.first.items.first.options.toSet(), {'بنى', 'بنا'});
    });
  });

  group('درس الألف اللّينة في الأفعال في التطبيق', () {
    setUpAll(loadAppFonts);
    setUp(mockPlatform);

    testWidgets('الدرس كاملًا من القاعدة إلى «إنهاء» مع خطأ', (t) async {
      final pages = buildAlifVerbLessonPages(Random(3));
      final state = await pumpScreen(
        t,
        LessonScreen(lessonId: 'qa', title: alifVerbLessonTitle, pages: pages),
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

      Future<void> tapIn(Finder f) async {
        await t.ensureVisible(f);
        await t.pumpAndSettle();
        await t.tap(f);
        await t.pump();
      }

      var mistakes = 0;
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
              if (item.writes) {
                await t.enterText(
                  inPage(find.byKey(ValueKey('q$k-field'))),
                  wrong && k == 0 ? 'خطأ' : item.answer!,
                );
                continue;
              }
              for (final a in item.answers) {
                // جملة السؤال لها شريط تمرير خاص، فالبحث في الشاشة كلها.
                await tapIn(find.byKey(ValueKey('q$k-$a')).last);
              }
            }
            await tapIn(inPage(find.text('إدخال')).last);
            await t.pump(const Duration(milliseconds: 3600));
            await t.pumpAndSettle();
            if (wrong) {
              mistakes++;
              await t.tapAt(const Offset(20, 20));
              await t.pumpAndSettle();
            }
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
  });
}
