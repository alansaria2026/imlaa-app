import 'dart:math';

import 'package:flutter/material.dart';

import '../app_state.dart';
import '../data/hamza_lesson.dart';
import '../data/lam_lesson.dart';
import '../services/speaker.dart';
import '../theme.dart';
import '../utils/arabic.dart';
import '../widgets/common.dart';
import '../widgets/pressable.dart';
import 'pages/quiz_page.dart';
import 'rule_content.dart';

/// همزة القطع بالأزرق وهمزة الوصل بالأحمر (كـ«ال» التعريف، وهي وصل دائمًا).
Color hamzaColor(Hamza h) => h == Hamza.qat ? AppColors.blue : AppColors.al;

void _say(BuildContext context, String text) =>
    Speaker.instance.speak(text, rate: AppScope.read(context).speechRate);

/// الكلمة وحرفها الأول (الهمزة) ملوّن.
TextSpan _hamzaWord(String word, Hamza h) => TextSpan(
  children: [
    TextSpan(
      text: word.substring(0, 1),
      style: TextStyle(color: hamzaColor(h)),
    ),
    TextSpan(text: word.substring(1)),
  ],
);

class _Heading extends StatelessWidget {
  const _Heading(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 18, bottom: 8),
    child: Text(
      text,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w800,
        color: AppColors.primary,
      ),
    ),
  );
}

class _Line extends StatelessWidget {
  const _Line(this.span);
  final InlineSpan span;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Text.rich(
      span,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
    ),
  );
}

class _Box extends StatelessWidget {
  const _Box({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: BoxDecoration(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(16),
    ),
    child: child,
  );
}

TextSpan _colored(String text, Color color) => TextSpan(
  text: text,
  style: TextStyle(color: color),
);

/// ص ١–٣: الفرق بين الهمزتين، والقاعدة الذهبية (أدخل «ثم»).
/// في صفحة المثال تظهر صورتا الهمزة وحدهما، والقاعدة الذهبية في «مساعدة».
class HamzaBasicsRule extends StatelessWidget {
  const HamzaBasicsRule({super.key, this.golden = true});

  /// تُعرض القاعدة الذهبية وأمثلتها تحت صورتي الهمزة.
  final bool golden;

  @override
  Widget build(BuildContext context) => NaskhRule(
    child: Builder(
      builder: (context) {
        final t = Theme.of(context).textTheme;
        // مستطيل من ثلاثة حقول رأسية: الاسم، والصورة، وموضع النطق.
        Widget card(Hamza h, String letters, String where) {
          Widget field(Widget child) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            child: Center(child: child),
          );
          const divider = Divider(
            height: 1.2,
            thickness: 1.2,
            color: AppColors.ink,
          );
          return Expanded(
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.ink, width: 1.2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  field(
                    Text(
                      h.label,
                      style: t.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: hamzaColor(h),
                      ),
                    ),
                  ),
                  divider,
                  field(
                    Text(
                      letters,
                      style: AppTheme.word(40, color: hamzaColor(h)),
                    ),
                  ),
                  divider,
                  field(
                    Text(
                      where,
                      textAlign: TextAlign.center,
                      style: t.bodyLarge,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  card(Hamza.qat, 'أ   إ', 'تُنطق في أول الكلام وفي وسطه'),
                  const SizedBox(width: 10),
                  card(
                    Hamza.wasl,
                    'ا',
                    'تُنطق في أول الكلام ولا تُنطق في وسطه',
                  ),
                ],
              ),
            ),
            if (golden) const HamzaGoldenRule(),
          ],
        );
      },
    ),
  );
}

/// القاعدة الذهبية (أدخل «ثم») وأمثلتها التي تُسمع بالضغط عليها.
class HamzaGoldenRule extends StatelessWidget {
  const HamzaGoldenRule({super.key});

  @override
  Widget build(BuildContext context) => NaskhRule(
    child: Builder(
      builder: (context) {
        final t = Theme.of(context).textTheme;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _Heading('القاعدة الذهبية'),
            const _Line(TextSpan(text: 'أدخل (ثم) قبل الكلمة وانطقها:')),
            _Line(
              TextSpan(
                children: [
                  const TextSpan(text: '• إذا اختفت الهمزة فهي '),
                  _colored('همزة وصل', hamzaColor(Hamza.wasl)),
                ],
              ),
            ),
            _Line(
              TextSpan(
                children: [
                  const TextSpan(text: '• إذا ظهرت الهمزة فهي '),
                  _colored('همزة قطع', hamzaColor(Hamza.qat)),
                ],
              ),
            ),
            const SizedBox(height: 8),
            for (final (spoken, verb, h) in goldenRuleExamples) ...[
              Material(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => _say(context, spoken),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      children: [
                        MarkedSentence(
                          stripDiacritics(spoken),
                          mark: verb,
                          size: 24,
                        ),
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: h == Hamza.wasl
                                    ? 'اختفت الهمزة: '
                                    : 'ظهرت الهمزة: ',
                              ),
                              _colored(h.label, hamzaColor(h)),
                            ],
                          ),
                          style: t.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ],
        );
      },
    ),
  );
}

/// مستطيل بإطار يحيط بالمحتوى.
BoxDecoration _framed() => BoxDecoration(
  color: AppColors.background,
  borderRadius: BorderRadius.circular(16),
  border: Border.all(color: AppColors.ink, width: 1.2),
);

/// ص ٧–٨ و١٠: همزة (ال) التعريف همزة وصل دائمًا (نافذة «القاعدة» كاملة).
class AlHamzaRule extends StatelessWidget {
  const AlHamzaRule({super.key});

  @override
  Widget build(BuildContext context) => const Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      AlStatementRule(),
      NaskhRule(child: _Heading('إضافة (ال) التعريف إلى الأسماء')),
      AlExamplesRule(),
      AlRememberRule(),
    ],
  );
}

/// القاعدة في مستطيل، وتحتها كلماتها في مستطيلات متساوية: ثلاث فوق وثلاث تحت.
class AlStatementRule extends StatelessWidget {
  const AlStatementRule({super.key});

  @override
  Widget build(BuildContext context) => NaskhRule(
    child: Builder(
      builder: (context) {
        Widget word(String w) => Expanded(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => _say(context, spokenForm(w)),
              child: Container(
                height: 64,
                padding: const EdgeInsets.symmetric(horizontal: 6),
                decoration: _framed(),
                alignment: Alignment.center,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: AlText(w, size: 28),
                ),
              ),
            ),
          ),
        );
        Widget row(Iterable<String> words) => Row(
          children: [
            for (final (i, w) in words.indexed) ...[
              if (i > 0) const SizedBox(width: 10),
              word(w),
            ],
          ],
        );
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: _framed(),
              child: Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(text: 'همزة '),
                    _colored('(ال)', AppColors.al),
                    const TextSpan(text: ' التعريف همزة وصل دائمًا'),
                  ],
                ),
                textAlign: TextAlign.center,
                style: AppTheme.word(24),
              ),
            ),
            const SizedBox(height: 14),
            row(alRuleWords.take(3)),
            const SizedBox(height: 10),
            row(alRuleWords.skip(3).take(3)),
          ],
        );
      },
    ),
  );
}

/// أمثلة إضافة (ال) التعريف إلى الأسماء: قلب + ال = القلب.
class AlExamplesRule extends StatelessWidget {
  const AlExamplesRule({super.key});

  @override
  Widget build(BuildContext context) => NaskhRule(
    child: Builder(
      builder: (context) {
        final op = Theme.of(context).textTheme.titleLarge?.copyWith(
          color: AppColors.muted,
          fontWeight: FontWeight.w700,
        );
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final w in alExampleWords)
              InkWell(
                onTap: () => Speaker.instance.speakAll([
                  spokenForm(w),
                  spokenForm('ال$w'),
                ], rate: AppScope.read(context).speechRate),
                // يصغر السطر كله على الشاشات الضيقة بدل أن يتجاوزها.
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AlText(w, size: 28),
                      const SizedBox(width: 8),
                      Text('+', style: op),
                      const SizedBox(width: 8),
                      const AlBox(size: 18, text: 'ال'),
                      const SizedBox(width: 8),
                      Text('=', style: op),
                      const SizedBox(width: 8),
                      AlText('ال$w', size: 28),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    ),
  );
}

/// «تذكّر»: (ال) لا تدخل إلا على الأسماء، وتبدأ بهمزة الوصل.
class AlRememberRule extends StatelessWidget {
  const AlRememberRule({super.key});

  @override
  Widget build(BuildContext context) => NaskhRule(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _Heading('تذكّر'),
        const _Line(TextSpan(text: '• (ال) التعريف لا تدخل إلا على الأسماء')),
        _Line(
          TextSpan(
            children: [
              const TextSpan(text: '• (ال) التعريف دائمًا تبدأ بـ'),
              _colored('همزة الوصل', AppColors.al),
            ],
          ),
        ),
      ],
    ),
  );
}

/// ص ١١–١٢: وزن الفعل = عدد حروف الفعل الماضي (نافذة «القاعدة» كاملة).
class WeightRule extends StatelessWidget {
  const WeightRule({super.key});

  @override
  Widget build(BuildContext context) => const Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      WeightLettersRule(),
      NaskhRule(child: _Heading('أمثلة')),
      WeightExamplesRule(),
    ],
  );
}

/// الأفعال الأربعة بحروفها المرقّمة في وسط الصفحة على شكل هرم،
/// ثم القاعدة: الوزن = عدد حروف الفعل الماضي.
class WeightLettersRule extends StatelessWidget {
  const WeightLettersRule({super.key});

  @override
  Widget build(BuildContext context) => NaskhRule(
    child: Builder(
      builder: (context) {
        final t = Theme.of(context).textTheme;
        // سطرا القاعدة أكبر من عناوين الأفعال.
        final bold = t.titleMedium?.copyWith(
          fontSize: 22,
          fontWeight: FontWeight.w800,
        );
        Widget letters(String word) => Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < word.length; i++)
              Container(
                width: 34,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                padding: const EdgeInsets.only(bottom: 2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.line, width: 1.5),
                ),
                child: Column(
                  children: [
                    Text(
                      word[i],
                      style: AppTheme.word(22, color: AppColors.al),
                    ),
                    Text(arDigits(i + 1), style: t.labelSmall),
                  ],
                ),
              ),
          ],
        );
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final (word, weight) in weightExampleLetters) ...[
              FittedBox(fit: BoxFit.scaleDown, child: letters(word)),
              const SizedBox(height: 2),
              Text(
                'فعل ${weight.label}',
                textAlign: TextAlign.center,
                style: t.titleSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
            ],
            _Box(
              child: Column(
                children: [
                  Text(
                    'لمعرفة وزن الفعل نحوّله إلى الماضي',
                    textAlign: TextAlign.center,
                    style: bold,
                  ),
                  Text.rich(
                    TextSpan(
                      children: [
                        _colored('الوزن', AppColors.blue),
                        const TextSpan(text: ' = '),
                        _colored('عدد حروف الفعل الماضي', AppColors.red),
                      ],
                    ),
                    textAlign: TextAlign.center,
                    style: bold,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    ),
  );
}

/// أمثلة الوزن في جدول: الفعل، وتحويله للماضي، ووزنه.
class WeightExamplesRule extends StatelessWidget {
  const WeightExamplesRule({super.key});

  @override
  Widget build(BuildContext context) => NaskhRule(
    child: Builder(
      builder: (context) {
        final t = Theme.of(context).textTheme;
        Widget cell(Widget child) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
          child: Center(
            child: FittedBox(fit: BoxFit.scaleDown, child: child),
          ),
        );
        Widget head(String text) => cell(
          Text(
            text,
            style: t.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
        );
        return Table(
          border: TableBorder.all(
            color: AppColors.ink,
            width: 1.2,
            borderRadius: BorderRadius.circular(12),
          ),
          columnWidths: const {
            0: FlexColumnWidth(),
            1: FlexColumnWidth(1.6),
            2: FlexColumnWidth(),
          },
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: [
            TableRow(
              decoration: const BoxDecoration(color: AppColors.primarySoft),
              children: [head('الفعل'), head('تحويل للماضي'), head('الوزن')],
            ),
            for (final (present, past, weight) in weightExampleVerbs)
              TableRow(
                children: [
                  cell(Text(present, style: AppTheme.word(28))),
                  cell(
                    Text(
                      '(${past.split('').join('-')})',
                      style: AppTheme.word(28, color: AppColors.al),
                    ),
                  ),
                  cell(Text(weight.label, style: AppTheme.word(28))),
                ],
              ),
          ],
        );
      },
    ),
  );
}

/// ص ١٣ مكرر: القاعدة العامة لهمزة الأفعال: جدول لكل زمن، صف لأوزانه
/// وتحته الهمزة، وتُدمج خانات الأوزان المتتالية التي لها الهمزة نفسها.
class VerbChartRule extends StatelessWidget {
  const VerbChartRule({super.key});

  static const _tenseTitles = {
    Tense.present: 'الفعل المضارع',
    Tense.past: 'الفعل الماضي',
    Tense.imperative: 'فعل الأمر',
  };

  @override
  Widget build(BuildContext context) => NaskhRule(
    child: Builder(
      builder: (context) {
        final t = Theme.of(context).textTheme;
        const side = BorderSide(color: AppColors.ink, width: 1.2);
        // خانة بفاصل بعدها؛ الحدود الخارجية من إطار الجدول.
        Widget cell(
          String text, {
          int flex = 1,
          Color fill = AppColors.surface,
          Color color = AppColors.ink,
          double size = 18,
          double height = 42,
          bool last = false,
        }) => Expanded(
          flex: flex,
          child: Container(
            height: height,
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            decoration: BoxDecoration(
              color: fill,
              border: BorderDirectional(end: last ? BorderSide.none : side),
            ),
            alignment: Alignment.center,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(text, style: AppTheme.word(size, color: color)),
            ),
          ),
        );
        Widget table(Tense tense) {
          // أوزان متتالية لها الهمزة نفسها تُدمج في خانة واحدة.
          final groups = <(Hamza, int)>[];
          for (final w in Weight.values) {
            final h = hamzaOf(tense, w);
            if (groups.isNotEmpty && groups.last.$1 == h) {
              groups.last = (h, groups.last.$2 + 1);
            } else {
              groups.add((h, 1));
            }
          }
          return Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.ink, width: 1.2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  color: AppColors.primarySoft,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    _tenseTitles[tense]!,
                    textAlign: TextAlign.center,
                    style: t.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ),
                const Divider(
                  height: 1.2,
                  thickness: 1.2,
                  color: AppColors.ink,
                ),
                Row(
                  children: [
                    for (final (i, w) in Weight.values.indexed)
                      cell('ال${w.label}', last: i == Weight.values.length - 1),
                  ],
                ),
                const Divider(
                  height: 1.2,
                  thickness: 1.2,
                  color: AppColors.ink,
                ),
                Row(
                  children: [
                    for (final (i, (h, span)) in groups.indexed)
                      cell(
                        h.label,
                        flex: span,
                        size: 22,
                        height: 50,
                        color: hamzaColor(h),
                        fill: h == Hamza.qat
                            ? AppColors.successSoft
                            : AppColors.errorSoft,
                        last: i == groups.length - 1,
                      ),
                  ],
                ),
              ],
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final (i, tense) in [
              Tense.present,
              Tense.past,
              Tense.imperative,
            ].indexed) ...[if (i > 0) const SizedBox(height: 16), table(tense)],
          ],
        );
      },
    ),
  );
}

/// مثال محلول لقاعدة من قواعد الأفعال (ص ١٤ وما بعدها): الفعل بالأحمر،
/// والإجابات الصحيحة بالأزرق، ثم القاعدة.
class VerbComboExample extends StatelessWidget {
  const VerbComboExample(this.combo, {super.key});
  final VerbCombo combo;

  @override
  Widget build(BuildContext context) => NaskhRule(
    child: Builder(
      builder: (context) {
        final t = Theme.of(context).textTheme;
        final s = combo.example;
        Widget row(int n, List<String> options, String answer) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: '${arDigits(n)}- '),
                    _colored(s.verb, AppColors.al),
                  ],
                ),
                style: AppTheme.word(22),
              ),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 6,
                children: [
                  for (final o in options)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: o == answer
                            ? AppColors.primarySoft
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: o == answer ? AppColors.blue : AppColors.line,
                          width: 2,
                        ),
                      ),
                      child: Text(
                        o,
                        style: AppTheme.word(
                          20,
                          color: o == answer ? AppColors.blue : AppColors.muted,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InkWell(
              onTap: () => _say(context, s.spoken),
              child: MarkedSentence('( ${s.text} )', mark: s.verb),
            ),
            const SizedBox(height: 8),
            row(1, [for (final x in Tense.values) x.label], s.tense.label),
            row(2, [for (final x in Weight.values) x.label], s.weight.label),
            row(3, [for (final x in Hamza.values) x.label], s.hamza.label),
            _Box(
              child: Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(text: 'القاعدة: ('),
                    _colored(combo.tense.label, AppColors.al),
                    const TextSpan(text: ' + '),
                    _colored('فعل ${combo.weight.label}', AppColors.al),
                    const TextSpan(text: ') = '),
                    _colored(combo.hamza.label, AppColors.blue),
                  ],
                ),
                textAlign: TextAlign.center,
                style: t.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        );
      },
    ),
  );
}

/// ص ٤١–٤٤: المصدر وهمزته، بجدول صاحب التطبيق: التعريف، ثم المثال، ثم القاعدة.
class MasdarRule extends StatelessWidget {
  const MasdarRule({super.key});

  @override
  Widget build(BuildContext context) => NaskhRule(
    child: Builder(
      builder: (context) {
        final t = Theme.of(context).textTheme;
        final head = t.titleSmall?.copyWith(
          fontWeight: FontWeight.w800,
          color: AppColors.muted,
        );
        final cell = t.titleMedium?.copyWith(fontWeight: FontWeight.w600);
        Widget c(String s, TextStyle? style) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          child: Text(s, textAlign: TextAlign.center, style: style),
        );
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Box(
              child: Text.rich(
                TextSpan(
                  children: [
                    _colored('المصدر', AppColors.al),
                    const TextSpan(text: ': هو الاسم الذي يُستخرج من الفعل.'),
                  ],
                ),
                textAlign: TextAlign.center,
                style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            const _Heading('مثال'),
            Table(
              border: TableBorder.all(
                color: AppColors.line,
                borderRadius: BorderRadius.circular(12),
              ),
              children: [
                TableRow(children: [c('الفعل', head), c('المصدر', head)]),
                for (final (verb, masdar) in masdarExamples)
                  TableRow(
                    children: [
                      c(verb, cell),
                      c(masdar, cell?.copyWith(color: AppColors.al)),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 14),
            _Line(
              TextSpan(
                children: [
                  const TextSpan(text: 'مصدر الخماسي والسداسي همزته '),
                  _colored('(وصل)', hamzaColor(Hamza.wasl)),
                ],
              ),
            ),
          ],
        );
      },
    ),
  );
}

/// ص ٥١: همزة الأسماء: القواعد الثلاث، والأمثلة في جدول يفتحه زر «إضاءة».
class NounHamzaRule extends StatelessWidget {
  const NounHamzaRule({super.key});

  @override
  Widget build(BuildContext context) => NaskhRule(
    child: Builder(
      builder: (context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Line(
            TextSpan(
              children: [
                const TextSpan(
                  text: '• جميع الأسماء (الأعلام) المبدوءة بالهمزة همزتها ',
                ),
                _colored('قطع', hamzaColor(Hamza.qat)),
              ],
            ),
          ),
          _Line(
            TextSpan(
              children: [
                TextSpan(text: '• ${waslNouns.join('، ')} همزتها '),
                _colored('وصل', hamzaColor(Hamza.wasl)),
                const TextSpan(text: ' دائمًا'),
              ],
            ),
          ),
          _Line(
            TextSpan(
              children: [
                const TextSpan(text: '• (ال) التعريف همزتها '),
                _colored('وصل', hamzaColor(Hamza.wasl)),
                const TextSpan(text: ' دائمًا'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppButton(
            key: const ValueKey('noun-hamza-light'),
            label: '💡 إضاءة',
            style: AppButtonStyle.outline,
            height: 48,
            onTap: () => showNounHamzaTable(context),
          ),
        ],
      ),
    ),
  );
}

/// «إضاءة»: أمثلة همزة الأسماء في جدول من ثلاثة أعمدة.
Future<void> showNounHamzaTable(BuildContext context) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '💡 إضاءة',
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              const NounHamzaTable(),
            ],
          ),
        ),
      ),
    );

/// جدول الأمثلة: الأعلام (قطع)، والأسماء الستة (وصل)، و(ال) التعريف (وصل).
class NounHamzaTable extends StatelessWidget {
  const NounHamzaTable({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final columns = <(InlineSpan, List<InlineSpan>)>[
      (
        TextSpan(
          children: [
            const TextSpan(text: 'الأعلام\n'),
            _colored('قطع', hamzaColor(Hamza.qat)),
          ],
        ),
        [for (final w in qatNames) _hamzaWord(w, Hamza.qat)],
      ),
      (
        TextSpan(
          children: [
            const TextSpan(text: 'أسماء\n'),
            _colored('وصل', hamzaColor(Hamza.wasl)),
          ],
        ),
        [for (final w in waslNouns) _hamzaWord(w, Hamza.wasl)],
      ),
      (
        TextSpan(
          children: [
            const TextSpan(text: '(ال) التعريف\n'),
            _colored('وصل', hamzaColor(Hamza.wasl)),
          ],
        ),
        [
          for (final w in alNounExamples)
            TextSpan(
              children: [
                _colored(w.substring(0, 2), hamzaColor(Hamza.wasl)),
                TextSpan(text: w.substring(2)),
              ],
            ),
        ],
      ),
    ];
    final rows = columns.map((c) => c.$2.length).reduce(max);
    Widget cell(InlineSpan? span, TextStyle? style) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      child: span == null
          ? const SizedBox.shrink()
          : Text.rich(span, textAlign: TextAlign.center, style: style),
    );
    return Table(
      border: TableBorder.all(
        color: AppColors.line,
        borderRadius: BorderRadius.circular(12),
      ),
      children: [
        TableRow(
          decoration: const BoxDecoration(color: AppColors.background),
          children: [
            for (final (head, _) in columns)
              cell(head, t.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
          ],
        ),
        for (var r = 0; r < rows; r++)
          TableRow(
            children: [
              for (final (_, words) in columns)
                cell(r < words.length ? words[r] : null, AppTheme.word(24)),
            ],
          ),
      ],
    );
  }
}

/// نافذة «القاعدة» للدرس كله: الأساس، والقاعدة العامة للأفعال، والأسماء.
class HamzaRuleContent extends StatelessWidget {
  const HamzaRuleContent({super.key});

  @override
  Widget build(BuildContext context) => const Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      HamzaBasicsRule(),
      NaskhRule(child: _Heading('همزة الأفعال')),
      VerbChartRule(),
      NaskhRule(child: _Heading('همزة الأسماء')),
      NounHamzaRule(),
    ],
  );
}
