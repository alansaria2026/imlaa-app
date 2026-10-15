import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imlaa/data/hamza_lesson.dart';
import 'package:imlaa/lesson/hamza_lesson_pages.dart';
import 'package:imlaa/lesson/hamza_rule_content.dart';
import 'package:imlaa/lesson/lesson_screen.dart';
import 'package:imlaa/lesson/lessons.dart';
import 'package:imlaa/lesson/page_handle.dart';
import 'package:imlaa/lesson/pages/quiz_page.dart';
import 'package:imlaa/screens/home_screen.dart';
import 'package:imlaa/services/speech_texts.dart';
import 'package:imlaa/widgets/common.dart';

import 'helpers/harness.dart';

/// صفحات «اختر الإجابة» في الدرس بعناوين محطاتها.
Map<String, QuizPage> _quizPages() => {
  for (final spec in buildHamzaLessonPages(Random(1)))
    if (spec.builder(PageHandle()) case final QuizPage q) spec.title: q,
};

void main() {
  group('محتوى درس الهمزة', () {
    test('القاعدة العامة (ص ١٣ مكرر)', () {
      String row(Tense t) => [
        for (final w in Weight.values) hamzaOf(t, w) == Hamza.qat ? 'ق' : 'و',
      ].join();
      expect(row(Tense.present), 'قققق');
      expect(row(Tense.past), 'ققوو');
      expect(row(Tense.imperative), 'وقوو');
    });

    test('صورة همزة كل فعل توافق القاعدة، والفعل في جملته', () {
      for (final s in allVerbSentences) {
        final words = s.text
            .replaceAll(RegExp('[؟()]'), '')
            .split(' ')
            .where((w) => w.isNotEmpty);
        expect(words, contains(s.verb), reason: s.spoken);
        final first = s.verb[0];
        expect(
          s.hamza == Hamza.qat ? 'أإ'.contains(first) : first == 'ا',
          isTrue,
          reason: '${s.verb}: ${s.hamza.label}',
        );
      }
    });

    test('اثنتا عشرة قاعدة مختلفة، ولكلٍّ مثال وجمل تطبيق من نوعها', () {
      expect(verbCombos.length, 12);
      expect({for (final c in verbCombos) (c.tense, c.weight)}.length, 12);
      for (final c in verbCombos) {
        expect(c.practice.length, greaterThanOrEqualTo(3), reason: c.rule);
        for (final s in [c.example, ...c.practice]) {
          expect((s.tense, s.weight), (c.tense, c.weight), reason: s.spoken);
        }
        expect(
          {for (final s in c.practice) s.verb + s.text}.length,
          c.practice.length,
        );
      }
      expect(verbReviewSentences.length, 12);
    });

    test('أوزان أفعال التمرين = عدد حروف الماضي', () {
      for (final (present, past, weight) in weightVerbs) {
        expect(past.length, weight.index + 3, reason: present);
        expect(present.startsWith('ي'), isTrue, reason: present);
      }
      expect(weightVerbs.map((v) => v.$1).toSet().length, weightVerbs.length);
    });

    test('المصدر: ألف قبل آخر الفعل، وكلاهما يبدأ بهمزة وصل', () {
      for (final (verb, masdar) in masdarPairs) {
        expect(verb[0], 'ا', reason: verb);
        expect(
          masdar,
          '${verb.substring(0, verb.length - 1)}ا${verb[verb.length - 1]}',
        );
        expect(masdarDistractor(verb), isNot(masdar));
      }
      expect(masdarPairs.toSet().length, masdarPairs.length);
    });

    test('الإجابة المكتوبة تراعي صورة الهمزة', () {
      expect(sameWriting('السكين', 'السكين'), isTrue);
      expect(sameWriting(' استهلكَ ', 'استهلك'), isTrue);
      expect(sameWriting('إستهلك', 'استهلك'), isFalse);
      expect(sameWriting('ألسكين', 'السكين'), isFalse);
    });

    test('كل نصوص الدرس المنطوقة في قائمة التسجيلات', () {
      final texts = allSpeechTexts();
      for (final s in allVerbSentences) {
        expect(texts, contains(s.spoken));
      }
      expect(texts, containsAll([hamzaRuleSpeech, alRuleSpeech]));
    });

    test('الدرس الثالث في المسار بإحدى وثلاثين محطة', () {
      expect(lessons.map((l) => l.id).elementAt(2), hamzaLessonId);
      expect(lessonById(hamzaLessonId).unit, 3);
      expect(buildHamzaLessonPages().length, 31);
    });
  });

  group('أسئلة التمارين', () {
    final pages = _quizPages();

    test('كل إجابة صحيحة بين الخيارات، والاختيار المفرد له إجابة واحدة', () {
      for (final MapEntry(key: name, value: page) in pages.entries) {
        for (var attempt = 0; attempt < 6; attempt++) {
          final rounds = page.build(Random(attempt), attempt);
          expect(rounds, isNotEmpty, reason: name);
          for (final r in rounds) {
            for (final item in r.items) {
              if (item.writes) {
                expect(item.answer, isNotEmpty, reason: name);
                continue;
              }
              expect(item.options.toSet().length, item.options.length);
              expect(item.options, containsAll(item.answers), reason: name);
              expect(item.answers, isNotEmpty, reason: name);
              if (!item.multi) expect(item.answers.length, 1, reason: name);
            }
          }
        }
      }
    });

    test('قطع أم وصل؟ عشرة أسئلة: خمس قطع وخمس وصل، وأولها «أكتب»', () {
      final page = pages['قطع أم وصل؟']!;
      for (var attempt = 0; attempt < 5; attempt++) {
        final rounds = page.build(Random(attempt), attempt);
        expect(rounds.length, 10);
        final answers = [for (final r in rounds) r.items.single.answers.single];
        expect(answers.where((a) => a == Hamza.qat.label).length, 5);
        expect({for (final r in rounds) r.sentence}.length, 10);
        if (attempt == 0) expect(rounds.first.mark, 'اكتب');
        // الهمزة مخفية في السؤال، وتظهر في الجملة بعد الإجابة.
        for (final r in rounds) {
          expect('أإ'.contains(r.mark![0]), isFalse, reason: r.mark);
          expect(r.sentence, contains(r.mark));
          expect(r.answerSentence, isNotNull);
        }
      }
    });

    test('ما وزنه؟ عشرون فعلًا مختلفًا، وكل جولة تشمل الأوزان الأربعة', () {
      final page = pages['ما وزنه؟']!;
      for (var attempt = 0; attempt < 5; attempt++) {
        final rounds = page.build(Random(attempt), attempt);
        expect(rounds.length, 5);
        expect(rounds.every((r) => r.items.length == 4), isTrue);
        final prompts = [
          for (final r in rounds)
            for (final i in r.items) i.prompt,
        ];
        expect(prompts.toSet().length, 20);
        // أول جولة في أول محاولة أفعال الكتاب كما هي (فيها خماسيان).
        for (final r in attempt == 0 ? rounds.skip(1) : rounds) {
          expect(
            {for (final i in r.items) i.answers.single}.length,
            4,
            reason: '$attempt',
          );
        }
      }
    });

    test('صنّف الفعل: اثنتا عشرة جملة بثلاث جولات، أولها جمل الكتاب', () {
      final page = pages['صنّف الفعل']!;
      final first = page.build(Random(0), 0);
      expect(
        [for (final r in first) r.mark],
        [
          for (final s in verbReviewSentences) ...[s.verb, s.verb, s.verb],
        ],
      );
      expect(
        [for (final r in first.take(3)) r.items.single.prompt],
        ['زمن الفعل:', 'الفعل في الماضي:', 'وزن الفعل:'],
      );
      // «هل أعتمد على نفسي؟»: مضارع، ماضيه «اعتمد»، خماسي.
      expect(
        [for (final r in first.skip(3).take(3)) r.items.single.answers.single],
        ['فعل مضارع', 'اعتمد', 'خماسي'],
      );
      expect(page.build(Random(1), 1).length, 36);
    });

    test('الماضي من كل فعل بعدد حروف وزنه', () {
      const letters = {
        Weight.three: 3,
        Weight.four: 4,
        Weight.five: 5,
        Weight.six: 6,
      };
      for (final s in allVerbSentences) {
        expect(s.past.length, letters[s.weight], reason: s.verb);
        if (s.tense == Tense.past) expect(s.past, s.verb);
      }
      final past = {for (final s in allVerbSentences) s.verb: s.past};
      expect(past['أستضيف'], 'استضاف');
      expect(past['اكتب'], 'كتب');
      expect(past['أكرم'], 'أكرم');
      expect(past['أشاهد'], 'شاهد');
    });

    test('حوّل: عشر كلمات مختلفة، وأولها كلمات الكتاب', () {
      final page = pages['حوّل']!;
      for (var attempt = 0; attempt < 5; attempt++) {
        final rounds = page.build(Random(attempt), attempt);
        final answers = [
          for (final r in rounds)
            for (final i in r.items) i.answer,
        ];
        expect(answers.length, 10);
        expect(answers.toSet().length, 10);
      }
      final book = page.build(Random(0), 0);
      expect(
        book.first.items.map((i) => i.prompt),
        containsAll(['افتتاح:', 'استهلاك:', 'استثمار:']),
      );
    });

    test('حلّل الفعل: ثلاث جولات بلا مثال محلول، ثم جمل القاعدة نفسها', () {
      for (final c in verbCombos) {
        final page =
            pages['${switch (c.tense) {
              Tense.past => 'ماضٍ',
              Tense.present => 'مضارع',
              Tense.imperative => 'أمر',
            }} ${c.weight.label}']!;
        final first = page.build(Random(0), 0);
        expect(first.map((r) => r.mark), [
          c.example.verb,
          c.practice[0].verb,
          c.practice[1].verb,
        ]);
        expect(first.every((r) => r.items.length == 3), isTrue);
        final all = {
          for (final s in [c.example, ...c.practice]) s.verb,
        };
        for (var a = 1; a < 6; a++) {
          final again = page.build(Random(a), a);
          expect(again.length, 3);
          expect(all.containsAll(again.map((r) => r.mark)), isTrue);
          expect(again.map((r) => r.mark).toSet().length, 3);
        }
      }
    });
  });

  group('درس الهمزة في التطبيق', () {
    setUpAll(loadAppFonts);
    setUp(mockPlatform);

    Finder inPage(Finder f) =>
        find.descendant(of: find.byType(QuizPage), matching: f);

    Future<void> open(WidgetTester t, int page) => pumpScreen(
      t,
      LessonScreen(
        lessonId: hamzaLessonId,
        title: hamzaLessonTitle,
        pages: buildHamzaLessonPages(Random(page)),
        initialPage: page,
      ),
    );

    VerbSentence shown(WidgetTester t) {
      final w = t.widget<MarkedSentence>(inPage(find.byType(MarkedSentence)));
      return allVerbSentences.firstWhere(
        (s) =>
            (w.mark == s.verb && w.text.contains(s.text)) ||
            (w.mark == s.hiddenVerb && w.text.contains(s.hiddenText)),
      );
    }

    testWidgets('الوحدة الثالثة مفتوحة في مسار التعلّم', (t) async {
      final state = await pumpScreen(t, const HomeScreen());
      final card = find.byKey(const ValueKey('unit-$hamzaLessonId'));
      await t.ensureVisible(card);
      expect(
        find.descendant(of: card, matching: find.text('قريبًا')),
        findsNothing,
      );
      await t.tap(card);
      await t.pumpAndSettle();
      expect(state.selectedLesson, hamzaLessonId);
      expect(find.text('قطع أم وصل؟'), findsOneWidget);
    });

    testWidgets('قطع أم وصل؟ الخطأ يُظهر القاعدة ثم يبدأ من جديد', (t) async {
      await open(t, 1);
      final first = shown(t);
      expect(first.verb, 'أكتب');
      expect(find.text('همزة الفعل «اكتب»:'), findsOneWidget);
      // الجملة تُسمع عند ظهورها.
      expect(lastSpoken, first.spoken);
      await t.tap(inPage(find.text(Hamza.wasl.label)));
      await t.pump();
      await t.tap(inPage(find.text('إدخال')));
      await t.pump();
      expect(find.textContaining('إجابة غير صحيحة'), findsOneWidget);
      await t.pump(const Duration(seconds: 2));
      await t.pumpAndSettle();
      // انبثقت القاعدة الذهبية.
      expect(find.text('القاعدة الذهبية'), findsWidgets);
      await t.tapAt(const Offset(20, 20));
      await t.pumpAndSettle();
      // من البداية بجمل جديدة.
      expect(scoreLabel('بقيت ١٠ أسئلة'), findsOneWidget);

      for (var i = 0; i < 10; i++) {
        final s = shown(t);
        await t.tap(inPage(find.text(s.hamza.label)));
        await t.pump();
        await t.tap(inPage(find.text('إدخال')));
        await t.pump();
        // بعد الإجابة تظهر الكتابة الصحيحة للفعل.
        expect(
          t.widget<MarkedSentence>(inPage(find.byType(MarkedSentence))).mark,
          s.verb,
        );
        await t.pumpAndSettle(const Duration(seconds: 2));
        if (find.byType(PageDoneMessage).evaluate().isEmpty) {
          expect(lastSpoken, shown(t).spoken);
        }
      }
      expect(find.byType(PageDoneMessage), findsOneWidget);
    });

    testWidgets('حلّل الفعل: ثلاث جولات مباشرة بلا مثال محلول', (t) async {
      final c = verbCombos.first;
      await open(t, 11);
      expect(find.text('طبّق الآن'), findsNothing);
      for (final s in [c.example, c.practice[0], c.practice[1]]) {
        expect(shown(t).verb, s.verb);
        for (final label in [c.tense.label, c.weight.label, c.hamza.label]) {
          await t.tap(inPage(find.text(label)));
          await t.pump();
        }
        await t.tap(nextButton());
        await t.pumpAndSettle(const Duration(seconds: 2));
      }
      expect(find.byType(PageDoneMessage), findsOneWidget);
    });

    testWidgets('الكتابة تراعي الهمزة: «أسكين» خطأ', (t) async {
      await open(t, 6);
      await t.tap(inPage(find.text('اسم')));
      await t.tap(inPage(find.text('وصل')));
      await t.enterText(inPage(find.byType(TextField)), 'ألسكين');
      await t.tap(inPage(find.text('إدخال')));
      await t.pump();
      expect(find.textContaining('إجابة غير صحيحة'), findsOneWidget);
      await t.pump(const Duration(seconds: 2));
      await t.pumpAndSettle();
      await t.tapAt(const Offset(20, 20));
      await t.pumpAndSettle();
      // كلمة جديدة غير «سكين».
      final prompt = t
          .widgetList<Text>(inPage(find.byType(Text)))
          .map((w) => w.data ?? '')
          .firstWhere((s) => s.contains('+ ال التعريف'));
      final noun = prompt.split(' ')[1];
      expect(noun, isNot('سكين'));
      await t.tap(inPage(find.text('اسم')));
      await t.tap(inPage(find.text('وصل')));
      await t.enterText(inPage(find.byType(TextField)), 'ال$noun');
      await t.tap(inPage(find.text('إدخال')));
      await t.pumpAndSettle(const Duration(seconds: 2));
      expect(find.byType(PageDoneMessage), findsOneWidget);
    });

    testWidgets('فتح القاعدة بين جولتين يعيد الأسئلة دون تخطي جولة', (t) async {
      await open(t, 1);
      await t.tap(inPage(find.text(shown(t).hamza.label)));
      await t.tap(inPage(find.text('إدخال')));
      await t.pump();
      expect(scoreLabel('بقيت ٩ أسئلة'), findsOneWidget);
      // قبل انتقال الجولة: القائمة ← القاعدة.
      await t.tap(find.byTooltip('القائمة'));
      await t.pumpAndSettle();
      await t.tap(find.text('القاعدة').last);
      await t.pumpAndSettle();
      await t.tapAt(const Offset(20, 20));
      await t.pumpAndSettle(const Duration(seconds: 2));
      expect(scoreLabel('بقيت ١٠ أسئلة'), findsOneWidget);
      var answered = 0;
      while (find.byType(PageDoneMessage).evaluate().isEmpty) {
        expect(++answered, lessThanOrEqualTo(10));
        await t.tap(inPage(find.text(shown(t).hamza.label)));
        await t.tap(inPage(find.text('إدخال')));
        await t.pumpAndSettle(const Duration(seconds: 2));
      }
      expect(answered, 10);
    });

    testWidgets('الصفحة الأولى: القاعدة الذهبية مخفية في «مساعدة»', (t) async {
      await open(t, 0);
      expect(find.text('أ   إ'), findsOneWidget);
      expect(find.text('القاعدة الذهبية'), findsNothing);
      await t.tap(find.byTooltip('القائمة'));
      await t.pumpAndSettle();
      await t.tap(find.text('مساعدة').last);
      await t.pumpAndSettle();
      expect(find.text('تلميح'), findsOneWidget);
      expect(find.text('القاعدة الذهبية'), findsOneWidget);
    });

    testWidgets(
      '(ال) التعريف: الأمثلة في الصفحة التالية و«تذكّر» في «مساعدة»',
      (t) async {
        await open(t, 3);
        expect(find.text('تذكّر'), findsNothing);
        expect(find.byType(AlBox), findsNothing);
        await t.tap(find.byTooltip('القائمة'));
        await t.pumpAndSettle();
        await t.tap(find.text('مساعدة').last);
        await t.pumpAndSettle();
        expect(find.text('تذكّر'), findsOneWidget);
      },
    );

    testWidgets('صفحة إضافة (ال) التعريف إلى الأسماء', (t) async {
      await open(t, 4);
      expect(find.text('إضافة (ال) التعريف إلى الأسماء'), findsOneWidget);
      expect(find.byType(AlBox), findsNWidgets(alExampleWords.length));
    });

    testWidgets('وزن الفعل: الأمثلة في جدول في الصفحة التالية', (t) async {
      await open(t, 7);
      expect(find.byType(Table), findsNothing);
      expect(find.text('أمثلة'), findsNothing);
    });

    testWidgets('همزة الأسماء: القواعد، والأمثلة في جدول من زر «إضاءة»', (
      t,
    ) async {
      final i = buildHamzaLessonPages(
        Random(0),
      ).indexWhere((p) => p.title == 'همزة الأسماء');
      await open(t, i);
      expect(find.byType(Table), findsNothing);
      await t.tap(find.byKey(const ValueKey('noun-hamza-light')));
      await t.pumpAndSettle();
      expect(find.byType(NounHamzaTable), findsOneWidget);
      expect(find.text('💡 إضاءة'), findsNWidgets(2)); // الزر وعنوان النافذة
    });

    testWidgets('أمثلة الوزن في جدول', (t) async {
      await open(t, 8);
      expect(find.byType(Table), findsOneWidget);
      expect(find.text('تحويل للماضي'), findsOneWidget);
      expect(find.text('(ر-ت-ب)'), findsOneWidget);
    });

    testWidgets('حلّل الفعل: «استمع» ينطق جملة الجولة الأولى', (t) async {
      await open(t, 11);
      await t.tap(find.byTooltip('القائمة'));
      await t.pumpAndSettle();
      await t.tap(find.text('استمع').last);
      await t.pumpAndSettle();
      expect(lastSpoken, verbCombos.first.example.spoken);
    });

    testWidgets('اختيار متعدد: تُختار الإجابات الثلاث معًا', (t) async {
      await open(t, 23);
      for (var i = 0; i < 5; i++) {
        final s = shown(t);
        for (final label in [
          s.tense.label,
          'فعل ${s.weight.label}',
          s.hamza.label,
        ]) {
          await t.tap(inPage(find.text(label)));
          await t.pump();
        }
        await t.tap(inPage(find.text('إدخال')));
        await t.pumpAndSettle(const Duration(seconds: 2));
      }
      expect(find.byType(PageDoneMessage), findsOneWidget);
    });
  });
}
