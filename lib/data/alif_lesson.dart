/// محتوى درس «الألف اللينة» بترتيب كتاب الدرس: الاسم الثلاثي (ص ١–٩)، ثم
/// الأسماء غير الثلاثية (ص ١–١٠).
library;

const alifLessonId = 'alif';
const alifLessonTitle = 'الألف اللينة';

/// حركة أول الاسم الثلاثي.
enum FirstVowel {
  fath('مفتوح أوله'),
  damm('مضموم أوله'),
  kasr('مكسور أوله');

  const FirstVowel(this.label);
  final String label;
}

/// اسم ينتهي بألف لينة: [spoken] مشكول للنطق، و[maqsura] صورة ألفه.
class AlifWord {
  const AlifWord(this.word, this.spoken, this.maqsura, {this.vowel});
  final String word;
  final String spoken;
  final bool maqsura;

  /// حركة أوله إن كان ثلاثيًا، وnull لغير الثلاثي.
  final FirstVowel? vowel;

  bool get triliteral => vowel != null;
}

// ——— القسم الأول: الاسم الثلاثي ———

const alifRuleSpeech =
    'الألفُ الممدودةُ تُكتَبُ هكذا: ا، مثلُ: سَنا. والألفُ المقصورةُ '
    'تُكتَبُ هكذا: ى، مثلُ: هَوى. والاسمُ الثلاثيُّ هو الذي يتكوّنُ من '
    'ثلاثةِ حروفٍ أصليةٍ، مثلُ: مَدى.';

/// أمثلة القاعدة (ص ١): الألف الممدودة، والمقصورة، والاسم الثلاثي.
const alifRuleExamples = [('سنا', 'سَنا'), ('هوى', 'هَوى'), ('مدى', 'مَدى')];

const triliteralRuleSpeech =
    'الاسمُ الثلاثيُّ المنتهي بالألفِ: إذا كانَ أولُه مضمومًا يُكتَبُ '
    'بالألفِ المقصورةِ، مثلُ: هُدى. وإذا كانَ أولُه مكسورًا يُكتَبُ بالألفِ '
    'المقصورةِ، مثلُ: رِضى. وإذا كانَ أولُه مفتوحًا نحوّلُه إلى المفردِ أو '
    'المثنى أو الجمعِ: فإذا انقلبتِ الألفُ واوًا يُكتَبُ بالألفِ الممدودةِ، '
    'مثلُ: شَذا، شَذَوات. وإذا انقلبتْ ياءً يُكتَبُ بالألفِ المقصورةِ، مثلُ: '
    'فَتى، فَتَيان.';

const triliteralRememberSpeech =
    'كلُّ اسمٍ ثلاثيٍّ أولُه مضمومٌ يُكتَبُ بالألفِ المقصورةِ. وكلُّ اسمٍ '
    'ثلاثيٍّ أولُه مكسورٌ يُكتَبُ بالألفِ المقصورةِ.';

/// الأسماء الثلاثية: كلمات صفحة ٩ وأمثالها.
const triliteralWords = [
  // مضموم أوله: بالألف المقصورة.
  AlifWord('قرى', 'قُرى', true, vowel: FirstVowel.damm),
  AlifWord('ضحى', 'ضُحى', true, vowel: FirstVowel.damm),
  AlifWord('هدى', 'هُدى', true, vowel: FirstVowel.damm),
  AlifWord('سهى', 'سُهى', true, vowel: FirstVowel.damm),
  AlifWord('خطى', 'خُطى', true, vowel: FirstVowel.damm),
  AlifWord('دمى', 'دُمى', true, vowel: FirstVowel.damm),
  // مكسور أوله: بالألف المقصورة.
  AlifWord('رضى', 'رِضى', true, vowel: FirstVowel.kasr),
  AlifWord('حمى', 'حِمى', true, vowel: FirstVowel.kasr),
  // مفتوح أوله: ممدودة إن انقلبت واوًا، ومقصورة إن انقلبت ياءً.
  AlifWord('حلا', 'حَلا', false, vowel: FirstVowel.fath),
  AlifWord('عصا', 'عَصا', false, vowel: FirstVowel.fath),
  AlifWord('مها', 'مَها', false, vowel: FirstVowel.fath),
  AlifWord('صفا', 'صَفا', false, vowel: FirstVowel.fath),
  AlifWord('شذا', 'شَذا', false, vowel: FirstVowel.fath),
  AlifWord('سنا', 'سَنا', false, vowel: FirstVowel.fath),
  AlifWord('فتى', 'فَتى', true, vowel: FirstVowel.fath),
  AlifWord('صدى', 'صَدى', true, vowel: FirstVowel.fath),
  AlifWord('ندى', 'نَدى', true, vowel: FirstVowel.fath),
  AlifWord('حصى', 'حَصى', true, vowel: FirstVowel.fath),
];

AlifWord triliteral(String word) =>
    triliteralWords.firstWhere((w) => w.word == word);

/// جملة فيها اسم ينتهي بألف لينة؛ [spoken] مشكولة للنطق.
class AlifSentence {
  const AlifSentence(this.spoken, this.word);
  final String spoken;
  final String word;
}

/// «اختر الإجابة الصحيحة» (ص ٣): ثلاث جمل ثابتة، وسؤال في كل مرحلة.
const triliteralSentences = [
  AlifSentence('اطلُبْ رِضى اللهِ', 'رضى'),
  AlifSentence('عَصا محمدٍ مكسورةٌ', 'عصا'),
  AlifSentence('صالحٌ فَتى مهذبٌ', 'فتى'),
];

/// جمل بديلة بعد الخطأ بالأنواع نفسها (مكسور، ومفتوح بالممدودة والمقصورة).
const triliteralSpareSentences = [
  AlifSentence('أسعى إلى رِضى والديَّ', 'رضى'),
  AlifSentence('شَمَمْتُ شَذا الوردِ', 'شذا'),
  AlifSentence('سمعتُ صَدى صوتي', 'صدى'),
];

/// «اختر الإجابة الصحيحة» (ص ٧): جملتان ثابتتان، واختياران في كل مرة.
const pairSentences = [
  AlifSentence('عَصا مروانَ قاسيةٌ', 'عصا'),
  AlifSentence('هُدى فتاةٌ مجتهدةٌ', 'هدى'),
];

/// «اختر الإجابات الصحيحة» (ص ٨–٩): ثلاث جولات، في كل جولة أربعة أمثلة
/// إجاباتها واحدة: مضموم أوله، ومفتوح أوله بالممدودة، ومفتوح أوله بالمقصورة.
const fourAnswerGroups = [
  [
    AlifSentence('ذهبتُ إلى قُرى بعيدةٍ', 'قرى'),
    AlifSentence('خرجْنا وقتَ ضُحى الجمعةِ', 'ضحى'),
    AlifSentence('رأيتُ سُهى في السماءِ', 'سهى'),
    AlifSentence('مشى الجنديُّ خُطى ثابتةً', 'خطى'),
  ],
  [
    AlifSentence('حَلا طالبةٌ مجتهدةٌ', 'حلا'),
    AlifSentence('عَصا الراعي طويلةٌ', 'عصا'),
    AlifSentence('رسمتْ مَها لوحةً جميلةً', 'مها'),
    AlifSentence('صَفا تحبُّ القراءةَ', 'صفا'),
  ],
  [
    AlifSentence('هذا فَتى شجاعٌ', 'فتى'),
    AlifSentence('سمعتُ صَدى صوتي', 'صدى'),
    AlifSentence('تساقطَ نَدى الصباحِ على الزهرِ', 'ندى'),
    AlifSentence('جمعَ الطفلُ حَصى الشاطئِ', 'حصى'),
  ],
];

/// جمل جديدة للكلمات نفسها بعد الخطأ، بترتيب [fourAnswerGroups].
const fourAnswerSpare = [
  [
    AlifSentence('زرْنا قُرى الجنوبِ', 'قرى'),
    AlifSentence('نلتقي ضُحى الغدِ', 'ضحى'),
    AlifSentence('سُهى نجمٌ صغيرٌ', 'سهى'),
    AlifSentence('سارَ الطفلُ خُطى قصيرةً', 'خطى'),
  ],
  [
    AlifSentence('نجحتْ حَلا في الاختبارِ', 'حلا'),
    AlifSentence('اتّكأَ جدّي على عَصا خشبيةٍ', 'عصا'),
    AlifSentence('مَها طالبةٌ متفوقةٌ', 'مها'),
    AlifSentence('كتبتْ صَفا رسالةً', 'صفا'),
  ],
  [
    AlifSentence('صالحٌ فَتى مهذبٌ', 'فتى'),
    AlifSentence('تردّدَ صَدى الأذانِ', 'صدى'),
    AlifSentence('لمعَ نَدى الفجرِ على العشبِ', 'ندى'),
    AlifSentence('رمى الولدُ حَصى صغيرةً', 'حصى'),
  ],
];

/// كل جمل التمرين، للتسجيلات والاختبارات.
final fourAnswerSentences = [
  for (final g in [...fourAnswerGroups, ...fourAnswerSpare]) ...g,
];

/// خيارات «اختر الإجابات الصحيحة» (ص ٨) بترتيب الكتاب.
const fourAnswerOptions = [
  'ثلاثي', 'أوله مكسور', 'اسم', //
  'أوله مفتوح', 'ألف مقصورة', 'أكثر من ثلاثة حروف', //
  'فعل', 'أوله مضموم', 'ألف ممدودة',
];

/// الإجابات الأربع لاسم ثلاثي.
Set<String> fourAnswersOf(AlifWord w) => {
  'اسم',
  'ثلاثي',
  switch (w.vowel!) {
    FirstVowel.fath => 'أوله مفتوح',
    FirstVowel.damm => 'أوله مضموم',
    FirstVowel.kasr => 'أوله مكسور',
  },
  w.maqsura ? 'ألف مقصورة' : 'ألف ممدودة',
};

// ——— القسم الثاني: الأسماء غير الثلاثية ———

const longRuleSpeech =
    'أيُّ اسمٍ عربيٍّ أكثرَ من ثلاثةِ حروفٍ يُكتَبُ بالألفِ المقصورةِ، مثلُ: '
    'مُستشفى، وحَلْوى. ما عدا: الاسمَ الأعجميَّ، يُكتَبُ بالألفِ الممدودةِ، '
    'مثلُ: فرنسا، وأستراليا. وإذا كانَ قبلَ الألفِ ياءٌ يُكتَبُ بالألفِ '
    'الممدودةِ، مثلُ: دُنيا، وقضايا.';

const longRememberSpeech =
    'أيُّ اسمٍ عربيٍّ أكثرَ من ثلاثةِ حروفٍ يُكتَبُ بالألفِ المقصورةِ، إلا '
    'الاسمَ الأعجميَّ، وما قبلَ ألفِه ياءٌ، فيُكتَبانِ بالألفِ الممدودةِ.';

/// «إضاءة» (ص ٢): أسماء شاذة تُكتب بالألف المقصورة دائمًا.
const irregularMaqsura = ['موسى', 'عيسى', 'كسرى', 'بخارى', 'متى'];

/// كلمة تُكتب على وجهين.
const twoWayWords = [('يحيى', 'اسم'), ('يحيا', 'فعل')];

const longLightSpeech =
    'أسماءٌ شاذةٌ تُكتَبُ بالألفِ المقصورةِ دائمًا: موسى، عيسى، كِسْرى، '
    'بُخارى، مَتى. وكلمةٌ تُكتَبُ على وجهينِ: يحيى اسمٌ، ويحيا فعلٌ.';

/// الأسماء غير الثلاثية (ص ٣–٤).
const longMaqsuraWords = [
  'سلوى', 'مستشفى', 'كبرى', 'تقوى', 'عظمى', 'ملتقى', 'منتدى', 'صغرى', //
  'مرضى', 'ذكرى', 'حلوى', 'بشرى', 'فتوى',
];
const longYaWords = [
  'هدايا', 'زوايا', 'نوايا', 'مزايا', 'قضايا', 'ضحايا', 'دنيا', 'خلايا', //
  'منايا', 'رعايا', 'خطايا',
];
const foreignWords = [
  'أمريكا', 'تركيا', 'كينيا', 'إسبانيا', 'إيطاليا', 'فرنسا', 'ألمانيا', //
  'إفريقيا', 'آسيا', 'روسيا', 'هولندا', 'أستراليا',
];

/// خيارات «اختر الإجابات الصحيحة» (ص ٣) بترتيب الكتاب.
const longOptions = [
  'ألف ممدودة', 'اسم', 'ثلاثي', //
  'فعل', 'أكثر من ثلاثة حروف', 'ألف مقصورة', //
  'أعجمي', 'قبل ألفه ياء', 'عربي',
];

/// الإجابات الصحيحة لاسم غير ثلاثي.
Set<String> longAnswersOf(String word) {
  final foreign = foreignWords.contains(word);
  final ya = longYaWords.contains(word);
  return {
    'اسم',
    'أكثر من ثلاثة حروف',
    if (foreign) 'أعجمي' else 'عربي',
    if (ya) 'قبل ألفه ياء',
    if (foreign || ya) 'ألف ممدودة' else 'ألف مقصورة',
  };
}

/// «اسمع الجملة واكتب الكلمة الناقصة» (ص ١٠): جمل الكتاب التسع.
const longListenSentences = [
  AlifSentence('حملتُ بُشرى سارّةً', 'بشرى'),
  AlifSentence('رسمتُ زوايا هندسيةً', 'زوايا'),
  AlifSentence('ما أكبرَ مستشفى المدينةِ', 'مستشفى'),
  AlifSentence('جمعتُ قضايا المراجعين', 'قضايا'),
  AlifSentence('أصدرَ العالِمُ فتوى شرعيةً', 'فتوى'),
  AlifSentence('قدّمَ المعلمُ هدايا للطلابِ', 'هدايا'),
  AlifSentence('زرتُ دولةَ هولندا', 'هولندا'),
  AlifSentence('يغفرُ اللهُ خطايا المؤمنين', 'خطايا'),
  AlifSentence('سافرَ كريمٌ إلى روسيا', 'روسيا'),
];

/// جمل بديلة بعد الخطأ بالأنواع نفسها.
const longListenSpare = [
  AlifSentence('شاركتُ في ملتقى الطلابِ', 'ملتقى'),
  AlifSentence('حضرتُ منتدى الشبابِ', 'منتدى'),
  AlifSentence('أحبُّ حلوى العيدِ', 'حلوى'),
  AlifSentence('للعسلِ مزايا كثيرةٌ', 'مزايا'),
  AlifSentence('نسألُ اللهَ خيرَ الدُّنيا', 'الدنيا'),
  AlifSentence('ساعدْنا ضحايا الحادثِ', 'ضحايا'),
  AlifSentence('سافرْنا إلى تركيا', 'تركيا'),
  AlifSentence('زرتُ إيطاليا في الصيفِ', 'إيطاليا'),
  AlifSentence('تقعُ كينيا في إفريقيا', 'كينيا'),
];
