import 'package:flutter/material.dart';

import '../../app_state.dart';
import '../../data/lam_lesson.dart';
import '../../services/speaker.dart';
import '../../theme.dart';
import '../../widgets/common.dart';
import '../page_handle.dart';
import '../rule_content.dart';

/// ص ١: مثال القاعدة.
class RulePage extends StatefulWidget {
  const RulePage({super.key, required this.handle});
  final PageHandle handle;

  @override
  State<RulePage> createState() => _RulePageState();
}

class _RulePageState extends State<RulePage> {
  @override
  void initState() {
    super.initState();
    widget.handle
      ..onListen = (() => Speaker.instance.speak(
        ruleSpeech,
        rate: AppScope.read(context).speechRate,
      ))
      ..onHint = () => showFeedback(
        context,
        'انطق الكلمة: إن سمعت اللام فهي قمرية، وإن اختفت وشُدِّد الحرف بعدها فهي شمسية.',
        tone: FeedbackTone.hint,
      );
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => widget.handle.markComplete(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const PageCard(
      tag: 'مثال القاعدة',
      title: 'تعرّف على اللام القمرية واللام الشمسية',
      subtitle: 'اضغط على المثال لتسمعه',
      child: RuleContent(),
    );
  }
}

/// أمثلة حذف (الـ) أو إضافتها حسب [add]؛ لكلٍّ صفحة مستقلة.
class ExamplesPage extends StatefulWidget {
  const ExamplesPage({super.key, required this.handle, required this.add});
  final PageHandle handle;
  final bool add;

  @override
  State<ExamplesPage> createState() => _ExamplesPageState();
}

class _ExamplesPageState extends State<ExamplesPage> {
  int? _playing;
  late final _rows = [
    for (final e in lamExamples)
      if (e.add == widget.add) e,
  ];

  @override
  void initState() {
    super.initState();
    widget.handle
      ..onListen = _playAll
      ..onHint = () => showFeedback(
        context,
        widget.add
            ? 'علامة (+) تعني أضف «الـ» إلى أول الكلمة.'
            : 'علامة (−) تعني احذف «الـ» من أول الكلمة.',
        tone: FeedbackTone.hint,
      );
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => widget.handle.markComplete(),
    );
  }

  Future<void> _play(int i) async {
    setState(() => _playing = i);
    final e = _rows[i];
    await Speaker.instance.speakAll([
      spokenForm(e.from),
      spokenForm(e.result),
    ], rate: AppScope.read(context).speechRate);
    if (mounted && _playing == i) setState(() => _playing = null);
  }

  Future<void> _playAll() async {
    for (var i = 0; i < _rows.length; i++) {
      if (!mounted) return;
      await _play(i);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageCard(
      tag: 'مثال',
      title: widget.add ? 'أضف (الـ) إلى الكلمة' : 'احذف (الـ) من الكلمة',
      subtitle: 'لاحظ كيف تتغير الكلمة، واضغط على أي سطر لتسمعه',
      child: Column(
        children: [
          for (var i = 0; i < _rows.length; i++) ...[
            _ExampleEquation(
              row: _rows[i],
              active: _playing == i,
              onTap: () => _play(i),
            ),
            if (i < _rows.length - 1) const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _ExampleEquation extends StatelessWidget {
  const _ExampleEquation({
    required this.row,
    required this.active,
    required this.onTap,
  });

  final ExampleRow row;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final op = Theme.of(context).textTheme.titleLarge?.copyWith(
      color: AppColors.muted,
      fontWeight: FontWeight.w700,
    );
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: active ? AppColors.primarySoft : AppColors.background,
        border: Border.all(color: active ? AppColors.ink : AppColors.line),
        borderRadius: BorderRadius.circular(18),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            children: [
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: AlText(row.from, size: 30),
                ),
              ),
              Text(row.add ? '+' : '−', style: op),
              const SizedBox(width: 8),
              const AlBox(size: 22),
              const SizedBox(width: 8),
              Text('=', style: op),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: AlText(row.result, size: 30, color: AppColors.blue),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
