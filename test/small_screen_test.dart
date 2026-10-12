import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:imlaa/lesson/lesson_screen.dart';
import 'package:imlaa/lesson/lessons.dart';
import 'package:imlaa/screens/home_screen.dart';

import 'helpers/harness.dart';

/// كل صفحات الدروس ونافذة القاعدة على جوال صغير (٣٢٠ × ٥٦٧) بخط الجهاز
/// مكبّرًا، مع لوحة مفاتيح الجهاز ومن دونها: لا تجاوز لحدود الشاشة.
void main() {
  setUpAll(loadAppFonts);
  setUp(mockPlatform);

  const small = Size(960, 1700);

  Future<void> bigText(WidgetTester t, double scale) async {
    t.platformDispatcher.textScaleFactorTestValue = scale;
    addTearDown(t.platformDispatcher.clearTextScaleFactorTestValue);
  }

  for (final scale in [1.3, 1.6, 2.0]) {
    for (final lesson in lessons) {
      final n = lesson.build().length;
      for (var i = 0; i < n; i++) {
        testWidgets('${lesson.id} ص ${i + 1}: خط ×$scale', (t) async {
          await bigText(t, scale);
          await pumpScreen(
            t,
            LessonScreen(
              lessonId: 'qa',
              title: lesson.title,
              pages: lesson.build(),
              initialPage: i,
            ),
            size: small,
          );
          await t.tap(find.byTooltip('القائمة'));
          await t.pumpAndSettle();
          await t.tap(find.text('القاعدة').last);
          await t.pumpAndSettle();
          await t.tapAt(const Offset(10, 10));
          await t.pumpAndSettle();

          // لوحة مفاتيح الجهاز مفتوحة (٢٦٠ نقطة).
          t.view.viewInsets = const FakeViewPadding(bottom: 780);
          addTearDown(t.view.resetViewInsets);
          await t.pumpAndSettle();
        });
      }
    }

    testWidgets('مسار التعلّم بالوحدتين: خط ×$scale', (t) async {
      await bigText(t, scale);
      final state = await pumpScreen(t, const HomeScreen(), size: small);
      for (final lesson in lessons) {
        state.selectLesson(lesson.id);
        await t.pumpAndSettle();
        await t.drag(find.byType(CustomScrollView), const Offset(0, -700));
        await t.pumpAndSettle();
        await t.drag(find.byType(CustomScrollView), const Offset(0, 1400));
        await t.pumpAndSettle();
      }
    });
  }
}
