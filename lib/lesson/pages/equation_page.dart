import 'dart:math';

import 'package:flutter/material.dart';

import '../../app_state.dart';
import '../../data/lam_lesson.dart';
import '../../services/speaker.dart';
import '../../theme.dart';
import '../../utils/arabic.dart';
import '../../widgets/common.dart';
import '../page_handle.dart';

/// تطبيق المعادلات: كلمة + الـ = ؟ (ص ٣) أو كلمة − الـ = ؟ (ص ٧).
///
/// في الوضع الصارم [strict] (تعليمات ص ٤): لا يُسمح بأي خطأ؛ أي خطأ يعيد
/// جميع الكلمات بترتيب مختلف، ومؤشر النتيجة يبدأ ممتلئًا وينقص مع كل خطأ.
class EquationPage extends StatefulWidget {
  const EquationPage({
    super.key,
    required this.handle,
    required this.rounds,
    required this.add,
    this.tag,
    required this.title,
    this.strict = false,
    this.showLamType = true,
  });

  final PageHandle handle;

  /// كل جولة مجموعة كلمات تظهر معًا.
  final List<List<String>> rounds;
  final bool add;
  final String? tag;
  final String title;
  final bool strict;

  /// إظهار نوع اللام (قمرية/شمسية) بعد الإجابة الصحيحة.
  final bool showLamType;

  /// مقدار نقص مؤشر النتيجة مع كل خطأ في الوضع الصارم.
  static const levelStep = 10;

  @override
  State<EquationPage> createState() => _EquationPageState();
}

enum _RowState { open, wrong, right }

class _EquationPageState extends State<EquationPage> {
  late List<List<String>> _rounds = widget.rounds;
  final _random = Random();
  int _mistakes = 0;
  bool _restarting = false;
  int _round = 0;
  int _solved = 0;
  late List<TextEditingController> _ctrls;

  /// المتحكمات القديمة تبقى حتى إغلاق الصفحة لأن الحركة الانتقالية
  /// ما زالت تعرض الحقول القديمة.
  final List<TextEditingController> _retired = [];
  int _generation = 0;
  late List<_RowState> _states;
  late List<int> _attempts;
  late List<String?> _hints;
  int _shake = 0;

  List<String> get _words => _rounds[_round];
  int get _total => _rounds.fold(0, (a, r) => a + r.length);
  int get _level => max(0, 100 - _mistakes * EquationPage.levelStep);

  String _answer(String w) => widget.add ? 'ال$w' : w.substring(2);

  @override
  void initState() {
    super.initState();
    _setupRound();
    widget.handle
      ..onHint = _hint
      ..onSubmit = _check
      ..onListen = () => Speaker.instance.speak(
        _words.map(spokenForm).join('، '),
        rate: AppScope.read(context).speechRate,
      );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.handle.setProgress(0, _total);
      if (widget.strict) widget.handle.setLevel(100);
    });
  }

  /// يعيد جميع الكلمات من البداية بترتيب يختلف عن السابق.
  void _restartShuffled() {
    final perRound = _rounds.first.length;
    final previous = _rounds.expand((r) => r).toList();
    var words = [...previous];
    if (words.length > 1) {
      do {
        words.shuffle(_random);
      } while (_listEquals(words, previous));
    }
    _retired.addAll(_ctrls);
    _rounds = [
      for (var i = 0; i < words.length; i += perRound)
        words.sublist(i, min(i + perRound, words.length)),
    ];
    _round = 0;
    _solved = 0;
    _generation++;
    _restarting = false;
    _setupRound();
    widget.handle.setProgress(0, _total);
  }

  static bool _listEquals(List<String> a, List<String> b) {
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  void _setupRound() {
    _ctrls = [for (final _ in _words) TextEditingController()];
    _states = [for (final _ in _words) _RowState.open];
    _attempts = [for (final _ in _words) 0];
    _hints = [for (final _ in _words) null];
  }

  @override
  void dispose() {
    for (final c in [..._retired, ..._ctrls]) {
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
    if (_restarting) return;
    FocusScope.of(context).unfocus();
    final app = AppScope.read(context);
    if (widget.strict) {
      _checkStrict();
      return;
    }
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
        showFeedback(context, 'أحسنت! ${remainingText(_total - _solved)}');
        Future.delayed(const Duration(milliseconds: 900), () {
          if (!mounted) return;
          setState(() {
            _retired.addAll(_ctrls);
            _round++;
            _setupRound();
          });
        });
      } else {
        showFeedback(context, 'ممتاز! أنهيت هذا التمرين');
        widget.handle.markComplete();
      }
    }
  }

  void _checkStrict() {
    // يضغط «إدخال» بعد الفراغ من الإجابة عن الأسئلة كلها.
    final open = [
      for (var i = 0; i < _words.length; i++)
        if (_states[i] != _RowState.right) i,
    ];
    if (open.any((i) => _ctrls[i].text.trim().isEmpty)) {
      showFeedback(
        context,
        'أجب عن جميع الأسئلة ثم اضغط «التالي»',
        tone: FeedbackTone.error,
      );
      return;
    }
    var anyWrong = false;
    setState(() {
      for (final i in open) {
        final ok =
            normalizeAnswer(_ctrls[i].text) ==
            normalizeAnswer(_answer(_words[i]));
        _states[i] = ok ? _RowState.right : _RowState.wrong;
        if (ok) {
          _solved++;
        } else {
          anyWrong = true;
        }
      }
      if (anyWrong) {
        _shake++;
        _mistakes++;
        _restarting = true;
      }
    });

    if (anyWrong) {
      widget.handle
        ..setLevel(_level)
        ..setProgress(_solved, _total);
      showFeedback(
        context,
        'لا يُسمح بالخطأ! ستُعاد جميع الكلمات بترتيب مختلف',
        tone: FeedbackTone.error,
        duration: const Duration(seconds: 5),
      );
      // وقت كافٍ لقراءة الرسالة ورؤية الإجابات الخاطئة قبل الإعادة.
      Future.delayed(const Duration(milliseconds: 3500), () {
        if (mounted) setState(_restartShuffled);
      });
      return;
    }

    widget.handle.setProgress(_solved, _total);
    if (_round < _rounds.length - 1) {
      showFeedback(context, 'أحسنت! ${remainingText(_total - _solved)}');
      _restarting = true;
      Future.delayed(const Duration(milliseconds: 900), () {
        if (!mounted) return;
        setState(() {
          _retired.addAll(_ctrls);
          _restarting = false;
          _round++;
          _setupRound();
        });
      });
    } else {
      // النقاط حسب المستوى المتبقي في المؤشر.
      AppScope.read(context).addPoints((_total * 10 * _level / 100).round());
      showFeedback(context, 'ممتاز! أنهيت هذا التمرين');
      widget.handle.markComplete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageCard(
      tag: widget.tag,
      title: widget.title,
      subtitle: widget.strict ? 'أي خطأ يعيد جميع الكلمات بترتيب جديد' : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Column(
              key: ValueKey('$_generation-$_round'),
              children: [
                for (var i = 0; i < _words.length; i++) ...[
                  _row(i),
                  const SizedBox(height: 12),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(int i) {
    final word = _words[i];
    final state = _states[i];
    final right = state == _RowState.right;
    final op = Theme.of(context).textTheme.titleLarge?.copyWith(
      color: AppColors.muted,
      fontWeight: FontWeight.w700,
    );
    final field = TextField(
      controller: _ctrls[i],
      enabled: !right,
      textAlign: TextAlign.center,
      textDirection: TextDirection.rtl,
      style: AppTheme.word(
        26,
        color: right ? AppColors.success : AppColors.ink,
      ).copyWith(height: 1.3),
      // يبقى السطر كاملًا ظاهرًا فوق لوحة المفاتيح.
      scrollPadding: const EdgeInsets.fromLTRB(20, 80, 20, 60),
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
          borderSide: const BorderSide(color: AppColors.success, width: 2),
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
                width: 100,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: AlText(word, size: 30, highlight: true),
                ),
              ),
              Text(widget.add ? '+' : '−', style: op),
              const SizedBox(width: 4),
              const AlBox(size: 18),
              const SizedBox(width: 4),
              Text('=', style: op),
              const SizedBox(width: 6),
              Expanded(child: field),
            ],
          ),
          if (right && widget.showLamType)
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
