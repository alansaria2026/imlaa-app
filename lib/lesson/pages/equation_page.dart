import 'dart:math';

import 'package:flutter/material.dart';

import '../../app_state.dart';
import '../../data/lam_lesson.dart';
import '../../data/bi_lesson.dart';
import '../../data/li_lesson.dart';
import '../../services/speaker.dart';
import '../../theme.dart';
import '../../utils/arabic.dart';
import '../../widgets/common.dart';
import '../../widgets/pressable.dart';
import '../page_handle.dart';

/// نوع المعادلة.
enum EquationOp {
  /// كتاب + الـ = الكتاب
  addAl,

  /// الكتاب − الـ = كتاب
  removeAl,

  /// الكتاب + لِـ = للكتاب
  addLi,

  /// للكتاب − لِـ = الكتاب
  removeLi,

  /// الكتاب + بـ = بالكتاب
  addBi,

  /// بالكتاب − بـ = الكتاب
  removeBi;

  bool get adds => this == addAl || this == addLi || this == addBi;

  /// ما يُضاف أو يُحذف.
  String get part => switch (this) {
    addLi || removeLi => 'لِـ',
    addBi || removeBi => 'بـ',
    _ => 'الـ',
  };

  /// الكلمة المعروضة في السؤال (الكلمات مخزنة بصيغتها مع «ال» إلا في addAl).
  String question(String w) => switch (this) {
    removeLi => liForm(w),
    removeBi => biForm(w),
    _ => w,
  };

  String answer(String w) => switch (this) {
    addAl => 'ال$w',
    removeAl => w.substring(2),
    addLi => liForm(w),
    addBi => biForm(w),
    removeLi || removeBi => w,
  };

  String spokenQuestion(String w) => switch (this) {
    removeLi => liSpoken(w),
    removeBi => biSpoken(w),
    _ => spokenForm(w),
  };
}

/// تطبيق المعادلات: كلمة ± الـ = ؟ أو كلمة ± لِـ = ؟
///
/// في الوضع الصارم [strict] (تعليمات ص ٤): لا يُسمح بأي خطأ؛ أي خطأ يعيد
/// جميع الكلمات بترتيب مختلف، ومؤشر النتيجة يبدأ ممتلئًا وينقص مع كل خطأ.
class EquationPage extends StatefulWidget {
  const EquationPage({
    super.key,
    required this.handle,
    required this.rounds,
    required this.op,
    this.tag,
    this.refill,
    this.example,
    required this.title,
    this.titleColor,
    this.strict = false,
    this.showLamType = true,
  });

  final PageHandle handle;

  /// كل جولة مجموعة كلمات تظهر معًا.
  final List<List<String>> rounds;
  final EquationOp op;

  /// كلمات جديدة عند الرجوع للقاعدة (تعليمات ص ٣ من درس اللام)؛ null للإبقاء.
  final List<List<String>> Function()? refill;

  /// كلمة مثال تُعرض محلولة فوق التمرين (الكتاب + لِـ = للكتاب).
  final String? example;
  final String? tag;
  final String title;

  /// لون العنوان؛ الافتراضي لون النص.
  final Color? titleColor;
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

  String _answer(String w) => widget.op.answer(w);

  @override
  void initState() {
    super.initState();
    _setupRound();
    widget.handle
      ..onHint = _hint
      ..onSubmit = _check
      ..onRuleOpened = _refill
      ..onListen = () => Speaker.instance.speakAll(
        _words.map(widget.op.spokenQuestion).toList(),
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

  /// بعد الرجوع للقاعدة: كلمات جديدة من البداية دون احتساب خطأ.
  void _refill() {
    final refill = widget.refill;
    if (refill == null || widget.handle.complete) return;
    setState(() {
      _retired.addAll(_ctrls);
      _rounds = refill();
      _round = 0;
      _solved = 0;
      _generation++;
      _restarting = false;
      _setupRound();
    });
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
      () => _hints[i] = switch (widget.op) {
        EquationOp.addAl => 'اكتب «ال» ثم الكلمة: ${ans.substring(0, 3)}…',
        EquationOp.removeAl => 'احذف أول حرفين «ال»: ${ans.substring(0, 1)}…',
        EquationOp.addLi => 'احذف الألف واكتب لامين فقط: لل…',
        EquationOp.removeLi => 'أعد «ال» إلى أول الكلمة: ال…',
        EquationOp.addBi => 'اكتب الباء ثم الكلمة كما هي: بال…',
        EquationOp.removeBi => 'احذف الباء فقط وأبقِ «ال»: ال…',
      },
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
    final empty = [
      for (final i in open)
        if (_ctrls[i].text.trim().isEmpty) i,
    ];
    if (empty.isNotEmpty) {
      // حقل فارغ لا يُحتسب خطأً: يُظلَّل بالأحمر ويُنبَّه الطالب فقط.
      setState(() {
        for (final i in empty) {
          _states[i] = _RowState.wrong;
        }
        _shake++;
      });
      showFeedback(
        context,
        empty.length == open.length
            ? (open.length > 1
                  ? 'اكتب الكلمتين ثم اضغط «إدخال»'
                  : 'اكتب الكلمة ثم اضغط «إدخال»')
            : 'لم تكتب إحدى الكلمتين، اكتبها ثم اضغط «إدخال»',
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
      titleColor: widget.titleColor,
      subtitle: widget.strict ? 'أي خطأ يعيد جميع الكلمات بترتيب جديد' : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.example case final e?) ...[
            _ExampleLine(
              key: const ValueKey('example'),
              op: widget.op,
              word: e,
            ),
            const SizedBox(height: 12),
          ],
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
          const SizedBox(height: 4),
          // يبقى ظاهرًا أثناء الكتابة حين يختفي زر «التالي».
          Builder(
            builder: (context) {
              final active =
                  !_restarting && !_states.every((s) => s == _RowState.right);
              return AppButton(
                label: 'إدخال',
                style: AppButtonStyle.secondary,
                enabled: active,
                onTap: active ? _check : null,
              );
            },
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
                  child: AlText(
                    widget.op.question(word),
                    size: 30,
                    highlight: false,
                  ),
                ),
              ),
              Text(widget.op.adds ? '+' : '−', style: op),
              const SizedBox(width: 4),
              AlBox(size: 18, text: widget.op.part),
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
                  lamTypeOf(widget.op.adds ? _answer(word) : word),
                  dense: true,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// مثال محلول بخط أصغر: الكتاب + لِـ = للكتاب.
class _ExampleLine extends StatelessWidget {
  const _ExampleLine({super.key, required this.op, required this.word});
  final EquationOp op;
  final String word;

  @override
  Widget build(BuildContext context) {
    final answer = op.answer(word);
    // الحرف المضاف بالأحمر في الناتج (لل/ل في لام الجر، ب في الباء).
    final red = switch (op) {
      EquationOp.addLi => liRedPrefix(word),
      EquationOp.addBi => 1,
      _ => 0,
    };
    final sign = TextStyle(color: AppColors.muted, fontSize: 20);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.line),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('مثال: ', style: AppTheme.word(18, color: AppColors.muted)),
            AlText(op.question(word), size: 22, highlight: false),
            Text(op.adds ? '  +  ' : '  −  ', style: sign),
            Text(op.part, style: AppTheme.word(22, color: AppColors.al)),
            Text('  =  ', style: sign),
            AlText(
              answer,
              size: 22,
              color: AppColors.blue,
              highlight: red > 0,
              redPrefix: red > 0 ? red : null,
            ),
          ],
        ),
      ),
    );
  }
}
