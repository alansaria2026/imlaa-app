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

/// هيكل الدرس: شريط علوي (رجوع، عنوان الدرس، الصفحة الرئيسية)، مؤشر النتيجة
/// والنقاط المكتسبة، ثم أزرار (القاعدة، تلميح، استمع، التالي).
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
    _pager.animateToPage(
      i,
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeOutCubic,
    );
  }

  void _back() {
    if (_page > 0) {
      _goTo(_page - 1);
    } else {
      Navigator.of(context).pop();
    }
  }

  void _next() {
    if (!_canAdvance(_page)) {
      final h = _handles[_page];
      showFeedback(
        context,
        h.total > 0
            ? 'أجب عن جميع الفقرات أولًا (${arDigits(h.done)} من ${arDigits(h.total)})'
            : 'أكمل التمرين أولًا',
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
          builder: (_) =>
              LessonCompleteScreen(title: widget.title, earned: earned),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final handle = _handles[_page];
    final last = _page == widget.pages.length - 1;
    final t = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
              child: Row(
                children: [
                  RoundIconButton(
                    tooltip: 'رجوع',
                    icon: Icons.arrow_back_rounded,
                    size: 44,
                    onTap: _back,
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          'عنوان الدرس',
                          style: t.labelSmall?.copyWith(color: AppColors.muted),
                        ),
                        Text(
                          widget.title,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: t.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  RoundIconButton(
                    tooltip: 'الصفحة الرئيسية',
                    icon: Icons.home_rounded,
                    size: 44,
                    onTap: () =>
                        Navigator.of(context).popUntil((r) => r.isFirst),
                  ),
                ],
              ),
            ),
            _ScoreBar(
              page: _page,
              pageCount: widget.pages.length,
              handle: handle,
              points: app.points,
            ),
            Expanded(
              child: PageView(
                controller: _pager,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  for (final p in _built)
                    _KeepAlive(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        child: p,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.line, width: 2)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            child: Row(
              children: [
                _ToolButton(
                  icon: Icons.menu_book_rounded,
                  label: 'القاعدة',
                  onTap: () => showRuleSheet(context),
                ),
                _ToolButton(
                  icon: Icons.lightbulb_rounded,
                  label: 'تلميح',
                  color: AppColors.sand,
                  onTap: () => handle.onHint?.call(),
                ),
                _ToolButton(
                  icon: Icons.volume_up_rounded,
                  label: 'استمع',
                  color: AppColors.moon,
                  onTap: () => handle.onListen?.call(),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: AppButton(
                    label: last ? 'إنهاء' : 'التالي',
                    icon: last
                        ? Icons.flag_rounded
                        : Icons.arrow_forward_rounded,
                    enabled: _canAdvance(_page),
                    onTap: _next,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// مؤشر النتيجة والنقاط المكتسبة.
class _ScoreBar extends StatelessWidget {
  const _ScoreBar({
    required this.page,
    required this.pageCount,
    required this.handle,
    required this.points,
  });

  final int page;
  final int pageCount;
  final PageHandle handle;
  final int points;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final fraction = handle.total == 0 ? null : handle.done / handle.total;
    // المؤشر العكسي: يبدأ ممتلئًا وينقص مع كل خطأ.
    final level = handle.level;
    final value = level != null ? level / 100 : fraction ?? 1;
    final color = level != null
        ? level >= 70
              ? AppColors.success
              : level >= 40
              ? AppColors.sand
              : AppColors.error
        : handle.complete || fraction == null
        ? AppColors.success
        : AppColors.primary;
    final caption = [
      'الصفحة ${arDigits(page + 1)} من ${arDigits(pageCount)}',
      if (handle.total > 0)
        'أنجزت ${arDigits(handle.done)}/${arDigits(handle.total)}',
      if (level != null) 'المستوى ${arDigits(level)}٪',
    ].join('  ·  ');

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: ChunkyProgress(value: value, color: color),
              ),
              const SizedBox(width: 12),
              Tooltip(
                message: 'النقاط المكتسبة',
                child: Row(
                  children: [
                    const Text('⭐', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 4),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      transitionBuilder: (c, a) =>
                          ScaleTransition(scale: a, child: c),
                      child: Text(
                        arDigits(points),
                        key: ValueKey(points),
                        style: t.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.sandDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              caption,
              style: t.labelMedium?.copyWith(
                color: AppColors.muted,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToolButton extends StatelessWidget {
  const _ToolButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = AppColors.primary,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RoundIconButton(icon: icon, iconColor: color, size: 42, onTap: onTap),
          const SizedBox(height: 3),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.muted,
            ),
          ),
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
