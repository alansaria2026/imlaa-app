// يكتب كل نصوص النطق إلى tool/speech_texts.json لتوليد التسجيلات:
//   flutter test tool/export_speech_test.dart
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:imlaa/services/speech_texts.dart';

void main() {
  test('تصدير نصوص النطق', () {
    final texts = allSpeechTexts().toList()..sort();
    File(
      'tool/speech_texts.json',
    ).writeAsStringSync(const JsonEncoder.withIndent('  ').convert(texts));
    expect(texts, isNotEmpty);
  });
}
