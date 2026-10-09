import 'package:flutter/material.dart';

import '../../app_state.dart';
import '../../services/speaker.dart';
import '../../theme.dart';
import '../../utils/arabic.dart';
import '../../widgets/common.dart';
import '../page_handle.dart';

/// تطبيق المعادلات: كلمة + الـ = ؟ (ص ٣) أو كلمة − الـ = ؟ (ص ٧).
class EquationPage extends StatefulWidget {
  const EquationPage({
    super.key,
    required this.handle,
    required this.rounds,
    required this.add,
    required this.tag,
    required this.title,
  });

  final PageHandle handle;

  /// كل جولة مجموعة كلمات تظهر معًا.
  final List<List<String>> rounds;
  final bool add;
  final String tag;
  final String title;

  @override
  State<EquationPage> createState() => _EquationPageState();
}

enum _RowState { open, wrong, right }

class _EquationPageState extends State<EquationPage> {
  int _round = 0;
  int _solved = 0;
  late List<TextEditingController> _ctrls;
  late List<_RowState> _states;
  late List<int> _attempts;
  late List<String?> _hints;
  int _shake = 0;

  List<String> get _words => widget.rounds[_round];
  int get _total => widget.rounds.fold(0, (a, r) => a + r.length);

  String _answer(String w) => widget.add ? 'ال$w' : w.substring(2);

  @override
  void initState() {
    super.initState();
    _setupRound();
    widget.handle
      ..onHint = _hint
      ..onListen = () => Speaker.instance.speak(
        _words.join('، '),
        rate: AppScope.read(context).speechRate,
      );
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => widget.handle.setProgress(0, _total),
    );
  }

  void _setupRound() {
    _ctrls = [for (final _ in _words) TextEditingController()];
    _states = [for (final _ in _words) _RowState.open];
    _attempts = [for (final _ in _words) 0];
    _hints = [for (final _ in _words) null];
  }

  @override
  void dispose() {
    for (final c in _ctrls) {
      c.dispose();
    }
    super.dispose();
  }

  void _hint() {
    final i = _states.indexWhere((s) => s != _RowState.right);
    if (i < 0) return;
    final ans = _answer(_words[i]);
    setState(
      () => _hints[i] = widget.add
          ? 'اكتب «ال» ثم الكلمة: ${ans.substring(0, 3)}…'
          : 'احذف أول حرفين «ال»: ${ans.substring(0, 1)}…',
    );
    showFeedback(context, _hints[i]!, tone: FeedbackTone.hint);
  }

  void _check() {
    FocusScope.of(context).unfocus();
    final app = AppScope.read(context);
    var newlySolved = 0;
    var anyWrong = false;
    var anyEmpty = false;
    setState(() {
      for (var i = 0; i < _words.length; i++) {
        if (_states[i] == _RowState.right) continue;
        final typed = _ctrls[i].text;
        if (typed.trim().isEmpty) {
          anyEmpty = true;
          continue;
        }
        _attempts[i]++;
        if (normalizeAnswer(typed) == normalizeAnswer(_answer(_words[i]))) {
          _states[i] = _RowState.right;
          newlySolved++;
          app.addPoints(_attempts[i] == 1 && _hints[i] == null ? 10 : 5);
        } else {
          _states[i] = _RowState.wrong;
          anyWrong = true;
        }
      }
      _solved += newlySolved;
      if (anyWrong) _shake++;
    });
    widget.handle.setProgress(_solved, _total);

    if (anyWrong) {
      showFeedback(
        context,
        'بعض الإجابات غير صحيحة، صحّح المربعات الحمراء',
        tone: FeedbackTone.error,
      );
      return;
    }
    if (anyEmpty) {
      showFeedback(
        context,
        'أكمل كتابة جميع الكلمات',
        tone: FeedbackTone.error,
      );
      return;
    }
    if (_states.every((s) => s == _RowState.right)) {
      if (_round < widget.rounds.length - 1) {
        showFeedback(context, 'أحسنت! إلى الكلمات التالية');
        Future.delayed(const Duration(milliseconds: 900), () {
          if (!mounted) return;
          setState(() {
            for (final c in _ctrls) {
              c.dispose();
            }
            _round++;
            _setupRound();
          });
        });
      } else {
        showFeedback(context, 'ممتاز! أنهيت هذا التطبيق 🎉');
        widget.handle.markComplete();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final roundsLabel = widget.rounds.length > 1
        ? 'المجموعة ${arDigits(_round + 1)} من ${arDigits(widget.rounds.length)}'
        : null;
    return PageCard(
      tag: widget.tag,
      title: widget.title,
      subtitle: roundsLabel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Column(
              key: ValueKey(_round),
              children: [
                for (var i = 0; i < _words.length; i++) ...[
                  _row(i),
                  const SizedBox(height: 12),
                ],
              ],
            ),
          ),
          const SizedBox(height: 6),
          FilledButton.icon(
            onPressed: _states.every((s) => s == _RowState.right)
                ? null
                : _check,
            icon: const Icon(Icons.keyboard_return_rounded),
            label: const Text('إدخال'),
          ),
        ],
      ),
    );
  }

  Widget _row(int i) {
    final word = _words[i];
    final state = _states[i];
    final right = state == _RowState.right;
    final op = Theme.of(context).textTheme.titleLarge
        ?.copyWith(color: AppColors.muted, fontWeight: FontWeight.w700);
    final field = TextField(
      controller: _ctrls[i],
      enabled: !right,
      textAlign: TextAlign.center,
      textDirection: TextDirection.rtl,
      style: AppTheme.word(
        20,
        color: right ? AppColors.success : AppColors.ink,
      ).copyWith(height: 1.3),
      textInputAction: i == _words.length - 1
          ? TextInputAction.done
          : TextInputAction.next,
      onSubmitted: (_) {
        if (i == _words.length - 1) _check();
      },
      onChanged: (_) {
        if (state == _RowState.wrong) {
          setState(() => _states[i] = _RowState.open);
        }
      },
      decoration: InputDecoration(
        hintText: '……',
        isDense: true,
        fillColor: switch (state) {
          _RowState.right => AppColors.successSoft,
          _RowState.wrong => AppColors.errorSoft,
          _RowState.open => AppColors.background,
        },
        enabledBorder: state == _RowState.wrong
            ? OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.error, width: 2),
              )
            : null,
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.success, width: 1.5),
        ),
      ),
    );

    return ShakeOnChange(
      trigger: state == _RowState.wrong ? _shake : 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              SizedBox(
                width: 92,
                child: AlText(word, size: 21, highlight: true),
              ),
              Text(widget.add ? '+' : '−', style: op),
              const SizedBox(width: 6),
              const AlBox(size: 16),
              const SizedBox(width: 6),
              Text('=', style: op),
              const SizedBox(width: 8),
              Expanded(child: field),
              const SizedBox(width: 6),
              SizedBox(
                width: 26,
                child: right
                    ? const Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.success,
                      )
                    : null,
              ),
            ],
          ),
          if (right)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Align(
                alignment: AlignmentDirectional.centerEnd,
                child: LamChip(
                  lamTypeOf(widget.add ? _answer(word) : word),
                  dense: true,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
