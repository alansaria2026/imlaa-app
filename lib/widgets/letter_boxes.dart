import 'package:flutter/material.dart';

import '../theme.dart';
import 'pressable.dart';

/// مربعات بعدد حروف (الـ + الكلمة)، يكون مربعا (الـ) باللون الأحمر.
class LetterBoxes extends StatelessWidget {
  const LetterBoxes({
    super.key,
    required this.length,
    required this.letters,
    this.alCount = 2,
    this.error = false,
  });

  final int length;
  final List<String> letters;
  final int alCount;
  final bool error;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        const gap = 8.0;
        final size = ((c.maxWidth - gap * (length - 1)) / length).clamp(
          30.0,
          50.0,
        );
        return Wrap(
          alignment: WrapAlignment.center,
          spacing: gap,
          runSpacing: gap,
          children: [
            for (var i = 0; i < length; i++)
              _Box(
                size: size,
                letter: i < letters.length ? letters[i] : null,
                isAl: i < alCount,
                active: i == letters.length,
                error: error,
              ),
          ],
        );
      },
    );
  }
}

class _Box extends StatelessWidget {
  const _Box({
    required this.size,
    required this.letter,
    required this.isAl,
    required this.active,
    required this.error,
  });

  final double size;
  final String? letter;
  final bool isAl;
  final bool active;
  final bool error;

  @override
  Widget build(BuildContext context) {
    final accent = isAl ? AppColors.al : AppColors.primary;
    final border = error
        ? AppColors.error
        : active
        ? accent
        : isAl
        ? AppColors.al.withValues(alpha: 0.45)
        : AppColors.line;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: size,
      height: size * 1.1,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isAl
            ? AppColors.al.withValues(alpha: 0.06)
            : letter != null
            ? AppColors.primarySoft.withValues(alpha: 0.5)
            : AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border, width: active ? 2.2 : 1.5),
      ),
      child: Text(
        letter ?? '',
        style: AppTheme.word(
          size * 0.5,
          color: isAl ? AppColors.al : AppColors.ink,
        ).copyWith(height: 1.2),
      ),
    );
  }
}

/// لوحة مفاتيح عربية مبسطة داخل التطبيق.
class ArabicKeyboard extends StatelessWidget {
  const ArabicKeyboard({
    super.key,
    required this.onLetter,
    required this.onBackspace,
  });

  final ValueChanged<String> onLetter;
  final VoidCallback onBackspace;

  static const _rows = [
    ['ض', 'ص', 'ث', 'ق', 'ف', 'غ', 'ع', 'ه', 'خ', 'ح', 'ج'],
    ['ش', 'س', 'ي', 'ب', 'ل', 'ا', 'ت', 'ن', 'م', 'ك', 'ط'],
    ['ذ', 'ء', 'ؤ', 'ر', 'ى', 'ة', 'و', 'ز', 'ظ', 'د'],
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(2, 6, 2, 6),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          for (var r = 0; r < _rows.length; r++)
            Row(
              children: [
                for (final l in _rows[r])
                  _Key(label: l, onTap: () => onLetter(l)),
                if (r == _rows.length - 1)
                  _Key(
                    icon: Icons.backspace_outlined,
                    flex: 1,
                    onTap: onBackspace,
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _Key extends StatelessWidget {
  const _Key({this.label, this.icon, required this.onTap, this.flex = 1});

  final String? label;
  final IconData? icon;
  final VoidCallback onTap;
  final int flex;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.all(2.5),
        child: Pressable(
          onTap: onTap,
          color: icon != null ? AppColors.primarySoft : AppColors.surface,
          edgeColor: icon != null ? AppColors.primary : AppColors.lineDark,
          radius: 10,
          depth: 3,
          child: SizedBox(
            height: 40,
            child: Center(
              child: icon != null
                  ? Icon(icon, size: 20, color: AppColors.primary)
                  : Text(
                      label!,
                      style: AppTheme.word(
                        19,
                      ).copyWith(height: 1.1, fontWeight: FontWeight.w600),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
