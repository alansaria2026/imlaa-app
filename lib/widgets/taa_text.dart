import 'package:flutter/material.dart';

import '../data/taa_lesson.dart';
import '../theme.dart';

/// لون التاء: المربوطة بالأحمر والمفتوحة بالأزرق.
Color taaColor(TaaType type) =>
    type == TaaType.marbuta ? AppColors.al : AppColors.blue;

/// الكلمة مع تلوين التاء في آخرها (وما بعدها من تشكيل).
TextSpan taaSpan(String word, {Color color = AppColors.ink}) {
  final type = taaTypeOf(word);
  if (type == null) {
    return TextSpan(
      text: word,
      style: TextStyle(color: color),
    );
  }
  final i = word.lastIndexOf(type == TaaType.marbuta ? 'ة' : 'ت');
  return TextSpan(
    style: TextStyle(color: color),
    children: [
      TextSpan(text: word.substring(0, i)),
      TextSpan(
        text: word.substring(i),
        style: TextStyle(color: taaColor(type)),
      ),
    ],
  );
}

/// نص بخط النسخ تُلوَّن فيه التاء في آخر كل كلمة.
class TaaText extends StatelessWidget {
  const TaaText(this.text, {super.key, this.size = 28});

  final String text;
  final double size;

  @override
  Widget build(BuildContext context) {
    final words = text.split(' ');
    return Text.rich(
      TextSpan(
        children: [
          for (var i = 0; i < words.length; i++) ...[
            taaSpan(words[i]),
            if (i < words.length - 1) const TextSpan(text: ' '),
          ],
        ],
      ),
      style: AppTheme.word(size),
      textAlign: TextAlign.center,
    );
  }
}
