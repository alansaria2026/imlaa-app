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
      await _tts.awaitSpeakCompletion(true);
    } catch (_) {
      // بعض الأجهزة لا تحتوي صوتًا عربيًا؛ يبقى التطبيق قابلًا للاستخدام.
    }
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
