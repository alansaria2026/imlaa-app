import 'dart:math';

import '../data/lam_lesson.dart';
import 'page_handle.dart';
import 'pages/challenge_page.dart';
import 'pages/equation_page.dart';
import 'pages/intro_pages.dart';
import 'pages/picture_page.dart';

/// صفحات درس اللام بالترتيب، مع خلط الكلمات والجمل في كل مرة.
List<LessonPageSpec> buildLamLessonPages([Random? random]) {
  final rnd = random ?? Random();

  final bank = [...addAlWordBank]..shuffle(rnd);
  final addWords = bank.take(12).toList();
  final addRounds = [
    for (var i = 0; i < addWords.length; i += 3) addWords.sublist(i, i + 3),
  ];

  final sentences = [...challengeSentences]..shuffle(rnd);

  return [
    LessonPageSpec(
      tag: 'مثال القاعدة',
      needsCompletion: false,
      builder: (h) => RulePage(handle: h),
    ),
    LessonPageSpec(
      tag: 'مثال',
      needsCompletion: false,
      builder: (h) => ExamplesPage(handle: h),
    ),
    LessonPageSpec(
      tag: 'تطبيق',
      builder: (h) => EquationPage(
        handle: h,
        rounds: addRounds,
        add: true,
        tag: 'تطبيق',
        title: 'أضف (الـ) إلى الكلمة واكتب الناتج',
        strict: true,
      ),
    ),
    LessonPageSpec(
      tag: 'تطبيق',
      builder: (h) => PicturePage(handle: h),
    ),
    LessonPageSpec(
      tag: 'تحدي',
      builder: (h) => ChallengePage(handle: h, sentences: sentences),
    ),
    LessonPageSpec(
      tag: 'تطبيق',
      builder: (h) => EquationPage(
        handle: h,
        rounds: const [removeAlWords],
        add: false,
        tag: 'تطبيق',
        title: 'احذف (الـ) من الكلمة واكتب الناتج',
      ),
    ),
  ];
}
