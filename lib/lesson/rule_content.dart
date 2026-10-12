import 'package:flutter/material.dart';

import '../app_state.dart';
import '../services/speaker.dart';
import '../theme.dart';
import '../utils/arabic.dart';
import '../widgets/common.dart';

/// القاعدة مكتوبة بخط النسخ مع أمثلتها؛ تُعرض في الصفحة الأولى وفي نافذة «القاعدة».
class RuleContent extends StatelessWidget {
  const RuleContent({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Theme(
      data: theme.copyWith(
        textTheme: theme.textTheme.apply(fontFamily: 'NotoNaskhArabic'),
      ),
      child: Builder(builder: _content),
    );
  }

  Widget _content(BuildContext context) {
    final t = Theme.of(context).textTheme;
    void say(String s) =>
        Speaker.instance.speak(s, rate: AppScope.read(context).speechRate);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'القاعدة',
          style: t.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 10),
        const _RuleLine(type: LamType.moon),
        const SizedBox(height: 8),
        const _RuleLine(type: LamType.sun),
        const SizedBox(height: 20),
        Text(
          'أمثلة',
          style: t.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 10),
        _ExampleTile(
          word: 'الكتاب',
          type: LamType.moon,
          onTap: () => say('الكِتاب'),
        ),
        const SizedBox(height: 8),
        _ExampleTile(
          word: 'السُّكَّر',
          type: LamType.sun,
          onTap: () => say('السُّكَّر'),
        ),
      ],
    );
  }
}

class _RuleLine extends StatelessWidget {
  const _RuleLine({required this.type});
  final LamType type;

  @override
  Widget build(BuildContext context) {
    final moon = type == LamType.moon;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 8,
        runSpacing: 6,
        children: [
          Text(
            moon ? 'اللام القمرية' : 'اللام الشمسية',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const AlBox(size: 18),
          Text('=', style: Theme.of(context).textTheme.titleMedium),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.line),
            ),
            child: Text(
              type.rule,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: moon ? AppColors.moon : AppColors.sun,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExampleTile extends StatelessWidget {
  const _ExampleTile({
    required this.word,
    required this.type,
    required this.onTap,
  });

  final String word;
  final LamType type;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          child: Row(
            children: [
              Expanded(
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 10,
                  children: [
                    AlText(word, size: 32),
                    Text('=', style: Theme.of(context).textTheme.titleMedium),
                    LamChip(type),
                  ],
                ),
              ),
              const Icon(
                Icons.volume_up_rounded,
                color: AppColors.primary,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// نافذة القاعدة؛ [content] لقاعدة غير قاعدة اللام القمرية والشمسية.
Future<void> showRuleSheet(BuildContext context, {Widget? content}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      builder: (context, controller) => ListView(
        controller: controller,
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
        children: [
          Text(
            'القاعدة',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
          content ?? const RuleContent(),
        ],
      ),
    ),
  );
}
