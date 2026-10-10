import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// نطق النصوص العربية عبر محرك تحويل النص إلى كلام في الجهاز.
class Speaker {
  Speaker._();
  static final instance = Speaker._();

  final FlutterTts _tts = FlutterTts();
  bool _ready = false;

  Future<void> _init() async {
    if (_ready) return;
    _ready = true;
    try {
      final saAvailable = await _tts.isLanguageAvailable('ar-SA');
      await _tts.setLanguage(saAvailable == true ? 'ar-SA' : 'ar');
      await _pickVoice();
      await _tts.setPitch(1.0);
      await _tts.setVolume(1.0);
      await _tts.awaitSpeakCompletion(true);
    } catch (_) {
      // بعض الأجهزة لا تحتوي صوتًا عربيًا؛ يبقى التطبيق قابلًا للاستخدام.
    }
  }

  /// يختار صوتًا عربيًا محليًا (أوضح وأسرع من الأصوات الشبكية) إن وُجد.
  Future<void> _pickVoice() async {
    final voices = await _tts.getVoices;
    if (voices is! List) return;
    final arabic = [
      for (final v in voices)
        if (v is Map &&
            '${v['locale']}'
                .toLowerCase()
                .replaceAll('_', '-')
                .startsWith('ar'))
          v,
    ];
    if (arabic.isEmpty) return;
    int score(Map v) {
      final locale = '${v['locale']}'.toLowerCase().replaceAll('_', '-');
      final name = '${v['name']}'.toLowerCase();
      return (locale == 'ar-sa' ? 2 : 0) +
          (name.contains('network') ? -3 : 0) +
          (name.contains('local') ? 1 : 0);
    }

    arabic.sort((a, b) => score(b).compareTo(score(a)));
    final best = arabic.first;
    await _tts.setVoice({
      'name': '${best['name']}',
      'locale': '${best['locale']}',
    });
  }

  /// [rate] بين 0 و 1 حيث 0.5 هي السرعة الطبيعية على الجوال.
  Future<void> speak(String text, {double rate = 0.42}) async {
    await _init();
    try {
      await _tts.stop();
      // على الويب السرعة الطبيعية = 1.
      await _tts.setSpeechRate(kIsWeb ? rate * 2 : rate);
      await _tts.speak(text);
    } catch (_) {}
  }

  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (_) {}
  }
}
