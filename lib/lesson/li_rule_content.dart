import 'package:flutter/material.dart';

import '../app_state.dart';
import '../data/li_lesson.dart';
import '../services/speaker.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'rule_content.dart';

/// قاعدة اتصال لام الجر (لِـ) بـ(ال) وأمثلتها؛ تُعرض في صفحة القاعدة وفي
/// نافذة «القاعدة» لصفحات اللام.
class LiRuleContent extends StatelessWidget {
  const LiRuleContent({super.key});

  @override
  Widget build(BuildContext context) =>
      NaskhRule(child: Builder(builder: _content));

  Widget _content(BuildContext context) {
    void say(String s) =>
        Speaker.instance.speak(s, rate: AppScope.read(context).speechRate);
    final label = Theme.of(context).textTheme.titleSmall?.copyWith(
      fontWeight: FontWeight.w800,
      color: AppColors.muted,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text.rich(
          TextSpan(
            children: [
              const TextSpan(text: 'كيف تتصل '),
              _red('(لِـ)'),
              const TextSpan(text: ' مع '),
              _red('(ال)'),
              const TextSpan(text: ' في الاسم؟'),
            ],
          ),
          textAlign: TextAlign.center,
          style: AppTheme.word(24),
        ),
        const SizedBox(height: 6),
        Text.rich(
          TextSpan(
            children: [
              const TextSpan(text: 'نبدأ الاسم بكتابة '),
              _red('لامين'),
              const TextSpan(text: ' فقط'),
            ],
          ),
          textAlign: TextAlign.center,
          style: AppTheme.word(24, color: AppColors.blue),
        ),
        const SizedBox(height: 4),
        Text(
          'وإن بدأ الاسم بلام مثل (اللحن) نكتب لامين فقط: للحن',
          textAlign: TextAlign.center,
          style: AppTheme.word(18, color: AppColors.muted),
        ),
        const SizedBox(height: 18),
        Text('مثال', style: label),
        const SizedBox(height: 8),
        for (final w in liRuleExamples) ...[
          _LiExample(alWord: w, onTap: () => say(liSpoken(w))),
          const SizedBox(height: 8),
        ],
        const SizedBox(height: 10),
        Text('في جملة', style: label),
        const SizedBox(height: 8),
        for (final (w, sentence) in liExamples) ...[
          _LiExample(alWord: w, sentence: sentence, onTap: () => say(sentence)),
          const SizedBox(height: 8),
        ],
      ],
    );
  }

  static TextSpan _red(String text) => TextSpan(
    text: text,
    style: const TextStyle(color: AppColors.al),
  );
}

/// سطر مثال: الكتاب = للكتاب، وتحته الجملة إن وُجدت.
class _LiExample extends StatelessWidget {
  const _LiExample({required this.alWord, required this.onTap, this.sentence});

  final String alWord;
  final String? sentence;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final op = Theme.of(context).textTheme.titleLarge?.copyWith(
      color: AppColors.muted,
      fontWeight: FontWeight.w700,
    );
    return Material(
      color: AppColors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.line),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: AlText(alWord, size: 28),
                    ),
                  ),
                  if (sentence != null) ...[
                    Text('+', style: op),
                    const SizedBox(width: 6),
                    const AlBox(size: 18, text: 'لِـ'),
                    const SizedBox(width: 6),
                  ],
                  Text('=', style: op),
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: AlText(
                        liForm(alWord),
                        size: 28,
                        color: AppColors.blue,
                        redPrefix: liRedPrefix(alWord),
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.volume_up_outlined,
                    color: AppColors.ink,
                    size: 20,
                  ),
                ],
              ),
              if (sentence != null)
                AlText(
                  '( ${sentence!} )',
                  size: 20,
                  highlight: false,
                  color: AppColors.muted,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
