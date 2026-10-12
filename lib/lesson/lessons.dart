import 'package:flutter/widgets.dart';

import '../data/lam_lesson.dart';
import '../data/taa_lesson.dart';
import 'lam_lesson_pages.dart';
import 'page_handle.dart';
import 'taa_lesson_pages.dart';
import 'taa_rule_content.dart';

/// درس في مسار التعلّم.
class LessonDef {
  const LessonDef({
    required this.id,
    required this.title,
    required this.unit,
    required this.build,
    this.rule,
  });

  final String id;
  final String title;
  final int unit;

  /// يبني صفحات الدرس من جديد (بكلمات مخلوطة) عند كل فتح.
  final List<LessonPageSpec> Function() build;

  /// محتوى نافذة «القاعدة»؛ null لقاعدة اللام القمرية والشمسية.
  final Widget? rule;
}

final lessons = [
  const LessonDef(
    id: lamLessonId,
    title: lamLessonTitle,
    unit: 1,
    build: buildLamLessonPages,
  ),
  const LessonDef(
    id: taaLessonId,
    title: taaLessonTitle,
    unit: 2,
    build: buildTaaLessonPages,
    rule: TaaRuleContent(),
  ),
];

/// الدرس بمعرّفه، أو درس اللام إن لم يوجد.
LessonDef lessonById(String id) =>
    lessons.firstWhere((l) => l.id == id, orElse: () => lessons.first);
