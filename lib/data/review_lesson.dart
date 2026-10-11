/// مراجعة الاستماع بعد درسي اتصال اللام والباء بـ(ال): أسئلة مختلطة.
library;

import 'dart:math';

import '../utils/arabic.dart';
import '../widgets/letter_boxes.dart';
import 'bi_lesson.dart';
import 'li_lesson.dart';

/// حرف الجر المتصل بـ(ال).
enum Prep {
  li,
  bi;

  String form(String alWord) => this == li ? liForm(alWord) : biForm(alWord);
  String spoken(String alWord) =>
      this == li ? liSpoken(alWord) : biSpoken(alWord);

  /// الحروف الحمراء في أول الكلمة: «لل» (أو «ل» في للحن)، و«ب».
  int redPrefix(String alWord) => this == li ? liRedPrefix(alWord) : 1;
}

/// سؤال استماع: يُسمع [spoken] ويكتب الطالب [answer] في المربعات.
class ListenItem {
  const ListenItem({
    required this.spoken,
    required this.answer,
    required this.redPrefix,
    this.sentence,
  });

  final String spoken;
  final String answer;
  final int redPrefix;

  /// الجملة مع «…» مكان الكلمة الناقصة؛ null لكلمة مفردة.
  final String? sentence;
}

/// جملة فيها كلمة بحرف جر متصل بـ(ال)، والجملة مشكولة للنطق.
class PrepSentence {
  const PrepSentence(this.prep, this.spoken, this.alWord);
  final Prep prep;
  final String spoken;
  final String alWord;
  String get answer => prep.form(alWord);
}

const prepSentences = [
  PrepSentence(Prep.li, 'ذهبتُ للطبيبِ', 'الطبيب'),
  PrepSentence(Prep.li, 'ذهبْنا للمطارِ', 'المطار'),
  PrepSentence(Prep.li, 'نظرتُ للسماءِ', 'السماء'),
  PrepSentence(Prep.li, 'استمعتُ للحنِ', 'اللحن'),
  PrepSentence(Prep.li, 'ترحيبُ الكُتّابِ للغةِ العربيةِ', 'اللغة'),
  PrepSentence(Prep.li, 'أعطى المدربُ الكرةَ للاعبِ', 'اللاعب'),
  PrepSentence(Prep.li, 'اشتريتُ هديةً للمعلمِ', 'المعلم'),
  PrepSentence(Prep.li, 'قدّمتُ الماءَ للضيفِ', 'الضيف'),
  PrepSentence(Prep.li, 'خرجْنا للحديقةِ', 'الحديقة'),
  PrepSentence(Prep.li, 'عُدْتُ للبيتِ مبكرًا', 'البيت'),
  PrepSentence(Prep.li, 'حبّي للوطنِ كبيرٌ', 'الوطن'),
  PrepSentence(Prep.li, 'أضفتُ السكرَ للبنِ', 'اللبن'),
  PrepSentence(Prep.li, 'قرأتُ القصةَ للطفلِ', 'الطفل'),
  PrepSentence(Prep.li, 'استعدَّ الطالبُ للسفرِ', 'السفر'),
  PrepSentence(Prep.li, 'أهديتُ الكتابَ للمكتبةِ', 'المكتبة'),
  PrepSentence(Prep.li, 'انتبهْ للونِ الإشارةِ', 'اللون'),
  PrepSentence(Prep.bi, 'كتبتُ بالقلمِ', 'القلم'),
  PrepSentence(Prep.bi, 'اعتنيتُ بالكتبِ', 'الكتب'),
  PrepSentence(Prep.bi, 'لعبْنا بالكرةِ', 'الكرة'),
  PrepSentence(Prep.bi, 'غسلتُ يديَّ بالصابونِ', 'الصابون'),
  PrepSentence(Prep.bi, 'أكلتُ الأرزَّ بالملعقةِ', 'الملعقة'),
  PrepSentence(Prep.bi, 'سافرْنا بالقطارِ', 'القطار'),
  PrepSentence(Prep.bi, 'فرحْنا بالنجاحِ', 'النجاح'),
  PrepSentence(Prep.bi, 'مررتُ بالصديقِ', 'الصديق'),
  PrepSentence(Prep.bi, 'نفخرُ بالوطنِ', 'الوطن'),
  PrepSentence(Prep.bi, 'طبختْ أمي الأرزَّ باللحمِ', 'اللحم'),
  PrepSentence(Prep.bi, 'نهتمُّ بالعلمِ', 'العلم'),
  PrepSentence(Prep.bi, 'شربتُ الشايَ باللبنِ', 'اللبن'),
  PrepSentence(Prep.bi, 'استمتعْنا بالحديقةِ', 'الحديقة'),
  PrepSentence(Prep.bi, 'وصلْنا بالسيارةِ', 'السيارة'),
];

/// عدد أسئلة كل صفحة استماع (نصفها باللام ونصفها بالباء).
const listenQuestionCount = 10;

ListenItem _wordItem(Prep p, String w) => ListenItem(
  spoken: p.spoken(w),
  answer: p.form(w),
  redPrefix: p.redPrefix(w),
);

ListenItem _sentenceItem(PrepSentence s) => ListenItem(
  spoken: s.spoken,
  answer: s.answer,
  redPrefix: s.prep.redPrefix(s.alWord),
  sentence: [
    for (final w in s.spoken.split(' '))
      stripDiacritics(w) == s.answer ? '…' : w,
  ].join(' '),
);

/// يأخذ من كل حرف نصف الأسئلة، ويعيد الباقي بدائل لـ«سؤال جديد».
(List<ListenItem>, List<ListenItem>) _mix(
  List<ListenItem> li,
  List<ListenItem> bi,
  Random rnd,
  int count,
) {
  final half = count ~/ 2;
  final items = [...li.take(half), ...bi.take(count - half)]..shuffle(rnd);
  final spare = [...li.skip(half), ...bi.skip(count - half)]..shuffle(rnd);
  return (items, spare);
}

/// «اسمع الكلمة واكتبها»: كلمات باللام وأخرى بالباء، بتركيز على
/// الكلمات المبدوءة باللام (للحن وباللحن).
(List<ListenItem>, List<ListenItem>) listenWordItems(
  Random rnd, {
  int count = listenQuestionCount,
}) {
  final half = count ~/ 2;
  // الكلمات المختارة أولًا (ثلاث منها على الأقل مبدوءة باللام)، ثم البقية.
  List<String> ordered(List<String> picked, List<String> bank) => [
    ...picked,
    ...([...bank.where((w) => !picked.contains(w))]..shuffle(rnd)),
  ];
  List<ListenItem> items(Prep p, List<String> words) => [
    for (final w in words)
      if (ArabicKeyboard.canType(p.form(w))) _wordItem(p, w),
  ];
  return _mix(
    items(Prep.li, ordered(pickLiWords(rnd, count: half), liWordBank)),
    items(Prep.bi, ordered(pickBiWords(rnd, count: count - half), biWordBank)),
    rnd,
    count,
  );
}

/// «اسمع واكتب الكلمة الناقصة»: جمل باللام وأخرى بالباء.
(List<ListenItem>, List<ListenItem>) listenSentenceItems(
  Random rnd, {
  int count = listenQuestionCount,
}) {
  List<ListenItem> of(Prep p) => [
    for (final s in [...prepSentences]..shuffle(rnd))
      if (s.prep == p && ArabicKeyboard.canType(s.answer)) _sentenceItem(s),
  ];
  return _mix(of(Prep.li), of(Prep.bi), rnd, count);
}
