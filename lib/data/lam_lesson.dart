/// محتوى درس «اللام القمرية واللام الشمسية».
library;

const lamLessonId = 'lam';
const lamLessonTitle = 'اللام القمرية واللام الشمسية';

const ruleSpeech =
    'اللامُ القمريةُ تُكتبُ وتُنطقُ، مثلُ: الكتاب. '
    'واللامُ الشمسيةُ تُكتبُ ولا تُنطقُ، مثلُ: السُّكَّر.';

/// صف في صفحة «مثال»: كلمة ± (الـ) = الناتج.
class ExampleRow {
  const ExampleRow(this.from, this.add, this.result);
  final String from;
  final bool add;
  final String result;
}

const lamExamples = [
  ExampleRow('اللحم', false, 'لحم'),
  ExampleRow('صلاة', true, 'الصلاة'),
  ExampleRow('أرض', true, 'الأرض'),
  ExampleRow('الطاولة', false, 'طاولة'),
  ExampleRow('الكوثر', false, 'كوثر'),
  ExampleRow('لبن', true, 'اللبن'),
  ExampleRow('بن', true, 'البن'),
  ExampleRow('الليل', false, 'ليل'),
];

/// الكلمات المستخدمة في تطبيق «أضف الـ» (ص ٣).
const addAlWordBank = [
  'لوحة', 'مربع', 'كتاب', 'بحر', 'أنوار', 'بعيد', 'بيوت', 'تين', //
  'ثوب', 'جديد', 'لهب', 'حرارة', 'حقول', 'دم', 'لغة', 'ذهب', //
  'رمان', 'زهور', 'ساعة', 'سراج', 'شعر', 'صبر', 'لعبة', 'ضمير', //
  'طفل', 'ظل', 'لغز', 'علم', 'غيوم', 'فجر', 'قلوب', 'كريم', //
  'لقمة', 'لطيف', 'لقاء', 'معركة', 'لقاح', 'نعيم', 'لحظة', 'هرم', //
  'لفظ', 'لقطة', 'لمسة', 'مروج', 'لوز', 'لذيذ', 'كلمة', 'يمين', 'ليث',
];

/// تطبيق «احذف الـ» (ص ٧).
const removeAlWords = [
  'اللسان', 'البرج', 'الحرير', 'اللثام', 'الحزن', //
  'اللجنة', 'الجنة', 'اللص', 'اللغو',
];

/// تطبيق الصور (ص ٥).
class PictureItem {
  const PictureItem(this.emoji, this.answer, this.spoken);
  final String emoji;
  final String answer;
  final String spoken;
}

const pictureItems = [
  PictureItem('🐻', 'الدب', 'الدُّبّ'),
  PictureItem('🔑', 'المفتاح', 'المِفتاح'),
  PictureItem('☀️', 'الشمس', 'الشَّمس'),
  PictureItem('⚽', 'الكرة', 'الكُرة'),
  PictureItem('🦊', 'الثعلب', 'الثَّعلب'),
  PictureItem('🖊️', 'القلم', 'القَلَم'),
  PictureItem('🌳', 'الشجرة', 'الشَّجرة'),
  PictureItem('🏟️', 'الملعب', 'المَلعب'),
];

/// جمل التحدي (ص ٦): كل جملة فيها كلمة واحدة بلام قمرية وأخرى بلام شمسية.
class ChallengeSentence {
  const ChallengeSentence(this.spoken, this.moon, this.sun);

  /// الجملة مشكولة للنطق والعرض.
  final String spoken;
  final String moon;
  final String sun;
}

const challengeSentences = [
  ChallengeSentence('المُدرِّبُ يُدرِّبُ اللاعبَ', 'المدرب', 'اللاعب'),
  ChallengeSentence('القمرُ يُضيءُ الليلَ', 'القمر', 'الليل'),
  ChallengeSentence('الولدُ يأكلُ اللحمَ', 'الولد', 'اللحم'),
  ChallengeSentence('الجدُّ يشربُ اللبنَ', 'الجد', 'اللبن'),
  ChallengeSentence('اللاعبُ يركلُ الكرةَ', 'الكرة', 'اللاعب'),
  ChallengeSentence('الطفلُ يحبُّ الحليبَ', 'الحليب', 'الطفل'),
  ChallengeSentence('الشمسُ تُدفئُ الأرضَ', 'الأرض', 'الشمس'),
  ChallengeSentence('النحلةُ تصنعُ العسلَ', 'العسل', 'النحلة'),
  ChallengeSentence('الفلاحُ يزرعُ الزيتونَ', 'الفلاح', 'الزيتون'),
  ChallengeSentence('السمكةُ تسبحُ في البحرِ', 'البحر', 'السمكة'),
];
