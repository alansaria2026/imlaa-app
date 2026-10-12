import '../data/bi_lesson.dart';
import '../data/lam_lesson.dart';
import '../data/li_lesson.dart';
import '../data/review_lesson.dart';
import '../data/taa_lesson.dart';

/// كل النصوص التي قد ينطقها التطبيق، لتوليد تسجيلاتها مسبقًا
/// (tool/generate_audio.py). أي نص غير موجود هنا يُنطق بصوت الجهاز.
Set<String> allSpeechTexts() => {
  // الإعدادات: «جرّب الصوت».
  'الشَّمسُ مُشرقةٌ والقمرُ جميل',
  // القاعدة والأمثلة.
  ruleSpeech,
  'الكِتاب',
  'السُّكَّر',
  for (final e in lamExamples) ...[spokenForm(e.from), spokenForm(e.result)],
  // أضف (الـ) واحذفها: تُنطق كلمة السؤال.
  for (final w in addAlWordBank) spokenForm(w),
  for (final w in removeAlWords) spokenForm(w),
  // سمِّ الصورة وتحدي الاستماع.
  for (final p in pictureItems) p.spoken,
  for (final s in challengeSentences) s.spoken,
  // اتصال اللام والباء وحذفهما، وصفحتا الاستماع.
  for (final w in liWordBank) ...[spokenForm(w), liSpoken(w)],
  for (final w in biWordBank) ...[spokenForm(w), biSpoken(w)],
  for (final s in prepSentences) s.spoken,
  for (final (_, sentence) in liExamples) sentence,
  for (final (_, sentence) in biExamples) sentence,
  // درس التاء المربوطة والتاء المفتوحة.
  taaRuleSpeech,
  taaRuleSentence,
  for (final (_, spoken) in taaRuleWords) spoken,
  for (final s in [...taaSentences, ...taaSpareSentences]) s.spoken,
  taaChoiceInstruction,
  for (final (a, b) in taaChoicePairs) ...[a.spoken, b.spoken],
};
