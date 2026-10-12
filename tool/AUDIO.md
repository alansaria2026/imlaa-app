# تسجيلات النطق

التطبيق يشغّل تسجيلًا جاهزًا لكل نص منطوق إن وُجد في
`lib/services/audio_catalog.g.dart`، وإلا ينطق بصوت الجهاز
(`lib/services/speaker.dart`). كل النصوص المنطوقة معرّفة في
`lib/services/speech_texts.dart`.

## توليد التسجيلات

يحتاج المفتاح `GEMINI_API_KEY` (مجاني من aistudio.google.com/apikey) في
متغيرات بيئة العمل.

```bash
# ١. تحديث قائمة النصوص (بعد أي تغيير في كلمات الدروس)
flutter test tool/export_speech_test.dart

# ٢. عينات من أربعة أصوات في build/voice_samples/ ليختار صاحب التطبيق
python3 tool/generate_audio.py --samples

# ٣. كل التسجيلات بالصوت المختار، ثم الفهرس
python3 tool/generate_audio.py --voice Orus
```

بعدها: `flutter analyze` و`flutter test`، ثم الالتزام ورفع الفرع، ونشر نسخة
الويب على فرع `gh-pages`:

```bash
flutter build web --release --base-href /imlaa-app/ --no-web-resources-cdn --pwa-strategy=none
# ثم انسخ محتوى build/web إلى فرع gh-pages (مع ملف .nojekyll ودون ملفات .symbols) وارفعه.
```

## الحالة الحالية (لمن يكمل العمل)

- اختار صاحب التطبيق الصوت **Orus** بالنموذج `gemini-3.8-flash-tts`.
- الحد المجاني ١٠ طلبات يوميًا لكل نموذج (يتجدد منتصف الليل بتوقيت المحيط
  الهادئ)، لذلك تجمع الأداة ٣٠ نصًا في الطلب ثم تقطع الصوت عند فترات الصمت.
  إن انتهى الحد فأعد تشغيل الأمر في اليوم التالي، فهو يكمل ما بقي فقط.
- النماذج الأحدث تقرأ أي تعليمات بصوت مسموع، فالأداة ترسل النص وحده.
- اشتكى صاحب التطبيق من نطق خاطئ لكلمة في صفحة «استماع الباء» بصوت الآيفون؛
  تحقق بعد التوليد من نطق كلمات الباء واللام الشمسية (مثل بِالشَّمْس، لِلَّحْن).
- الفوترة في Google Cloud غير متاحة مباشرة في السعودية (عبر CNTXT)، لذلك
  نستخدم Gemini من AI Studio بلا فوترة.
