import 'dart:math';

import 'package:flutter/material.dart';

import '../app_state.dart';
import '../data/hamza_lesson.dart';
import '../data/lam_lesson.dart';
import '../services/speaker.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'hamza_rule_content.dart';
import 'page_handle.dart';
import 'pages/equation_page.dart';
import 'pages/quiz_page.dart';
import 'rule_content.dart';

const _tenseEmoji = {
  Tense.past: '⏮️',
  Tense.present: '⏯️',
  Tense.imperative: '📣',
};

/// صفحات درس الهمزة بترتيب كتاب الدرس: في الأفعال (ص ١–٤٠)، ثم في الأسماء
/// (ص ٤١–٥١). صفحات «مثال» المتتالية في موضوع واحد صفحة واحدة، ومثال كل
/// قاعدة من قواعد الأفعال وتطبيقها محطة واحدة.
List<LessonPageSpec> buildHamzaLessonPages([Random? random]) {
  final rnd = random ?? Random();
  return [
    _example(
      title: 'القاعدة',
      emoji: '📖',
      tappable: true,
      heading: 'الفرق بين همزة القطع وهمزة الوصل',
      rule: const HamzaBasicsRule(),
      // الصفحة تعرض صورتي الهمزة فقط، والقاعدة الذهبية مخفية في «مساعدة».
      content: const HamzaBasicsRule(golden: false),
      hintContent: const HamzaGoldenRule(),
      speech: hamzaRuleSpeech,
      hint:
          'أدخل (ثم) قبل الكلمة وانطقها: إن ظهرت الهمزة فهي قطع، وإن اختفت فهي وصل.',
    ),
    LessonPageSpec(
      title: 'قطع أم وصل؟',
      emoji: '🔍',
      rule: const HamzaBasicsRule(),
      centered: true,
      builder: (h) => QuizPage(
        handle: h,
        title: 'اختر الإجابة الصحيحة',
        rule: const HamzaBasicsRule(),
        autoSpeak: true,
        build: _qatOrWasl,
      ),
    ),
    LessonPageSpec(
      title: 'أين تُنطق؟',
      emoji: '🗣️',
      rule: const HamzaBasicsRule(),
      centered: true,
      builder: (h) => QuizPage(
        handle: h,
        title: 'اختر الإجابة الصحيحة',
        rule: const HamzaBasicsRule(),
        build: (_, _) => _whereSpoken,
      ),
    ),
    _example(
      title: '(ال) التعريف',
      emoji: '🔤',
      tappable: true,
      heading: 'همزة (ال) التعريف',
      rule: const AlHamzaRule(),
      content: const AlStatementRule(),
      hintContent: const AlRememberRule(),
      speech: alRuleSpeech,
      hint: 'كل اسم تدخل عليه (ال) يبدأ بهمزة وصل.',
    ),
    _example(
      title: 'إضافة (ال)',
      emoji: '➕',
      tappable: true,
      heading: 'إضافة (ال) التعريف إلى الأسماء',
      rule: const AlHamzaRule(),
      content: const AlExamplesRule(),
      hintContent: const AlRememberRule(),
      speech: alRuleSpeech,
      speechAll: [
        for (final w in alExampleWords) ...[spokenForm(w), spokenForm('ال$w')],
      ],
      hint: 'كل اسم تدخل عليه (ال) يبدأ بهمزة وصل.',
    ),
    LessonPageSpec(
      title: 'أضف (ال)',
      emoji: '✍️',
      rule: const AlHamzaRule(),
      builder: (h) => EquationPage(
        handle: h,
        rounds: hamzaAlRounds(rnd),
        refill: () => hamzaAlRounds(rnd),
        op: EquationOp.addAl,
        title: 'أضف (ال) التعريف إلى الكلمة واكتب الناتج',
        titleColor: AppColors.red,
        strict: true,
      ),
    ),
    LessonPageSpec(
      title: 'اسم أم فعل؟',
      emoji: '🔪',
      rule: const AlHamzaRule(),
      centered: true,
      builder: (h) => QuizPage(
        handle: h,
        title: 'اختر الإجابة الصحيحة',
        rule: const AlHamzaRule(),
        build: _nounWithAl,
      ),
    ),
    _example(
      title: 'وزن الفعل',
      emoji: '⚖️',
      heading: 'وزن الفعل',
      rule: const WeightRule(),
      content: const WeightLettersRule(),
      speech:
          'لمعرفةِ وزنِ الفعلِ نحوِّلُهُ إلى الماضي، والوزنُ هو عددُ '
          'حروفِ الفعلِ الماضي.',
      hint: 'حوّل الفعل إلى الماضي ثم عُدّ حروفه.',
    ),
    _example(
      title: 'أمثلة الوزن',
      emoji: '📋',
      heading: 'أمثلة على وزن الفعل',
      rule: const WeightRule(),
      content: const WeightExamplesRule(),
      speech: weightExamplesSpeech,
      hint: 'حوّل الفعل إلى الماضي ثم عُدّ حروفه.',
    ),
    LessonPageSpec(
      title: 'ما وزنه؟',
      emoji: '🔢',
      rule: const WeightRule(),
      centered: true,
      builder: (h) => QuizPage(
        handle: h,
        title: 'اختر وزن الفعل',
        subtitle: 'عشرون فعلًا متتاليًا بلا خطأ',
        rule: const WeightRule(),
        build: _weights,
      ),
    ),
    _example(
      title: 'القاعدة العامة',
      emoji: '🗂️',
      heading: 'همزة القطع وهمزة الوصل في الأفعال',
      rule: const VerbChartRule(),
      speech:
          'همزةُ المضارعِ قطعٌ دائمًا. وهمزةُ الماضي قطعٌ في الثلاثيِّ '
          'والرباعيِّ، ووصلٌ في الخماسيِّ والسداسيِّ. وهمزةُ الأمرِ قطعٌ '
          'في الرباعيِّ، ووصلٌ في الثلاثيِّ والخماسيِّ والسداسيِّ.',
      hint: 'المضارع قطع دائمًا، والرباعي قطع دائمًا.',
    ),
    for (final c in verbCombos)
      LessonPageSpec(
        title: '${_short(c.tense)} ${c.weight.label}',
        emoji: _tenseEmoji[c.tense]!,
        rule: VerbComboExample(c),
        centered: true,
        builder: (h) => QuizPage(
          handle: h,
          title: 'حلّل الفعل',
          rule: VerbComboExample(c),
          build: (rnd, attempt) => _analysis(c, rnd, attempt),
        ),
      ),
    LessonPageSpec(
      title: 'اختر الإجابات',
      emoji: '☑️',
      rule: const VerbChartRule(),
      centered: true,
      builder: (h) => QuizPage(
        handle: h,
        title: 'اختر الإجابات الصحيحة',
        rule: const VerbChartRule(),
        build: _threeAnswers,
      ),
    ),
    LessonPageSpec(
      title: 'صنّف الفعل',
      emoji: '🧩',
      rule: const VerbChartRule(),
      centered: true,
      builder: (h) => QuizPage(
        handle: h,
        title: 'اختر الإجابة الصحيحة',
        subtitle: 'اثنا عشر سؤالًا متتاليًا بلا خطأ',
        rule: const VerbChartRule(),
        build: _classify,
      ),
    ),
    _example(
      title: 'المصدر',
      emoji: '📚',
      heading: 'همزة القطع وهمزة الوصل في الأسماء',
      rule: const MasdarRule(),
      speech:
          'المصدرُ هو الاسمُ الذي يُستخرَجُ من الفعلِ. ومصدرُ الفعلِ '
          'الماضي الخماسيِّ والسداسيِّ همزتُه وصلٌ، وكذلك مصدرُ فعلِ الأمرِ '
          'الخماسيِّ والسداسيِّ.',
      hint: 'مصدر الخماسي والسداسي يبدأ بهمزة وصل: مصدر اعتمد «اعتماد».',
    ),
    LessonPageSpec(
      title: 'اختبر نفسك',
      emoji: '📝',
      rule: const MasdarRule(),
      centered: true,
      builder: (h) => QuizPage(
        handle: h,
        title: 'اختر الإجابة الصحيحة',
        rule: const MasdarRule(),
        build: _masdarQuiz,
      ),
    ),
    LessonPageSpec(
      title: 'الاسم والفعل',
      emoji: '👆',
      rule: const MasdarRule(),
      centered: true,
      builder: (h) => QuizPage(
        handle: h,
        title: 'ميّز الاسم من الفعل',
        rule: const MasdarRule(),
        build: _nounOrVerb,
      ),
    ),
    LessonPageSpec(
      title: 'ميّز الكلمات',
      emoji: '🎯',
      rule: const MasdarRule(),
      centered: true,
      builder: (h) => QuizPage(
        handle: h,
        title: 'ميّز الأسماء والأفعال',
        rule: const MasdarRule(),
        build: _pickAll,
      ),
    ),
    LessonPageSpec(
      title: 'حوّل',
      emoji: '🔄',
      rule: const MasdarRule(),
      centered: true,
      builder: (h) => QuizPage(
        handle: h,
        title: 'حوّل الكلمة واكتبها',
        subtitle: 'انتبه لصورة الهمزة في أول الكلمة',
        rule: const MasdarRule(),
        build: _convert,
      ),
    ),
    _example(
      title: 'همزة الأسماء',
      emoji: '🏷️',
      heading: 'همزة الأسماء',
      rule: const NounHamzaRule(),
      speech:
          'جميعُ الأعلامِ المبدوءةِ بالهمزةِ همزتُها قطعٌ، مثلُ: أحمدَ '
          'وإسماعيلَ. وهذه الأسماءُ همزتُها وصلٌ دائمًا: ابنٌ، ابنةٌ، اسمٌ، '
          'اثنانِ، امرؤٌ، امرأةٌ. وألُ التعريفِ همزتُها وصلٌ دائمًا.',
      hint: 'أسماء الأعلام همزتها قطع، و(ابن، اسم، اثنان، امرأة) همزتها وصل.',
    ),
  ];
}

String _short(Tense t) => switch (t) {
  Tense.past => 'ماضٍ',
  Tense.present => 'مضارع',
  Tense.imperative => 'أمر',
};

LessonPageSpec _example({
  required String title,
  required String emoji,
  required String heading,
  required Widget rule,
  required String speech,
  required String hint,
  Widget? content,
  Widget? hintContent,
  List<String>? speechAll,
  bool tappable = false,
}) => LessonPageSpec(
  tag: 'مثال وقاعدة',
  title: title,
  emoji: emoji,
  needsCompletion: false,
  rule: rule,
  builder: (h) => _ExamplePage(
    handle: h,
    heading: heading,
    speech: speech,
    hint: hint,
    hintContent: hintContent,
    speechAll: speechAll,
    tappable: tappable,
    child: content ?? rule,
  ),
);

class _ExamplePage extends StatefulWidget {
  const _ExamplePage({
    required this.handle,
    required this.heading,
    required this.speech,
    required this.hint,
    required this.child,
    this.hintContent,
    this.speechAll,
    this.tappable = false,
  });

  final PageHandle handle;
  final String heading;
  final String speech;
  final String hint;
  final Widget child;

  /// محتوى «مساعدة» في نافذة بدل رسالة [hint] القصيرة.
  final Widget? hintContent;

  /// نصوص «استمع» تُنطق متتالية بدل [speech].
  final List<String>? speechAll;

  /// في المحتوى أمثلة تُسمع بالضغط عليها.
  final bool tappable;

  @override
  State<_ExamplePage> createState() => _ExamplePageState();
}

class _ExamplePageState extends State<_ExamplePage> {
  @override
  void initState() {
    super.initState();
    widget.handle
      ..onListen = () {
        final rate = AppScope.read(context).speechRate;
        if (widget.speechAll case final texts?) {
          Speaker.instance.speakAll(texts, rate: rate);
        } else {
          Speaker.instance.speak(widget.speech, rate: rate);
        }
      }
      ..onHint = () => widget.hintContent == null
          ? showFeedback(context, widget.hint, tone: FeedbackTone.hint)
          : showRuleSheet(context, title: 'تلميح', content: widget.hintContent);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => widget.handle.markComplete(),
    );
  }

  @override
  Widget build(BuildContext context) => PageCard(
    tag: 'مثال وقاعدة',
    title: widget.heading,
    subtitle: widget.tappable ? 'اضغط على المثال لتسمعه' : null,
    child: widget.child,
  );
}

// ——— بناة الأسئلة ———

List<T> _pick<T>(List<T> pool, int n, Random rnd, {Set<T> avoid = const {}}) {
  final list = [
    for (final x in pool)
      if (!avoid.contains(x)) x,
  ]..shuffle(rnd);
  return list.take(n).toList();
}

final _hamzaOptions = [for (final h in Hamza.values) h.label];
final _tenseOptions = [for (final t in Tense.values) t.label];
final _weightOptions = [for (final w in Weight.values) w.label];

const _goldenHint =
    'أدخل (ثم) قبل الفعل وانطقه: إن ظهرت الهمزة فهي قطع، وإن اختفت فهي وصل.';
const _verbHint =
    'حوّل الفعل إلى الماضي وعُدّ حروفه لتعرف وزنه، ثم طبّق القاعدة العامة.';

/// ص ٣–٤: نوع همزة الفعل في الجملة؛ خمس قطع وخمس وصل بترتيب عشوائي.
List<QuizRound> _qatOrWasl(Random rnd, int attempt) {
  final first = attempt == 0 ? [hamzaFirstSentence] : <VerbSentence>[];
  final pool = allVerbSentences.where((s) => !first.contains(s)).toList();
  final qat = _pick(pool.where((s) => s.hamza == Hamza.qat).toList(), 5, rnd);
  final wasl = _pick(pool.where((s) => s.hamza == Hamza.wasl).toList(), 5, rnd);
  final picked = [...qat.skip(first.length), ...wasl]..shuffle(rnd);
  return [
    for (final s in [...first, ...picked])
      QuizRound(
        // الهمزة مخفية حتى يجيب الطالب، ثم تظهر الكتابة الصحيحة.
        sentence: s.hiddenText,
        mark: s.hiddenVerb,
        answerSentence: s.text,
        answerMark: s.verb,
        spoken: s.spoken,
        hint: _goldenHint,
        items: [
          QuizItem(
            prompt: 'همزة الفعل «${s.hiddenVerb}»:',
            options: _hamzaOptions,
            answers: {s.hamza.label},
          ),
        ],
      ),
  ];
}

/// ص ٥–٦: أين تُنطق كل همزة (قد تصح أكثر من إجابة).
const _first = 'أول الكلام', _middle = 'وسط الكلام';
const _qatL = 'همزة القطع', _waslL = 'همزة الوصل';
const _whereSpoken = [
  QuizRound(
    instruction: 'اختر كل الإجابات الصحيحة',
    hint: 'همزة القطع تُنطق دائمًا، وهمزة الوصل لا تُنطق في وسط الكلام.',
    items: [
      QuizItem(
        prompt: 'همزة القطع تُنطق في:',
        options: [_first, _middle],
        answers: {_first, _middle},
        multi: true,
      ),
      QuizItem(
        prompt: 'همزة الوصل تُنطق في:',
        options: [_first, _middle],
        answers: {_first},
        multi: true,
      ),
    ],
  ),
  QuizRound(
    instruction: 'اختر كل الإجابات الصحيحة',
    hint: 'همزة الوصل ألف بلا همزة (ا) ولا تُنطق في وسط الكلام.',
    items: [
      QuizItem(
        prompt: 'همزة الوصل:',
        options: ['ا', 'أ  إ'],
        answers: {'ا'},
        multi: true,
      ),
      QuizItem(
        prompt: 'همزة الوصل:',
        options: ['تُنطق في $_first', 'تُنطق في $_middle'],
        answers: {'تُنطق في $_first'},
        multi: true,
      ),
      QuizItem(
        prompt: 'تُنطق في أول الكلام:',
        options: [_qatL, _waslL],
        answers: {_qatL, _waslL},
        multi: true,
      ),
      QuizItem(
        prompt: 'تُنطق في وسط الكلام:',
        options: [_waslL, _qatL],
        answers: {_qatL},
        multi: true,
      ),
    ],
  ),
];

/// ص ١٠: اسم نكرة، ثم إضافة (ال) إليه، ثم نوع همزته؛ كلمة جديدة بعد الخطأ.
List<QuizRound> _nounWithAl(Random rnd, int attempt) {
  final n = attempt == 0
      ? hamzaNouns.first
      : _pick(hamzaNouns, 1, rnd, avoid: {hamzaNouns.first}).first;
  return [
    QuizRound(
      hint: '(ال) التعريف لا تدخل إلا على الأسماء، وتبدأ دائمًا بهمزة الوصل.',
      items: [
        QuizItem(prompt: '«$n»:', options: ['اسم', 'فعل'], answers: {'اسم'}),
        QuizItem(prompt: '$n + ال التعريف =', answer: 'ال$n'),
        QuizItem(
          prompt: '«ال$n» تبدأ بهمزة:',
          options: ['وصل', 'قطع'],
          answers: {'وصل'},
        ),
      ],
    ),
  ];
}

/// ص ١٣: وزن الفعل المضارع؛ أربع جولات من خمسة أفعال تشمل كل الأوزان.
List<QuizRound> _weights(Random rnd, int attempt) {
  final used = <String>{};
  final rounds = <QuizRound>[];
  // خمس جولات في كل منها أربعة أفعال، فعل لكل وزن، حتى يبقى «إدخال» ظاهرًا.
  for (var r = 0; r < 5; r++) {
    final verbs = <(String, String, Weight)>[];
    if (r == 0 && attempt == 0) {
      verbs.addAll(weightVerbs.where((v) => weightFirstVerbs.contains(v.$1)));
    } else {
      for (final w in Weight.values) {
        verbs.add(
          _pick(
            weightVerbs.where((v) => v.$3 == w).toList(),
            1,
            rnd,
            avoid: {
              for (final v in weightVerbs)
                if (used.contains(v.$1)) v,
            },
          ).first,
        );
      }
    }
    used.addAll(verbs.map((v) => v.$1));
    verbs.shuffle(rnd);
    rounds.add(
      QuizRound(
        hint: 'حوّل الفعل إلى الماضي وعُدّ حروفه: يحارب ماضيه «حارب» (٤ حروف).',
        items: [
          for (final (present, _, weight) in verbs)
            QuizItem(
              prompt: '$present:',
              options: _weightOptions,
              answers: {weight.label},
            ),
        ],
      ),
    );
  }
  return rounds;
}

/// ص ١٤–٣٧: الزمن والوزن ونوع الهمزة لفعل الجملة.
/// عدد جمل «حلّل الفعل» في الصفحة، وفي كل جملة ثلاثة أسئلة.
const _analysisRounds = 3;

/// «حلّل الفعل»: ثلاث جولات بلا مثال محلول. أول مرة جملة المثال ثم جملتا
/// التطبيق الأوليان، وبعد الخطأ ثلاث جمل أخرى من جمل القاعدة نفسها.
List<QuizRound> _analysis(VerbCombo c, Random rnd, int attempt) {
  final all = [c.example, ...c.practice];
  final sentences = attempt == 0
      ? all.take(_analysisRounds).toList()
      : _pick(all, _analysisRounds, rnd);
  return [for (final s in sentences) _analysisRound(s)];
}

QuizRound _analysisRound(VerbSentence s) {
  return QuizRound(
    sentence: '( ${s.text} )',
    mark: s.verb,
    spoken: s.spoken,
    hint: _verbHint,
    items: [
      QuizItem(
        prompt: 'زمن الفعل:',
        options: _tenseOptions,
        answers: {s.tense.label},
      ),
      QuizItem(
        prompt: 'وزن الفعل:',
        options: _weightOptions,
        answers: {s.weight.label},
      ),
      QuizItem(
        prompt: 'نوع الهمزة:',
        options: _hamzaOptions,
        answers: {s.hamza.label},
      ),
    ],
  );
}

/// ص ٣٨: ثلاث إجابات صحيحة من تسعة خيارات.
List<QuizRound> _threeAnswers(Random rnd, int attempt) {
  final first = attempt == 0 ? [multiChoiceSentence] : <VerbSentence>[];
  final rest = _pick(
    allVerbSentences,
    5 - first.length,
    rnd,
    avoid: {multiChoiceSentence},
  );
  return [
    for (final s in [...first, ...rest])
      QuizRound(
        instruction: 'اختر الإجابات الصحيحة الثلاث',
        sentence: '( ${s.text} )',
        mark: s.verb,
        spoken: s.spoken,
        hint: _verbHint,
        items: [
          QuizItem(
            options: [
              ..._tenseOptions,
              for (final w in Weight.values) 'فعل ${w.label}',
              ..._hamzaOptions,
            ],
            answers: {s.tense.label, 'فعل ${s.weight.label}', s.hamza.label},
            multi: true,
          ),
        ],
      ),
  ];
}

/// ص ٣٩–٤٠: زمن الفعل ووزنه من اثني عشر خيارًا.
List<QuizRound> _classify(Random rnd, int attempt) {
  final sentences = attempt == 0
      ? verbReviewSentences
      : _pick(allVerbSentences, 12, rnd);
  String label(Tense t, Weight w) => '${t.label} ${w.label}';
  final options = [
    for (final t in [Tense.present, Tense.past, Tense.imperative])
      for (final w in Weight.values) label(t, w),
  ];
  return [
    for (final s in sentences)
      QuizRound(
        sentence: s.text,
        mark: s.verb,
        spoken: s.spoken,
        hint: _verbHint,
        items: [
          QuizItem(options: options, answers: {label(s.tense, s.weight)}),
        ],
      ),
  ];
}

/// أفعال يصلح منها اسم مشابه خاطئ (استشعر ← مستشعر).
final _distractable = [
  for (final p in masdarPairs)
    if (!p.$1.endsWith('ى')) p,
];

/// ص ٤٥: سبع فقرات؛ الفقرتان (٣، ٥) بفعلين جديدين بعد الخطأ.
List<QuizRound> _masdarQuiz(Random rnd, int attempt) {
  final (a, b) = attempt == 0
      ? (('استشعر', 'استشعار'), ('احتمل', 'احتمال'))
      : (() {
          final two = _pick(_distractable, 2, rnd);
          return (two[0], two[1]);
        })();
  return [
    QuizRound(
      hint: 'المصدر اسم، ومصدر الخماسي والسداسي يبدأ بهمزة وصل.',
      items: [
        const QuizItem(
          prompt: 'المصدر هو ……',
          options: ['فعل', 'اسم'],
          answers: {'اسم'},
        ),
        QuizItem(
          prompt: 'مصدر الفعل (${a.$1}):',
          options: [masdarDistractor(a.$1), a.$2],
          answers: {a.$2},
        ),
        QuizItem(
          prompt: 'مصدر الفعل (${b.$1}):',
          options: [masdarDistractor(b.$1), b.$2],
          answers: {b.$2},
        ),
        const QuizItem(
          prompt: 'مصدر فعل الأمر الخماسي والسداسي همزته (……):',
          options: ['وصل', 'قطع'],
          answers: {'وصل'},
        ),
      ],
    ),
  ];
}

/// ص ٤٧: اضغط على الاسم (المصدر)، ثم اضغط على الفعل؛ ست فقرات لكلٍّ.
List<QuizRound> _nounOrVerb(Random rnd, int attempt) {
  final pairs = _pick(masdarPairs, 12, rnd);
  QuizRound round(
    String instruction,
    Iterable<(String, String)> ps,
    bool noun,
  ) => QuizRound(
    instruction: instruction,
    hint: 'المصدر اسم ينتهي غالبًا بألف قبل آخره: اعتماد، استقبال.',
    items: [
      for (final (verb, masdar) in ps)
        QuizItem(options: [verb, masdar], answers: {noun ? masdar : verb}),
    ],
  );
  return [
    round('اضغط على الاسم', pairs.take(6), true),
    round('اضغط على الفعل', pairs.skip(6), false),
  ];
}

/// ص ٤٩: كل الأسماء ثم كل الأفعال بين خمس كلمات.
List<QuizRound> _pickAll(Random rnd, int attempt) {
  final pairs = _pick(masdarPairs, 10, rnd);
  QuizRound round(String instruction, List<(String, String)> ps, bool noun) {
    final k = 2 + rnd.nextInt(2);
    final right = [for (final p in ps.take(k)) noun ? p.$2 : p.$1];
    final wrong = [for (final p in ps.skip(k)) noun ? p.$1 : p.$2];
    return QuizRound(
      instruction: instruction,
      hint: 'المصدر اسم يُستخرج من الفعل: مصدر اجتمع «اجتماع».',
      items: [
        QuizItem(
          options: [...right, ...wrong],
          answers: right.toSet(),
          multi: true,
        ),
      ],
    );
  }

  return [
    round('اضغط على كل الأسماء', pairs.take(5).toList(), true),
    round('اضغط على كل الأفعال', pairs.skip(5).toList(), false),
  ];
}

/// ص ٥٠: المصدر إلى فعل، والفعل إلى مصدر؛ خمس كلمات لكلٍّ.
List<QuizRound> _convert(Random rnd, int attempt) {
  const book1 = ['افتتاح', 'استهلاك', 'استثمار'];
  const book2 = ['اختلف', 'اقتنع'];
  final used = <(String, String)>{};
  List<(String, String)> take(List<String> book, bool byMasdar) {
    final picked = [
      if (attempt == 0)
        for (final w in book)
          masdarPairs.firstWhere((p) => (byMasdar ? p.$2 : p.$1) == w),
    ];
    used.addAll(picked);
    picked.addAll(_pick(masdarPairs, 5 - picked.length, rnd, avoid: used));
    used.addAll(picked);
    return picked..shuffle(rnd);
  }

  final first = take(book1, true);
  final second = take(book2, false);
  return [
    QuizRound(
      instruction: 'حوّل المصدر إلى فعل ماضٍ أو أمر',
      hint: 'احذف الألف التي قبل آخر المصدر: «استهلاك» تصير «استهلك».',
      items: [
        for (final (verb, masdar) in first)
          QuizItem(prompt: '$masdar:', answer: verb),
      ],
    ),
    QuizRound(
      instruction: 'حوّل الفعل إلى مصدر',
      hint: 'زد ألفًا قبل آخر الفعل: «اختلف» يصير «اختلاف».',
      items: [
        for (final (verb, masdar) in second)
          QuizItem(prompt: '$verb:', answer: masdar),
      ],
    ),
  ];
}
