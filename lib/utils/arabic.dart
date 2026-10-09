final _diacritics = RegExp('[ً-ْٰـ]');

bool isDiacritic(String char) => _diacritics.hasMatch(char);

/// يحذف التشكيل والتطويل.
String stripDiacritics(String s) => s.replaceAll(_diacritics, '');

/// توحيد الإجابة للمقارنة: بدون تشكيل أو مسافات زائدة، وتوحيد صور الألف
/// (الدرس عن اللام وليس عن الهمزات).
String normalizeAnswer(String s) => stripDiacritics(
  s,
).trim().replaceAll(RegExp(r'\s+'), ' ').replaceAll(RegExp('[أإآ]'), 'ا');

/// الحروف الشمسية الأربعة عشر.
const solarLetters = 'تثدذرزسشصضطظلن';
const lunarLetters = 'ابجحخعغفقكمهوي';

enum LamType {
  moon('لام قمرية', 'تُكتب وتُنطق'),
  sun('لام شمسية', 'تُكتب ولا تُنطق');

  const LamType(this.label, this.rule);
  final String label;
  final String rule;
}

/// نوع اللام حسب الحرف الذي يلي (الـ).
LamType lamTypeOf(String word) {
  final w = stripDiacritics(word);
  final base = w.startsWith('ال') ? w.substring(2) : w;
  return solarLetters.contains(base[0]) ? LamType.sun : LamType.moon;
}

/// الحرف الذي يلي (الـ) في الكلمة.
String letterAfterAl(String word) {
  final w = stripDiacritics(word);
  return w.startsWith('ال') ? w[2] : w[0];
}

/// عدد الحروف (بدون تشكيل) التي تمثل (الـ) في بداية [text] بما فيها
/// تشكيلها، أو 0 إن لم تبدأ بها.
int alPrefixLength(String text) {
  if (!stripDiacritics(text).startsWith('ال')) return 0;
  var letters = 0;
  var i = 0;
  while (i < text.length) {
    if (!isDiacritic(text[i])) letters++;
    i++;
    if (letters == 2) {
      while (i < text.length && isDiacritic(text[i])) {
        i++;
      }
      return i;
    }
  }
  return i;
}

String arDigits(int n) {
  const digits = '٠١٢٣٤٥٦٧٨٩';
  return n
      .toString()
      .split('')
      .map((c) => c == '-' ? c : digits[int.parse(c)])
      .join();
}
