import 'dart:math';

import '../data/lam_lesson.dart';
import '../data/bi_lesson.dart';
import '../data/li_lesson.dart';
import 'page_handle.dart';
import 'pages/challenge_page.dart';
import 'pages/equation_page.dart';
import 'bi_rule_content.dart';
import 'li_rule_content.dart';
import 'pages/intro_pages.dart';
import 'pages/li_pages.dart';
import 'pages/picture_page.dart';

/// صفحات درس اللام بالترتيب، مع خلط الكلمات والجمل في كل مرة.
List<LessonPageSpec> buildLamLessonPages([Random? random]) {
  final rnd = random ?? Random();

  final bank = [...addAlWordBank]..shuffle(rnd);
  final addWords = bank.take(12).toList();
  final addRounds = _groupsOfTwo(addWords);

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
      title: 'أضف (الـ)',
      emoji: '✍️',
      builder: (h) => EquationPage(
        handle: h,
        rounds: addRounds,
        op: EquationOp.addAl,
        title: 'أضف (الـ) إلى الكلمة واكتب الناتج',
        strict: true,
      ),
    ),
    LessonPageSpec(
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
      title: 'احذف (الـ)',
      emoji: '✂️',
      builder: (h) => EquationPage(
        handle: h,
        rounds: _groupsOfTwo(removeAlWords),
        op: EquationOp.removeAl,
        title: 'احذف (الـ) من الكلمة واكتب الناتج',
        strict: true,
        showLamType: false,
      ),
    ),
    // اتصال اللام (لِـ) بـ(ال) التعريف.
    LessonPageSpec(
      tag: 'القاعدة',
      title: 'قاعدة (لِـ)',
      emoji: '📘',
      needsCompletion: false,
      rule: const LiRuleContent(),
      builder: (h) => LiRulePage(handle: h),
    ),
    LessonPageSpec(
      title: 'أضف (لِـ)',
      emoji: '➕',
      rule: const LiRuleContent(),
      builder: (h) => EquationPage(
        handle: h,
        rounds: _groupsOfTwo(pickLiWords(rnd)),
        refill: () => _groupsOfTwo(pickLiWords(rnd)),
        op: EquationOp.addLi,
        title: 'أضف (لِـ) إلى الكلمة واكتب الناتج',
        strict: true,
        showLamType: false,
      ),
    ),
    LessonPageSpec(
      title: 'احذف (لِـ)',
      emoji: '➖',
      rule: const LiRuleContent(),
      builder: (h) => EquationPage(
        handle: h,
        rounds: _groupsOfTwo(pickLiWords(rnd)),
        refill: () => _groupsOfTwo(pickLiWords(rnd)),
        op: EquationOp.removeLi,
        title: 'احذف (لِـ) من الكلمة واكتب الناتج',
        strict: true,
        showLamType: false,
      ),
    ),
    LessonPageSpec(
      title: 'اسمع واكتب',
      emoji: '👂',
      rule: const LiRuleContent(),
      builder: (h) {
        final (items, spare) = liWordItems(rnd);
        return LiListenPage(
          handle: h,
          title: 'اسمع الكلمة واكتبها',
          items: items,
          spare: spare,
        );
      },
    ),
    LessonPageSpec(
      title: 'الكلمة الناقصة',
      emoji: '🧩',
      rule: const LiRuleContent(),
      builder: (h) {
        final (items, spare) = liSentenceItems(rnd);
        return LiListenPage(
          handle: h,
          title: 'اسمع واكتب الكلمة الناقصة',
          items: items,
          spare: spare,
        );
      },
    ),
    // اتصال الباء (بـ) بـ(ال) التعريف.
    LessonPageSpec(
      tag: 'القاعدة',
      title: 'قاعدة (بـ)',
      emoji: '📗',
      needsCompletion: false,
      rule: const BiRuleContent(),
      builder: (h) => BiRulePage(handle: h),
    ),
    LessonPageSpec(
      title: 'أضف (بـ)',
      emoji: '➕',
      rule: const BiRuleContent(),
      builder: (h) => EquationPage(
        handle: h,
        rounds: _groupsOfTwo(pickBiWords(rnd)),
        refill: () => _groupsOfTwo(pickBiWords(rnd)),
        op: EquationOp.addBi,
        title: 'أضف (بـ) إلى الكلمة واكتب الناتج',
        strict: true,
        showLamType: false,
      ),
    ),
    LessonPageSpec(
      title: 'احذف (بـ)',
      emoji: '➖',
      rule: const BiRuleContent(),
      builder: (h) => EquationPage(
        handle: h,
        rounds: _groupsOfTwo(pickBiWords(rnd)),
        refill: () => _groupsOfTwo(pickBiWords(rnd)),
        op: EquationOp.removeBi,
        title: 'احذف (بـ) من الكلمة واكتب الناتج',
        strict: true,
        showLamType: false,
      ),
    ),
  ];
}

/// سؤالان في كل شاشة.
List<List<String>> _groupsOfTwo(List<String> words) => [
  for (var i = 0; i < words.length; i += 2)
    words.sublist(i, min(i + 2, words.length)),
];
