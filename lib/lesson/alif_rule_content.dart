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

/// مربع صغير فيه صورة الألف أو العدد (ص ١).
WidgetSpan _shape(String s) => WidgetSpan(
  alignment: PlaceholderAlignment.middle,
  child: Container(
    margin: const EdgeInsets.symmetric(horizontal: 4),
    padding: const EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: AppColors.al, width: 1.5),
    ),
    child: Text(s, style: AppTheme.word(26, color: AppColors.al)),
  ),
);

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

/// ص ١: الألف الممدودة والمقصورة، والاسم الثلاثي.
class AlifBasicsRule extends StatelessWidget {
  const AlifBasicsRule({super.key});

  @override
  Widget build(BuildContext context) {
    final [(mw, ms), (qw, qs), (tw, ts)] = alifRuleExamples;
    return NaskhRule(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Line(
            TextSpan(
              children: [
                const TextSpan(text: 'الألف الممدودة', style: _red),
                const TextSpan(text: ' تُكتب هكذا '),
                _shape('ا'),
                const TextSpan(text: ' مثل ( '),
                _example(context, mw, ms),
                const TextSpan(text: ' )'),
              ],
            ),
          ),
          _Line(
            TextSpan(
              children: [
                const TextSpan(text: 'الألف المقصورة', style: _red),
                const TextSpan(text: ' تُكتب هكذا '),
                _shape('ى'),
                const TextSpan(text: ' مثل ( '),
                _example(context, qw, qs),
                const TextSpan(text: ' )'),
              ],
            ),
          ),
          const SizedBox(height: 8),
          _Line(
            TextSpan(
              children: [
                const TextSpan(text: 'الاسم الثلاثي', style: _red),
                const TextSpan(text: ' هو الذي يتكوّن من '),
                _shape('٣'),
                const TextSpan(text: ' حروف أصلية، مثل ( '),
                _example(context, tw, ts),
                const TextSpan(text: ' )'),
              ],
            ),
          ),
        ],
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
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 16,
          children: [
            for (final w in irregularMaqsura)
              Text(w, style: AppTheme.word(26, color: AppColors.blue)),
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
        for (final (w, kind) in twoWayWords)
          _Line(
            TextSpan(
              children: [
                const TextSpan(text: '   • ( '),
                TextSpan(text: w, style: _blue),
                TextSpan(text: ' ) ـ $kind'),
              ],
            ),
          ),
      ],
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
