import 'package:flutter/material.dart';

import '../app_state.dart';
import '../data/bi_lesson.dart';
import '../services/speaker.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'rule_content.dart';

/// قاعدة اتصال الباء (بـ) بـ(ال): الباء بالأحمر وبقية الكلمة بالأزرق.
class BiRuleContent extends StatelessWidget {
  const BiRuleContent({super.key});

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
    const red = TextStyle(color: AppColors.al);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text.rich(
          const TextSpan(
            children: [
              TextSpan(text: 'كيف تتصل '),
              TextSpan(text: '(الباء)', style: red),
              TextSpan(text: ' مع (ال)؟'),
            ],
          ),
          textAlign: TextAlign.center,
          style: AppTheme.word(24),
        ),
        const SizedBox(height: 6),
        Text.rich(
          const TextSpan(
            children: [
              TextSpan(text: 'تُكتب '),
              TextSpan(text: '(بـ)', style: red),
              TextSpan(text: ' ونكمل الاسم دون تغيير'),
            ],
          ),
          textAlign: TextAlign.center,
          style: AppTheme.word(24, color: AppColors.blue),
        ),
        const SizedBox(height: 4),
        Text(
          'حتى لو بدأ الاسم بلام: اللحم + بـ = باللحم',
          textAlign: TextAlign.center,
          style: AppTheme.word(18, color: AppColors.muted),
        ),
        const SizedBox(height: 18),
        Text('مثال', style: label),
        const SizedBox(height: 8),
        for (final (w, sentence) in biExamples) ...[
          _BiExample(alWord: w, sentence: sentence, onTap: () => say(sentence)),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _BiExample extends StatelessWidget {
  const _BiExample({
    required this.alWord,
    required this.sentence,
    required this.onTap,
  });

  final String alWord;
  final String sentence;
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
                      child: AlText(alWord, size: 28, highlight: false),
                    ),
                  ),
                  Text('+', style: op),
                  const SizedBox(width: 6),
                  const AlBox(size: 18, text: 'بـ'),
                  const SizedBox(width: 6),
                  Text('=', style: op),
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: AlText(
                        biForm(alWord),
                        size: 28,
                        color: AppColors.blue,
                        redPrefix: 1,
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
              AlText(
                '( $sentence )',
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
