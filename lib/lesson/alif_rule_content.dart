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
  const TriliteralRule({super.key, this.heading = true});

  /// العنوان الأحمر فوق القاعدة (يُخفى في صفحة لها العنوان نفسه).
  final bool heading;

  @override
  Widget build(BuildContext context) {
    return NaskhRule(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (heading)
            const _CenterHeading('قاعدة الاسم الثلاثي المنتهي بالألف'),
          _RuleCard(
            exampleStyle: _red,
            inline: true,
            lines: [
              (
                TextSpan(
                  children: [
                    TextSpan(text: '١- إذا كان '),
                    TextSpan(text: 'أوله مضمومًا', style: _red),
                    TextSpan(text: ' يُكتب بالألف المقصورة'),
                  ],
                ),
                [('هُدى', 'هُدى')],
              ),
            ],
          ),
          _RuleCard(
            exampleStyle: _red,
            inline: true,
            lines: [
              (
                TextSpan(
                  children: [
                    TextSpan(text: '٢- إذا كان '),
                    TextSpan(text: 'أوله مكسورًا', style: _red),
                    TextSpan(text: ' يُكتب بالألف المقصورة'),
                  ],
                ),
                [('رِضى', 'رِضى')],
              ),
            ],
          ),
          _RuleCard(
            exampleStyle: _red,
            inline: true,
            lines: [
              (
                TextSpan(
                  children: [
                    TextSpan(text: '٣- إذا كان '),
                    TextSpan(text: 'أوله مفتوحًا', style: _red),
                    TextSpan(text: ' نحوّل الاسم إلى (مفرد أو مثنى أو جمع):'),
                  ],
                ),
                [],
              ),
              (
                TextSpan(
                  children: [
                    TextSpan(text: '• إذا انقلبت الألف إلى '),
                    TextSpan(text: 'الواو', style: _red),
                    TextSpan(text: ' يُكتب بالألف الممدودة'),
                  ],
                ),
                [('شَذا ـ شَذَوات', 'شَذا، شَذَوات')],
              ),
              (
                TextSpan(
                  children: [
                    TextSpan(text: '• إذا انقلبت الألف إلى '),
                    TextSpan(text: 'الياء', style: _red),
                    TextSpan(text: ' يُكتب بالألف المقصورة'),
                  ],
                ),
                [('فَتى ـ فَتَيان', 'فَتى، فَتَيان')],
              ),
            ],
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

  /// زر «إضاءة» فوق القاعدة.
  final bool light;

  @override
  Widget build(BuildContext context) {
    return NaskhRule(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (light) ...[
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
            const SizedBox(height: 8),
          ],
          const _CenterHeading('القاعدة'),
          const _RuleCard(
            lines: [
              (
                TextSpan(
                  children: [
                    TextSpan(text: 'أي '),
                    TextSpan(text: 'اسم عربي', style: _red),
                    TextSpan(text: '، أكثر من ثلاثة حروف، يُكتب بالألف '),
                    TextSpan(text: 'المقصورة\u00A0(ى)', style: _red),
                  ],
                ),
                [('مستشفى', 'مستشفى'), ('حلوى', 'حلوى')],
              ),
            ],
          ),
          const _CenterHeading('ما عدا'),
          const _RuleCard(
            lines: [
              (
                TextSpan(
                  children: [
                    TextSpan(text: '١- '),
                    TextSpan(text: 'الاسم الأعجمي', style: _red),
                    TextSpan(text: ' يُكتب بالألف الممدودة\u00A0(ا)'),
                  ],
                ),
                [('فرنسا', 'فرنسا'), ('أستراليا', 'أستراليا')],
              ),
            ],
          ),
          const _RuleCard(
            lines: [
              (
                TextSpan(
                  children: [
                    TextSpan(text: '٢- إذا كان '),
                    TextSpan(text: 'قبل حرف الألف (ياء)', style: _red),
                    TextSpan(text: ' يُكتب بالألف الممدودة\u00A0(ا)'),
                  ],
                ),
                [('دنيا', 'دنيا'), ('قضايا', 'قضايا')],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// عنوان أحمر في وسط السطر.
class _CenterHeading extends StatelessWidget {
  const _CenterHeading(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 4, bottom: 6),
    child: Text(
      text,
      textAlign: TextAlign.center,
      style: AppTheme.word(23, color: AppColors.al).copyWith(height: 1.4),
    ),
  );
}

/// قاعدة في مربع: كل سطر نصه في الوسط، وتحته أمثلته (الكلمة وما يُنطق)
/// تُسمع بالضغط عليها.
class _RuleCard extends StatelessWidget {
  const _RuleCard({
    required this.lines,
    this.exampleStyle = _blue,
    this.inline = false,
  });
  final List<(InlineSpan, List<(String, String)>)> lines;
  final TextStyle exampleStyle;

  /// الأمثلة في سطر النص نفسه بعد «، مثل» بدل سطر وحدها.
  final bool inline;

  /// «مثل ( … ـ … )» والأمثلة تُسمع بالضغط عليها.
  InlineSpan _examplesSpan(
    BuildContext context,
    List<(String, String)> examples,
  ) => TextSpan(
    children: [
      const TextSpan(text: 'مثل ( '),
      for (final (i, (w, spoken)) in examples.indexed) ...[
        if (i > 0) const TextSpan(text: ' ـ '),
        _example(
          context,
          w,
          spoken,
          style: exampleStyle.copyWith(fontSize: 21, height: 1.4),
        ),
      ],
      const TextSpan(text: ' )'),
    ],
  );

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
    decoration: BoxDecoration(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.lineDark),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (k, (span, examples)) in lines.indexed) ...[
          if (k > 0) const SizedBox(height: 6),
          if (inline)
            Text.rich(
              TextSpan(
                children: [
                  span,
                  if (examples.isNotEmpty) ...[
                    const TextSpan(text: '، '),
                    _examplesSpan(context, examples),
                  ],
                ],
              ),
              textAlign: TextAlign.center,
              style: AppTheme.word(20).copyWith(height: 1.6),
            )
          else ...[
            Text.rich(
              span,
              textAlign: TextAlign.center,
              style: AppTheme.word(20).copyWith(height: 1.6),
            ),
            if (examples.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text.rich(
                _examplesSpan(context, examples),
                textAlign: TextAlign.center,
                style: AppTheme.word(20).copyWith(height: 1.4),
              ),
            ],
          ],
        ],
      ],
    ),
  );
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
