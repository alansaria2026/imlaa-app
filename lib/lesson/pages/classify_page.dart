import 'package:flutter/material.dart';

import '../../app_state.dart';
import '../../services/speaker.dart';
import '../../theme.dart';
import '../../utils/arabic.dart';
import '../../widgets/common.dart';
import '../page_handle.dart';

/// تدريب: صنّف لام الكلمة (قمرية أم شمسية).
class ClassifyPage extends StatefulWidget {
  const ClassifyPage({super.key, required this.handle, required this.words});

  final PageHandle handle;
  final List<String> words;

  @override
  State<ClassifyPage> createState() => _ClassifyPageState();
}

class _ClassifyPageState extends State<ClassifyPage> {
  late final List<String> _queue = [...widget.words];
  final Set<String> _missed = {};
  int _solved = 0;
  int _shake = 0;
  LamType? _flash;

  String? get _current => _queue.isEmpty ? null : _queue.first;

  @override
  void initState() {
    super.initState();
    widget.handle
      ..onListen = _speak
      ..onHint = () {
        final w = _current;
        if (w == null) return;
        _speak();
        showFeedback(
          context,
          'استمع جيدًا: هل تسمع اللام قبل حرف «${letterAfterAl(w)}»؟',
          tone: FeedbackTone.hint,
        );
      };
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => widget.handle.setProgress(0, widget.words.length),
    );
  }

  void _speak() {
    final w = _current;
    if (w != null) {
      Speaker.instance.speak(w, rate: AppScope.read(context).speechRate);
    }
  }

  void _answer(LamType choice) {
    final w = _current;
    if (w == null || _flash != null) return;
    final correct = lamTypeOf(w);
    final letter = letterAfterAl(w);
    if (choice == correct) {
      AppScope.read(context).addPoints(_missed.contains(w) ? 5 : 10);
      showFeedback(
        context,
        'صحيح! «$letter» حرف ${correct == LamType.moon ? 'قمري' : 'شمسي'}',
      );
      setState(() {
        _flash = choice;
        _solved++;
      });
      widget.handle.setProgress(_solved, widget.words.length);
      Future.delayed(const Duration(milliseconds: 700), () {
        if (!mounted) return;
        setState(() {
          _queue.removeAt(0);
          _flash = null;
        });
        if (_queue.isEmpty) widget.handle.markComplete();
      });
    } else {
      showFeedback(
        context,
        'الحرف بعد (الـ) هو «$letter» وهو حرف ${correct == LamType.moon ? 'قمري' : 'شمسي'}، سنعيد الكلمة لاحقًا',
        tone: FeedbackTone.error,
      );
      setState(() {
        _shake++;
        _missed.add(w);
        _queue
          ..removeAt(0)
          ..add(w);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = _current;
    return PageCard(
      tag: 'تدريب',
      title: 'صنّف الكلمة: لامها قمرية أم شمسية؟',
      subtitle: 'انطق الكلمة، ثم اختر الإجابة',
      child: w == null
          ? const _Done()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ShakeOnChange(
                  trigger: _shake,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: Container(
                      key: ValueKey('$w$_solved'),
                      padding: const EdgeInsets.symmetric(vertical: 28),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        children: [
                          AlText(w, size: 44),
                          IconButton.filledTonal(
                            onPressed: _speak,
                            icon: const Icon(Icons.volume_up_rounded),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: _ChoiceButton(
                        type: LamType.moon,
                        highlighted: _flash == LamType.moon,
                        onTap: () => _answer(LamType.moon),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ChoiceButton(
                        type: LamType.sun,
                        highlighted: _flash == LamType.sun,
                        onTap: () => _answer(LamType.sun),
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}

class _ChoiceButton extends StatelessWidget {
  const _ChoiceButton({
    required this.type,
    required this.highlighted,
    required this.onTap,
  });

  final LamType type;
  final bool highlighted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final moon = type == LamType.moon;
    final color = moon ? AppColors.moon : AppColors.sun;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: highlighted
            ? AppColors.successSoft
            : moon
            ? AppColors.moonSoft
            : AppColors.sunSoft,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: highlighted ? AppColors.success : color.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18),
          child: Column(
            children: [
              Text(moon ? '🌙' : '☀️', style: const TextStyle(fontSize: 30)),
              const SizedBox(height: 6),
              Text(
                type.label,
                style: Theme.of(context).textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              Text(
                type.rule,
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(color: AppColors.muted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Done extends StatelessWidget {
  const _Done();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          const Text('🎉', style: TextStyle(fontSize: 54)),
          const SizedBox(height: 8),
          Text(
            'أحسنت! صنّفت جميع الكلمات',
            style: Theme.of(context).textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            'اضغط «التالي» للمتابعة',
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}

/// رسالة إكمال مشتركة لصفحات التمارين.
class PageDoneMessage extends StatelessWidget {
  const PageDoneMessage({super.key});

  @override
  Widget build(BuildContext context) => const _Done();
}
