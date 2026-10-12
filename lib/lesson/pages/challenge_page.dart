import 'package:flutter/material.dart';

import '../../app_state.dart';
import '../../data/lam_lesson.dart';
import '../../services/speaker.dart';
import '../../theme.dart';
import '../../utils/arabic.dart';
import '../../widgets/common.dart';
import '../../widgets/pressable.dart';
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
      ..onEnter = _speak
      ..onSubmit = _submit
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
    // حقل فارغ لا يُحتسب خطأً: يُنبَّه الطالب فقط.
    final emptyMoon = normalizeAnswer(_moonCtrl.text).isEmpty;
    final emptySun = normalizeAnswer(_sunCtrl.text).isEmpty;
    if (emptyMoon || emptySun) {
      setState(() {
        _moonError = emptyMoon ? 'اكتب الكلمة' : null;
        _sunError = emptySun ? 'اكتب الكلمة' : null;
      });
      showFeedback(
        context,
        emptyMoon && emptySun
            ? 'اكتب الكلمتين ثم اضغط «إدخال»'
            : 'لم تكتب إحدى الكلمتين، اكتبها ثم اضغط «إدخال»',
        tone: FeedbackTone.error,
      );
      return;
    }
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
    showFeedback(
      context,
      'إجابة رائعة! ${remainingText(widget.sentences.length - _index - 1)}',
    );
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
    return PageCard(
      tag: 'تحدي',
      title: 'اسمع الجملة واكتب منها ما يلي',
      child: s == null
          ? const PageDoneMessage()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: RoundIconButton(
                    tooltip: 'استمع',
                    icon: Icons.volume_up_rounded,
                    size: 60,
                    color: AppColors.ink,
                    iconColor: Colors.white,
                    onTap: _speak,
                  ),
                ),
                if (_solvedCurrent) ...[
                  const SizedBox(height: 16),
                  AlText('( ${s.spoken} )', size: 30),
                ],
                const SizedBox(height: 16),
                // الحقلان متجاوران ليبقيا فوق لوحة المفاتيح.
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _AnswerField(
                        type: LamType.moon,
                        controller: _moonCtrl,
                        error: _moonError,
                        done: _solvedCurrent,
                        onChanged: () => setState(() => _moonError = null),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _AnswerField(
                        type: LamType.sun,
                        controller: _sunCtrl,
                        error: _sunError,
                        done: _solvedCurrent,
                        onChanged: () => setState(() => _sunError = null),
                        onSubmitted: _submit,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // يبقى ظاهرًا أثناء الكتابة حين يختفي زر «التالي».
                AppButton(
                  label: 'إدخال',
                  style: AppButtonStyle.secondary,
                  enabled: !_solvedCurrent,
                  onTap: _solvedCurrent ? null : _submit,
                ),
              ],
            ),
    );
  }
}

class _AnswerField extends StatelessWidget {
  const _AnswerField({
    required this.type,
    required this.controller,
    required this.error,
    required this.done,
    required this.onChanged,
    this.onSubmitted,
  });

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
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 4,
          children: [
            Text('كلمة بها', style: AppTheme.word(18).copyWith(height: 1.3)),
            LamChip(type, dense: true),
          ],
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          enabled: !done,
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.center,
          style: AppTheme.word(
            26,
            color: done ? AppColors.success : AppColors.ink,
          ).copyWith(height: 1.3),
          scrollPadding: const EdgeInsets.fromLTRB(20, 90, 20, 120),
          textInputAction: onSubmitted == null
              ? TextInputAction.next
              : TextInputAction.done,
          onChanged: (_) {
            if (error != null) onChanged();
          },
          onSubmitted: (_) => onSubmitted?.call(),
          decoration: InputDecoration(
            hintText: moon ? 'القمر' : 'الشمس',
            hintStyle: AppTheme.word(20, color: AppColors.lineDark),
            errorText: error,
            errorMaxLines: 2,
            fillColor: done ? AppColors.successSoft : AppColors.surface,
          ),
        ),
      ],
    );
  }
}
