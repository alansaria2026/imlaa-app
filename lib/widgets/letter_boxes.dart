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
        // الكلمات الطويلة على الشاشات الضيقة: مربعات أصغر في سطر واحد.
        final gap = length > 7 ? 5.0 : 8.0;
        final size = ((c.maxWidth - gap * (length - 1)) / length).clamp(
          22.0,
          58.0,
        );
        // حجم الحرف من حجم المربع، فلا يكبر مع خط الجهاز.
        return MediaQuery.withNoTextScaling(
          child: Wrap(
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
          ),
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

  /// هل يمكن كتابة [word] بحروف اللوحة (على أي جهاز).
  static bool canType(String word) => word
      .split('')
      .every((c) => [..._iosRows, ..._androidRows].any((r) => r.contains(c)));

  /// لوحة الآيفون العربية من اليسار إلى اليمين («ض» مكان Q)، وزر الحذف
  /// في آخر الصف الثالث يمينًا. الصف الأخير حروف الهمزة التي تظهر في الجوال
  /// بالضغط المطوّل.
  static const _iosRows = [
    ['ض', 'ص', 'ث', 'ق', 'ف', 'غ', 'ع', 'ه', 'خ', 'ح', 'ج'],
    ['ش', 'س', 'ي', 'ب', 'ل', 'ا', 'ت', 'ن', 'م', 'ك', 'ة'],
    ['ء', 'ظ', 'ط', 'ذ', 'د', 'ز', 'ر', 'و', 'ى'],
    ['أ', 'إ', 'آ', 'ؤ', 'ئ'],
  ];

  /// لوحة أندرويد العربية من اليمين إلى اليسار («ض» في أقصى اليمين).
  static const _androidRows = [
    ['ض', 'ص', 'ث', 'ق', 'ف', 'غ', 'ع', 'ه', 'خ', 'ح', 'ج'],
    ['ش', 'س', 'ي', 'ب', 'ل', 'ا', 'ت', 'ن', 'م', 'ك', 'ط'],
    ['ذ', 'ء', 'ؤ', 'ر', 'ى', 'ة', 'و', 'ز', 'ظ', 'د'],
    ['أ', 'إ', 'آ', 'ئ'],
  ];

  @override
  Widget build(BuildContext context) {
    // على الويب أيضًا يعكس نظام الجهاز (آيفون أو أندرويد).
    final platform = Theme.of(context).platform;
    final ios =
        platform == TargetPlatform.iOS || platform == TargetPlatform.macOS;
    final rows = ios ? _iosRows : _androidRows;
    const letterRows = 3;

    // المفاتيح بعرض ثابت، فلا يكبر حرفها مع خط الجهاز.
    return MediaQuery.withNoTextScaling(
      child: Container(
        padding: const EdgeInsets.fromLTRB(2, 6, 2, 6),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Directionality(
          textDirection: ios ? TextDirection.ltr : TextDirection.rtl,
          child: Column(
            children: [
              for (var r = 0; r < rows.length; r++)
                Row(
                  children: [
                    // صف الهمزات أقصر فيتوسط اللوحة بمفاتيح بالعرض نفسه.
                    if (r == letterRows) Spacer(flex: 11 - rows[r].length),
                    for (final l in rows[r])
                      _Key(
                        label: l,
                        flex: r == letterRows ? 2 : 1,
                        onTap: () => onLetter(l),
                      ),
                    if (r == letterRows) Spacer(flex: 11 - rows[r].length),
                    if (r == letterRows - 1)
                      _Key(
                        icon: Icons.backspace_outlined,
                        flex: 11 - rows[r].length,
                        onTap: onBackspace,
                      ),
                  ],
                ),
            ],
          ),
        ),
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
        padding: const EdgeInsets.all(2),
        child: Pressable(
          onTap: onTap,
          color: icon != null ? AppColors.primarySoft : AppColors.surface,
          edgeColor: icon != null ? AppColors.primary : AppColors.lineDark,
          radius: 10,
          depth: 3,
          child: SizedBox(
            height: 48,
            child: Center(
              child: icon != null
                  ? Icon(icon, size: 24, color: AppColors.primary)
                  // حرف كبير يصغر فقط إن ضاق المفتاح على شاشة صغيرة جدًا.
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          label!,
                          style: AppTheme.word(
                            26,
                          ).copyWith(height: 1.1, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
