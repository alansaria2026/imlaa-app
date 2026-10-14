import 'dart:math';

import 'package:flutter/material.dart';

import '../app_state.dart';
import '../services/speaker.dart';
import '../theme.dart';
import '../utils/arabic.dart';
import '../widgets/common.dart';
import '../widgets/pressable.dart';
import 'lesson_complete_screen.dart';
import 'page_handle.dart';
import 'rule_content.dart';

/// هيكل الدرس (من اليمين إلى اليسار):
/// أعلى: القائمة المنسدلة، عنوان الدرس، مؤشر النتيجة وتحته مربعات الأسئلة،
/// الصفحة الرئيسية. أسفل: الرجوع والتالي فقط.
class LessonScreen extends StatefulWidget {
  const LessonScreen({
    super.key,
    required this.lessonId,
    required this.title,
    required this.pages,
    this.initialPage = 0,
  });

  final String lessonId;
  final String title;
  final List<LessonPageSpec> pages;
  final int initialPage;

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  late final _pager = PageController(initialPage: widget.initialPage);
  late final List<PageHandle> _handles = [
    for (final _ in widget.pages) PageHandle(),
  ];
  late final List<Widget> _built = [
    for (var i = 0; i < widget.pages.length; i++)
      widget.pages[i].builder(_handles[i]),
  ];
  late final int _startPoints;
  late int _page = widget.initialPage;

  @override
  void initState() {
    super.initState();
    _startPoints = AppScope.read(context).points;
    for (var i = 0; i < _handles.length; i++) {
      _handles[i].addListener(() {
        if (_handles[i].complete) {
          AppScope.read(context).markPageDone(widget.lessonId, i);
        }
        if (mounted) setState(() {});
      });
    }
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _handles[_page].onEnter?.call(),
    );
  }

  @override
  void dispose() {
    Speaker.instance.stop();
    hideFeedback();
    _pager.dispose();
    for (final h in _handles) {
      h.dispose();
    }
    super.dispose();
  }

  bool _canAdvance(int i) =>
      !widget.pages[i].needsCompletion ||
      _handles[i].complete ||
      AppScope.read(context).isPageDone(widget.lessonId, i);

  void _goTo(int i) {
    Speaker.instance.stop();
    FocusScope.of(context).unfocus();
    hideFeedback();
    setState(() => _page = i);
    _pager
        .animateToPage(
          i,
          duration: const Duration(milliseconds: 380),
          curve: Curves.easeOutCubic,
        )
        .then((_) {
          // بعد انتهاء الانتقال تكون الصفحة قد بُنيت.
          if (mounted && _page == i) _handles[i].onEnter?.call();
        });
  }

  void _back() {
    if (_page > 0) {
      _goTo(_page - 1);
    } else {
      Navigator.of(context).pop();
    }
  }

  void _next() {
    final h = _handles[_page];
    if (!_canAdvance(_page)) {
      // قبل إكمال الصفحة يصحّح «التالي» الإجابات الحالية.
      if (h.onSubmit != null) {
        h.onSubmit!();
        return;
      }
      showFeedback(
        context,
        h.total > 0 ? remainingText(h.total - h.done) : 'أكمل التمرين أولًا',
        tone: FeedbackTone.error,
      );
      return;
    }
    if (_page < widget.pages.length - 1) {
      _goTo(_page + 1);
    } else {
      final app = AppScope.read(context)..markLessonCompleted();
      final earned = app.points - _startPoints;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => LessonCompleteScreen(
            lessonId: widget.lessonId,
            title: widget.title,
            earned: earned,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final handle = _handles[_page];
    final last = _page == widget.pages.length - 1;
    // تُخفى أزرار التنقل أثناء الكتابة حتى لا تضيق المساحة فوق لوحة المفاتيح.
    final typing = MediaQuery.viewInsetsOf(context).bottom > 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 6, 10, 4),
              child: Row(
                children: [
                  _LessonMenu(handle: handle, rule: widget.pages[_page].rule),
                  const SizedBox(width: 6),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 96),
                    child: Text(
                      widget.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontSize: 10.5,
                        height: 1.25,
                        color: AppColors.muted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: _ScoreBar(handle: handle)),
                  const SizedBox(width: 10),
                  _SquareButton(
                    tooltip: 'الصفحة الرئيسية',
                    icon: Icons.home_outlined,
                    onTap: () =>
                        Navigator.of(context).popUntil((r) => r.isFirst),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pager,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  for (var i = 0; i < _built.length; i++)
                    _KeepAlive(
                      child: LayoutBuilder(
                        builder: (context, box) => SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                          keyboardDismissBehavior:
                              ScrollViewKeyboardDismissBehavior.onDrag,
                          child: widget.pages[i].centered
                              // في الوسط إن اتسعت الشاشة، وإلا يُمرَّر من أعلى.
                              ? ConstrainedBox(
                                  constraints: BoxConstraints(
                                    minHeight: max(0, box.maxHeight - 32),
                                  ),
                                  child: Center(child: _built[i]),
                                )
                              : _built[i],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (!typing)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
                child: Row(
                  children: [
                    _SquareButton(
                      tooltip: 'رجوع',
                      icon: Icons.arrow_back_rounded,
                      size: 54,
                      onTap: _back,
                    ),
                    const Spacer(),
                    _SquareButton(
                      tooltip: last ? 'إنهاء' : 'التالي',
                      icon: Icons.arrow_forward_rounded,
                      // في آخر صفحة زر مكتوب عليه «إنهاء» بدل السهم.
                      label: last ? 'إنهاء' : null,
                      size: 54,
                      filled: _canAdvance(_page) || handle.onSubmit != null,
                      onTap: _next,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// زر مربع بإطار أسود.
class _SquareButton extends StatelessWidget {
  const _SquareButton({
    required this.tooltip,
    required this.icon,
    required this.onTap,
    this.size = 40,
    this.filled = false,
    this.label,
  });

  final String tooltip;
  final IconData icon;

  /// نص يظهر بدل الأيقونة.
  final String? label;
  final VoidCallback onTap;
  final double size;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: filled ? AppColors.ink : AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: AppColors.ink, width: 1.5),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: SizedBox(
            width: label == null ? size : null,
            height: size,
            child: label == null
                ? Icon(
                    icon,
                    size: size * 0.55,
                    color: filled ? Colors.white : AppColors.ink,
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 26),
                    child: Center(
                      child: Text(
                        label!,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: filled ? Colors.white : AppColors.ink,
                            ),
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

/// القائمة المنسدلة: القاعدة، استمع، مساعدة.
class _LessonMenu extends StatelessWidget {
  const _LessonMenu({required this.handle, this.rule});
  final PageHandle handle;
  final Widget? rule;

  Future<void> _openRule(BuildContext context) async {
    await showRuleSheet(context, content: rule);
    handle.onRuleOpened?.call();
  }

  @override
  Widget build(BuildContext context) {
    final items = <(IconData, String, VoidCallback)>[
      (Icons.menu_book_outlined, 'القاعدة', () => _openRule(context)),
      if (handle.onListen != null)
        (Icons.volume_up_outlined, 'استمع', handle.onListen!),
      if (handle.onHint != null)
        (Icons.help_outline_rounded, 'مساعدة', handle.onHint!),
    ];
    return PopupMenuButton<int>(
      tooltip: 'القائمة',
      color: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      position: PopupMenuPosition.under,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.ink, width: 1.2),
      ),
      onSelected: (i) => items[i].$3(),
      itemBuilder: (_) => [
        for (var i = 0; i < items.length; i++)
          PopupMenuItem(
            value: i,
            child: Row(
              children: [
                Icon(items[i].$1, color: AppColors.ink),
                const SizedBox(width: 12),
                Text(
                  items[i].$2,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
      ],
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.ink, width: 1.5),
        ),
        child: const Icon(Icons.more_vert_rounded, color: AppColors.ink),
      ),
    );
  }
}

/// مؤشر النتيجة، وتحته مربع لكل سؤال يمتلئ عند اجتيازه.
class _ScoreBar extends StatelessWidget {
  const _ScoreBar({required this.handle});

  final PageHandle handle;

  @override
  Widget build(BuildContext context) {
    final total = handle.total;
    final fraction = total == 0 ? null : handle.done / total;
    // المؤشر العكسي: يبدأ ممتلئًا وينقص مع كل خطأ.
    final level = handle.level;
    final value = level != null ? level / 100 : fraction ?? 1;
    final color = level != null && level < 50 ? AppColors.red : AppColors.ink;
    final label = level != null ? 'النتيجة ${arDigits(level)}٪' : null;

    return Semantics(
      label: [
        ?label,
        if (total > 0) remainingText(total - handle.done),
      ].join('، '),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ChunkyProgress(value: value, color: color, height: 10),
          if (total > 0) ...[
            const SizedBox(height: 6),
            SizedBox(
              height: 10,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  children: [
                    for (var i = 0; i < total; i++)
                      Container(
                        key: ValueKey('q$i'),
                        width: 10,
                        height: 10,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          color: i < handle.done
                              ? AppColors.blue
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(2),
                          border: Border.all(
                            color: i < handle.done
                                ? AppColors.blue
                                : AppColors.ink,
                            width: 1.2,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _KeepAlive extends StatefulWidget {
  const _KeepAlive({required this.child});
  final Widget child;

  @override
  State<_KeepAlive> createState() => _KeepAliveState();
}

class _KeepAliveState extends State<_KeepAlive>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}
