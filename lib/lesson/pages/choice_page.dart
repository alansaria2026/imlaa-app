import 'package:flutter/material.dart';

import '../../app_state.dart';
import '../../data/taa_lesson.dart';
import '../../services/speaker.dart';
import '../../theme.dart';
import '../../utils/arabic.dart';
import '../../widgets/common.dart';
import '../../widgets/pressable.dart';
import '../page_handle.dart';

/// اختر الكلمة المناسبة لإكمال الجملة: الكلمة تنتهي بتاء مربوطة أو بهاء،
/// فلا تُسمع الكلمة وحدها (تُنطق بالهاء في الحالتين عند الوقف)، وتُنطق
/// الجملة كاملة بعد الإجابة الصحيحة.
class ChoicePage extends StatefulWidget {
  const ChoicePage({
    super.key,
    required this.handle,
    required this.items,
    this.spare = const [],
  });

  final PageHandle handle;
  final List<TaaChoice> items;

  /// بدائل بترتيب [items]: بعد الخطأ في السؤال يأتي بديله لاحقًا.
  final List<TaaChoice> spare;

  @override
  State<ChoicePage> createState() => _ChoicePageState();
}

class _ChoicePageState extends State<ChoicePage> {
  late final List<TaaChoice> _queue = [...widget.items];
  late final _optionsOf = {for (final c in widget.items) c: _order(c)};
  final Set<TaaChoice> _penalty = {};
  int _solved = 0;
  String? _picked;
  bool _correct = false;

  int get _total => widget.items.length;
  TaaChoice? get _item => _queue.isEmpty ? null : _queue.first;

  /// ترتيب ثابت للخيارين لكل سؤال، يختلف بين الأسئلة.
  List<String> _order(TaaChoice c) =>
      c.answer.length.isEven ? [c.answer, c.wrong] : [c.wrong, c.answer];

  @override
  void initState() {
    super.initState();
    widget.handle
      ..onListen = _speakInstruction
      ..onHint = _hint;
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => widget.handle.setProgress(0, _total),
    );
  }

  void _speakInstruction() => Speaker.instance.speak(
    taaChoiceInstruction,
    rate: AppScope.read(context).speechRate,
  );

  void _hint() {
    final item = _item;
    if (item == null || _correct) return;
    _penalty.add(item);
    final marbuta = stripDiacritics(item.word).endsWith('ة');
    showFeedback(
      context,
      marbuta
          ? 'آخر «${item.word}» تاء مربوطة (ة) بنقطتين، فهي اسم واحد'
          : 'آخر «${item.word}» هاء (ه) بلا نقط، أي: الذي له',
      tone: FeedbackTone.hint,
    );
  }

  void _pick(String option) {
    final item = _item;
    if (item == null || _picked != null) return;
    final ok = option == item.answer;
    setState(() {
      _picked = option;
      _correct = ok;
    });
    if (ok) {
      AppScope.read(context).addPoints(_penalty.contains(item) ? 5 : 10);
      showFeedback(context, 'أحسنت! ${remainingText(_total - _solved - 1)}');
      Speaker.instance.speak(
        item.spoken,
        rate: AppScope.read(context).speechRate,
      );
      setState(() => _solved++);
      widget.handle.setProgress(_solved, _total);
      Future.delayed(const Duration(milliseconds: 1800), () {
        if (!mounted) return;
        setState(() {
          _queue.removeAt(0);
          _picked = null;
          _correct = false;
        });
        if (_queue.isEmpty) widget.handle.markComplete();
      });
    } else {
      _penalty.add(item);
      showFeedback(
        context,
        'انتبه لآخر الكلمة: تاء مربوطة (ة) أم هاء (ه)؟',
        tone: FeedbackTone.error,
      );
      Future.delayed(const Duration(milliseconds: 1400), () {
        if (!mounted) return;
        setState(() {
          _picked = null;
          final current = _queue.removeAt(0);
          // بعد الخطأ: الصورة الأخرى للكلمة في آخر الأسئلة.
          final i = widget.items.indexOf(current);
          final next = i >= 0 && i < widget.spare.length
              ? widget.spare[i]
              : current;
          _optionsOf.putIfAbsent(next, () => _order(next));
          _queue.add(next);
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = _item;
    return PageCard(
      title: 'اختر الكلمة المناسبة لإكمال الجملة',
      subtitle: 'انظر إلى آخر الكلمة: تاء مربوطة (ة) أم هاء (ه)؟',
      child: item == null
          ? const PageDoneMessage()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: item.word),
                      const TextSpan(text: '  '),
                      _correct
                          ? TextSpan(
                              text: item.answer,
                              style: const TextStyle(color: AppColors.blue),
                            )
                          : const TextSpan(
                              text: '………',
                              style: TextStyle(color: AppColors.muted),
                            ),
                    ],
                  ),
                  key: const ValueKey('choice-question'),
                  textAlign: TextAlign.center,
                  style: AppTheme.word(40),
                ),
                const SizedBox(height: 24),
                for (final option in _optionsOf[item]!) ...[
                  _OptionButton(
                    label: option,
                    state: _picked == option ? option == item.answer : null,
                    onTap: () => _pick(option),
                  ),
                  const SizedBox(height: 12),
                ],
              ],
            ),
    );
  }
}

class _OptionButton extends StatelessWidget {
  const _OptionButton({
    required this.label,
    required this.state,
    required this.onTap,
  });

  final String label;

  /// true صحيح، false خطأ، null لم يُختر.
  final bool? state;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final (color, border) = switch (state) {
      true => (AppColors.primarySoft, AppColors.blue),
      false => (AppColors.surface, AppColors.al),
      null => (AppColors.surface, AppColors.line),
    };
    return Pressable(
      onTap: onTap,
      color: color,
      borderColor: border,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: AppTheme.word(
            30,
            color: state == false ? AppColors.al : AppColors.ink,
          ),
        ),
      ),
    );
  }
}
