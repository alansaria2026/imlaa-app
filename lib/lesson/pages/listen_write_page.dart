import 'package:flutter/material.dart';

import '../../app_state.dart';
import '../../data/review_lesson.dart';
import '../../services/speaker.dart';
import '../../theme.dart';
import '../../utils/arabic.dart';
import '../../widgets/common.dart';
import '../../widgets/letter_boxes.dart';
import '../../widgets/pressable.dart';
import '../../widgets/taa_text.dart';
import '../page_handle.dart';

/// اسمع الكلمة (أو الجملة) واكتب الكلمة بحرف الجر في المربعات ثم «إدخال».
class ListenWritePage extends StatefulWidget {
  const ListenWritePage({
    super.key,
    required this.handle,
    required this.title,
    required this.items,
    this.spare = const [],
    this.newOnError = false,
    this.explainMistake,
    this.titleColor,
    this.sentenceColor = AppColors.ink,
  });

  final PageHandle handle;
  final String title;
  final List<ListenItem> items;

  /// أسئلة بديلة: الرجوع للقاعدة يعيد الطالب «بكلمة جديدة».
  final List<ListenItem> spare;

  /// بعد الخطأ يُؤجَّل السؤال ويأتي مكانه سؤال جديد من [spare].
  final bool newOnError;

  /// شرح للخطأ من الإجابة المكتوبة والصحيحة؛ null إن لم يوجد شرح.
  final String? Function(String typed, String answer)? explainMistake;

  /// لون العنوان (السؤال)؛ null للون الأساسي.
  final Color? titleColor;

  /// لون الجملة.
  final Color sentenceColor;

  @override
  State<ListenWritePage> createState() => _ListenWritePageState();
}

class _ListenWritePageState extends State<ListenWritePage> {
  late final List<ListenItem> _queue = [...widget.items];
  late final List<ListenItem> _spare = [...widget.spare];
  final Set<ListenItem> _penalty = {};
  final List<String> _typed = [];
  int _solved = 0;
  int _shake = 0;
  bool _error = false;
  bool _showWord = false;

  int get _total => widget.items.length;
  ListenItem? get _item => _queue.isEmpty ? null : _queue.first;

  @override
  void initState() {
    super.initState();
    widget.handle
      ..onListen = _speak
      ..onEnter = _speak
      ..onSubmit = _submit
      ..onRuleOpened = _newQuestion
      ..onHint = _hint;
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => widget.handle.setProgress(0, _total),
    );
  }

  void _speak() {
    final item = _item;
    if (item == null) return;
    Speaker.instance.speak(
      item.spoken,
      rate: AppScope.read(context).speechRate,
    );
  }

  /// بعد الرجوع للقاعدة: سؤال جديد مكان السؤال الحالي.
  void _newQuestion() {
    if (_item == null || _showWord) return;
    setState(() {
      final current = _queue.removeAt(0);
      if (_spare.isNotEmpty) {
        _queue.insert(0, _spare.removeAt(0));
        _spare.add(current);
      } else {
        _queue.add(current);
      }
      _typed.clear();
      _error = false;
    });
  }

  void _hint() {
    final item = _item;
    if (item == null || _showWord) return;
    final target = item.answer.split('');
    var keep = 0;
    while (keep < _typed.length &&
        keep < target.length &&
        _typed[keep] == target[keep]) {
      keep++;
    }
    if (keep >= target.length) return;
    _penalty.add(item);
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
  }

  void _onLetter(String l) {
    final item = _item;
    if (item == null || _showWord) return;
    if (_typed.length >= item.answer.length) return;
    setState(() {
      _error = false;
      _typed.add(l);
    });
  }

  void _onBackspace() {
    if (_typed.isEmpty || _showWord) return;
    setState(() {
      _error = false;
      _typed.removeLast();
    });
  }

  /// «إدخال» بعد الفراغ من الإجابة.
  void _submit() {
    final item = _item;
    if (item == null || _showWord) return;
    if (_typed.length < item.answer.length) {
      showFeedback(
        context,
        'أكمل كتابة الكلمة ثم اضغط «إدخال»',
        tone: FeedbackTone.error,
      );
      return;
    }
    if (_typed.join() == item.answer) {
      AppScope.read(context).addPoints(_penalty.contains(item) ? 5 : 10);
      showFeedback(context, 'أحسنت! ${remainingText(_total - _solved - 1)}');
      setState(() {
        _showWord = true;
        _solved++;
      });
      widget.handle.setProgress(_solved, _total);
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (!mounted) return;
        setState(() {
          _queue.removeAt(0);
          _typed.clear();
          _showWord = false;
        });
        if (_queue.isEmpty) {
          widget.handle.markComplete();
        } else {
          _speak();
        }
      });
    } else {
      _penalty.add(item);
      showFeedback(
        context,
        [
          widget.explainMistake?.call(_typed.join(), item.answer) ??
              'الإجابة غير صحيحة',
          widget.newOnError && _spare.isNotEmpty
              ? 'إليك جملة جديدة'
              : 'سيعاد هذا السؤال لاحقًا',
        ].join('، '),
        tone: FeedbackTone.error,
      );
      setState(() {
        _error = true;
        _shake++;
      });
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (!mounted) return;
        setState(() {
          _error = false;
          _typed.clear();
          if (widget.newOnError && _spare.isNotEmpty) {
            _spare.add(_queue.removeAt(0));
            _queue.add(_spare.removeAt(0));
          } else if (_queue.length > 1) {
            _queue.add(_queue.removeAt(0));
          }
        });
        _speak();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = _item;
    return PageCard(
      title: widget.title,
      titleColor: widget.titleColor,
      child: item == null
          ? const PageDoneMessage()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: RoundIconButton(
                    tooltip: 'استمع',
                    icon: Icons.volume_up_rounded,
                    size: 58,
                    color: AppColors.ink,
                    iconColor: Colors.white,
                    onTap: _speak,
                  ),
                ),
                if (item.sentence != null) ...[
                  const SizedBox(height: 10),
                  _SentenceWithBlank(
                    item: item,
                    filled: _showWord,
                    color: widget.sentenceColor,
                  ),
                ],
                const SizedBox(height: 12),
                SizedBox(
                  height: 64,
                  child: _showWord
                      ? Center(
                          child: item.colorTaa
                              ? TaaText(item.answer, size: 40)
                              : AlText(
                                  item.answer,
                                  size: 40,
                                  color: AppColors.blue,
                                  redPrefix: item.redPrefix,
                                ),
                        )
                      : ShakeOnChange(
                          trigger: _shake,
                          child: Center(
                            child: LetterBoxes(
                              length: item.answer.length,
                              letters: _typed,
                              alCount: item.redPrefix,
                              error: _error,
                            ),
                          ),
                        ),
                ),
                const SizedBox(height: 10),
                ArabicKeyboard(onLetter: _onLetter, onBackspace: _onBackspace),
                const SizedBox(height: 12),
                AppButton(
                  label: 'إدخال',
                  style: AppButtonStyle.secondary,
                  enabled: !_showWord,
                  onTap: _showWord ? null : _submit,
                ),
              ],
            ),
    );
  }
}

/// الجملة مع فراغ مكان الكلمة الناقصة، وتظهر الكلمة بعد الإجابة الصحيحة.
class _SentenceWithBlank extends StatelessWidget {
  const _SentenceWithBlank({
    required this.item,
    required this.filled,
    required this.color,
  });
  final ListenItem item;
  final bool filled;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final parts = item.sentence!.split('…');
    final base = AppTheme.word(26, color: color);
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: '( ${parts.first}'),
          filled
              ? item.colorTaa
                    ? taaSpan(item.answer)
                    : TextSpan(
                        text: item.answer,
                        style: const TextStyle(color: AppColors.blue),
                      )
              : const TextSpan(
                  text: '………',
                  style: TextStyle(color: AppColors.muted),
                ),
          TextSpan(text: '${parts.length > 1 ? parts[1] : ''} )'),
        ],
      ),
      textAlign: TextAlign.center,
      style: base,
    );
  }
}
