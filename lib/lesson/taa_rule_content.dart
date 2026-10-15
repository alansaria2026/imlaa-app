import 'package:flutter/material.dart';

import '../app_state.dart';
import '../data/taa_lesson.dart';
import '../services/speaker.dart';
import '../theme.dart';
import '../widgets/taa_text.dart';
import 'rule_content.dart';

/// قاعدة التاء المربوطة والتاء المفتوحة: سؤال وجواب، ثم جملة المثال
/// والتاء المربوطة فيها بالأحمر والمفتوحة بالأزرق، ثم كلمتا المثال تتحركان.
class TaaRuleContent extends StatelessWidget {
  const TaaRuleContent({super.key});

  @override
  Widget build(BuildContext context) =>
      NaskhRule(child: Builder(builder: _content));

  Widget _content(BuildContext context) {
    final t = Theme.of(context).textTheme;
    void say(String s) =>
        Speaker.instance.speak(s, rate: AppScope.read(context).speechRate);
    final label = t.titleLarge?.copyWith(
      fontWeight: FontWeight.w800,
      color: AppColors.primary,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'كيف نفرّق بين التاء المربوطة والتاء المفتوحة؟',
          textAlign: TextAlign.center,
          style: AppTheme.word(22),
        ),
        const SizedBox(height: 12),
        const _RuleLine(type: TaaType.marbuta),
        const SizedBox(height: 8),
        const _RuleLine(type: TaaType.maftuha),
        const SizedBox(height: 20),
        Text('مثال', textAlign: TextAlign.center, style: label),
        const SizedBox(height: 8),
        Material(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            key: const ValueKey('taa-sentence'),
            borderRadius: BorderRadius.circular(16),
            onTap: () => say(taaRuleSentence),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  const Expanded(child: TaaText('( $taaRuleSentence )')),
                  const Icon(
                    Icons.volume_up_rounded,
                    color: AppColors.primary,
                    size: 28,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        for (final (word, spoken) in taaRuleWords) ...[
          _WordTile(word: word, onTap: () => say(spoken)),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _RuleLine extends StatelessWidget {
  const _RuleLine({required this.type});
  final TaaType type;

  @override
  Widget build(BuildContext context) {
    final marbuta = type == TaaType.marbuta;
    final t = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
      ),
      // سطر واحد في الوسط بأكبر خط ممكن؛ يصغر على الشاشات الضيقة.
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              marbuta ? 'التاء المربوطة' : 'التاء المفتوحة',
              style: t.titleLarge?.copyWith(
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              marbuta ? '(ة)' : '(ت)',
              style: AppTheme.word(28, color: taaColor(type)),
            ),
            const SizedBox(width: 8),
            Text('=', style: t.titleLarge),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.line),
              ),
              child: Text(
                marbuta ? 'يمكن أن تُقلب هاءً' : 'لا يمكن أن تُقلب هاءً',
                style: t.titleLarge?.copyWith(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: taaColor(type),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// كلمة المثال تتحرك حركة نشطة، وبالضغط تُنطق عند الوقف.
class _WordTile extends StatefulWidget {
  const _WordTile({required this.word, required this.onTap});
  final String word;
  final VoidCallback onTap;

  @override
  State<_WordTile> createState() => _WordTileState();
}

class _WordTileState extends State<_WordTile>
    with SingleTickerProviderStateMixin {
  late final _bounce = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _bounce.stop();
    } else if (!_bounce.isAnimating) {
      _bounce.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _bounce.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final type = taaTypeOf(widget.word)!;
    final t = Theme.of(context).textTheme;
    return Material(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          child: Row(
            children: [
              ScaleTransition(
                scale: Tween(begin: 1.0, end: 1.12).animate(
                  CurvedAnimation(parent: _bounce, curve: Curves.easeInOut),
                ),
                child: TaaText(widget.word, size: 36),
              ),
              const SizedBox(width: 10),
              // الوصف بأكبر خط يتسع له السطر بجانب الكلمة.
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    '${type.label}: ${type == TaaType.marbuta ? 'يمكن أن تُقلب هاءً' : 'لا يمكن أن تُقلب هاءً'}',
                    style: t.titleLarge?.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: taaColor(type),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              const Icon(
                Icons.volume_up_rounded,
                color: AppColors.primary,
                size: 28,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
