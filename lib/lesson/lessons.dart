import 'package:flutter/widgets.dart';

import '../data/alif_lesson.dart';
import '../data/hamza_lesson.dart';
import '../data/lam_lesson.dart';
import '../data/taa_lesson.dart';
import 'alif_lesson_pages.dart';
import 'alif_rule_content.dart';
import 'hamza_lesson_pages.dart';
import 'hamza_rule_content.dart';
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
  const LessonDef(
    id: hamzaLessonId,
    title: hamzaLessonTitle,
    unit: 3,
    build: buildHamzaLessonPages,
    rule: HamzaRuleContent(),
  ),
  const LessonDef(
    id: alifLessonId,
    title: alifLessonTitle,
    unit: 4,
    build: buildAlifLessonPages,
    rule: AlifRuleContent(),
  ),
];

/// الدرس بمعرّفه، أو درس اللام إن لم يوجد.
LessonDef lessonById(String id) =>
    lessons.firstWhere((l) => l.id == id, orElse: () => lessons.first);
