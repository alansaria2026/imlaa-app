import 'dart:math';

import 'package:flutter/material.dart';

import '../../app_state.dart';
import '../../data/hamza_lesson.dart';
import '../../services/speaker.dart';
import '../../theme.dart';
import '../../utils/arabic.dart';
import '../../widgets/common.dart';
import '../../widgets/pressable.dart';
import '../page_handle.dart';
import '../rule_content.dart';

/// سؤال: اختيار من [options] (الصحيحة [answers])، أو كتابة [answer].
class QuizItem {
  const QuizItem({
    this.prompt,
    this.options = const [],
    this.answers = const {},
    this.answer,
    this.multi = false,
  });

  final String? prompt;
  final List<String> options;
  final Set<String> answers;

  /// الإجابة المكتوبة لسؤال كتابة؛ null لسؤال اختيار.
  final String? answer;

  /// يختار الطالب كل الإجابات الصحيحة بدل إجابة واحدة.
  final bool multi;

  bool get writes => answer != null;
}

/// مجموعة أسئلة تظهر معًا ويُضغط بعدها «إدخال».
class QuizRound {
  const QuizRound({
    required this.items,
    this.instruction,
    this.sentence,
    this.mark,
    this.answerSentence,
    this.answerMark,
    this.spoken,
    this.hint,
    this.marks = const {},
    this.markLastLetter = false,
    this.spokenAll,
  });

  final List<QuizItem> items;
  final String? instruction;

  /// جملة السؤال، والكلمة [mark] فيها بالأحمر.
  final String? sentence;
  final String? mark;

  /// الجملة كما تُكتب صحيحةً، تحل محل [sentence] بعد الإجابة.
  final String? answerSentence;
  final String? answerMark;

  /// ما يُنطق بزر «استمع» وبعد الإجابة الصحيحة.
  final String? spoken;
  final String? hint;

  /// كلمات أخرى بالأحمر في [sentence] (الجمل في أسطر بـ\n).
  final Set<String> marks;

  /// يُلوَّن الحرف الأخير من الكلمة وحده (الألف في آخر الاسم).
  final bool markLastLetter;

  /// جمل تُنطق متتالية بزر «استمع» بدل [spoken] (لكل جملة تسجيلها).
  final List<String>? spokenAll;
}

/// أسئلة الصفحة كلها؛ [attempt] صفر أول مرة (أسئلة الكتاب) ثم يزيد مع كل
/// إعادة بأسئلة جديدة.
typedef QuizBuilder = List<QuizRound> Function(Random rnd, int attempt);

/// تمرين «اختر الإجابة الصحيحة» بتعليمات كتاب درس الهمزة: يُجاب عن الأسئلة
/// على التوالي؛ أي خطأ تنبثق بعده القاعدة ثم تُعاد الأسئلة من البداية بأسئلة
/// جديدة وأماكن خيارات مختلفة، ومؤشر النتيجة ينقص مع كل خطأ.
class QuizPage extends StatefulWidget {
  const QuizPage({
    super.key,
    required this.handle,
    required this.title,
    required this.build,
    this.tag,
    this.subtitle,
    this.rule,
    this.intro,
    this.introSpeech,
    this.autoSpeak = false,
    this.sentenceColor = AppColors.ink,
  });

  final PageHandle handle;
  final String title;
  final String? tag;
  final String? subtitle;
  final QuizBuilder build;

  /// القاعدة التي تنبثق بعد الخطأ.
  final Widget? rule;

  /// مثال محلول يُعرض قبل التطبيق، ثم «طبّق الآن».
  final Widget? intro;

  /// ما ينطقه «استمع» قبل بدء التطبيق (جملة المثال).
  final String? introSpeech;

  /// تُنطق جملة كل سؤال عند ظهوره (تمارين «اسمع»).
  final bool autoSpeak;

  /// لون جملة السؤال (كلماتها المعلّمة تبقى بالأحمر).
  final Color sentenceColor;

  static const levelStep = 10;

  @override
  State<QuizPage> createState() => QuizPageState();
}

enum _State { open, wrong, right }

class QuizPageState extends State<QuizPage> {
  final _rnd = Random();
  int _attempt = 0;
  late List<QuizRound> _rounds = widget.build(_rnd, 0);
  int _round = 0;
  int _solved = 0;
  int _mistakes = 0;
  int _generation = 0;
  int _shake = 0;
  bool _busy = false;
  late bool _started = widget.intro == null;

  late List<List<String>> _orders;
  late List<Set<String>> _picked;
  late List<_State> _states;
  late List<TextEditingController> _ctrls;

  /// تبقى حتى إغلاق الصفحة لأن الحركة الانتقالية تعرض الحقول القديمة.
  final List<TextEditingController> _retired = [];

  QuizRound get _current => _rounds[_round];

  /// الجولة الظاهرة؛ تقرؤها الاختبارات لتجيب بالضغط على الأزرار.
  @visibleForTesting
  QuizRound get currentRound => _current;
  int get _total => _rounds.fold(0, (a, r) => a + r.items.length);
  int get _level => max(0, 100 - _mistakes * QuizPage.levelStep);
  bool get _done => widget.handle.complete;

  @override
  void initState() {
    super.initState();
    _setupRound();
    widget.handle
      ..onHint = _hint
      ..onListen = _listen
      ..onRuleOpened = _restart
      ..onEnter = widget.autoSpeak ? _listen : null;
    // عدد الأسئلة يظهر من البداية، وبه تتحدث القائمة (استمع، مساعدة).
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => widget.handle.setProgress(_solved, _total),
    );
    if (_started) _activate();
  }

  /// يربط «التالي» بالتصحيح ويُظهر المؤشرين بعد بدء التطبيق.
  void _activate() {
    widget.handle.onSubmit = _check;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.handle
        ..setProgress(_solved, _total)
        ..setLevel(_level);
    });
  }

  @override
  void dispose() {
    for (final c in [..._retired, ..._ctrls]) {
      c.dispose();
    }
    super.dispose();
  }

  void _setupRound() {
    final items = _current.items;
    _orders = [
      for (final it in items) [...it.options]..shuffle(_rnd),
    ];
    _picked = [for (final _ in items) <String>{}];
    _states = [for (final _ in items) _State.open];
    _ctrls = [for (final _ in items) TextEditingController()];
  }

  void _listen() {
    final rate = AppScope.read(context).speechRate;
    if (_started && _current.spokenAll != null) {
      Speaker.instance.speakAll(_current.spokenAll!, rate: rate);
      return;
    }
    final text = _started ? _current.spoken : widget.introSpeech;
    Speaker.instance.speak(text ?? widget.title, rate: rate);
  }

  void _hint() {
    if (_done) return;
    if (!_started) {
      showFeedback(
        context,
        'اقرأ المثال المحلول والقاعدة، ثم اضغط «طبّق الآن»',
        tone: FeedbackTone.hint,
      );
      return;
    }
    showFeedback(
      context,
      _current.hint ?? 'افتح «القاعدة» من القائمة وراجعها قبل الإجابة',
      tone: FeedbackTone.hint,
    );
  }

  /// أسئلة جديدة من البداية (بعد الخطأ أو الرجوع للقاعدة).
  void _restart() {
    if (!_started || _done || !mounted) return;
    setState(() {
      _retired.addAll(_ctrls);
      _attempt++;
      _rounds = widget.build(_rnd, _attempt);
      _round = 0;
      _solved = 0;
      _generation++;
      _busy = false;
      _setupRound();
    });
    widget.handle.setProgress(0, _total);
    if (widget.autoSpeak) _listen();
  }

  void _pick(int i, String option) {
    if (_busy || _states[i] == _State.right) return;
    setState(() {
      final item = _current.items[i];
      final set = _picked[i];
      if (item.multi) {
        if (!set.remove(option)) set.add(option);
      } else {
        set
          ..clear()
          ..add(option);
      }
      _states[i] = _State.open;
    });
  }

  bool _isRight(int i) {
    final item = _current.items[i];
    if (item.writes) return sameWriting(_ctrls[i].text, item.answer!);
    final p = _picked[i];
    return p.length == item.answers.length && p.containsAll(item.answers);
  }

  bool _isEmpty(int i) => _current.items[i].writes
      ? _ctrls[i].text.trim().isEmpty
      : _picked[i].isEmpty;

  void _check() {
    if (_busy || _done || !_started) return;
    FocusScope.of(context).unfocus();
    final items = _current.items;
    final open = [
      for (var i = 0; i < items.length; i++)
        if (_states[i] != _State.right) i,
    ];
    // سؤال بلا إجابة لا يُحتسب خطأً: يُنبَّه الطالب فقط.
    if (open.any(_isEmpty)) {
      setState(() => _shake++);
      showFeedback(
        context,
        items.length > 1
            ? 'أجب عن جميع الأسئلة ثم اضغط «إدخال»'
            : 'اختر الإجابة ثم اضغط «إدخال»',
        tone: FeedbackTone.error,
      );
      return;
    }
    var anyWrong = false;
    setState(() {
      for (final i in open) {
        final ok = _isRight(i);
        _states[i] = ok ? _State.right : _State.wrong;
        if (!ok) anyWrong = true;
      }
      if (anyWrong) {
        _shake++;
        _mistakes++;
      }
      _busy = true;
    });

    // خطوة مؤجلة تُلغى إن أُعيدت الأسئلة قبلها (بفتح القاعدة من القائمة).
    final generation = _generation;

    if (anyWrong) {
      widget.handle.setLevel(_level);
      showFeedback(
        context,
        'إجابة غير صحيحة! راجع القاعدة، ثم تبدأ من جديد بأسئلة أخرى',
        tone: FeedbackTone.error,
      );
      // وقت لرؤية الإجابات الصحيحة قبل انبثاق القاعدة.
      Future.delayed(const Duration(milliseconds: 1800), () async {
        if (!mounted || _generation != generation) return;
        if (widget.rule != null) {
          await showRuleSheet(context, content: widget.rule);
        }
        if (mounted && _generation == generation) _restart();
      });
      return;
    }

    _solved += items.length;
    widget.handle.setProgress(_solved, _total);
    // في تمارين «اسمع» تُسمع جملة السؤال التالي بدل إعادة هذه.
    if (_current.spoken case final s? when !widget.autoSpeak) {
      Speaker.instance.speak(s, rate: AppScope.read(context).speechRate);
    }
    if (_round < _rounds.length - 1) {
      showFeedback(context, 'أحسنت! ${remainingText(_total - _solved)}');
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (!mounted || _generation != generation) return;
        setState(() {
          _retired.addAll(_ctrls);
          _round++;
          _busy = false;
          _setupRound();
        });
        if (widget.autoSpeak) _listen();
      });
    } else {
      showFeedback(context, 'ممتاز! أنهيت هذا التمرين');
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (!mounted || _generation != generation) return;
        // النقاط حسب المستوى المتبقي في المؤشر.
        AppScope.read(context).addPoints((_total * 10 * _level / 100).round());
        setState(widget.handle.markComplete);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_done) {
      return PageCard(title: widget.title, child: const PageDoneMessage());
    }
    if (!_started) {
      return PageCard(
        tag: widget.tag,
        title: widget.title,
        subtitle: widget.subtitle,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            widget.intro!,
            const SizedBox(height: 20),
            AppButton(
              label: 'طبّق الآن',
              icon: Icons.edit_rounded,
              onTap: () {
                setState(() => _started = true);
                _activate();
              },
            ),
          ],
        ),
      );
    }
    final round = _current;
    return PageCard(
      tag: widget.tag,
      title: widget.title,
      titleColor: AppColors.red,
      subtitle: widget.subtitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Column(
              key: ValueKey('$_generation-$_round'),
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (round.instruction case final s?)
                  Text(
                    s,
                    textAlign: TextAlign.center,
                    style: AppTheme.word(22, color: AppColors.primary),
                  ),
                if (round.sentence case final s?)
                  GestureDetector(
                    onTap: _listen,
                    child: _busy && round.answerSentence != null
                        ? MarkedSentence(
                            round.answerSentence!,
                            mark: round.answerMark,
                            color: widget.sentenceColor,
                          )
                        : MarkedSentence(
                            s,
                            mark: round.mark,
                            marks: round.marks,
                            lastLetterOnly: round.markLastLetter,
                            color: widget.sentenceColor,
                          ),
                  ),
                const SizedBox(height: 8),
                for (var i = 0; i < round.items.length; i++) ...[
                  _item(i),
                  const SizedBox(height: 14),
                ],
              ],
            ),
          ),
          AppButton(
            label: 'إدخال',
            style: AppButtonStyle.secondary,
            enabled: !_busy,
            onTap: _busy ? null : _check,
          ),
        ],
      ),
    );
  }

  Widget _item(int i) {
    final item = _current.items[i];
    final many = _current.items.length > 1;
    final prompt = [
      if (many) '${arDigits(i + 1)}-',
      if (item.prompt != null) item.prompt!,
    ].join(' ');
    final promptText = prompt.isEmpty
        ? null
        : Text(
            prompt,
            // السؤال بالأزرق في وسط السطر، والعنوان بالأحمر.
            textAlign: TextAlign.center,
            style: AppTheme.word(
              22,
              color: AppColors.blue,
            ).copyWith(height: 1.5),
          );
    final state = _states[i];

    if (item.writes) {
      // السؤال القصير (كلمة واحدة) بجانب الحقل حتى يبقى «إدخال» ظاهرًا،
      // والطويل فوقه حتى لا يضيق السطر مع الخط الكبير.
      final short = (item.prompt ?? '').length <= 12;
      return ShakeOnChange(
        trigger: state == _State.wrong ? _shake : 0,
        child: short && promptText != null
            ? Row(
                children: [
                  // عرض ثابت للسؤال حتى تتساوى الحقول تحت بعضها.
                  Expanded(child: promptText),
                  const SizedBox(width: 10),
                  Expanded(flex: 2, child: _field(i)),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [?promptText, const SizedBox(height: 6), _field(i)],
              ),
      );
    }

    Widget chip(String o, {bool compact = false}) => _OptionChip(
      key: ValueKey('q$i-$o'),
      label: o,
      picked: _picked[i].contains(o),
      // بعد الخطأ تظهر الإجابات الصحيحة بالأخضر.
      reveal: state == _State.wrong && item.answers.contains(o),
      state: state,
      compact: compact,
      onTap: () => _pick(i, o),
    );
    // ثلاثة خيارات أو أربعة في سطر واحد بأزرار متساوية، حتى لا تنزل إلى
    // سطر ثانٍ فتدفع «إدخال» خارج الشاشة الصغيرة.
    final order = _orders[i];
    final Widget options = order.length >= 3 && order.length <= 4
        ? Row(
            children: [
              for (final (k, o) in order.indexed) ...[
                if (k > 0) const SizedBox(width: 6),
                Expanded(child: chip(o, compact: true)),
              ],
            ],
          )
        // الخيارات الكثيرة (تسعة أو اثنا عشر) خياران في كل سطر بأزرار
        // متساوية، بدل خيار في كل سطر يدفع «إدخال» خارج الشاشة.
        : order.length > 6
        ? Column(
            children: [
              for (var k = 0; k < order.length; k += 2)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      Expanded(child: chip(order[k], compact: true)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: k + 1 < order.length
                            ? chip(order[k + 1], compact: true)
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
            ],
          )
        : Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [for (final o in _orders[i]) chip(o)],
          );
    return ShakeOnChange(
      trigger: state == _State.wrong ? _shake : 0,
      // رقم الفقرة وحده يبقى في سطر الخيارات.
      child: item.prompt == null && promptText != null
          ? Row(
              children: [
                promptText,
                const SizedBox(width: 8),
                Expanded(child: options),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [?promptText, const SizedBox(height: 6), options],
            ),
    );
  }

  Widget _field(int i) {
    final state = _states[i];
    final right = state == _State.right;
    return TextField(
      key: ValueKey('q$i-field'),
      controller: _ctrls[i],
      enabled: !right && !_busy,
      textAlign: TextAlign.center,
      textDirection: TextDirection.rtl,
      style: AppTheme.word(
        24,
        color: right ? AppColors.success : AppColors.ink,
      ).copyWith(height: 1.3),
      scrollPadding: const EdgeInsets.fromLTRB(20, 80, 20, 60),
      onSubmitted: (_) => _check(),
      onChanged: (_) {
        if (state == _State.wrong) setState(() => _states[i] = _State.open);
      },
      decoration: InputDecoration(
        hintText: '……',
        isDense: true,
        fillColor: switch (state) {
          _State.right => AppColors.successSoft,
          _State.wrong => AppColors.errorSoft,
          _State.open => AppColors.background,
        },
        helperText: state == _State.wrong ? _current.items[i].answer : null,
        helperStyle: AppTheme.word(18, color: AppColors.success),
      ),
    );
  }
}

class _OptionChip extends StatelessWidget {
  const _OptionChip({
    super.key,
    required this.label,
    required this.picked,
    required this.reveal,
    required this.state,
    required this.onTap,
    this.compact = false,
  });

  final String label;
  final bool picked;
  final bool reveal;
  final _State state;
  final VoidCallback onTap;

  /// زر في سطر متساوي الأزرار: يصغر نصه بدل أن يتجاوز عرضه.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final wrongPick = picked && state == _State.wrong && !reveal;
    final (color, border, text) = switch (true) {
      _ when wrongPick => (
        AppColors.errorSoft,
        AppColors.error,
        AppColors.error,
      ),
      _ when reveal || (picked && state == _State.right) => (
        AppColors.successSoft,
        AppColors.success,
        AppColors.success,
      ),
      _ when picked => (AppColors.primarySoft, AppColors.ink, AppColors.ink),
      _ => (AppColors.surface, AppColors.line, AppColors.ink),
    };
    return Semantics(
      button: true,
      selected: picked,
      child: Pressable(
        onTap: onTap,
        color: color,
        borderColor: border,
        radius: 14,
        depth: 3,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 6 : 16,
            vertical: 6,
          ),
          child: compact
              ? Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(label, style: AppTheme.word(22, color: text)),
                  ),
                )
              : Text(label, style: AppTheme.word(22, color: text)),
        ),
      ),
    );
  }
}

/// جملة بخط النسخ والكلمة [mark] فيها بالأحمر.
/// جملة (أو جمل في أسطر) والكلمة [mark] و[marks] فيها بالأحمر، أو حرفها
/// الأخير وحده إن كان [lastLetterOnly].
class MarkedSentence extends StatelessWidget {
  const MarkedSentence(
    this.text, {
    super.key,
    this.mark,
    this.marks = const {},
    this.lastLetterOnly = false,
    this.size = 30,
    this.color = AppColors.ink,
  });

  final String text;
  final String? mark;
  final Set<String> marks;
  final bool lastLetterOnly;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    const red = TextStyle(color: AppColors.al);
    InlineSpan word(String w) {
      final plain = stripDiacritics(w).replaceAll('؟', '');
      if (plain != mark && !marks.contains(plain)) return TextSpan(text: w);
      if (!lastLetterOnly) return TextSpan(text: w, style: red);
      // الحرف الأخير مع تشكيله.
      var cut = w.length - 1;
      while (cut > 0 && stripDiacritics(w.substring(cut)).isEmpty) {
        cut--;
      }
      return TextSpan(
        children: [
          TextSpan(text: w.substring(0, cut)),
          TextSpan(text: w.substring(cut), style: red),
        ],
      );
    }

    final lines = text.split('\n');
    return Text.rich(
      TextSpan(
        children: [
          for (var l = 0; l < lines.length; l++) ...[
            if (l > 0) const TextSpan(text: '\n'),
            for (final (i, w) in lines[l].split(' ').indexed) ...[
              if (i > 0) const TextSpan(text: ' '),
              word(w),
            ],
          ],
        ],
      ),
      textAlign: TextAlign.center,
      style: AppTheme.word(size, color: color).copyWith(height: 1.6),
    );
  }
}
