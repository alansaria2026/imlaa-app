import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'audio_catalog.g.dart';

/// نطق النصوص العربية: تسجيل جاهز من [audioCatalog] إن وُجد (صوت واحد واضح
/// على كل الأجهزة)، وإلا فمحرك النطق في الجهاز.
class Speaker {
  Speaker._();
  static final instance = Speaker._();

  final FlutterTts _tts = FlutterTts();
  AudioPlayer? _player;
  bool _ready = false;

  /// آخر نص طُلب نطقه (بتسجيل أو بصوت الجهاز)؛ تقرؤه الاختبارات.
  String? lastText;

  /// يزداد مع كل نطق جديد أو إيقاف، فتتوقف السلاسل القديمة ([speakAll]).
  int _generation = 0;

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

  /// [rate] بين 0 و 1 حيث 0.42 هي السرعة الافتراضية؛ وتنتهي عند انتهاء النطق.
  Future<void> speak(String text, {double rate = 0.42}) async {
    lastText = text;
    final generation = ++_generation;
    await _stopAll();
    if (generation != _generation) return;
    final asset = audioCatalog[text];
    if (asset != null && await _playAsset(asset, rate, generation)) return;
    await _init();
    try {
      // على الويب السرعة الطبيعية = 1.
      await _tts.setSpeechRate(kIsWeb ? rate * 2 : rate);
      await _tts.speak(text);
    } catch (_) {}
  }

  /// ينطق النصوص واحدًا بعد الآخر، ويتوقف إن بدأ نطق آخر.
  Future<void> speakAll(List<String> texts, {double rate = 0.42}) async {
    for (final t in texts) {
      final generation = _generation + 1;
      await speak(t, rate: rate);
      if (generation != _generation) return;
      await Future<void>.delayed(const Duration(milliseconds: 250));
      if (generation != _generation) return;
    }
  }

  Future<bool> _playAsset(String asset, double rate, int generation) async {
    try {
      final player = _player ??= AudioPlayer();
      final done = player.onPlayerComplete.first;
      // سرعة التسجيل نسبةً إلى السرعة الافتراضية (البطيئة ≈ ٠٫٦).
      await player.setPlaybackRate((rate / 0.42).clamp(0.5, 1.5));
      await player.play(AssetSource(asset));
      await Future.any([
        done,
        // لا ينتظر إلى الأبد إن أُوقف التشغيل.
        _until(() => generation != _generation),
      ]);
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<void> _until(bool Function() test) async {
    while (!test()) {
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
  }

  Future<void> _stopAll() async {
    try {
      await _player?.stop();
    } catch (_) {}
    try {
      await _tts.stop();
    } catch (_) {}
  }

  Future<void> stop() async {
    _generation++;
    await _stopAll();
  }
}
