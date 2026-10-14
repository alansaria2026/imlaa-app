import 'package:flutter/material.dart';

import '../app_state.dart';
import '../data/alif_lesson.dart';
import '../services/speaker.dart';
import '../theme.dart';
import '../widgets/pressable.dart';
import 'rule_content.dart';

void _say(BuildContext context, String text) =>
    Speaker.instance.speak(text, rate: AppScope.read(context).speechRate);

const _red = TextStyle(color: AppColors.al);
const _blue = TextStyle(color: AppColors.blue);

class _Line extends StatelessWidget {
  const _Line(this.span);
  final InlineSpan span;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Text.rich(span, style: AppTheme.word(22).copyWith(height: 1.7)),
  );
}

class _Heading extends StatelessWidget {
  const _Heading(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 14, bottom: 6),
    child: Text(text, style: AppTheme.word(22, color: AppColors.al)),
  );
}

/// مثال يُسمع بالضغط عليه.
InlineSpan _example(
  BuildContext context,
  String word,
  String spoken, {
  TextStyle style = _blue,
}) => WidgetSpan(
  alignment: PlaceholderAlignment.middle,
  child: GestureDetector(
    onTap: () => _say(context, spoken),
    child: Text(word, style: AppTheme.word(24).merge(style)),
  ),
);

/// مربع بإطار في مخطط ص ١.
class _Box extends StatelessWidget {
  const _Box({required this.child, this.padding});
  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) => Container(
    padding: padding ?? const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.ink, width: 1.8),
    ),
    child: child,
  );
}

/// عنوان المربع بالأحمر، يصغر ليتسع في الشاشات الضيقة.
class _BoxTitle extends StatelessWidget {
  const _BoxTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => _Box(
    child: FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(text, style: AppTheme.word(22, color: AppColors.al)),
    ),
  );
}

/// سهم نازل يصل المربعات.
class _DownArrow extends StatelessWidget {
  const _DownArrow();

  @override
  Widget build(BuildContext context) => const SizedBox(
    width: 20,
    height: 34,
    child: CustomPaint(painter: _ArrowPainter()),
  );
}

class _ArrowPainter extends CustomPainter {
  const _ArrowPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.ink
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final x = size.width / 2;
    canvas
      ..drawLine(Offset(x, 0), Offset(x, size.height - 1), paint)
      ..drawLine(
        Offset(x - 6, size.height - 8),
        Offset(x, size.height - 1),
        paint,
      )
      ..drawLine(
        Offset(x + 6, size.height - 8),
        Offset(x, size.height - 1),
        paint,
      );
  }

  @override
  bool shouldRepaint(_ArrowPainter oldDelegate) => false;
}

/// فرع الألف: العنوان ← صورة الألف ← المثال.
class _AlifBranch extends StatelessWidget {
  const _AlifBranch({
    required this.title,
    required this.letter,
    required this.word,
    required this.spoken,
  });

  final String title;
  final String letter;
  final String word;
  final String spoken;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      _BoxTitle(title),
      const _DownArrow(),
      _Box(
        padding: const EdgeInsets.symmetric(horizontal: 26),
        child: Text(letter, style: AppTheme.word(38, color: AppColors.al)),
      ),
      const SizedBox(height: 10),
      _BoxExample(word, spoken),
    ],
  );
}

/// مثال بين قوسين تحت المربع، يُسمع بالضغط عليه.
class _BoxExample extends StatelessWidget {
  const _BoxExample(this.word, this.spoken);
  final String word;
  final String spoken;

  @override
  Widget build(BuildContext context) => Text.rich(
    TextSpan(
      children: [
        const TextSpan(text: '( '),
        _example(context, word, spoken),
        const TextSpan(text: ' )'),
      ],
    ),
    style: AppTheme.word(24),
  );
}

/// ص ١: الألف الممدودة والمقصورة، والاسم الثلاثي، مرسومة مربعات وأسهمًا.
class AlifBasicsRule extends StatelessWidget {
  const AlifBasicsRule({super.key});

  @override
  Widget build(BuildContext context) {
    final [(mw, ms), (qw, qs), (tw, ts)] = alifRuleExamples;
    return NaskhRule(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _AlifBranch(
                    title: 'الألف المقصورة',
                    letter: 'ى',
                    word: qw,
                    spoken: qs,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _AlifBranch(
                    title: 'الألف الممدودة',
                    letter: 'ا',
                    word: mw,
                    spoken: ms,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 36),
            const FractionallySizedBox(
              widthFactor: 0.6,
              child: _BoxTitle('الاسم الثلاثي'),
            ),
            const _DownArrow(),
            _Box(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text.rich(
                  const TextSpan(
                    children: [
                      TextSpan(text: 'يتكوّن من ( '),
                      TextSpan(text: '٣', style: _red),
                      TextSpan(text: ' ) حروف أصلية'),
                    ],
                  ),
                  style: AppTheme.word(22),
                ),
              ),
            ),
            const SizedBox(height: 10),
            _BoxExample(tw, ts),
          ],
        ),
      ),
    );
  }
}

/// ص ٢: قاعدة الاسم الثلاثي المنتهي بالألف؛ الأمثلة بالأحمر.
class TriliteralRule extends StatelessWidget {
  const TriliteralRule({super.key});

  @override
  Widget build(BuildContext context) {
    InlineSpan ex(String w, String s) => _example(context, w, s, style: _red);
    return NaskhRule(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _Heading('قاعدة الاسم الثلاثي المنتهي بالألف'),
          _Line(
            TextSpan(
              children: [
                const TextSpan(text: '١- إذا كان '),
                const TextSpan(text: 'أوله مضمومًا', style: _red),
                const TextSpan(text: ' يُكتب بالألف المقصورة، مثل ( '),
                ex('هُدى', 'هُدى'),
                const TextSpan(text: ' )'),
              ],
            ),
          ),
          _Line(
            TextSpan(
              children: [
                const TextSpan(text: '٢- إذا كان '),
                const TextSpan(text: 'أوله مكسورًا', style: _red),
                const TextSpan(text: ' يُكتب بالألف المقصورة، مثل ( '),
                ex('رِضى', 'رِضى'),
                const TextSpan(text: ' )'),
              ],
            ),
          ),
          const _Line(
            TextSpan(
              children: [
                TextSpan(text: '٣- إذا كان '),
                TextSpan(text: 'أوله مفتوحًا', style: _red),
                TextSpan(text: ' نحوّل الاسم إلى (مفرد أو مثنى أو جمع):'),
              ],
            ),
          ),
          _Line(
            TextSpan(
              children: [
                const TextSpan(text: '   • إذا انقلبت الألف إلى '),
                const TextSpan(text: 'الواو', style: _red),
                const TextSpan(text: ' يُكتب بالألف الممدودة، مثل ( '),
                ex('شَذا ـ شَذَوات', 'شَذا، شَذَوات'),
                const TextSpan(text: ' )'),
              ],
            ),
          ),
          _Line(
            TextSpan(
              children: [
                const TextSpan(text: '   • إذا انقلبت الألف إلى '),
                const TextSpan(text: 'الياء', style: _red),
                const TextSpan(text: ' يُكتب بالألف المقصورة، مثل ( '),
                ex('فَتى ـ فَتَيان', 'فَتى، فَتَيان'),
                const TextSpan(text: ' )'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RememberBox extends StatelessWidget {
  const _RememberBox(this.number, this.span);
  final String? number;
  final InlineSpan span;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.line),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (number != null)
          Text(
            'القاعدة $number',
            textAlign: TextAlign.center,
            style: AppTheme.word(20, color: AppColors.al),
          ),
        Text.rich(span, style: AppTheme.word(22).copyWith(height: 1.7)),
      ],
    ),
  );
}

/// ص ٤: «احفظ هاتين القاعدتين دائمًا للامتحان».
class TriliteralRemember extends StatelessWidget {
  const TriliteralRemember({super.key});

  @override
  Widget build(BuildContext context) => const NaskhRule(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _RememberBox(
          '١',
          TextSpan(
            children: [
              TextSpan(text: 'كل اسم ثلاثي، '),
              TextSpan(text: 'أوله مضموم', style: _red),
              TextSpan(text: '، يُكتب بالألف المقصورة'),
            ],
          ),
        ),
        _RememberBox(
          '٢',
          TextSpan(
            children: [
              TextSpan(text: 'كل اسم ثلاثي، '),
              TextSpan(text: 'أوله مكسور', style: _red),
              TextSpan(text: '، يُكتب بالألف المقصورة'),
            ],
          ),
        ),
      ],
    ),
  );
}

/// ص ١ (الأسماء غير الثلاثية): العناوين بالأحمر والأمثلة بالأزرق، ومعها
/// زر «إضاءة» للأسماء الشاذة.
class LongNounRule extends StatelessWidget {
  const LongNounRule({super.key, this.light = true});

  /// زر «إضاءة» تحت القاعدة.
  final bool light;

  @override
  Widget build(BuildContext context) {
    InlineSpan ex(String w) => _example(context, w, w);
    return NaskhRule(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _Heading('القاعدة'),
          _Line(
            TextSpan(
              children: [
                const TextSpan(text: 'أي '),
                const TextSpan(text: 'اسم عربي', style: _red),
                const TextSpan(text: '، أكثر من ثلاثة حروف، يُكتب بالألف '),
                const TextSpan(text: 'المقصورة (ى)', style: _red),
                const TextSpan(text: '، مثل ( '),
                ex('مستشفى'),
                const TextSpan(text: ' ـ '),
                ex('حلوى'),
                const TextSpan(text: ' )'),
              ],
            ),
          ),
          const _Heading('ما عدا:'),
          _Line(
            TextSpan(
              children: [
                const TextSpan(text: '١- '),
                const TextSpan(text: 'الاسم الأعجمي', style: _red),
                const TextSpan(text: ' يُكتب بالألف الممدودة (ا)، مثل ( '),
                ex('فرنسا'),
                const TextSpan(text: ' ـ '),
                ex('أستراليا'),
                const TextSpan(text: ' )'),
              ],
            ),
          ),
          _Line(
            TextSpan(
              children: [
                const TextSpan(text: '٢- إذا كان '),
                const TextSpan(text: 'قبل حرف الألف (ياء)', style: _red),
                const TextSpan(text: ' يُكتب بالألف الممدودة، مثل ( '),
                ex('دنيا'),
                const TextSpan(text: ' ـ '),
                ex('قضايا'),
                const TextSpan(text: ' )'),
              ],
            ),
          ),
          if (light) ...[
            const SizedBox(height: 16),
            AppButton(
              key: const ValueKey('alif-light'),
              label: '💡 إضاءة',
              style: AppButtonStyle.outline,
              height: 48,
              onTap: () => showRuleSheet(
                context,
                title: '💡 إضاءة',
                content: const LongNounLight(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// ص ٢: «إضاءة»: الأسماء الشاذة، وكلمة تُكتب على وجهين.
class LongNounLight extends StatelessWidget {
  const LongNounLight({super.key});

  @override
  Widget build(BuildContext context) => NaskhRule(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _Line(
          TextSpan(
            children: [
              TextSpan(text: '١- '),
              TextSpan(text: 'الأسماء الشاذة', style: _red),
              TextSpan(text: ' التي تُكتب بالألف المقصورة دائمًا:'),
            ],
          ),
        ),
        const SizedBox(height: 6),
        _LightTable(
          rows: [
            [
              for (final w in irregularMaqsura)
                _LightCell(w, color: AppColors.blue),
            ],
          ],
        ),
        const SizedBox(height: 10),
        const _Line(
          TextSpan(
            children: [
              TextSpan(text: '٢- '),
              TextSpan(text: 'الكلمة', style: _red),
              TextSpan(text: ' التي تُكتب على '),
              TextSpan(text: 'الوجهين', style: _red),
              TextSpan(text: ':'),
            ],
          ),
        ),
        const SizedBox(height: 6),
        _LightTable(
          header: true,
          rows: [
            [for (final (_, kind) in twoWayWords) _LightCell(kind)],
            [
              for (final (w, _) in twoWayWords)
                _LightCell(w, color: AppColors.blue),
            ],
          ],
        ),
      ],
    ),
  );
}

/// جدول «إضاءة»؛ الصف الأول عناوين بخلفية إن كان [header].
class _LightTable extends StatelessWidget {
  const _LightTable({required this.rows, this.header = false});
  final List<List<Widget>> rows;
  final bool header;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(12),
    child: Table(
      border: TableBorder.all(
        color: AppColors.lineDark,
        borderRadius: BorderRadius.circular(12),
      ),
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        for (final (i, row) in rows.indexed)
          TableRow(
            decoration: header && i == 0
                ? const BoxDecoration(color: AppColors.primarySoft)
                : null,
            children: row,
          ),
      ],
    ),
  );
}

class _LightCell extends StatelessWidget {
  const _LightCell(this.text, {this.color = AppColors.ink});
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
    child: FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(text, style: AppTheme.word(24, color: color)),
    ),
  );
}

/// ص ٥: «احفظ هذه القاعدة وافهمها دائمًا للامتحان».
class LongNounRemember extends StatelessWidget {
  const LongNounRemember({super.key});

  @override
  Widget build(BuildContext context) => const NaskhRule(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _RememberBox(
          null,
          TextSpan(
            children: [
              TextSpan(text: 'أي '),
              TextSpan(text: 'اسم عربي', style: _red),
              TextSpan(
                text: '، أكثر من ثلاثة حروف، يُكتب بالألف المقصورة (ى)، ',
              ),
              TextSpan(text: 'ما عدا', style: _red),
              TextSpan(
                text:
                    ': الاسم الأعجمي، وما قبل ألفه ياء، فيُكتبان بالألف '
                    'الممدودة (ا).',
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

/// نافذة «القاعدة» للدرس كله.
class AlifRuleContent extends StatelessWidget {
  const AlifRuleContent({super.key});

  @override
  Widget build(BuildContext context) => const Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      AlifBasicsRule(),
      TriliteralRule(),
      NaskhRule(child: _Heading('الأسماء غير الثلاثية')),
      LongNounRule(),
    ],
  );
}
