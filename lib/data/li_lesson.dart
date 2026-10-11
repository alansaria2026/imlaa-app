/// محتوى «اتصال اللام (لِـ) بـ(ال) التعريف».
library;

import 'dart:math';

import '../utils/arabic.dart';
import 'lam_lesson.dart';

/// الاسم مع لام الجر: تُحذف ألف (ال)، وإن بدأ الاسم بلام تُحذف لام (ال)
/// أيضًا فلا تجتمع ثلاث لامات (اللحن ← للحن).
String liForm(String alWord) {
  final w = stripDiacritics(alWord);
  assert(w.startsWith('ال'));
  return w[2] == 'ل' ? 'ل${w.substring(2)}' : 'ل${w.substring(1)}';
}

/// نطق الاسم مع لام الجر مشكولًا: لِلْكِتاب، لِلطَّبِيب، لِلَّحْن.
String liSpoken(String alWord) {
  final s = spokenForm(alWord);
  final w = stripDiacritics(alWord);
  if (w[2] == 'ل') {
    // «اللَّحْن» ← «لِلَّحْن»: تسقط الألف ولام (ال).
    return 'لِ${s.substring(alPrefixLength(s))}';
  }
  return 'لِ${s.substring(1)}';
}

/// عدد الحروف الحمراء في أول صيغة لام الجر: «لل» في للكتاب، و«ل» وحدها
/// في للحن لأن اللام الثانية من أصل الكلمة.
int liRedPrefix(String alWord) => stripDiacritics(alWord)[2] == 'ل' ? 1 : 2;

/// أمثلة القاعدة (ص ١).
const liRuleExamples = ['الكتاب', 'السكر', 'اللوحة'];

/// أمثلة الإضافة مع جملها (ص ٢)، وهي نفسها أمثلة الحذف (ص ٣).
const liExamples = [
  ('الطبيب', 'ذهبتُ للطبيبِ'),
  ('المطار', 'ذهبتُ للمطارِ'),
  ('السماء', 'نظرتُ للسماءِ'),
  ('اللحن', 'استمعتُ للحنِ'),
];

/// بنك كلمات التطبيقات: قمرية وشمسية، مع تركيز على المبدوءة باللام.
const liWordBank = [
  'الطبيب', 'المطار', 'السماء', 'اللحن', 'الكتاب', 'السكر', 'اللوحة', //
  'المدرسة', 'البيت', 'الشمس', 'القمر', 'الحديقة', 'الوطن', 'الصديق', //
  'النجاح', 'العلم', 'اللاعب', 'الليل', 'اللبن', 'اللغة', 'اللعبة', //
  'الطالب', 'المعلم', 'الفريق', 'الضيف', 'الزهرة', 'الرياضة', 'التلميذ', //
  'الجار', 'السفر', 'النهر', 'اللحم', 'اللون',
];

/// عدد أسئلة كل تمرين.
const liQuestionCount = 10;

/// [count] كلمة مختلفة في كل مرة، نحو خُمسيها مبدوءة باللام.
List<String> pickLiWords(Random rnd, {int count = liQuestionCount}) {
  final lam = liWordBank.where((w) => w[2] == 'ل').toList()..shuffle(rnd);
  final other = liWordBank.where((w) => w[2] != 'ل').toList()..shuffle(rnd);
  final lamCount = min(max(3, count * 2 ~/ 5), lam.length);
  return [...lam.take(lamCount), ...other.take(count - lamCount)]..shuffle(rnd);
}
