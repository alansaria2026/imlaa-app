/// محتوى درس «الألف اللّينة في الأفعال» بترتيب كتاب الدرس: الفعل الثلاثي
/// (ص ١–١٣).
library;

const alifVerbLessonId = 'alifVerb';
const alifVerbLessonTitle = 'الألف اللّينة في الأفعال';

/// فعل ثلاثي ينتهي بألف لينة: [spoken] مشكول للنطق.
class AlifVerb {
  const AlifVerb(this.word, this.spoken);
  final String word;
  final String spoken;

  /// تُكتب ألفه مقصورة (تنقلب ياءً مع تاء الفاعل).
  bool get maqsura => word.endsWith('ى');

  String get _stem => word.substring(0, word.length - 1);
  String get _spokenStem => spoken.substring(0, spoken.length - 1);

  /// الفعل بعد إضافة تاء الفاعل: بكى ← بكيت، دعا ← دعوت.
  String get withTa => '$_stem${maqsura ? 'ي' : 'و'}ت';
  String get spokenTa => '$_spokenStemَ${maqsura ? 'ي' : 'و'}ْتُ';

  /// الكتابة الخاطئة بالألف الأخرى: بكا، دعى.
  String get wrong => '$_stem${maqsura ? 'ا' : 'ى'}';

  /// الحرف الذي انقلبت إليه الألف.
  String get turnsTo => maqsura ? 'الياء' : 'الواو';

  /// صورة الألف في الفعل.
  String get alifKind => maqsura ? 'المقصورة' : 'الممدودة';
}

/// كل أفعال الدرس.
const alifVerbs = [
  AlifVerb('بكى', 'بَكى'),
  AlifVerb('دعا', 'دَعا'),
  AlifVerb('طوى', 'طَوى'),
  AlifVerb('عفا', 'عَفا'),
  AlifVerb('عوى', 'عَوى'),
  AlifVerb('رأى', 'رَأى'),
  AlifVerb('سها', 'سَها'),
  AlifVerb('جرى', 'جَرى'),
  AlifVerb('مشى', 'مَشى'),
  AlifVerb('قسا', 'قَسا'),
  AlifVerb('نما', 'نَما'),
  AlifVerb('نهى', 'نَهى'),
  AlifVerb('عدا', 'عَدا'),
  AlifVerb('سقى', 'سَقى'),
  AlifVerb('كوى', 'كَوى'),
  AlifVerb('شدا', 'شَدا'),
  AlifVerb('روى', 'رَوى'),
  AlifVerb('خلا', 'خَلا'),
  AlifVerb('صحا', 'صَحا'),
  AlifVerb('لوى', 'لَوى'),
  AlifVerb('خطا', 'خَطا'),
  AlifVerb('حكى', 'حَكى'),
  AlifVerb('جنى', 'جَنى'),
  AlifVerb('بنى', 'بَنى'),
  AlifVerb('سعى', 'سَعى'),
  AlifVerb('غزا', 'غَزا'),
  AlifVerb('رعى', 'رَعى'),
  AlifVerb('محا', 'مَحا'),
  AlifVerb('دنا', 'دَنا'),
  AlifVerb('شكا', 'شَكا'),
  AlifVerb('نوى', 'نَوى'),
  AlifVerb('أتى', 'أَتى'),
  AlifVerb('شوى', 'شَوى'),
  AlifVerb('عصى', 'عَصى'),
  AlifVerb('نجا', 'نَجا'),
  AlifVerb('رمى', 'رَمى'),
  AlifVerb('سما', 'سَما'),
  AlifVerb('غفا', 'غَفا'),
];

AlifVerb alifVerb(String word) => alifVerbs.firstWhere((v) => v.word == word);

// ——— القسم الأول: الفعل الثلاثي ———

const verbBasicsSpeech =
    'الألفُ المقصورةُ تُكتَبُ هكذا: ى، مثلُ: بَكى. والألفُ الممدودةُ '
    'تُكتَبُ هكذا: ا، مثلُ: دَعا.';

const verbRuleSpeech =
    'عندما تحتارُ في كتابةِ الألفِ في الفعلِ الثلاثيِّ، أسنِدِ الفعلَ إلى '
    'نفسِكَ بتاءِ الفاعلِ، مثلُ: بَكى، بَكَيْتُ. دَعا، دَعَوْتُ. إذا نطقتَ '
    'الياءَ فاكتبِ الألفَ مقصورةً، وإذا نطقتَ الواوَ فاكتبِ الألفَ ممدودةً.';

const verbTurnSpeech =
    'لاحظْ كيفَ تنقلبُ الألفُ إلى الياءِ: طَوى، طَوَيْتُ. ولاحظْ كيفَ تنقلبُ '
    'الألفُ إلى الواوِ: عَفا، عَفَوْتُ.';

const verbRememberSpeech =
    'إذا انقلبتِ الألفُ في الفعلِ الثلاثيِّ إلى الواوِ تُكتَبُ ممدودةً. '
    'وإذا انقلبتِ الألفُ في الفعلِ الثلاثيِّ إلى الياءِ تُكتَبُ مقصورةً.';

/// أمثلة القاعدة (ص ١–٣).
const verbRuleExamples = ['بكى', 'دعا'];
const verbTurnExamples = ['طوى', 'عفا'];

/// «اكتب الفعل بعد إضافة تاء الفاعل أو حذفها» (ص ٤–٥) بترتيب الكتاب:
/// الفعل، وهل المعطى الفعل (true) أم الفعل مع تاء الفاعل (false).
const addTaItems = [
  ('عوى', true),
  ('رأى', false),
  ('عفا', false),
  ('دعا', true),
  ('سها', true),
  ('جرى', false),
  ('مشى', true),
  ('قسا', false),
  ('نما', true),
];

/// جملة فيها فعل ثلاثي ينتهي بألف لينة؛ [spoken] مشكولة للنطق.
class AlifVerbSentence {
  const AlifVerbSentence(this.spoken, this.verb);
  final String spoken;
  final String verb;
}

/// المثال المحلول (ص ٦).
const verbExampleSentence = AlifVerbSentence('نَهى اللهُ عن الكذبِ', 'نهى');

const verbExampleSpeech =
    'نَهى اللهُ عن الكذبِ. الفعلُ: نَهى، ومعَ تاءِ الفاعلِ: نَهَيْتُ. '
    'انقلبتِ الألفُ إلى الياءِ، فتُكتَبُ بالألفِ المقصورةِ.';

/// جمل التطبيق (ص ٧).
const verbTableSentences = [
  AlifVerbSentence('عَدا اللاعبُ حولَ الملعبِ', 'عدا'),
  AlifVerbSentence('سَقى المؤمنُ الكلبَ', 'سقى'),
  AlifVerbSentence('كَوى سعيدٌ ثيابَهُ', 'كوى'),
  AlifVerbSentence('شَدا العصفورُ صباحًا', 'شدا'),
  AlifVerbSentence('رَوى خليلٌ القصةَ', 'روى'),
  AlifVerbSentence('خَلا المكانُ من الناسِ', 'خلا'),
  AlifVerbSentence('صَحا عمرُ من النومِ', 'صحا'),
  AlifVerbSentence('لَوى الشرطيُّ يدَ المجرمِ', 'لوى'),
  AlifVerbSentence('خَطا صالحٌ خطواتٍ قليلةً', 'خطا'),
  AlifVerbSentence('نَهى الإسلامُ عن الكذبِ', 'نهى'),
  AlifVerbSentence('حَكى موسى القصةَ', 'حكى'),
  AlifVerbSentence('جَنى المزارعُ الثمارَ', 'جنى'),
];

/// «اختر الكلمة الصحيحة» (ص ١١–١٣).
const verbChoiceSentences = [
  AlifVerbSentence('بَنى العاملُ المنزلَ', 'بنى'),
  AlifVerbSentence('سَعى الحاجُّ بينَ الصفا والمروةِ', 'سعى'),
  AlifVerbSentence('غَزا الجيشُ المدينةَ', 'غزا'),
  AlifVerbSentence('رَعى صالحٌ الأغنامَ', 'رعى'),
  AlifVerbSentence('مَحا طارقٌ السبورةَ', 'محا'),
  AlifVerbSentence('دَنا من النارِ', 'دنا'),
  AlifVerbSentence('شَكا المريضُ من الألمِ', 'شكا'),
  AlifVerbSentence('نَوى عمرُ أن يصلّيَ', 'نوى'),
  AlifVerbSentence('أَتى محمودٌ من المطارِ', 'أتى'),
  AlifVerbSentence('شَوى إبراهيمُ اللحمَ', 'شوى'),
  AlifVerbSentence('عَصى الولدُ أباهُ', 'عصى'),
  AlifVerbSentence('نَجا الغوّاصُ من الموتِ', 'نجا'),
];
