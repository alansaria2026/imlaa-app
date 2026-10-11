/// محتوى «اتصال الباء (بـ) بـ(ال) التعريف».
library;

import 'dart:math';

import 'lam_lesson.dart';

/// الاسم مع باء الجر: لا يتغير منه شيء (الكتاب ← بالكتاب، اللحم ← باللحم).
String biForm(String alWord) => 'ب$alWord';

/// نطق الاسم مع باء الجر مشكولًا: بِالْكِتاب، بِالطّائِرَة.
String biSpoken(String alWord) => 'بِ${spokenForm(alWord)}';

/// أمثلة القاعدة مع جملها (ص ١).
const biExamples = [
  ('الطائرة', 'سافرتُ بالطائرةِ'),
  ('الكتب', 'اعتنيتُ بالكتبِ'),
];

/// بنك كلمات التطبيقين (ص ٢ وما يشبهها).
const biWordBank = [
  'الفحم', 'الحياة', 'الرجل', 'الصديق', 'الدولة', 'الساحل', 'السعودية', //
  'الطائرة', 'الكتب', 'القلم', 'السيارة', 'الماء', 'الشمس', 'اللحم', //
  'اللبن', 'الحديقة', 'البيت', 'القطار', 'اليد', 'الصابون', 'الكرة', //
  'الوطن', 'الملعقة', 'العلم', 'المطار',
];

/// [count] كلمة مختلفة، منها اثنتان مبدوءتان باللام للمقارنة بدرس اللام.
List<String> pickBiWords(Random rnd, {int count = 10}) {
  final lam = biWordBank.where((w) => w[2] == 'ل').toList()..shuffle(rnd);
  final other = biWordBank.where((w) => w[2] != 'ل').toList()..shuffle(rnd);
  final lamCount = min(2, lam.length);
  return [...lam.take(lamCount), ...other.take(count - lamCount)]..shuffle(rnd);
}
