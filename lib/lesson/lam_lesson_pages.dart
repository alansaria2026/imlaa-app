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
  final addRounds = _groupsOfThree(addWords);

  final sentences = [...challengeSentences]..shuffle(rnd);

  return [
    LessonPageSpec(
      tag: 'مثال القاعدة',
      title: 'القاعدة',
      emoji: '📖',
      needsCompletion: false,
      builder: (h) => RulePage(handle: h),
    ),
    LessonPageSpec(
      tag: 'مثال',
      title: 'أمثلة',
      emoji: '💡',
      needsCompletion: false,
      builder: (h) => ExamplesPage(handle: h),
    ),
    LessonPageSpec(
      tag: 'تطبيق',
      title: 'أضف (الـ)',
      emoji: '➕',
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
      title: 'سمِّ الصورة',
      emoji: '🖼️',
      builder: (h) => PicturePage(handle: h),
    ),
    LessonPageSpec(
      tag: 'تحدي',
      title: 'تحدي الاستماع',
      emoji: '🎧',
      builder: (h) => ChallengePage(handle: h, sentences: sentences),
    ),
    LessonPageSpec(
      tag: 'تطبيق',
      title: 'احذف (الـ)',
      emoji: '✂️',
      builder: (h) => EquationPage(
        handle: h,
        rounds: _groupsOfThree(removeAlWords),
        add: false,
        tag: 'تطبيق',
        title: 'احذف (الـ) من الكلمة واكتب الناتج',
        strict: true,
      ),
    ),
  ];
}

/// ثلاثة أسئلة في كل شاشة (تعليمات ص ٤).
List<List<String>> _groupsOfThree(List<String> words) => [
  for (var i = 0; i < words.length; i += 3)
    words.sublist(i, min(i + 3, words.length)),
];
