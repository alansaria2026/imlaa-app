import 'package:flutter/material.dart';

import '../app_state.dart';
import '../services/speaker.dart';
import '../theme.dart';
import '../utils/arabic.dart';
import '../widgets/common.dart';
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
  });

  final String lessonId;
  final String title;
  final List<LessonPageSpec> pages;

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  final _pager = PageController();
  late final List<PageHandle> _handles = [
    for (final _ in widget.pages) PageHandle(),
  ];
  late final List<Widget> _built = [
    for (var i = 0; i < widget.pages.length; i++)
      widget.pages[i].builder(_handles[i]),
  ];
  late final int _startPoints;
  int _page = 0;

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
      final earned = AppScope.read(context).points - _startPoints;
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

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'رجوع',
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: _back,
        ),
        title: Column(
          children: [
            Text(
              'عنوان الدرس',
              style: Theme.of(context).textTheme.labelSmall
                  ?.copyWith(color: AppColors.muted),
            ),
            Text(widget.title),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'الصفحة الرئيسية',
            icon: const Icon(Icons.home_rounded),
            onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          _StatusBar(
            pageCount: widget.pages.length,
            page: _page,
            isDone: (i) => _canAdvance(i) && widget.pages[i].needsCompletion,
            handle: handle,
            points: app.points,
            onJump: (i) {
              if (i <= _page || _canAdvance(i - 1)) _goTo(i);
            },
          ),
          Expanded(
            child: PageView(
              controller: _pager,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                for (final p in _built)
                  _KeepAlive(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
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
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          decoration: BoxDecoration(
            color: AppColors.surface,
            boxShadow: [
              BoxShadow(
                color: AppColors.ink.withValues(alpha: 0.06),
                blurRadius: 16,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Row(
            children: [
              _ToolButton(
                icon: Icons.menu_book_rounded,
                label: 'القاعدة',
                onTap: () => showRuleSheet(context),
              ),
              _ToolButton(
                icon: Icons.lightbulb_outline_rounded,
                label: 'تلميح',
                onTap: () => handle.onHint?.call(),
              ),
              _ToolButton(
                icon: Icons.volume_up_rounded,
                label: 'استمع',
                onTap: () => handle.onListen?.call(),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: _canAdvance(_page)
                        ? AppColors.primary
                        : AppColors.primary.withValues(alpha: 0.4),
                  ),
                  onPressed: _next,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(last ? 'إنهاء' : 'التالي'),
                      const SizedBox(width: 6),
                      Icon(
                        last ? Icons.flag_rounded : Icons.arrow_forward_rounded,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBar extends StatelessWidget {
  const _StatusBar({
    required this.pageCount,
    required this.page,
    required this.isDone,
    required this.handle,
    required this.points,
    required this.onJump,
  });

  final int pageCount;
  final int page;
  final bool Function(int) isDone;
  final PageHandle handle;
  final int points;
  final ValueChanged<int> onJump;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final fraction = handle.total == 0 ? null : handle.done / handle.total;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Column(
        children: [
          Row(
            children: [
              for (var i = 0; i < pageCount; i++)
                Expanded(
                  child: GestureDetector(
                    onTap: () => onJump(i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      height: 6,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: i == page
                            ? AppColors.primary
                            : isDone(i) || i < page
                            ? AppColors.primary.withValues(alpha: 0.35)
                            : AppColors.line,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              // مؤشر النتيجة
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'الصفحة ${arDigits(page + 1)}/${arDigits(pageCount)}',
                        style: t.labelLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: fraction ?? 1,
                            minHeight: 6,
                            color: handle.complete || fraction == null
                                ? AppColors.success
                                : AppColors.sand,
                            backgroundColor: AppColors.line,
                          ),
                        ),
                      ),
                      if (handle.total > 0) ...[
                        const SizedBox(width: 8),
                        Text(
                          '${arDigits(handle.done)}/${arDigits(handle.total)}',
                          style: t.labelMedium?.copyWith(
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // النقاط المكتسبة
              Tooltip(
                message: 'النقاط المكتسبة',
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.sandSoft,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        size: 18,
                        color: AppColors.sand,
                      ),
                      const SizedBox(width: 4),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        transitionBuilder: (c, a) =>
                            ScaleTransition(scale: a, child: c),
                        child: Text(
                          arDigits(points),
                          key: ValueKey(points),
                          style: t.labelLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF9A6A1E),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
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
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: AppColors.primary),
              const SizedBox(height: 2),
              Text(
                label,
                style: Theme.of(context).textTheme.labelMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
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
