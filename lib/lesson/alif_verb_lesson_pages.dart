import 'dart:math';

import '../data/alif_verb_lesson.dart';
import '../theme.dart';
import '../utils/arabic.dart';
import 'alif_rule_content.dart';
import 'page_handle.dart';
import 'pages/example_page.dart';
import 'pages/quiz_page.dart';

/// صفحات درس «الألف اللّينة في الأفعال» بترتيب كتاب الدرس: الفعل الثلاثي.
List<LessonPageSpec> buildAlifVerbLessonPages([Random? random]) => [
  // ——— الفعل الثلاثي ———
  examplePage(
    title: 'القاعدة',
    emoji: '📖',
    tappable: true,
    heading: 'الألف اللّينة في الفعل الثلاثي',
    rule: const VerbAlifRule(),
    speech: verbRuleSpeech,
    hint: _hint,
  ),
  examplePage(
    title: 'نوعا الألف',
    emoji: '📏',
    tappable: true,
    heading: 'الفرق بين الألف المقصورة والألف الممدودة',
    rule: const VerbAlifRule(),
    content: const VerbAlifBasicsRule(),
    speech: verbBasicsSpeech,
    hint: 'الممدودة (ا) قائمة، والمقصورة (ى) كالياء بلا نقطتين.',
  ),
  examplePage(
    title: 'انقلاب الألف',
    emoji: '🔄',
    tappable: true,
    heading: 'كيف تنقلب الألف؟',
    rule: const VerbAlifRule(),
    content: const VerbAlifTurnRule(),
    speech: verbTurnSpeech,
    hint: _hint,
  ),
  LessonPageSpec(
    title: 'أضف التاء',
    emoji: '✍️',
    rule: const VerbAlifRule(),
    centered: true,
    builder: (h) => QuizPage(
      handle: h,
      title: 'اكتب الفعل بعد إضافة (تاء الفاعل) أو حذفها',
      titleSize: 22,
      autoSpeak: true,
      rule: const VerbAlifRule(),
      build: _addTa,
    ),
  ),
  examplePage(
    title: 'مثال',
    emoji: '💡',
    tappable: true,
    heading: 'افهم طريقة الحل وابدأ الاختبار',
    titleColor: AppColors.red,
    action: 'ابدأ الاختبار',
    rule: const VerbAlifRule(),
    content: const VerbExampleTable(),
    speech: verbExampleSpeech,
    hint: _hint,
  ),
  LessonPageSpec(
    title: 'أكمل الجدول',
    emoji: '🔬',
    rule: const VerbAlifRule(),
    centered: true,
    builder: (h) => QuizPage(
      handle: h,
      title: 'اسمع الجملة وأكمل',
      autoSpeak: true,
      rule: const VerbAlifRule(),
      build: _table,
    ),
  ),
  LessonPageSpec(
    title: 'أكمل القاعدة',
    emoji: '✏️',
    rule: const VerbAlifRule(),
    centered: true,
    builder: (h) => QuizPage(
      handle: h,
      title: 'اختر الإجابة الصحيحة',
      rule: const VerbAlifRule(),
      build: _blanks,
    ),
  ),
  examplePage(
    title: 'احفظ القاعدتين',
    emoji: '🧠',
    heading: 'احفظ هاتين القاعدتين جيدًا للاختبار',
    titleColor: AppColors.red,
    action: 'ابدأ الاختبار',
    rule: const VerbAlifRule(),
    content: const VerbAlifRemember(),
    speech: verbRememberSpeech,
    hint: _hint,
  ),
  LessonPageSpec(
    title: 'اختر الكلمة',
    emoji: '🎯',
    rule: const VerbAlifRule(),
    centered: true,
    builder: (h) => QuizPage(
      handle: h,
      title: 'اختر الكلمة الصحيحة',
      autoSpeak: true,
      // بعد الخطأ تظهر القاعدة التي طُلب حفظها.
      rule: const VerbAlifRemember(),
      build: _choose,
    ),
  ),
];

const _hint =
    'أسند الفعل إلى تاء الفاعل: إن نطقت الياء (بكيتُ) فالألف مقصورة، وإن '
    'نطقت الواو (دعوتُ) فالألف ممدودة.';

const _ta = 'تاء الفاعل';

/// ص ٤–٥: تسعة أفعال في ثلاث جولات، والفراغ مرة في الفعل ومرة في الفعل مع
/// تاء الفاعل. بعد الخطأ أفعال أخرى من الدرس.
List<QuizRound> _addTa(Random rnd, int attempt) {
  final items = attempt == 0
      ? [for (final (w, given) in addTaItems) (alifVerb(w), given)]
      : [
          for (final (i, v) in ([...alifVerbs]..shuffle(rnd)).take(9).indexed)
            (v, i.isEven),
        ];
  return [
    for (var r = 0; r < items.length; r += 3)
      QuizRound(
        hint: _hint,
        spokenAll: [
          for (final (v, given) in items.sublist(r, r + 3))
            given ? v.spoken : v.spokenTa,
        ],
        items: [
          for (final (v, given) in items.sublist(r, r + 3))
            given
                ? QuizItem(prompt: '${v.word} + $_ta =', answer: v.withTa)
                : QuizItem(prompt: '${v.withTa} − $_ta =', answer: v.word),
        ],
      ),
  ];
}

/// ص ٦–٧: اثنتا عشرة جملة تُسمع والفعل مخفي فيها؛ يكتب الطالب الفعل أو
/// الفعل مع تاء الفاعل (ست مرات لكلٍّ)، ثم ما انقلبت إليه الألف وصورتها.
/// بعد الخطأ ترتيب جديد وتتبدل خانة الفراغ.
List<QuizRound> _table(Random rnd, int attempt) {
  final sentences = attempt == 0
      ? verbTableSentences
      : ([...verbTableSentences]..shuffle(rnd));
  final blankVerb = [for (var i = 0; i < 12; i++) i.isEven];
  if (attempt > 0) blankVerb.shuffle(rnd);
  return [
    for (final (i, s) in sentences.indexed)
      () {
        final v = alifVerb(s.verb);
        final text = stripDiacritics(s.spoken);
        return QuizRound(
          sentence: '( ${text.replaceFirst(v.word, '……')} )',
          answerSentence: '( $text )',
          answerMark: v.word,
          spoken: s.spoken,
          hint: _hint,
          items: [
            blankVerb[i]
                ? QuizItem(prompt: 'الفعل + $_ta = ${v.withTa}', answer: v.word)
                : QuizItem(prompt: '${v.word} + $_ta =', answer: v.withTa),
            QuizItem(
              prompt: 'انقلبت الألف إلى:',
              options: const ['الياء', 'الواو'],
              answers: {v.turnsTo},
            ),
            QuizItem(
              prompt: 'تُكتب بالألف:',
              options: const ['المقصورة', 'الممدودة'],
              answers: {v.alifKind},
            ),
          ],
        );
      }(),
  ];
}

/// ص ٨–٩: أكمل القاعدة، الفقرات الأربع في جولتين.
List<QuizRound> _blanks(Random rnd, int attempt) {
  final items = [..._ruleBlanks];
  if (attempt > 0) items.shuffle(rnd);
  return [
    for (var i = 0; i < items.length; i += 2)
      QuizRound(hint: _hint, items: items.sublist(i, i + 2)),
  ];
}

const _ruleBlanks = [
  QuizItem(
    prompt: 'إذا انقلبت (الألف) في الفعل الثلاثي إلى (الياء) تُكتب ……',
    options: ['ممدودة', 'مقصورة'],
    answers: {'مقصورة'},
  ),
  QuizItem(
    prompt: 'إذا انقلبت …… في الفعل الثلاثي إلى (الواو) تُكتب ممدودة',
    options: ['الواو', 'الألف'],
    answers: {'الألف'},
  ),
  QuizItem(
    prompt: 'إذا انقلبت (الألف) في الفعل الثلاثي إلى (الواو) تُكتب ……',
    options: ['مقصورة', 'ممدودة'],
    answers: {'ممدودة'},
  ),
  QuizItem(
    prompt: 'إذا انقلبت (الألف) في الفعل الثلاثي إلى (……) تُكتب ممدودة',
    options: ['الألف', 'الواو'],
    answers: {'الواو'},
  ),
];

/// ص ١١–١٣: اثنتا عشرة جملة في ثلاث جولات، والفعل بالألف الصحيحة من
/// كتابتين. بعد الخطأ ترتيب جديد للجمل.
List<QuizRound> _choose(Random rnd, int attempt) {
  final sentences = attempt == 0
      ? verbChoiceSentences
      : ([...verbChoiceSentences]..shuffle(rnd));
  return [
    for (var r = 0; r < sentences.length; r += 4)
      QuizRound(
        hint: _hint,
        spokenAll: [for (final s in sentences.sublist(r, r + 4)) s.spoken],
        items: [
          for (final s in sentences.sublist(r, r + 4))
            QuizItem(
              prompt: stripDiacritics(s.spoken).replaceFirst(s.verb, '……'),
              options: [s.verb, alifVerb(s.verb).wrong],
              answers: {s.verb},
            ),
        ],
      ),
  ];
}
