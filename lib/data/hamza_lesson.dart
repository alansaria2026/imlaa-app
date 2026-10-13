/// محتوى درس «همزة القطع وهمزة الوصل» (في الأفعال، ثم في الأسماء)
/// بترتيب كتاب الدرس.
library;

import 'dart:math';

import '../utils/arabic.dart';

const hamzaLessonId = 'hamza';
const hamzaLessonTitle = 'همزة القطع وهمزة الوصل';

enum Hamza {
  qat('همزة قطع'),
  wasl('همزة وصل');

  const Hamza(this.label);
  final String label;
}

/// زمن الفعل.
enum Tense {
  past('فعل ماضٍ'),
  present('فعل مضارع'),
  imperative('فعل أمر');

  const Tense(this.label);
  final String label;
}

/// وزن الفعل: عدد حروف الفعل الماضي.
enum Weight {
  three('ثلاثي'),
  four('رباعي'),
  five('خماسي'),
  six('سداسي');

  const Weight(this.label);
  final String label;
}

/// القاعدة العامة (ص ١٣ مكرر): همزة المضارع قطع دائمًا، وهمزة الماضي قطع
/// في الثلاثي والرباعي، وهمزة الأمر قطع في الرباعي وحده.
Hamza hamzaOf(Tense tense, Weight weight) => switch (tense) {
  Tense.present => Hamza.qat,
  Tense.past =>
    weight == Weight.three || weight == Weight.four ? Hamza.qat : Hamza.wasl,
  Tense.imperative => weight == Weight.four ? Hamza.qat : Hamza.wasl,
};

/// نص القاعدة: (فعل أمر + فعل ثلاثي) = همزة وصل.
String comboRule(Tense tense, Weight weight) =>
    '(${tense.label} + فعل ${weight.label}) = ${hamzaOf(tense, weight).label}';

/// جملة فيها فعل يبدأ بهمزة؛ [spoken] مشكولة للنطق، وتُعرض بلا تشكيل.
class VerbSentence {
  const VerbSentence(this.spoken, this.verb, this.tense, this.weight);
  final String spoken;

  /// الفعل كما يُكتب في الجملة (يُلوَّن بالأحمر).
  final String verb;
  final Tense tense;
  final Weight weight;

  String get text => stripDiacritics(spoken);
  Hamza get hamza => hamzaOf(tense, weight);

  /// الفعل بلا صورة الهمزة (أكتب ← اكتب) ليعتمد الطالب على القاعدة الذهبية.
  String get hiddenVerb => hideHamza(verb);

  /// الجملة والفعل فيها بلا صورة الهمزة.
  String get hiddenText =>
      [for (final w in text.split(' ')) w == verb ? hiddenVerb : w].join(' ');
}

/// يكتب الهمزة في أول الكلمة ألفًا (أ، إ ← ا).
String hideHamza(String word) => word.replaceFirst(RegExp('^[أإ]'), 'ا');

/// قاعدة من قواعد الأفعال (ص ١٤–٣٧): جملة مثال محلولة، ثم جمل التطبيق؛
/// الأولى من الكتاب، والبقية بدائل بعد الخطأ.
class VerbCombo {
  const VerbCombo(this.tense, this.weight, this.example, this.practice);
  final Tense tense;
  final Weight weight;
  final VerbSentence example;
  final List<VerbSentence> practice;

  Hamza get hamza => hamzaOf(tense, weight);
  String get rule => comboRule(tense, weight);
}

const _m = Tense.past, _p = Tense.present, _a = Tense.imperative;
const _w3 = Weight.three, _w4 = Weight.four, _w5 = Weight.five;
const _w6 = Weight.six;

/// القواعد الاثنتا عشرة بترتيب الكتاب.
const verbCombos = [
  VerbCombo(_a, _w3, VerbSentence('يا محمدُ احْمَدِ اللهَ', 'احمد', _a, _w3), [
    VerbSentence('اسْمَعْ نصيحةَ أبيكَ', 'اسمع', _a, _w3),
    VerbSentence('اكْتُبْ درسَكَ يا عليُّ', 'اكتب', _a, _w3),
    VerbSentence('اجْلِسْ في مكانِكَ', 'اجلس', _a, _w3),
    VerbSentence('اشْرَبِ الحليبَ يا سعدُ', 'اشرب', _a, _w3),
  ]),
  VerbCombo(_p, _w4, VerbSentence('أنا أُكْرِمُ الضيفَ', 'أكرم', _p, _w4), [
    VerbSentence('أنا أُنْجِزُ أعمالي', 'أنجز', _p, _w4),
    VerbSentence('أنا أُرْسِلُ رسالةً إلى صديقي', 'أرسل', _p, _w4),
    VerbSentence('أنا أُحْسِنُ إلى جاري', 'أحسن', _p, _w4),
    VerbSentence('أنا أُشاهِدُ المباراةَ', 'أشاهد', _p, _w4),
  ]),
  VerbCombo(
    _m,
    _w5,
    VerbSentence('انْطَلَقَ القطارُ بسرعةٍ', 'انطلق', _m, _w5),
    [
      VerbSentence('ارْتَفَعَ الطيرُ في السماءِ', 'ارتفع', _m, _w5),
      VerbSentence('انْتَصَرَ فريقُنا في المباراةِ', 'انتصر', _m, _w5),
      VerbSentence('ابْتَعَدَ القاربُ عن الشاطئِ', 'ابتعد', _m, _w5),
      VerbSentence('اشْتَرى أبي سيارةً جديدةً', 'اشترى', _m, _w5),
    ],
  ),
  VerbCombo(
    _a,
    _w5,
    VerbSentence('احْتَرِمْ أخاكَ الكبيرَ', 'احترم', _a, _w5),
    [
      VerbSentence('ابْتَسِمْ في وجهِ أخيكَ', 'ابتسم', _a, _w5),
      VerbSentence('انْتَبِهْ إلى الشرحِ يا خالدُ', 'انتبه', _a, _w5),
      VerbSentence('اجْتَهِدْ في دروسِكَ', 'اجتهد', _a, _w5),
      VerbSentence('اعْتَمِدْ على نفسِكَ', 'اعتمد', _a, _w5),
    ],
  ),
  VerbCombo(
    _m,
    _w6,
    VerbSentence('اسْتَقْبَلَ محمدٌ ضيوفَهُ', 'استقبل', _m, _w6),
    [
      VerbSentence('اسْتَرْجَعَ خالدٌ دروسَهُ', 'استرجع', _m, _w6),
      VerbSentence('اسْتَيْقَظَ أحمدُ مبكرًا', 'استيقظ', _m, _w6),
      VerbSentence('اسْتَعْمَلَ الطالبُ الحاسوبَ', 'استعمل', _m, _w6),
      VerbSentence('اسْتَخْدَمَ النجارُ المطرقةَ', 'استخدم', _m, _w6),
    ],
  ),
  VerbCombo(
    _m,
    _w4,
    VerbSentence('الحَكَمُ أَعْلَنَ النتيجةَ', 'أعلن', _m, _w4),
    [
      VerbSentence('صالحٌ أَنْجَزَ عملَهُ', 'أنجز', _m, _w4),
      VerbSentence('أَكْرَمَ الرجلُ ضيفَهُ', 'أكرم', _m, _w4),
      VerbSentence('أَرْسَلَ المعلمُ رسالةً', 'أرسل', _m, _w4),
      VerbSentence('أَغْلَقَ الحارسُ البابَ', 'أغلق', _m, _w4),
    ],
  ),
  VerbCombo(
    _a,
    _w4,
    VerbSentence('أَحْسِنْ إلى الفقراءِ يا سعيدُ', 'أحسن', _a, _w4),
    [
      VerbSentence('أَرْشِدِ الناسَ للحقِّ يا مصطفى', 'أرشد', _a, _w4),
      VerbSentence('أَكْرِمْ ضيفَكَ يا عمرُ', 'أكرم', _a, _w4),
      VerbSentence('أَنْجِزْ واجبَكَ يا عليُّ', 'أنجز', _a, _w4),
      VerbSentence('أَغْلِقِ البابَ يا فهدُ', 'أغلق', _a, _w4),
    ],
  ),
  VerbCombo(
    _a,
    _w6,
    VerbSentence('يا سميرُ اسْتَهْلِكِ الطعامَ بحذرٍ', 'استهلك', _a, _w6),
    [
      VerbSentence('اسْتَثْمِرْ وقتَكَ يا ماجدُ', 'استثمر', _a, _w6),
      VerbSentence('اسْتَغْفِرِ اللهَ دائمًا', 'استغفر', _a, _w6),
      VerbSentence('اسْتَخْدِمِ القلمَ الأزرقَ', 'استخدم', _a, _w6),
      VerbSentence('اسْتَعْمِلِ المسطرةَ يا سالمُ', 'استعمل', _a, _w6),
    ],
  ),
  VerbCombo(
    _p,
    _w5,
    VerbSentence('أنا أَشْتَرِكُ في المسابقةِ', 'أشترك', _p, _w5),
    [
      VerbSentence('أنا أَنْتَظِرُ الحافلةَ', 'أنتظر', _p, _w5),
      VerbSentence('أنا أَحْتَرِمُ معلمي', 'أحترم', _p, _w5),
      VerbSentence('أنا أَبْتَعِدُ عن الخطرِ', 'أبتعد', _p, _w5),
      VerbSentence('أنا أَجْتَهِدُ في دروسي', 'أجتهد', _p, _w5),
    ],
  ),
  VerbCombo(
    _p,
    _w6,
    VerbSentence('أنا أَسْتَعِينُ باللهِ', 'أستعين', _p, _w6),
    [
      VerbSentence('أنا أَسْتَعْمِلُ قلمَ الحبرِ', 'أستعمل', _p, _w6),
      VerbSentence('أنا أَسْتَيْقِظُ مبكرًا', 'أستيقظ', _p, _w6),
      VerbSentence('أنا أَسْتَغْفِرُ اللهَ', 'أستغفر', _p, _w6),
      VerbSentence('أنا أَسْتَقْبِلُ الضيوفَ', 'أستقبل', _p, _w6),
    ],
  ),
  VerbCombo(
    _p,
    _w3,
    VerbSentence('أنا أَلْعَبُ في الحديقةِ', 'ألعب', _p, _w3),
    [
      VerbSentence('أنا أَرْسُمُ بقلمِ الرصاصِ', 'أرسم', _p, _w3),
      VerbSentence('أنا أَكْتُبُ الدرسَ', 'أكتب', _p, _w3),
      VerbSentence('أنا أَشْرَبُ الحليبَ', 'أشرب', _p, _w3),
      VerbSentence('أنا أَجْلِسُ في الصفِّ', 'أجلس', _p, _w3),
    ],
  ),
  VerbCombo(_m, _w3, VerbSentence('أَكَلَ محمدٌ البرتقالةَ', 'أكل', _m, _w3), [
    VerbSentence('أَمَرَ الوالدُ ابنَهُ', 'أمر', _m, _w3),
    VerbSentence('أَذِنَ المعلمُ للطالبِ', 'أذن', _m, _w3),
    VerbSentence('أَسِفَ عليٌّ على خطئِهِ', 'أسف', _m, _w3),
    VerbSentence('أَخَذَ الطفلُ اللعبةَ', 'أخذ', _m, _w3),
  ]),
];

/// «اختر الإجابة الصحيحة» (ص ٣٩): اثنتا عشرة جملة تُصنَّف أفعالها.
const verbReviewSentences = [
  VerbSentence('متى اسْتُخْرِجَ البترولُ في السعوديةِ؟', 'استخرج', _m, _w6),
  VerbSentence('هل أَعْتَمِدُ على نفسي؟', 'أعتمد', _p, _w5),
  VerbSentence('كيف أُبْدِعُ في الرسمِ؟', 'أبدع', _p, _w4),
  VerbSentence('كيف أَجْمَعُ الأرقامَ؟', 'أجمع', _p, _w3),
  VerbSentence('يا صالحُ انْتَقِدْ نفسَكَ', 'انتقد', _a, _w5),
  VerbSentence('اليومَ أَسْتَضِيفُ زملائي', 'أستضيف', _p, _w6),
  VerbSentence('أَسْرَعَ العدّاءُ في الجري', 'أسرع', _m, _w4),
  VerbSentence('اغْتَنِمِ الفرصةَ يا فيصلُ', 'اغتنم', _a, _w5),
  VerbSentence('اجْتَمَعَ المديرُ بالطلابِ', 'اجتمع', _m, _w5),
  VerbSentence('اخْرُجْ يا عثمانُ للفناءِ', 'اخرج', _a, _w3),
  VerbSentence('اسْتَرْجِعْ يا عمرُ ذكرياتِكَ', 'استرجع', _a, _w6),
  VerbSentence('أَخَذَ خالدٌ الكتابَ', 'أخذ', _m, _w3),
];

/// جملة «اختر الإجابة الصحيحة» الأولى (ص ٣) وجملة «اختر الإجابات» (ص ٣٨).
const hamzaFirstSentence = VerbSentence('أنا أَكْتُبُ رسالةً', 'أكتب', _p, _w3);
const multiChoiceSentence = VerbSentence(
  'ارْفَعْ يا محمدُ يديكَ إلى السماءِ',
  'ارفع',
  _a,
  _w3,
);

/// كل جمل الأفعال: لأسئلة «قطع أم وصل؟» والبدائل بعد الخطأ.
final List<VerbSentence> allVerbSentences = [
  hamzaFirstSentence,
  multiChoiceSentence,
  for (final c in verbCombos) ...[c.example, ...c.practice],
  ...verbReviewSentences,
];

/// «القاعدة الذهبية» (ص ٢ب): أدخل (ثم) قبل الكلمة.
const goldenRuleExamples = [
  ('عليٌّ وقفَ بينَ يديِ اللهِ ثُمَّ اسْتَغْفَرَ', 'استغفر', Hamza.wasl),
  ('أنا أقفُ بينَ يديِ اللهِ ثُمَّ أَسْتَغْفِرُ', 'أستغفر', Hamza.qat),
];

const hamzaRuleSpeech =
    'همزةُ القطعِ تُكتَبُ هكذا: أَ أو إِ، وتُنطَقُ في أولِ الكلامِ ووسطِه. '
    'وهمزةُ الوصلِ تُكتَبُ ألفًا بلا همزةٍ، وتُنطَقُ في أولِ الكلامِ '
    'ولا تُنطَقُ في وسطِه. أدخِلْ ثُمَّ قبلَ الكلمةِ وانطقْها: إذا اختفتِ '
    'الهمزةُ فهي همزةُ وصلٍ، وإذا ظهرتْ فهي همزةُ قطعٍ.';

/// (ال) التعريف (ص ٧–٨).
const alRuleSpeech = 'همزةُ ألِ التعريفِ همزةُ وصلٍ دائمًا.';
const alRuleWords = ['السماء', 'النار', 'الجنة', 'الأرض', 'التراب', 'الهواء'];
const alExampleWords = ['قلب', 'مسجد', 'أسد', 'ألماس'];

/// «أضف (ال) التعريف» (ص ٩): كلمات قمرية وشمسية، بلا كلمات تبدأ باللام.
const hamzaAlMoonWords = [
  'ورد', 'مشكلة', 'قمر', 'باب', 'بحر', 'جبل', 'حصان', 'فيل', 'عصفور', //
  'كرسي',
];
const hamzaAlSunWords = [
  'ضيف', 'شاهد', 'رجل', 'شمس', 'نهر', 'سوق', 'دفتر', 'زهرة', 'صديق', //
  'تفاحة',
];

/// عشر كلمات في جولات من كلمتين: خمس قمرية وخمس شمسية مخلوطة.
List<List<String>> hamzaAlRounds(Random rnd) {
  final moon = [...hamzaAlMoonWords]..shuffle(rnd);
  final sun = [...hamzaAlSunWords]..shuffle(rnd);
  final words = [...moon.take(5), ...sun.take(5)]..shuffle(rnd);
  return [for (var i = 0; i < words.length; i += 2) words.sublist(i, i + 2)];
}

/// «اسم أم فعل؟» (ص ١٠): أسماء نكرة تدخل عليها (ال).
const hamzaNouns = [
  'سكين', 'قلم', 'كتاب', 'شجرة', 'سيارة', 'نافذة', 'طاولة', 'مفتاح', //
  'ساعة', 'حقيبة',
];

/// «وزن الفعل» (ص ١١–١٢).
const weightExampleLetters = [
  ('لعب', Weight.three),
  ('سافر', Weight.four),
  ('اقترب', Weight.five),
  ('استفاد', Weight.six),
];
const weightExampleVerbs = [
  ('يرتب', 'رتب', Weight.three),
  ('يحارب', 'حارب', Weight.four),
  ('يشتري', 'اشترى', Weight.five),
  ('يستشير', 'استشار', Weight.six),
];

/// «استمع» في صفحة أمثلة الوزن.
const weightExamplesSpeech =
    'يُرتِّبُ: الماضي رتَّبَ، فعلٌ ثلاثيّ. يُحارِبُ: الماضي حارَبَ، فعلٌ رباعيّ. '
    'يشتري: الماضي اشترى، فعلٌ خماسيّ. يستشيرُ: الماضي استشارَ، فعلٌ سداسيّ.';

/// أفعال مضارعة لتمرين الوزن (ص ١٣): (المضارع، الماضي، الوزن).
const weightVerbs = [
  ('يخرج', 'خرج', _w3),
  ('يكتب', 'كتب', _w3),
  ('يلعب', 'لعب', _w3),
  ('يرسم', 'رسم', _w3),
  ('يجلس', 'جلس', _w3),
  ('يشرب', 'شرب', _w3),
  ('يفتح', 'فتح', _w3),
  ('يدرس', 'درس', _w3),
  ('يحارب', 'حارب', _w4),
  ('يسافر', 'سافر', _w4),
  ('يكرم', 'أكرم', _w4),
  ('يرسل', 'أرسل', _w4),
  ('يحسن', 'أحسن', _w4),
  ('يشاهد', 'شاهد', _w4),
  ('ينجز', 'أنجز', _w4),
  ('يعلن', 'أعلن', _w4),
  ('يبتعد', 'ابتعد', _w5),
  ('يشتعل', 'اشتعل', _w5),
  ('ينطلق', 'انطلق', _w5),
  ('يجتمع', 'اجتمع', _w5),
  ('يحترم', 'احترم', _w5),
  ('يبتسم', 'ابتسم', _w5),
  ('ينتظر', 'انتظر', _w5),
  ('يعتمد', 'اعتمد', _w5),
  ('يستشير', 'استشار', _w6),
  ('يستقبل', 'استقبل', _w6),
  ('يستخرج', 'استخرج', _w6),
  ('يستعمل', 'استعمل', _w6),
  ('يستغفر', 'استغفر', _w6),
  ('يستثمر', 'استثمر', _w6),
  ('يستهلك', 'استهلك', _w6),
  ('يسترجع', 'استرجع', _w6),
];

/// أفعال أول جولة كما في الكتاب: يخرج، يستشير، يبتعد، يشتعل.
const weightFirstVerbs = ['يخرج', 'يستشير', 'يبتعد', 'يشتعل'];

/// المصدر (ص ٤١–٥٠): (الفعل الماضي الخماسي أو السداسي، مصدره).
const masdarPairs = [
  ('اعتمد', 'اعتماد'),
  ('استشهد', 'استشهاد'),
  ('ارتكب', 'ارتكاب'),
  ('استغفر', 'استغفار'),
  ('انتشر', 'انتشار'),
  ('استقبل', 'استقبال'),
  ('استمع', 'استماع'),
  ('استنكر', 'استنكار'),
  ('استشعر', 'استشعار'),
  ('احتمل', 'احتمال'),
  ('اشتعل', 'اشتعال'),
  ('امتلك', 'امتلاك'),
  ('ابتكر', 'ابتكار'),
  ('انصهر', 'انصهار'),
  ('انتعش', 'انتعاش'),
  ('استكبر', 'استكبار'),
  ('اجتمع', 'اجتماع'),
  ('اعترف', 'اعتراف'),
  ('استعلم', 'استعلام'),
  ('احتفل', 'احتفال'),
  ('انطلق', 'انطلاق'),
  ('افتتح', 'افتتاح'),
  ('استهلك', 'استهلاك'),
  ('استثمر', 'استثمار'),
  ('اختلف', 'اختلاف'),
  ('اقتنع', 'اقتناع'),
  ('استخرج', 'استخراج'),
  ('انتظر', 'انتظار'),
  ('اشترك', 'اشتراك'),
  ('احترم', 'احترام'),
  ('استخدم', 'استخدام'),
  ('استعمل', 'استعمال'),
  ('انتصر', 'انتصار'),
  ('اجتهد', 'اجتهاد'),
  ('استفسر', 'استفسار'),
  ('استنتج', 'استنتاج'),
];

/// أمثلة المصدر في الكتاب: (الفعل، زمنه، وزنه، مصدره).
const masdarExamples = [
  ('اعتمد', Tense.past, _w5, 'اعتماد'),
  ('استشهد', Tense.past, _w6, 'استشهاد'),
  ('ارتكب', Tense.imperative, _w5, 'ارتكاب'),
  ('استغفر', Tense.imperative, _w6, 'استغفار'),
  ('انتشر', Tense.past, _w5, 'انتشار'),
  ('استقبل', Tense.past, _w6, 'استقبال'),
  ('استمع', Tense.imperative, _w5, 'استماع'),
  ('استنكر', Tense.imperative, _w6, 'استنكار'),
];

/// اسم مشابه للمصدر ليس مصدرًا (استشعر ← مستشعر) خيارًا خاطئًا.
String masdarDistractor(String verb) => 'م${verb.substring(1)}';

/// قاعدة الأسماء (ص ٥١).
const qatNames = ['أحمد', 'إسماعيل', 'إيمان', 'أكرم', 'أشرف'];
const waslNouns = ['ابن', 'ابنة', 'اسم', 'اثنان', 'امرؤ', 'امرأة'];
const alNounExamples = ['الرسم', 'الباب', 'التمر', 'البرتقال'];

/// مقارنة الإجابة المكتوبة مع مراعاة صورة الهمزة (بخلاف [normalizeAnswer]
/// الذي يوحّد الألف في دروس اللام).
bool sameWriting(String typed, String answer) =>
    stripDiacritics(typed).trim() == stripDiacritics(answer).trim();
