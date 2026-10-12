/// محتوى درس «التاء المربوطة والتاء المفتوحة».
library;

import 'dart:math';

import '../utils/arabic.dart';
import 'review_lesson.dart';

const taaLessonId = 'taa';
const taaLessonTitle = 'التاء المربوطة والتاء المفتوحة';

const taaRuleSpeech =
    'التاءُ المربوطةُ يمكنُ أن تُقلَبَ هاءً عندَ الوقفِ، مثلُ: الكريمَهْ. '
    'والتاءُ المفتوحةُ لا يمكنُ أن تُقلَبَ هاءً، مثلُ: الياقوتْ.';

/// جملة مثال القاعدة (ص ١): الياقوت بتاء مفتوحة، والكريمة والجميلة بتاء مربوطة.
const taaRuleSentence = 'الياقوتُ من الأحجارِ الكريمةِ والجميلةِ';

/// كلمتا المثال: الكلمة، ونطقها عند الوقف.
const taaRuleWords = [('الكريمة', 'الكَرِيمَهْ'), ('الياقوت', 'اليَاقُوتْ')];

/// نوع التاء في آخر الكلمة.
enum TaaType {
  marbuta,
  maftuha;

  String get label => this == marbuta ? 'تاء مربوطة' : 'تاء مفتوحة';
}

/// نوع التاء في آخر [word]، أو null إن لم تنتهِ بتاء.
TaaType? taaTypeOf(String word) {
  final w = stripDiacritics(word);
  if (w.endsWith('ة')) return TaaType.marbuta;
  if (w.endsWith('ت')) return TaaType.maftuha;
  return null;
}

/// «اسمع الجملة واكتب الكلمة الناقصة» (ص ٣): الجملة مشكولة للنطق،
/// و[word] الكلمة الناقصة كما تُكتب.
class TaaSentence {
  const TaaSentence(this.spoken, this.word);
  final String spoken;
  final String word;
}

/// جمل كتاب الدرس العشر.
const taaSentences = [
  TaaSentence('حافِظْ على الصلواتِ الخمسِ', 'الصلوات'),
  TaaSentence('السبتُ من أيامِ الأسبوعِ', 'السبت'),
  TaaSentence('الكعبةُ بيتُ اللهِ الحرامُ', 'بيت'),
  TaaSentence('السعوديةُ تُصدِّرُ البترولَ', 'السعودية'),
  TaaSentence('الرياضةُ مفيدةٌ للجسمِ', 'الرياضة'),
  TaaSentence('الحوتُ الأزرقُ حجمُهُ كبيرٌ', 'الحوت'),
  TaaSentence('أُحبُّ مادةَ التربيةِ البدنيةِ', 'التربية'),
  TaaSentence('الكتبُ بها معلوماتٌ مفيدةٌ', 'معلومات'),
  TaaSentence('يومُ الجمعةِ أفضلُ الأيامِ', 'الجمعة'),
  TaaSentence('صوتُ الأذانِ مرتفعٌ', 'صوت'),
];

/// جمل بديلة بالتوزيع نفسه: إذا أخطأ الطالب تُعاد عليه الأسئلة بجمل جديدة.
const taaSpareSentences = [
  TaaSentence('الوقتُ من ذهبٍ', 'الوقت'),
  TaaSentence('التوتُ فاكهةٌ لذيذةٌ', 'التوت'),
  TaaSentence('البنتُ مجتهدةٌ', 'البنت'),
  TaaSentence('حفِظْتُ أبياتَ القصيدةِ', 'أبيات'),
  TaaSentence('الطالباتُ في الفصلِ', 'الطالبات'),
  TaaSentence('زرعْنا النباتاتِ في الحديقةِ', 'النباتات'),
  TaaSentence('قرأْتُ الصفحاتِ كلَّها', 'الصفحات'),
  TaaSentence('المدرسةُ نظيفةٌ', 'المدرسة'),
  TaaSentence('ركبْتُ السيارةَ مع أبي', 'السيارة'),
  TaaSentence('الشجرةُ عاليةٌ', 'الشجرة'),
];

ListenItem _listenItem(TaaSentence s) => ListenItem(
  spoken: s.spoken,
  answer: s.word,
  redPrefix: 0,
  sentence: [
    for (final w in s.spoken.split(' ')) stripDiacritics(w) == s.word ? '…' : w,
  ].join(' '),
  colorTaa: true,
);

/// أسئلة صفحة الاستماع: جمل الكتاب مخلوطة، والبدائل للأسئلة المعادة.
(List<ListenItem>, List<ListenItem>) taaListenItems(Random rnd) => (
  [
    for (final s in [...taaSentences]..shuffle(rnd)) _listenItem(s),
  ],
  [
    for (final s in [...taaSpareSentences]..shuffle(rnd)) _listenItem(s),
  ],
);

/// شرح الخطأ إن اختلفت الإجابة في الحرف الأخير فقط (ة/ت/ه)، وإلا null.
String? taaMistake(String typed, String answer) {
  if (typed.length != answer.length || typed == answer) return null;
  final n = answer.length - 1;
  if (typed.substring(0, n) != answer.substring(0, n)) return null;
  final wrote = typed[n];
  if (answer[n] == 'ة') {
    return wrote == 'ه'
        ? 'آخر الكلمة تاء مربوطة (ة) بنقطتين، وليست هاءً (ه)'
        : 'آخر الكلمة تاء مربوطة (ة): قف عليها تسمعها هاءً';
  }
  if (answer[n] == 'ت' && (wrote == 'ة' || wrote == 'ه')) {
    return 'آخر الكلمة تاء مفتوحة (ت): تبقى تاءً عند الوقف';
  }
  return null;
}

/// «اختر الكلمة المناسبة لإكمال الجملة» (ص ٥): الكلمة تنتهي بتاء مربوطة
/// أو بهاء، والمعنى يتغير بينهما (مكتبة: تبيع الكتب، مكتبه: واسع).
class TaaChoice {
  const TaaChoice(this.word, this.answer, this.wrong, this.spoken);

  /// الكلمة كما تُكتب في السؤال.
  final String word;
  final String answer;
  final String wrong;

  /// الجملة كاملة مشكولة، تُنطق بعد الإجابة الصحيحة.
  final String spoken;
}

/// أزواج الكلمات: الأولى كما في كتاب الدرس، والثانية صورتها الأخرى
/// (التاء المربوطة مكان الهاء أو العكس) بالخيارين نفسيهما.
const taaChoicePairs = [
  (
    TaaChoice('مكتبه', 'واسع', 'تبيع الكتب', 'مَكْتَبُهُ واسِعٌ'),
    TaaChoice('مكتبة', 'تبيع الكتب', 'واسع', 'مَكْتَبَةٌ تَبِيعُ الكُتُبَ'),
  ),
  (
    TaaChoice('ليلة', 'السبت', 'مظلم', 'لَيْلَةُ السَّبْتِ'),
    TaaChoice('ليله', 'مظلم', 'السبت', 'لَيْلُهُ مُظْلِمٌ'),
  ),
  (
    TaaChoice('الكره', 'عكس الحب', 'في الملعب', 'الكُرْهُ عَكْسُ الحُبِّ'),
    TaaChoice('الكرة', 'في الملعب', 'عكس الحب', 'الكُرَةُ فِي المَلْعَبِ'),
  ),
  (
    TaaChoice('كتابة', 'بالقلم', 'نظيف', 'كِتابَةٌ بِالقَلَمِ'),
    TaaChoice('كتابه', 'نظيف', 'بالقلم', 'كِتابُهُ نَظِيفٌ'),
  ),
  (
    TaaChoice('عمره', 'طويل', 'مقبولة', 'عُمْرُهُ طَوِيلٌ'),
    TaaChoice('عمرة', 'مقبولة', 'طويل', 'عُمْرَةٌ مَقْبُولَةٌ'),
  ),
];

const taaChoiceInstruction = 'اخترِ الكلمةَ المناسبةَ لإكمالِ الجملةِ';

/// الصورة الأخرى للكلمة (مكتبة ← مكتبه).
TaaChoice taaChoicePartner(TaaChoice c) {
  final (a, b) = taaChoicePairs.firstWhere((p) => p.$1 == c || p.$2 == c);
  return a == c ? b : a;
}

/// خمسة أسئلة: صورة واحدة من كل زوج، والصورة الأخرى بديل يأتي بعد الخطأ.
(List<TaaChoice>, List<TaaChoice>) taaChoiceItems(Random rnd) {
  final items = <TaaChoice>[];
  final spare = <TaaChoice>[];
  for (final (a, b) in [...taaChoicePairs]..shuffle(rnd)) {
    final first = rnd.nextBool();
    items.add(first ? a : b);
    spare.add(first ? b : a);
  }
  return (items, spare);
}
