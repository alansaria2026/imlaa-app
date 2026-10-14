import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imlaa/data/hamza_lesson.dart';
import 'package:imlaa/lesson/hamza_lesson_pages.dart';
import 'package:imlaa/lesson/lesson_complete_screen.dart';
import 'package:imlaa/lesson/lesson_screen.dart';
import 'package:imlaa/lesson/pages/equation_page.dart';
import 'package:imlaa/lesson/pages/quiz_page.dart';

import 'helpers/harness.dart';

/// الطالب يمر بدرس الهمزة كاملًا بالترتيب، بالضغط على الأزرار والكتابة في
/// الحقول، مع خطأ في أول تمرين، حتى «إنهاء».
void main() {
  setUpAll(loadAppFonts);
  setUp(mockPlatform);

  testWidgets('درس الهمزة كاملًا من القاعدة إلى «إنهاء»', (t) async {
    final pages = buildHamzaLessonPages(Random(7));
    final state = await pumpScreen(
      t,
      LessonScreen(lessonId: 'qa', title: hamzaLessonTitle, pages: pages),
    );

    // الصفحة الظاهرة الآن (الصفحات السابقة تبقى في الشجرة خارج الشاشة).
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

    Future<void> enter() async {
      final button = inPage(find.text('إدخال')).last;
      await t.ensureVisible(button);
      await t.pumpAndSettle();
      await t.tap(button);
      await t.pump();
    }

    /// يجيب عن الجولة الظاهرة كلها بالضغط على الأزرار والكتابة.
    Future<void> answerRound({bool wrongFirst = false}) async {
      final round = t
          .state<QuizPageState>(inPage(find.byType(QuizPage)))
          .currentRound;
      for (final (i, item) in round.items.indexed) {
        if (item.writes) {
          await t.enterText(
            inPage(find.byKey(ValueKey('q$i-field'))),
            item.answer!,
          );
          continue;
        }
        final picks = wrongFirst && i == 0
            ? [item.options.firstWhere((o) => !item.answers.contains(o))]
            : item.answers;
        for (final a in picks) {
          final chip = inPage(find.byKey(ValueKey('q$i-$a'))).last;
          await t.ensureVisible(chip);
          await t.pumpAndSettle();
          await t.tap(chip);
          await t.pump();
        }
      }
      await enter();
    }

    var mistakes = 0;
    for (var i = 0; i < pages.length; i++) {
      await t.pumpAndSettle();
      if (inPage(find.byType(QuizPage)).evaluate().isNotEmpty) {
        var guard = 0;
        while (!done(i)) {
          expect(++guard, lessThan(40), reason: 'الصفحة ${i + 1} لا تنتهي');
          // خطأ واحد في أول تمرين: تنبثق القاعدة ثم تبدأ الأسئلة من جديد.
          final wrong = mistakes == 0;
          await answerRound(wrongFirst: wrong);
          await settle();
          if (wrong) {
            mistakes++;
            expect(find.textContaining('القاعدة'), findsWidgets);
            await t.tapAt(const Offset(20, 20));
            await t.pumpAndSettle();
          }
        }
      } else if (inPage(find.byType(EquationPage)).evaluate().isNotEmpty) {
        final words = {...hamzaAlMoonWords, ...hamzaAlSunWords};
        var guard = 0;
        while (!done(i)) {
          expect(++guard, lessThan(20), reason: 'الصفحة ${i + 1} لا تنتهي');
          final shown = [
            for (final w in t.widgetList<Text>(inPage(find.byType(Text))))
              w.data ?? w.textSpan?.toPlainText() ?? '',
          ].where(words.contains).toList();
          expect(shown, isNotEmpty, reason: 'الصفحة ${i + 1}');
          final fields = inPage(find.byType(TextField));
          for (var k = 0; k < shown.length; k++) {
            await t.enterText(fields.at(k), 'ال${shown[k]}');
          }
          await enter();
          await settle();
        }
      }
      expect(
        done(i) || !pages[i].needsCompletion,
        isTrue,
        reason: 'الصفحة ${i + 1}: ${pages[i].title}',
      );
      if (i < pages.length - 1) {
        await t.tap(nextButton());
        await t.pump();
      }
    }

    expect(mistakes, 1);
    expect(find.text('إنهاء'), findsOneWidget);
    await t.tap(find.text('إنهاء'));
    await t.pumpAndSettle();
    expect(find.byType(LessonCompleteScreen), findsOneWidget);
    expect(state.lessonsCompleted, 1);
    expect(state.points, greaterThan(0));
  });

  testWidgets('كل تمارين الدرس: «إدخال» ظاهر في جوال عرضه ٣٦٠ دون تمرير', (
    t,
  ) async {
    final n = buildHamzaLessonPages(Random(0)).length;
    for (var i = 0; i < n; i++) {
      await pumpScreen(
        t,
        LessonScreen(
          key: ValueKey(i),
          lessonId: 'qa',
          title: hamzaLessonTitle,
          pages: buildHamzaLessonPages(Random(i)),
          initialPage: i,
        ),
      );
      final enter = find.text('إدخال').hitTestable();
      if (find.byType(QuizPage).evaluate().isEmpty &&
          find.byType(EquationPage).evaluate().isEmpty) {
        continue;
      }
      expect(enter, findsOneWidget, reason: 'الصفحة ${i + 1}');
      expect(
        t.getRect(enter).bottom,
        lessThan(t.getRect(nextButton()).top),
        reason: 'الصفحة ${i + 1}: «إدخال» تحت أزرار التنقل',
      );
    }
  });
}
