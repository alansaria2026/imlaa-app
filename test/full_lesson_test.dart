import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imlaa/data/bi_lesson.dart';
import 'package:imlaa/data/lam_lesson.dart';
import 'package:imlaa/data/li_lesson.dart';
import 'package:imlaa/data/review_lesson.dart';
import 'package:imlaa/lesson/lam_lesson_pages.dart';
import 'package:imlaa/lesson/lesson_complete_screen.dart';
import 'package:imlaa/lesson/lesson_screen.dart';
import 'package:imlaa/lesson/pages/picture_page.dart';

import 'helpers/harness.dart';

/// الطالب يمر بالدرس كاملًا بالترتيب، مع أخطاء في الطريق، حتى «إنهاء».
void main() {
  setUpAll(loadAppFonts);
  setUp(mockPlatform);

  testWidgets('الدرس كاملًا من القاعدة إلى «إنهاء»', (t) async {
    final pages = buildLamLessonPages();
    final state = await pumpScreen(
      t,
      LessonScreen(lessonId: 'qa', title: lamLessonTitle, pages: pages),
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

    List<String> texts() {
      final example = t
          .widgetList<Text>(
            inPage(
              find.descendant(
                of: find.byKey(const ValueKey('example')),
                matching: find.byType(Text),
              ),
            ),
          )
          .toSet();
      return t
          .widgetList<Text>(inPage(find.byType(Text)))
          .where((w) => !example.contains(w))
          .map((w) => w.textSpan?.toPlainText() ?? w.data ?? '')
          .toList();
    }

    Future<void> settle() async {
      await t.pump(const Duration(milliseconds: 3600));
      await t.pumpAndSettle();
    }

    Future<void> next() async {
      await t.pumpAndSettle();
      await t.tap(nextButton());
      await t.pump();
    }

    Future<void> enter() async {
      await t.tap(inPage(find.text('إدخال')));
      await t.pump();
    }

    Future<void> type(String word) async {
      for (final l in word.split('')) {
        await t.tap(inPage(find.text(l)).last);
        await t.pump();
      }
    }

    bool done(int i) => state.isPageDone('qa', i);

    /// تمرين المعادلات: [bank] الكلمات الظاهرة ← الإجابة.
    Future<void> equations(int i, Map<String, String> answers) async {
      var guard = 0;
      while (!done(i)) {
        expect(++guard, lessThan(20), reason: 'الصفحة ${i + 1} لا تنتهي');
        final words = texts().where(answers.containsKey).toList();
        expect(words, isNotEmpty, reason: 'الصفحة ${i + 1}');
        final fields = inPage(find.byType(TextField));
        for (var k = 0; k < words.length; k++) {
          await t.enterText(fields.at(k), answers[words[k]]!);
        }
        await enter();
        await settle();
      }
    }

    /// صفحات المربعات: [answerOf] يعطي الإجابة من آخر نص مسموع.
    Future<void> boxes(int i, String Function() answerOf) async {
      var guard = 0;
      while (!done(i)) {
        expect(++guard, lessThan(20), reason: 'الصفحة ${i + 1} لا تنتهي');
        await type(answerOf());
        if (inPage(find.text('إدخال')).evaluate().isNotEmpty) await enter();
        await settle();
      }
    }

    // ١ القاعدة، ٢ مثال الحذف، ٣ مثال الإضافة: لا تمرين فيها.
    expect(find.text('تعرّف على اللام القمرية واللام الشمسية'), findsOneWidget);
    await next();
    await t.pumpAndSettle();
    expect(find.text('احذف (الـ) من الكلمة'), findsOneWidget);
    await next();
    await t.pumpAndSettle();
    expect(find.text('أضف (الـ) إلى الكلمة'), findsOneWidget);
    await next();
    await t.pumpAndSettle();

    // ٤ أضف (الـ): خطأ أولًا يعيد الكلمات وينقص النتيجة.
    final first = texts().where(addAlWordBank.contains).toList();
    final fields = inPage(find.byType(TextField));
    await t.enterText(fields.at(0), 'خطأ');
    await t.enterText(fields.at(1), 'ال${first[1]}');
    await enter();
    expect(find.textContaining('لا يُسمح بالخطأ'), findsOneWidget);
    await settle();
    await equations(3, {for (final w in addAlWordBank) w: 'ال$w'});
    await next();
    await t.pumpAndSettle();

    // ٥ سمِّ الصورة.
    await boxes(4, () {
      if (inPage(find.byType(FootballPitch)).evaluate().isNotEmpty) {
        return 'الملعب';
      }
      final shown = texts();
      return pictureItems.firstWhere((p) => shown.contains(p.emoji)).answer;
    });
    await next();
    await t.pumpAndSettle();

    // ٦ تحدي الاستماع: الجملة تُشغَّل تلقائيًا.
    var guard = 0;
    while (!done(5)) {
      expect(++guard, lessThan(20));
      final s = challengeSentences.firstWhere((c) => c.spoken == lastSpoken);
      final f = inPage(find.byType(TextField));
      await t.enterText(f.at(0), s.moon);
      await t.enterText(f.at(1), s.sun);
      await enter();
      await settle();
    }
    await next();
    await t.pumpAndSettle();

    // ٧ احذف (الـ).
    await equations(6, {for (final w in removeAlWords) w: w.substring(2)});
    await next();
    await t.pumpAndSettle();

    // ٨ اتصال اللام، ٩ حذف اللام.
    await equations(7, {for (final w in liWordBank) w: liForm(w)});
    await next();
    await t.pumpAndSettle();
    await equations(8, {for (final w in liWordBank) liForm(w): w});
    await next();
    await t.pumpAndSettle();

    // ١٠ استماع اللام.
    final liSpokenMap = {
      for (final w in liWordBank) liSpoken(w): liForm(w),
      for (final s in prepSentences) s.spoken: s.answer,
    };
    await boxes(9, () => liSpokenMap[lastSpoken]!);
    await next();
    await t.pumpAndSettle();

    // ١١ اتصال الباء، ١٢ حذف الباء.
    await equations(10, {for (final w in biWordBank) w: biForm(w)});
    await next();
    await t.pumpAndSettle();
    await equations(11, {for (final w in biWordBank) biForm(w): w});
    await next();
    await t.pumpAndSettle();

    // ١٣ استماع الباء ثم «إنهاء».
    final biSpokenMap = {
      for (final w in biWordBank) biSpoken(w): biForm(w),
      for (final s in prepSentences) s.spoken: s.answer,
    };
    await boxes(12, () => biSpokenMap[lastSpoken]!);
    expect(find.text('إنهاء'), findsOneWidget);
    for (var i = 0; i < pages.length; i++) {
      expect(done(i), isTrue, reason: 'الصفحة ${i + 1}');
    }
    await t.tap(find.text('إنهاء'));
    await t.pumpAndSettle();
    expect(find.byType(LessonCompleteScreen), findsOneWidget);
    expect(state.lessonsCompleted, 1);
    expect(state.points, greaterThan(300));
  });
}
