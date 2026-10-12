import 'dart:math';

import 'package:flutter/material.dart';

import '../app_state.dart';
import '../data/taa_lesson.dart';
import '../services/speaker.dart';
import '../widgets/common.dart';
import 'page_handle.dart';
import 'pages/choice_page.dart';
import 'pages/listen_write_page.dart';
import 'taa_rule_content.dart';

/// صفحات درس التاء بترتيب كتاب الدرس: القاعدة، ثم «اسمع واكتب الكلمة
/// الناقصة»، ثم «اختر الكلمة المناسبة».
List<LessonPageSpec> buildTaaLessonPages([Random? random]) {
  final rnd = random ?? Random();
  return [
    LessonPageSpec(
      tag: 'مثال القاعدة',
      title: 'القاعدة',
      emoji: '📖',
      needsCompletion: false,
      rule: const TaaRuleContent(),
      builder: (h) => _TaaRulePage(handle: h),
    ),
    LessonPageSpec(
      title: 'اسمع واكتب',
      emoji: '👂',
      rule: const TaaRuleContent(),
      builder: (h) {
        final (items, spare) = taaListenItems(rnd);
        return ListenWritePage(
          handle: h,
          title: 'اسمع الجملة واكتب الكلمة الناقصة',
          items: items,
          spare: spare,
          newOnError: true,
        );
      },
    ),
    LessonPageSpec(
      title: 'اختر الكلمة',
      emoji: '🔤',
      rule: const TaaRuleContent(),
      builder: (h) {
        final (items, spare) = taaChoiceItems(rnd);
        return ChoicePage(handle: h, items: items, spare: spare);
      },
    ),
  ];
}

class _TaaRulePage extends StatefulWidget {
  const _TaaRulePage({required this.handle});
  final PageHandle handle;

  @override
  State<_TaaRulePage> createState() => _TaaRulePageState();
}

class _TaaRulePageState extends State<_TaaRulePage> {
  @override
  void initState() {
    super.initState();
    widget.handle
      ..onListen = (() => Speaker.instance.speak(
        taaRuleSpeech,
        rate: AppScope.read(context).speechRate,
      ))
      ..onHint = () => showFeedback(
        context,
        'قف على الكلمة: إن نطقتها هاءً فهي تاء مربوطة (ة)، وإن بقيت تاءً فهي مفتوحة (ت).',
        tone: FeedbackTone.hint,
      );
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => widget.handle.markComplete(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const PageCard(
      tag: 'مثال القاعدة',
      title: 'تعرّف على التاء المربوطة والتاء المفتوحة',
      subtitle: 'اضغط على المثال لتسمعه',
      child: TaaRuleContent(),
    );
  }
}
