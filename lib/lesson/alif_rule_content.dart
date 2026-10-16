import 'package:flutter/material.dart';

import '../app_state.dart';
import '../data/alif_lesson.dart';
import '../data/alif_verb_lesson.dart';
import '../services/speaker.dart';
import '../theme.dart';
import '../utils/arabic.dart';
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
    this.lastRed = false,
  });

  final String title;
  final String letter;
  final String word;
  final String spoken;
  final bool lastRed;

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
      _BoxExample(word, spoken, lastRed: lastRed),
    ],
  );
}

/// مثال بين قوسين تحت المربع، يُسمع بالضغط عليه.
class _BoxExample extends StatelessWidget {
  const _BoxExample(this.word, this.spoken, {this.lastRed = false});
  final String word;
  final String spoken;

  /// الحرف الأخير بالأحمر (صورة الألف) وبقية الكلمة بالأسود.
  final bool lastRed;

  @override
  Widget build(BuildContext context) => Text.rich(
    TextSpan(
      children: [
        const TextSpan(text: '( '),
        if (lastRed)
          _tapWord(context, spoken, _lastRedSpan(word, size: 24))
        else
          _example(context, word, spoken),
        const TextSpan(text: ' )'),
      ],
    ),
    style: AppTheme.word(24),
  );
}

/// الكلمة وحرفها الأخير بالأحمر.
TextSpan _lastRedSpan(String word, {double size = 24, int red = 1}) => TextSpan(
  style: AppTheme.word(size),
  children: [
    TextSpan(text: word.substring(0, word.length - red)),
    TextSpan(
      text: word.substring(word.length - red, word.length - red + 1),
      style: _red,
    ),
    if (red > 1) TextSpan(text: word.substring(word.length - red + 1)),
  ],
);

/// [span] يُسمع بالضغط عليه.
InlineSpan _tapWord(BuildContext context, String spoken, InlineSpan span) =>
    WidgetSpan(
      alignment: PlaceholderAlignment.middle,
      child: GestureDetector(
        onTap: () => _say(context, spoken),
        child: Text.rich(span),
      ),
    );

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

// ——— الألف اللّينة في الأفعال ———

/// ص ١: الفرق بين الألف المقصورة (بكى) والممدودة (دعا).
class VerbAlifBasicsRule extends StatelessWidget {
  const VerbAlifBasicsRule({super.key});

  @override
  Widget build(BuildContext context) {
    final [q, m] = [for (final w in verbRuleExamples) alifVerb(w)];
    return NaskhRule(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _AlifBranch(
                title: 'الألف المقصورة',
                letter: 'ى',
                word: q.word,
                spoken: q.spoken,
                lastRed: true,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _AlifBranch(
                title: 'الألف الممدودة',
                letter: 'ا',
                word: m.word,
                spoken: m.spoken,
                lastRed: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// الفعل ← الفعل مع تاء الفاعل، والألف وما انقلبت إليه بالأحمر.
class _TaPair extends StatelessWidget {
  const _TaPair(this.verb);
  final AlifVerb verb;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Text.rich(
      TextSpan(
        children: [
          _tapWord(context, verb.spoken, _lastRedSpan(verb.word, size: 26)),
          // سهم من الفعل إلى ما بعده (يتجه يسارًا في الكتابة من اليمين).
          const WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 14),
              child: Icon(Icons.arrow_forward_rounded, color: AppColors.ink),
            ),
          ),
          _tapWord(
            context,
            verb.spokenTa,
            _lastRedSpan(verb.withTa, size: 26, red: 2),
          ),
        ],
      ),
      textAlign: TextAlign.center,
      style: AppTheme.word(26),
    ),
  );
}

/// ص ٢: القاعدة؛ أسند الفعل إلى تاء الفاعل.
class VerbAlifRule extends StatelessWidget {
  const VerbAlifRule({super.key, this.heading = true});

  /// العنوان الأحمر «القاعدة» فوقها.
  final bool heading;

  @override
  Widget build(BuildContext context) => NaskhRule(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (heading) const _CenterHeading('القاعدة'),
        Text.rich(
          const TextSpan(
            children: [
              TextSpan(text: 'عندما تحتار في كتابة الألف في '),
              TextSpan(text: 'الفعل الثلاثي', style: _red),
              TextSpan(text: '، أسند الفعل إلى نفسك بـ'),
              TextSpan(text: '(تاء الفاعل)', style: _red),
              TextSpan(text: '، مثل:'),
            ],
          ),
          textAlign: TextAlign.center,
          style: AppTheme.word(21).copyWith(height: 1.7),
        ),
        const SizedBox(height: 4),
        for (final w in verbRuleExamples) _TaPair(alifVerb(w)),
        const SizedBox(height: 10),
        const _RuleCard(
          lines: [
            (
              TextSpan(
                children: [
                  TextSpan(text: '١- إذا نطقت '),
                  TextSpan(text: '(الياء)', style: _red),
                  TextSpan(text: ' فاكتب الألف '),
                  TextSpan(text: 'مقصورة', style: _red),
                ],
              ),
              [],
            ),
            (
              TextSpan(
                children: [
                  TextSpan(text: '٢- إذا نطقت '),
                  TextSpan(text: '(الواو)', style: _red),
                  TextSpan(text: ' فاكتب الألف '),
                  TextSpan(text: 'ممدودة', style: _red),
                ],
              ),
              [],
            ),
          ],
        ),
      ],
    ),
  );
}

/// حروف الكلمة في مربعات، والمربع [mark] بالأحمر.
class _LetterRow extends StatelessWidget {
  const _LetterRow(this.word, this.mark);
  final String word;
  final int mark;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (final (i, l) in word.split('').indexed)
          Container(
            width: 48,
            height: 48,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: i == mark ? AppColors.errorSoft : AppColors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: i == mark ? AppColors.al : AppColors.ink,
                width: 1.6,
              ),
            ),
            child: Text(
              l,
              style: AppTheme.word(
                24,
                color: i == mark ? AppColors.al : AppColors.ink,
              ),
            ),
          ),
      ],
    ),
  );
}

/// ص ٣: لاحظ كيف تنقلب الألف إلى الياء (طوى) وإلى الواو (عفا).
class VerbAlifTurnRule extends StatelessWidget {
  const VerbAlifTurnRule({super.key});

  @override
  Widget build(BuildContext context) => NaskhRule(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (i, w) in verbTurnExamples.indexed) ...[
          if (i > 0) const SizedBox(height: 18),
          Builder(
            builder: (context) {
              final v = alifVerb(w);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text.rich(
                    TextSpan(
                      children: [
                        const TextSpan(text: 'لاحظ كيف تنقلب '),
                        const TextSpan(text: '(الألف)', style: _red),
                        const TextSpan(text: ' إلى '),
                        TextSpan(text: '(${v.turnsTo})', style: _red),
                      ],
                    ),
                    textAlign: TextAlign.center,
                    style: AppTheme.word(21).copyWith(height: 1.6),
                  ),
                  _TaPair(v),
                  _LetterRow(v.word, v.word.length - 1),
                  _LetterRow(v.withTa, v.withTa.length - 2),
                ],
              );
            },
          ),
        ],
      ],
    ),
  );
}

/// ص ٦: المثال المحلول؛ الإجابات الصحيحة بالأحمر.
class VerbExampleTable extends StatelessWidget {
  const VerbExampleTable({super.key});

  @override
  Widget build(BuildContext context) {
    final s = verbExampleSentence;
    final v = alifVerb(s.verb);
    Widget cell(String text, {bool right = false, bool label = false}) =>
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              text,
              style: AppTheme.word(
                label ? 19 : 22,
                color: right ? AppColors.al : AppColors.ink,
              ),
            ),
          ),
        );
    Widget choices(String a, String b, String answer) => Row(
      children: [
        for (final o in [a, b]) Expanded(child: cell(o, right: o == answer)),
      ],
    );
    return NaskhRule(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text.rich(
            TextSpan(
              children: [
                const TextSpan(text: '( '),
                _tapWord(
                  context,
                  s.spoken,
                  TextSpan(
                    children: [
                      TextSpan(text: v.word, style: _red),
                      TextSpan(
                        text: stripDiacritics(
                          s.spoken.substring(v.spoken.length),
                        ),
                      ),
                    ],
                    style: AppTheme.word(26),
                  ),
                ),
                const TextSpan(text: ' )'),
              ],
            ),
            textAlign: TextAlign.center,
            style: AppTheme.word(26),
          ),
          const SizedBox(height: 12),
          Table(
            border: TableBorder.all(
              color: AppColors.lineDark,
              borderRadius: BorderRadius.circular(12),
            ),
            columnWidths: const {0: FlexColumnWidth(5), 1: FlexColumnWidth(6)},
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: [
              TableRow(
                children: [
                  cell('الفعل', label: true),
                  cell(v.word, right: true),
                ],
              ),
              TableRow(
                children: [
                  cell('+ تاء الفاعل', label: true),
                  cell(v.withTa, right: true),
                ],
              ),
              TableRow(
                children: [
                  cell('انقلبت الألف إلى', label: true),
                  choices('الياء', 'الواو', v.turnsTo),
                ],
              ),
              TableRow(
                children: [
                  cell('تُكتب بالألف', label: true),
                  choices('المقصورة', 'الممدودة', v.alifKind),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// ص ١٠: «احفظ هاتين القاعدتين جيدًا للاختبار».
class VerbAlifRemember extends StatelessWidget {
  const VerbAlifRemember({super.key});

  @override
  Widget build(BuildContext context) => const NaskhRule(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _RememberBox(
          '١',
          TextSpan(
            children: [
              TextSpan(text: 'إذا انقلبت '),
              TextSpan(text: '(الألف)', style: _red),
              TextSpan(text: ' في الفعل الثلاثي إلى '),
              TextSpan(text: '(الواو)', style: _red),
              TextSpan(text: ' تُكتب '),
              TextSpan(text: 'ممدودة', style: _blue),
            ],
          ),
        ),
        _RememberBox(
          '٢',
          TextSpan(
            children: [
              TextSpan(text: 'إذا انقلبت '),
              TextSpan(text: '(الألف)', style: _red),
              TextSpan(text: ' في الفعل الثلاثي إلى '),
              TextSpan(text: '(الياء)', style: _red),
              TextSpan(text: ' تُكتب '),
              TextSpan(text: 'مقصورة', style: _blue),
            ],
          ),
        ),
      ],
    ),
  );
}

/// ص ١ (الأفعال غير الثلاثية): القاعدتان، ومعهما زر «إضاءة» (يحيى ويحيا).
class LongVerbRule extends StatelessWidget {
  const LongVerbRule({super.key, this.light = true});

  /// زر «إضاءة» فوق القاعدة.
  final bool light;

  @override
  Widget build(BuildContext context) => NaskhRule(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (light) ...[
          AppButton(
            key: const ValueKey('verb-light'),
            label: '💡 إضاءة',
            style: AppButtonStyle.outline,
            height: 48,
            onTap: () => showRuleSheet(
              context,
              title: '💡 إضاءة',
              content: const LongVerbLight(),
            ),
          ),
          const SizedBox(height: 8),
        ],
        const _CenterHeading('القاعدة ١'),
        const _RuleCard(
          lines: [
            (
              TextSpan(
                children: [
                  TextSpan(text: 'كل '),
                  TextSpan(text: 'فعل غير ثلاثي', style: _red),
                  TextSpan(text: ' وينتهي بالألف يُكتب بالألف '),
                  TextSpan(text: 'المقصورة (ى)', style: _red),
                ],
              ),
              longVerbMaqsuraExamples,
            ),
          ],
        ),
        const _CenterHeading('القاعدة ٢'),
        const _RuleCard(
          lines: [
            (
              TextSpan(
                children: [
                  TextSpan(text: 'كل '),
                  TextSpan(text: 'فعل غير ثلاثي', style: _red),
                  TextSpan(text: ' وينتهي بالألف '),
                  TextSpan(text: 'وقبلها (ياء)', style: _red),
                  TextSpan(text: ' يُكتب بالألف '),
                  TextSpan(text: 'الممدودة (ا)', style: _red),
                ],
              ),
              longVerbYaExamples,
            ),
          ],
        ),
      ],
    ),
  );
}

/// ص ٢: «إضاءة»: يحيى اسم بالمقصورة، ويحيا فعل بالممدودة.
class LongVerbLight extends StatelessWidget {
  const LongVerbLight({super.key});

  @override
  Widget build(BuildContext context) => NaskhRule(
    child: _LightTable(
      header: true,
      rows: [
        const [
          _LightCell('الكلمة'),
          _LightCell('نوعها'),
          _LightCell('تُكتب بـ'),
        ],
        for (final (w, kind, alif) in longVerbLight)
          [
            _LightCell(w, color: AppColors.blue),
            _LightCell(kind, color: AppColors.al),
            _LightCell(alif),
          ],
      ],
    ),
  );
}

/// نافذة «القاعدة» لدرس الألف اللّينة في الأفعال.
class AlifVerbRuleContent extends StatelessWidget {
  const AlifVerbRuleContent({super.key});

  @override
  Widget build(BuildContext context) => const Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      NaskhRule(child: _Heading('الألف اللّينة في الفعل الثلاثي')),
      VerbAlifBasicsRule(),
      VerbAlifRule(),
      NaskhRule(child: _Heading('الألف اللّينة في الأفعال غير الثلاثية')),
      LongVerbRule(),
    ],
  );
}
