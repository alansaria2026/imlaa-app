import 'package:flutter/material.dart';

import '../../app_state.dart';
import '../../data/lam_lesson.dart';
import '../../services/speaker.dart';
import '../../theme.dart';
import '../../utils/arabic.dart';
import '../../widgets/common.dart';
import '../../widgets/letter_boxes.dart';
import '../page_handle.dart';

/// ص ٥: اكتب اسم ما تراه في الصورة مع (الـ) داخل المربعات.
class PicturePage extends StatefulWidget {
  const PicturePage({super.key, required this.handle});
  final PageHandle handle;

  @override
  State<PicturePage> createState() => _PicturePageState();
}

class _PicturePageState extends State<PicturePage> {
  /// الأسئلة الخاطئة تُعاد إلى آخر الطابور حتى يجيب عن الثمانية كلها.
  late final List<int> _queue = [
    for (var i = 0; i < pictureItems.length; i++) i,
  ];
  final Set<int> _penalty = {};
  final List<String> _typed = [];
  int _solved = 0;
  int _shake = 0;
  bool _error = false;
  bool _showWord = false;

  PictureItem? get _item => _queue.isEmpty ? null : pictureItems[_queue.first];
  List<String> get _target => _item!.answer.split('');

  @override
  void initState() {
    super.initState();
    widget.handle
      ..onListen = () {
        final item = _item;
        if (item != null) {
          Speaker.instance.speak(
            item.spoken,
            rate: AppScope.read(context).speechRate,
          );
        }
      }
      ..onHint = _hint;
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => widget.handle.setProgress(0, pictureItems.length),
    );
  }

  void _hint() {
    if (_item == null || _showWord) return;
    final target = _target;
    var keep = 0;
    while (keep < _typed.length &&
        keep < target.length &&
        _typed[keep] == target[keep]) {
      keep++;
    }
    if (keep >= target.length) return;
    _penalty.add(_queue.first);
    setState(() {
      _error = false;
      _typed
        ..removeRange(keep, _typed.length)
        ..add(target[keep]);
    });
    showFeedback(
      context,
      'الحرف التالي هو «${target[keep]}»',
      tone: FeedbackTone.hint,
    );
    if (_typed.length == target.length) _evaluate();
  }

  void _onLetter(String l) {
    if (_item == null || _showWord) return;
    if (_typed.length >= _target.length) return;
    setState(() {
      _error = false;
      _typed.add(l);
    });
    if (_typed.length == _target.length) _evaluate();
  }

  void _onBackspace() {
    if (_typed.isEmpty || _showWord) return;
    setState(() {
      _error = false;
      _typed.removeLast();
    });
  }

  void _evaluate() {
    final idx = _queue.first;
    final item = pictureItems[idx];
    if (_typed.join() == item.answer) {
      AppScope.read(context).addPoints(_penalty.contains(idx) ? 5 : 10);
      showFeedback(
        context,
        'أحسنت! ${remainingText(pictureItems.length - _solved - 1)}',
      );
      Speaker.instance.speak(
        item.spoken,
        rate: AppScope.read(context).speechRate,
      );
      setState(() {
        _showWord = true;
        _solved++;
      });
      widget.handle.setProgress(_solved, pictureItems.length);
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (!mounted) return;
        setState(() {
          _queue.removeAt(0);
          _typed.clear();
          _showWord = false;
        });
        if (_queue.isEmpty) widget.handle.markComplete();
      });
    } else {
      _penalty.add(idx);
      showFeedback(
        context,
        'الإجابة غير صحيحة، سيعاد هذا السؤال لاحقًا',
        tone: FeedbackTone.error,
      );
      setState(() {
        _error = true;
        _shake++;
      });
      Future.delayed(const Duration(milliseconds: 900), () {
        if (!mounted) return;
        setState(() {
          _error = false;
          _typed.clear();
          if (_queue.length > 1) _queue.add(_queue.removeAt(0));
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = _item;
    return PageCard(
      title: 'اكتب اسم ما تراه في الصورة',
      child: item == null
          ? const PageDoneMessage()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Container(
                    key: ValueKey(_queue.first),
                    height: 108,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.line, width: 1.5),
                    ),
                    child: Text(
                      item.emoji,
                      style: const TextStyle(fontSize: 64),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 68,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 350),
                    transitionBuilder: (c, a) => ScaleTransition(
                      scale: a,
                      child: FadeTransition(opacity: a, child: c),
                    ),
                    child: _showWord
                        ? Center(
                            key: const ValueKey('word'),
                            child: AlText(item.answer, size: 44),
                          )
                        : ShakeOnChange(
                            key: const ValueKey('boxes'),
                            trigger: _shake,
                            child: Center(
                              child: LetterBoxes(
                                length: _target.length,
                                letters: _typed,
                                error: _error,
                              ),
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 12),
                ArabicKeyboard(onLetter: _onLetter, onBackspace: _onBackspace),
              ],
            ),
    );
  }
}
