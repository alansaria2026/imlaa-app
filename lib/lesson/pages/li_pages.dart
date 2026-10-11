import 'dart:math';

import 'package:flutter/material.dart';

import '../../app_state.dart';
import '../../data/li_lesson.dart';
import '../../services/speaker.dart';
import '../../theme.dart';
import '../../utils/arabic.dart';
import '../../widgets/common.dart';
import '../../widgets/letter_boxes.dart';
import '../../widgets/pressable.dart';
import '../li_rule_content.dart';
import '../page_handle.dart';

/// قاعدة اتصال اللام بـ(ال) (ص ١ من درس اللام).
class LiRulePage extends StatefulWidget {
  const LiRulePage({super.key, required this.handle});
  final PageHandle handle;

  @override
  State<LiRulePage> createState() => _LiRulePageState();
}

class _LiRulePageState extends State<LiRulePage> {
  @override
  void initState() {
    super.initState();
    widget.handle
      ..onListen = (() => Speaker.instance.speak(
        liRuleSpeech,
        rate: AppScope.read(context).speechRate,
      ))
      ..onHint = () => showFeedback(
        context,
        'تسقط ألف (ال) فتبقى لامان فقط: الكتاب ← للكتاب، اللحن ← للحن.',
        tone: FeedbackTone.hint,
      );
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => widget.handle.markComplete(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const PageCard(
      tag: 'القاعدة',
      title: 'اتصال اللام بـ(ال) التعريف',
      subtitle: 'اضغط على المثال لتسمعه',
      child: LiRuleContent(),
    );
  }
}

/// سؤال استماع: يُسمع [spoken] ويكتب الطالب [answer] في المربعات.
class LiListenItem {
  const LiListenItem({
    required this.spoken,
    required this.answer,
    required this.redPrefix,
    this.sentence,
  });

  final String spoken;
  final String answer;
  final int redPrefix;

  /// الجملة مع فراغ مكان الكلمة (تمرين «الكلمة الناقصة»)؛ null لكلمة مفردة.
  final String? sentence;
}

/// اسمع الكلمة (أو الجملة) واكتب الكلمة بلام الجر في المربعات (ص ٤ و٥).
class LiListenPage extends StatefulWidget {
  const LiListenPage({
    super.key,
    required this.handle,
    required this.title,
    required this.items,
    this.spare = const [],
  });

  final PageHandle handle;
  final String title;
  final List<LiListenItem> items;

  /// أسئلة بديلة: الرجوع للقاعدة يعيد الطالب «بكلمة جديدة».
  final List<LiListenItem> spare;

  @override
  State<LiListenPage> createState() => _LiListenPageState();
}

class _LiListenPageState extends State<LiListenPage> {
  late final List<LiListenItem> _queue = [...widget.items];
  late final List<LiListenItem> _spare = [...widget.spare];
  final Set<LiListenItem> _penalty = {};
  final List<String> _typed = [];
  int _solved = 0;
  int _shake = 0;
  bool _error = false;
  bool _showWord = false;

  int get _total => widget.items.length;
  LiListenItem? get _item => _queue.isEmpty ? null : _queue.first;

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

  void _speak({bool slow = false}) {
    final item = _item;
    if (item == null) return;
    final rate = AppScope.read(context).speechRate;
    Speaker.instance.speak(item.spoken, rate: slow ? rate * 0.6 : rate);
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
        'الإجابة غير صحيحة، سيعاد هذا السؤال لاحقًا',
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
          if (_queue.length > 1) _queue.add(_queue.removeAt(0));
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
      child: item == null
          ? const PageDoneMessage()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RoundIconButton(
                      tooltip: 'استمع',
                      icon: Icons.volume_up_rounded,
                      size: 58,
                      color: AppColors.ink,
                      iconColor: Colors.white,
                      onTap: _speak,
                    ),
                    const SizedBox(width: 14),
                    Pressable(
                      onTap: () => _speak(slow: true),
                      color: AppColors.surface,
                      borderColor: AppColors.ink,
                      shape: BoxShape.circle,
                      child: const SizedBox(
                        width: 46,
                        height: 46,
                        child: Center(
                          child: Text('🐢', style: TextStyle(fontSize: 22)),
                        ),
                      ),
                    ),
                  ],
                ),
                if (item.sentence != null) ...[
                  const SizedBox(height: 10),
                  _SentenceWithBlank(item: item, filled: _showWord),
                ],
                const SizedBox(height: 12),
                SizedBox(
                  height: 64,
                  child: _showWord
                      ? Center(
                          child: AlText(
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
  const _SentenceWithBlank({required this.item, required this.filled});
  final LiListenItem item;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final parts = item.sentence!.split('…');
    final base = AppTheme.word(26);
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: '( ${parts.first}'),
          filled
              ? TextSpan(
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

/// أسئلة «اسمع الكلمة واكتبها»: [count] كلمة، والباقي بدائل.
(List<LiListenItem>, List<LiListenItem>) liWordItems(
  Random rnd, {
  int count = liQuestionCount,
}) {
  final words = pickLiWords(rnd, count: liWordBank.length);
  LiListenItem item(String w) => LiListenItem(
    spoken: liSpoken(w),
    answer: liForm(w),
    redPrefix: liRedPrefix(w),
  );
  return (
    [for (final w in words.take(count)) item(w)],
    [for (final w in words.skip(count)) item(w)],
  );
}

/// أسئلة «اسمع واكتب الكلمة الناقصة»: [count] جمل، والباقي بدائل.
(List<LiListenItem>, List<LiListenItem>) liSentenceItems(
  Random rnd, {
  int count = liQuestionCount,
}) {
  final sentences = [...liSentences]..shuffle(rnd);
  final items = [
    for (final s in sentences)
      LiListenItem(
        spoken: s.spoken,
        answer: s.answer,
        redPrefix: liRedPrefix(s.alWord),
        sentence: _blank(s),
      ),
  ];
  return (items.take(count).toList(), items.skip(count).toList());
}

String _blank(LiSentence s) {
  final words = s.spoken.split(' ');
  return [
    for (final w in words) stripDiacritics(w) == s.answer ? '…' : w,
  ].join(' ');
}
