import 'package:flutter/material.dart';

import '../../app_state.dart';
import '../../data/lam_lesson.dart';
import '../../services/speaker.dart';
import '../../theme.dart';
import '../../utils/arabic.dart';
import '../../widgets/common.dart';
import '../page_handle.dart';

/// ص ٦: اسمع الجملة واستخرج كلمة بلام قمرية وأخرى بلام شمسية.
class ChallengePage extends StatefulWidget {
  const ChallengePage({
    super.key,
    required this.handle,
    required this.sentences,
  });

  final PageHandle handle;
  final List<ChallengeSentence> sentences;

  @override
  State<ChallengePage> createState() => _ChallengePageState();
}

class _ChallengePageState extends State<ChallengePage> {
  final _moonCtrl = TextEditingController();
  final _sunCtrl = TextEditingController();
  int _index = 0;
  bool _usedHelp = false;
  bool _solvedCurrent = false;
  String? _moonError;
  String? _sunError;

  ChallengeSentence? get _s =>
      _index < widget.sentences.length ? widget.sentences[_index] : null;

  @override
  void initState() {
    super.initState();
    widget.handle
      ..onListen = _speak
      ..onHint = _hint;
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => widget.handle.setProgress(0, widget.sentences.length),
    );
  }

  @override
  void dispose() {
    _moonCtrl.dispose();
    _sunCtrl.dispose();
    super.dispose();
  }

  void _speak() {
    final s = _s;
    if (s != null) {
      Speaker.instance.speak(s.spoken, rate: AppScope.read(context).speechRate);
    }
  }

  void _hint() {
    final s = _s;
    if (s == null) return;
    _usedHelp = true;
    showFeedback(
      context,
      'القمرية تبدأ بـ «ال${letterAfterAl(s.moon)}…» والشمسية تبدأ بـ «ال${letterAfterAl(s.sun)}…»',
      tone: FeedbackTone.hint,
    );
  }

  /// رسالة خطأ توضيحية أو null إن كانت الإجابة صحيحة.
  String? _validate(String typed, String expected, LamType type) {
    final t = normalizeAnswer(typed);
    if (t.isEmpty) return 'اكتب الكلمة';
    if (t == normalizeAnswer(expected)) return null;
    final s = _s!;
    final words = normalizeAnswer(s.spoken).split(' ');
    if (!words.contains(t)) return 'هذه الكلمة ليست في الجملة';
    if (!t.startsWith('ال')) return 'اختر كلمة تبدأ بـ (الـ)';
    if (lamTypeOf(t) != type) {
      return 'لام هذه الكلمة ${lamTypeOf(t) == LamType.moon ? 'قمرية' : 'شمسية'}';
    }
    return 'حاول مرة أخرى';
  }

  void _submit() {
    final s = _s;
    if (s == null || _solvedCurrent) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _moonError = _validate(_moonCtrl.text, s.moon, LamType.moon);
      _sunError = _validate(_sunCtrl.text, s.sun, LamType.sun);
    });
    if (_moonError != null || _sunError != null) {
      _usedHelp = true;
      showFeedback(context, 'راجع الإجابة المظللة', tone: FeedbackTone.error);
      return;
    }
    AppScope.read(context).addPoints(_usedHelp ? 10 : 20);
    showFeedback(context, 'إجابة رائعة! +${arDigits(_usedHelp ? 10 : 20)}');
    setState(() => _solvedCurrent = true);
    widget.handle.setProgress(_index + 1, widget.sentences.length);
    Future.delayed(const Duration(milliseconds: 1100), () {
      if (!mounted) return;
      setState(() {
        _index++;
        _usedHelp = false;
        _solvedCurrent = false;
        _moonCtrl.clear();
        _sunCtrl.clear();
      });
      if (_s == null) {
        widget.handle.markComplete();
      } else {
        _speak();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = _s;
    final t = Theme.of(context).textTheme;
    return PageCard(
      tag: 'تحدي',
      title: 'اسمع الجملة واستخرج منها ما يلي',
      subtitle: s == null
          ? null
          : 'الجملة ${arDigits(_index + 1)} من ${arDigits(widget.sentences.length)}',
      child: s == null
          ? const PageDoneMessage()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Material(
                    key: ValueKey(_index),
                    color: AppColors.sandSoft,
                    borderRadius: BorderRadius.circular(22),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(22),
                      onTap: _speak,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
                        child: Column(
                          children: [
                            AlText(
                              '( ${s.spoken} )',
                              size: 26,
                              highlight: _solvedCurrent,
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.headphones_rounded,
                                  size: 18,
                                  color: Color(0xFF9A6A1E),
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    'اضغط لتسمع الجملة',
                                    style: t.labelLarge?.copyWith(
                                      color: const Color(0xFF9A6A1E),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _AnswerField(
                  number: 1,
                  type: LamType.moon,
                  controller: _moonCtrl,
                  error: _moonError,
                  done: _solvedCurrent,
                  onChanged: () => setState(() => _moonError = null),
                ),
                const SizedBox(height: 14),
                _AnswerField(
                  number: 2,
                  type: LamType.sun,
                  controller: _sunCtrl,
                  error: _sunError,
                  done: _solvedCurrent,
                  onChanged: () => setState(() => _sunError = null),
                  onSubmitted: _submit,
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: _solvedCurrent ? null : _submit,
                  icon: const Icon(Icons.keyboard_return_rounded),
                  label: const Text('إدخال'),
                ),
              ],
            ),
    );
  }
}

class _AnswerField extends StatelessWidget {
  const _AnswerField({
    required this.number,
    required this.type,
    required this.controller,
    required this.error,
    required this.done,
    required this.onChanged,
    this.onSubmitted,
  });

  final int number;
  final LamType type;
  final TextEditingController controller;
  final String? error;
  final bool done;
  final VoidCallback onChanged;
  final VoidCallback? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final moon = type == LamType.moon;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                '${arDigits(number)}. كلمة بها ',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            LamChip(type, dense: true),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          enabled: !done,
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.center,
          style: AppTheme.word(
            20,
            color: done ? AppColors.success : AppColors.ink,
          ).copyWith(height: 1.3),
          textInputAction: onSubmitted == null
              ? TextInputAction.next
              : TextInputAction.done,
          onChanged: (_) {
            if (error != null) onChanged();
          },
          onSubmitted: (_) => onSubmitted?.call(),
          decoration: InputDecoration(
            hintText: moon ? 'مثل: القمر' : 'مثل: الشمس',
            errorText: error,
            fillColor: done
                ? AppColors.successSoft
                : moon
                ? AppColors.moonSoft.withValues(alpha: 0.5)
                : AppColors.sunSoft.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }
}
