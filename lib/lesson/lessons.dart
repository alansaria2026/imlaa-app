import 'package:flutter/widgets.dart';

import '../data/alif_lesson.dart';
import '../data/alif_verb_lesson.dart';
import '../data/hamza_lesson.dart';
import '../data/lam_lesson.dart';
import '../data/taa_lesson.dart';
import 'alif_lesson_pages.dart';
import 'alif_rule_content.dart';
import 'alif_verb_lesson_pages.dart';
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

/// الدروس الجاهزة بترتيب المسار؛ [LessonDef.unit] رقم الدرس في المسار كله
/// مع الدروس القادمة ([upcomingLessons]).
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
    id: alifLessonId,
    title: alifLessonTitle,
    unit: 4,
    build: buildAlifLessonPages,
    rule: AlifRuleContent(),
  ),
  const LessonDef(
    id: alifVerbLessonId,
    title: alifVerbLessonTitle,
    unit: 5,
    build: buildAlifVerbLessonPages,
    rule: AlifVerbRuleContent(),
  ),
  const LessonDef(
    id: hamzaLessonId,
    title: hamzaLessonTitle,
    unit: 6,
    build: buildHamzaLessonPages,
    rule: HamzaRuleContent(),
  ),
];

/// دروس المسار التي لم تُبنَ بعد: (رقمها في المسار، عنوانها)، وتظهر «قريبًا».
const upcomingLessons = [
  (3, 'التاء المربوطة والهاء'),
  (7, 'الهمزة المتوسطة'),
  (8, 'الهمزة المتطرفة'),
  (9, 'واو الجماعة'),
  (10, 'الواو الأصلية في الفعل'),
  (11, 'واو الجمع'),
  (12, 'اتصال (ما) بـ(كل)'),
  (13, 'اتصال (ما) بحروف الجر'),
  (14, 'اتصال (مِن) بـ(مَن)'),
  (15, 'اتصال (عن) بـ(مَن)'),
];

/// الدرس بمعرّفه، أو درس اللام إن لم يوجد.
LessonDef lessonById(String id) =>
    lessons.firstWhere((l) => l.id == id, orElse: () => lessons.first);
