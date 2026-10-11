import 'package:flutter_test/flutter_test.dart';
import 'dart:math';

import 'package:imlaa/data/bi_lesson.dart';
import 'package:imlaa/data/lam_lesson.dart';
import 'package:imlaa/data/li_lesson.dart';
import 'package:imlaa/lesson/lam_lesson_pages.dart';
import 'package:imlaa/utils/arabic.dart';

void main() {
  group('lamTypeOf', () {
    test('يميز القمرية والشمسية', () {
      expect(lamTypeOf('الكتاب'), LamType.moon);
      expect(lamTypeOf('السُّكَّر'), LamType.sun);
      expect(lamTypeOf('الليل'), LamType.sun);
      expect(lamTypeOf('الأرض'), LamType.moon);
    });

    test('مجموعتا الحروف تغطيان ١٤ + ١٤ حرفًا بلا تكرار', () {
      expect(solarLetters.length, 14);
      expect(lunarLetters.length, 14);
      expect(
        solarLetters
            .split('')
            .toSet()
            .intersection(lunarLetters.split('').toSet()),
        isEmpty,
      );
    });
  });

  test('alPrefixLength يشمل تشكيل اللام', () {
    expect(alPrefixLength('الكتاب'), 2);
    expect(alPrefixLength('الْكتاب'), 3);
    expect(alPrefixLength('كتاب'), 0);
  });

  test('normalizeAnswer يتجاهل التشكيل وصور الألف', () {
    expect(normalizeAnswer(' المُدرِّبُ '), 'المدرب');
    expect(normalizeAnswer('الأرض'), normalizeAnswer('الارض'));
  });

  test('كل جملة تحدٍّ فيها كلمة قمرية وكلمة شمسية فقط', () {
    expect(challengeSentences.length, 10);
    for (final s in challengeSentences) {
      final words = normalizeAnswer(s.spoken).split(' ');
      final alWords = words.where((w) => w.startsWith('ال')).toList();
      expect(alWords.length, 2, reason: s.spoken);
      expect(words, contains(normalizeAnswer(s.moon)), reason: s.spoken);
      expect(words, contains(normalizeAnswer(s.sun)), reason: s.spoken);
      expect(lamTypeOf(s.moon), LamType.moon, reason: s.moon);
      expect(lamTypeOf(s.sun), LamType.sun, reason: s.sun);
    }
  });

  test('إجابات الصور تبدأ بـ (الـ)', () {
    expect(pictureItems.length, 8);
    for (final p in pictureItems) {
      expect(p.answer.startsWith('ال'), isTrue);
      expect(normalizeAnswer(p.spoken), p.answer);
    }
    expect(pictureItems.first.answer.split(''), ['ا', 'ل', 'د', 'ب']);
  });

  test('أمثلة الإضافة والحذف متسقة', () {
    for (final e in lamExamples) {
      expect(e.add ? 'ال${e.from}' : e.from.substring(2), e.result);
    }
    for (final w in removeAlWords) {
      expect(w.startsWith('ال'), isTrue);
    }
  });

  test('بناء صفحات الدرس', () {
    final pages = buildLamLessonPages();
    expect(pages.length, 14);
    expect(addAlWordBank.toSet().length, addAlWordBank.length);
  });

  test('النطق مشكول: سكون للقمرية وشدة للشمسية', () {
    expect(spokenForm('كتاب'), 'كِتاب');
    expect(spokenForm('الكتاب'), 'الْكِتاب');
    // الشدة تُضاف بعد الحرف مباشرة ثم حركته.
    expect(spokenForm('الشعر'), 'الش\u0651\u064Eعْر');
    expect(spokenForm('الظل'), 'الظ\u0651\u0650لّ');
    for (final w in [...addAlWordBank, ...removeAlWords]) {
      expect(spokenForm(w), isNot(w), reason: w);
      expect(normalizeAnswer(spokenForm(w)), normalizeAnswer(w), reason: w);
    }
    for (final e in lamExamples) {
      expect(normalizeAnswer(spokenForm(e.result)), normalizeAnswer(e.result));
    }
  });

  group('اتصال اللام بـ(ال)', () {
    test('لامان فقط، ولا تجتمع ثلاث لامات', () {
      expect(liForm('الكتاب'), 'للكتاب');
      expect(liForm('السكر'), 'للسكر');
      expect(liForm('اللوحة'), 'للوحة');
      expect(liForm('اللحن'), 'للحن');
      expect(liRedPrefix('الكتاب'), 2);
      expect(liRedPrefix('اللحن'), 1);
    });

    test('النطق مشكول', () {
      expect(liSpoken('الكتاب'), 'لِلْكِتاب');
      expect(normalizeAnswer(liSpoken('الطبيب')), 'للطبيب');
      expect(normalizeAnswer(liSpoken('اللحن')), 'للحن');
      for (final w in liWordBank) {
        expect(spokenForm(w), isNot(w), reason: w);
        expect(normalizeAnswer(liSpoken(w)), liForm(w), reason: w);
      }
    });

    test('عشر كلمات مختلفة منها أربع مبدوءة باللام', () {
      expect(liWordBank.toSet().length, liWordBank.length);
      final words = pickLiWords(Random(1));
      expect(words.length, 10);
      expect(words.toSet().length, 10);
      expect(words.where((w) => w[2] == 'ل').length, 4);
      // البنك كله (للبدائل) دون فقد كلمات.
      expect(
        pickLiWords(Random(1), count: liWordBank.length).toSet(),
        liWordBank.toSet(),
      );
    });

    test('كل جملة فيها الكلمة الناقصة مرة واحدة', () {
      expect(liSentences.length, 20);
      for (final s in liSentences) {
        final words = normalizeAnswer(s.spoken).split(' ');
        expect(words.where((w) => w == s.answer).length, 1, reason: s.spoken);
      }
    });
  });

  group('اتصال الباء بـ(ال)', () {
    test('تُكتب الباء ويبقى الاسم كما هو', () {
      expect(biForm('الطائرة'), 'بالطائرة');
      expect(biForm('اللحم'), 'باللحم');
      expect(biSpoken('الكتب'), 'بِالْكُتُب');
      for (final w in biWordBank) {
        expect(spokenForm(w), isNot(w), reason: w);
        expect(normalizeAnswer(biSpoken(w)), normalizeAnswer(biForm(w)));
      }
    });

    test('عشر كلمات مختلفة منها اثنتان مبدوءتان باللام', () {
      expect(biWordBank.toSet().length, biWordBank.length);
      final words = pickBiWords(Random(2));
      expect(words.toSet().length, 10);
      expect(words.where((w) => w[2] == 'ل').length, 2);
    });
  });
}
