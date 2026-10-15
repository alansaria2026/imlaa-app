import 'dart:math';

import '../data/alif_lesson.dart';
import '../data/review_lesson.dart';
import '../theme.dart';
import '../utils/arabic.dart';
import 'alif_rule_content.dart';
import 'page_handle.dart';
import 'pages/example_page.dart';
import 'pages/listen_write_page.dart';
import 'pages/quiz_page.dart';

/// صفحات درس الألف اللينة بترتيب كتاب الدرس: الاسم الثلاثي، ثم الأسماء غير
/// الثلاثية.
List<LessonPageSpec> buildAlifLessonPages([Random? random]) {
  final rnd = random ?? Random();
  return [
    // ——— الاسم الثلاثي ———
    examplePage(
      title: 'القاعدة',
      emoji: '📖',
      tappable: true,
      heading: 'الألف المقصورة والألف الممدودة',
      rule: const AlifBasicsRule(),
      speech: alifRuleSpeech,
      hint: 'الممدودة (ا) قائمة، والمقصورة (ى) كالياء بلا نقطتين.',
    ),
    examplePage(
      title: 'الاسم الثلاثي',
      emoji: '3️⃣',
      tappable: true,
      heading: 'الاسم الثلاثي المنتهي بالألف',
      rule: const TriliteralRule(),
      content: const TriliteralRule(heading: false),
      speech: triliteralRuleSpeech,
      hint: _triliteralHint,
    ),
    LessonPageSpec(
      title: 'اختر الإجابة',
      emoji: '🔍',
      rule: const TriliteralRule(),
      centered: true,
      builder: (h) => QuizPage(
        handle: h,
        title: 'اختر الإجابة الصحيحة',
        rule: const TriliteralRule(),
        build: _threeSentences,
      ),
    ),
    examplePage(
      title: 'احفظ القاعدتين',
      emoji: '🧠',
      heading: 'احفظ هاتين القاعدتين وابدأ الامتحان',
      titleColor: AppColors.red,
      action: 'ابدأ الامتحان',
      rule: const TriliteralRule(),
      content: const TriliteralRemember(),
      speech: triliteralRememberSpeech,
      hint: _triliteralHint,
    ),
    LessonPageSpec(
      title: 'أكمل القاعدة',
      emoji: '✏️',
      rule: const TriliteralRule(),
      centered: true,
      builder: (h) => QuizPage(
        handle: h,
        title: 'اختر الإجابة الصحيحة',
        rule: const TriliteralRule(),
        build: (rnd, attempt) => _inRounds(_triliteralBlanks, 2, rnd, attempt),
      ),
    ),
    LessonPageSpec(
      title: 'عصا وهدى',
      emoji: '🪄',
      rule: const TriliteralRule(),
      centered: true,
      builder: (h) => QuizPage(
        handle: h,
        title: 'اختر الإجابة الصحيحة',
        rule: const TriliteralRule(),
        build: _pairQuiz,
      ),
    ),
    LessonPageSpec(
      title: 'أربع إجابات',
      emoji: '☑️',
      rule: const TriliteralRule(),
      centered: true,
      builder: (h) => QuizPage(
        handle: h,
        title: 'اختر الصفات المشتركة بين الكلمات التي باللون الأحمر',
        // العنوان طويل يأخذ سطرين؛ خط أصغر للعنوان والجمل حتى يبقى «إدخال»
        // ظاهرًا فوق أزرار التنقل.
        titleSize: 21,
        sentenceSize: 26,
        subtitle: 'أربع إجابات صحيحة',
        rule: const TriliteralRule(),
        build: _fourAnswers,
      ),
    ),
    // ——— الأسماء غير الثلاثية ———
    examplePage(
      title: 'غير الثلاثية',
      emoji: '📚',
      tappable: true,
      heading: 'الأسماء غير الثلاثية',
      rule: const LongNounRule(),
      // «إضاءة» في نافذة القاعدة فقط، لا في الصفحة.
      content: const LongNounRule(light: false),
      speech: longRuleSpeech,
      hint: _longHint,
    ),
    LessonPageSpec(
      title: 'اختر الإجابات',
      emoji: '🧩',
      rule: const LongNounRule(),
      centered: true,
      builder: (h) => QuizPage(
        handle: h,
        title: 'اختر الإجابات الصحيحة',
        rule: const LongNounRule(),
        build: _longAnswers,
      ),
    ),
    examplePage(
      title: 'احفظ القاعدة',
      emoji: '🧠',
      heading: 'احفظ هذه القاعدة وافهمها وابدأ الامتحان',
      titleColor: AppColors.red,
      action: 'ابدأ الامتحان',
      rule: const LongNounRule(),
      content: const LongNounRemember(),
      speech: longRememberSpeech,
      hint: _longHint,
    ),
    LessonPageSpec(
      title: 'أكمل القاعدة',
      emoji: '✏️',
      rule: const LongNounRule(),
      centered: true,
      builder: (h) => QuizPage(
        handle: h,
        title: 'اختر الإجابة الصحيحة',
        rule: const LongNounRule(),
        build: (rnd, attempt) => _inRounds(_longBlanks, 3, rnd, attempt),
      ),
    ),
    LessonPageSpec(
      title: 'اسمع واكتب',
      emoji: '👂',
      rule: const LongNounRule(),
      builder: (h) {
        final (items, spare) = alifListenItems(rnd);
        return ListenWritePage(
          handle: h,
          title: 'اسمع الجملة واكتب الكلمة الناقصة',
          items: items,
          spare: spare,
          newOnError: true,
          titleColor: AppColors.red,
        );
      },
    ),
  ];
}

const _triliteralHint =
    'المضموم أوله والمكسور أوله بالمقصورة. والمفتوح أوله: ردّه إلى المثنى '
    'أو الجمع، فإن ظهرت واو فبالممدودة، وإن ظهرت ياء فبالمقصورة.';

const _longHint =
    'الاسم العربي فوق ثلاثة حروف بالمقصورة، إلا الأعجمي وما قبل ألفه ياء.';

List<T> _pick<T>(List<T> pool, int n, Random rnd, {Set<T> avoid = const {}}) {
  final list = [
    for (final x in pool)
      if (!avoid.contains(x)) x,
  ]..shuffle(rnd);
  return list.take(n).toList();
}

/// أسئلة [items] في جولات من [size]؛ بعد الخطأ بترتيب جديد.
List<QuizRound> _inRounds(
  List<QuizItem> items,
  int size,
  Random rnd,
  int attempt,
) {
  final list = attempt == 0 ? items : ([...items]..shuffle(rnd));
  return [
    for (var i = 0; i < list.length; i += size)
      QuizRound(items: list.sublist(i, min(i + size, list.length))),
  ];
}

String _lines(List<AlifSentence> sentences) =>
    sentences.map((s) => stripDiacritics(s.spoken)).join('\n');

List<String> _spoken(List<AlifSentence> sentences) => [
  for (final s in sentences) s.spoken,
];

/// ص ٣: ثلاث جمل ثابتة وسؤال في كل مرحلة. بعد الخطأ تتبدل بعض الجمل
/// بأمثالها وتتغير المراحل وأماكن الخيارات.
List<QuizRound> _threeSentences(Random rnd, int attempt) {
  final sentences = [
    for (final (i, s) in triliteralSentences.indexed)
      attempt > 0 && rnd.nextBool() ? triliteralSpareSentences[i] : s,
  ];
  final [kasr, mamduda, maqsura] = [
    for (final s in sentences) triliteral(s.word),
  ];
  final questions = [
    QuizItem(
      prompt: 'اسم ثلاثي، ينتهي بألف ممدودة:',
      options: [kasr.word, mamduda.word],
      answers: {mamduda.word},
    ),
    QuizItem(
      prompt: 'اسم ثلاثي، مكسور أوله:',
      options: [maqsura.word, kasr.word],
      answers: {kasr.word},
    ),
    QuizItem(
      prompt: 'اسم ثلاثي، مفتوح أوله، ينتهي بألف مقصورة:',
      options: [mamduda.word, maqsura.word],
      answers: {maqsura.word},
    ),
  ];
  if (attempt > 0) questions.shuffle(rnd);
  final order = attempt > 0 ? ([...sentences]..shuffle(rnd)) : sentences;
  return [
    for (final q in questions)
      QuizRound(
        sentence: _lines(order),
        marks: {for (final s in order) s.word},
        spokenAll: _spoken(order),
        hint: _triliteralHint,
        items: [q],
      ),
  ];
}

/// ص ٥–٦: أكمل القاعدة، الفقرات الثماني (اختياران في كل صفحة).
const _triliteralBlanks = [
  QuizItem(
    prompt: 'كل اسم ……، أوله مضموم، يُكتب بالألف المقصورة',
    options: ['رباعي', 'ثلاثي'],
    answers: {'ثلاثي'},
  ),
  QuizItem(
    prompt: 'كل …… ثلاثي، أوله مكسور، يُكتب بالألف المقصورة',
    options: ['فعل', 'اسم'],
    answers: {'اسم'},
  ),
  QuizItem(
    prompt: 'كل اسم ثلاثي، أوله مضموم، يُكتب بالألف ……',
    options: ['المقصورة', 'الممدودة'],
    answers: {'المقصورة'},
  ),
  QuizItem(
    prompt: 'كل اسم ……، أوله مكسور، يُكتب بالألف المقصورة',
    options: ['ثلاثي', 'رباعي'],
    answers: {'ثلاثي'},
  ),
  QuizItem(
    prompt: 'كل …… ثلاثي، مضموم أوله، يُكتب بالألف المقصورة',
    options: ['اسم', 'فعل'],
    answers: {'اسم'},
  ),
  QuizItem(
    prompt: 'كل اسم ثلاثي، أوله مكسور، يُكتب بالألف ……',
    options: ['الممدودة', 'المقصورة'],
    answers: {'المقصورة'},
  ),
  QuizItem(
    prompt: 'كل اسم ثلاثي، أوله ……، يُكتب بالألف المقصورة',
    options: ['مفتوح', 'مكسور'],
    answers: {'مكسور'},
  ),
  QuizItem(
    prompt: 'كل اسم ثلاثي، أوله ……، يُكتب بالألف المقصورة',
    options: ['مضموم', 'مفتوح'],
    answers: {'مضموم'},
  ),
];

/// ص ٧: جملتان ثابتتان، وتتغير الأسئلة تحتهما اختيارين في كل مرة.
List<QuizRound> _pairQuiz(Random rnd, int attempt) {
  const asaa = 'عصا', huda = 'هدى';
  const vowels = ['مفتوح أوله', 'مكسور أوله', 'مضموم أوله'];
  final items = [
    const QuizItem(
      prompt: '«$asaa»:',
      options: ['اسم', 'فعل'],
      answers: {'اسم'},
    ),
    const QuizItem(
      prompt: '«$huda»:',
      options: ['اسم ثلاثي', 'أكثر من ثلاثة حروف'],
      answers: {'اسم ثلاثي'},
    ),
    const QuizItem(
      prompt: '«$asaa»:',
      options: vowels,
      answers: {'مفتوح أوله'},
    ),
    const QuizItem(
      prompt: '«$huda»:',
      options: ['فعل', 'اسم'],
      answers: {'اسم'},
    ),
    const QuizItem(
      prompt: '«$asaa»:',
      options: ['أكثر من ثلاثة حروف', 'اسم ثلاثي'],
      answers: {'اسم ثلاثي'},
    ),
    const QuizItem(
      prompt: '«$huda»:',
      options: vowels,
      answers: {'مضموم أوله'},
    ),
  ];
  if (attempt > 0) items.shuffle(rnd);
  return [
    for (var i = 0; i < items.length; i += 2)
      QuizRound(
        sentence: _lines(pairSentences),
        marks: const {asaa, huda},
        spokenAll: _spoken(pairSentences),
        hint: _triliteralHint,
        items: items.sublist(i, i + 2),
      ),
  ];
}

/// ص ٨–٩: أربع إجابات صحيحة؛ ثلاث جولات في كل جولة أربعة أمثلة إجاباتها
/// واحدة. بعد الخطأ جمل جديدة للكلمات وتتغير الجولات وأماكن الأمثلة.
List<QuizRound> _fourAnswers(Random rnd, int attempt) {
  final groups = [
    for (final (g, group) in fourAnswerGroups.indexed)
      [
        for (final (i, s) in group.indexed)
          attempt > 0 ? fourAnswerSpare[g][i] : s,
      ],
  ];
  if (attempt > 0) {
    groups.shuffle(rnd);
    for (final g in groups) {
      g.shuffle(rnd);
    }
  }
  return [
    for (final g in groups)
      QuizRound(
        sentence: _lines(g),
        marks: {for (final s in g) s.word},
        spokenAll: _spoken(g),
        hint: _triliteralHint,
        items: [
          QuizItem(
            options: fourAnswerOptions,
            answers: fourAnswersOf(triliteral(g.first.word)),
            multi: true,
          ),
        ],
      ),
  ];
}

/// ص ٣–٤: كل الإجابات الصحيحة لاسم غير ثلاثي، والألف الأخيرة بالأحمر.
/// ثلاث جولات: اسم بالمقصورة («سلوى» أول مرة)، وما قبل ألفه ياء، وأعجمي.
List<QuizRound> _longAnswers(Random rnd, int attempt) {
  final words = [
    attempt == 0
        ? longMaqsuraWords.first
        : _pick(longMaqsuraWords, 1, rnd).single,
    _pick(longYaWords, 1, rnd).single,
    _pick(foreignWords, 1, rnd).single,
  ];
  if (attempt > 0) words.shuffle(rnd);
  return [
    for (final w in words)
      QuizRound(
        sentence: w,
        mark: w,
        markLastLetter: true,
        spoken: w,
        hint: _longHint,
        items: [
          QuizItem(
            options: longOptions,
            answers: longAnswersOf(w),
            multi: true,
          ),
        ],
      ),
  ];
}

/// ص ٦–٨: أكمل القاعدة، الفقرات الاثنتا عشرة.
const _longBlanks = [
  QuizItem(
    prompt: 'أي اسم عربي، ينتهي بالألف، وأكثر من ثلاثة حروف، يُكتب بالألف ……',
    options: ['الممدودة', 'المقصورة'],
    answers: {'المقصورة'},
  ),
  QuizItem(
    prompt:
        'أي اسم ……، ينتهي بالألف، وأكثر من ثلاثة حروف، يُكتب بالألف المقصورة',
    options: ['عربي', 'أعجمي'],
    answers: {'عربي'},
  ),
  QuizItem(
    prompt: 'أي اسم عربي، ينتهي بالألف قبلها (ياء)، ……، يُكتب بالألف الممدودة',
    options: ['ثلاثي', 'أكثر من ثلاثة حروف'],
    answers: {'أكثر من ثلاثة حروف'},
  ),
  QuizItem(
    prompt:
        'أي …… عربي، ينتهي بالألف، أكثر من ثلاثة حروف، يُكتب بالألف المقصورة',
    options: ['اسم', 'فعل'],
    answers: {'اسم'},
  ),
  QuizItem(
    prompt: 'أي اسم أعجمي، ينتهي بالألف، ……، يُكتب بالألف الممدودة',
    options: ['أكثر من ثلاثة حروف', 'ثلاثي'],
    answers: {'أكثر من ثلاثة حروف'},
  ),
  QuizItem(
    prompt:
        'أي اسم ……، ينتهي بالألف قبلها (ياء)، وأكثر من ثلاثة حروف، يُكتب بالألف الممدودة',
    options: ['عربي', 'أعجمي'],
    answers: {'عربي'},
  ),
  QuizItem(
    prompt: 'أي اسم أعجمي، ينتهي بالألف، وأكثر من ثلاثة حروف، يُكتب بالألف ……',
    options: ['المقصورة', 'الممدودة'],
    answers: {'الممدودة'},
  ),
  QuizItem(
    prompt: 'أي اسم عربي، ينتهي بالألف، ……، يُكتب بالألف المقصورة',
    options: ['أكثر من ثلاثة حروف', 'ثلاثي'],
    answers: {'أكثر من ثلاثة حروف'},
  ),
  QuizItem(
    prompt:
        'أي …… عربي، ينتهي بالألف قبلها (ياء)، أكثر من ثلاثة حروف، يُكتب بالألف الممدودة',
    options: ['فعل', 'اسم'],
    answers: {'اسم'},
  ),
  QuizItem(
    prompt:
        'أي …… أعجمي، ينتهي بالألف، وأكثر من ثلاثة حروف، يُكتب بالألف الممدودة',
    options: ['اسم', 'فعل'],
    answers: {'اسم'},
  ),
  QuizItem(
    prompt:
        'أي اسم عربي، ينتهي بالألف وقبلها ……، وأكثر من ثلاثة حروف، يُكتب بالألف الممدودة',
    options: ['ألف', 'ياء'],
    answers: {'ياء'},
  ),
  QuizItem(
    prompt:
        'أي اسم عربي، ينتهي بالألف وقبلها (ياء)، وأكثر من ثلاثة حروف، يُكتب بالألف ……',
    options: ['الممدودة', 'المقصورة'],
    answers: {'الممدودة'},
  ),
];

ListenItem _listenItem(AlifSentence s) => ListenItem(
  spoken: s.spoken,
  answer: s.word,
  redPrefix: 0,
  sentence: [
    for (final w in s.spoken.split(' ')) stripDiacritics(w) == s.word ? '…' : w,
  ].join(' '),
);

/// ص ١٠: جمل الكتاب التسع مخلوطة، والبدائل للأسئلة المعادة بعد الخطأ.
(List<ListenItem>, List<ListenItem>) alifListenItems(Random rnd) => (
  [
    for (final s in [...longListenSentences]..shuffle(rnd)) _listenItem(s),
  ],
  [
    for (final s in [...longListenSpare]..shuffle(rnd)) _listenItem(s),
  ],
);
