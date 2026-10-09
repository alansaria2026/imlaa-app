import 'package:flutter/material.dart';

import '../app_state.dart';
import '../data/lam_lesson.dart';
import '../lesson/lam_lesson_pages.dart';
import '../lesson/lesson_screen.dart';
import '../lesson/page_handle.dart';
import '../lesson/rule_content.dart';
import '../theme.dart';
import '../utils/arabic.dart';
import '../widgets/common.dart';
import '../widgets/mascot.dart';
import '../widgets/pressable.dart';

/// مسار التعلّم: محطات الدرس متعرّجة، والحالية تنبض بزر «ابدأ».
class LearnTab extends StatefulWidget {
  const LearnTab({super.key});

  @override
  State<LearnTab> createState() => _LearnTabState();
}

class _LearnTabState extends State<LearnTab> {
  /// للعرض فقط (العناوين والأيقونات)؛ يُبنى الدرس من جديد عند فتحه.
  final List<LessonPageSpec> _stations = buildLamLessonPages();

  /// إزاحة كل محطة أفقيًا لرسم مسار متعرّج.
  static const _offsets = [0.0, 0.42, 0.62, 0.25, -0.3, -0.58, -0.15];

  void _open(int page) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LessonScreen(
          lessonId: lamLessonId,
          title: lamLessonTitle,
          pages: buildLamLessonPages(),
          initialPage: page,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final n = _stations.length;
    final done = [for (var i = 0; i < n; i++) app.isPageDone(lamLessonId, i)];
    final current = done.indexOf(false); // -1 = أنهى الدرس كله
    final doneCount = done.where((d) => d).length;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _TopBar(app: app)),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          sliver: SliverToBoxAdapter(
            child: _UnitBanner(
              done: doneCount,
              total: n,
              onGuide: () => showRuleSheet(context),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
          sliver: SliverList.list(
            children: [
              for (var i = 0; i <= n; i++)
                _PathRow(
                  offset: _offsets[i % _offsets.length],
                  side: i == 2
                      ? _Side.mascot(current == -1 || current > 2)
                      : null,
                  child: i == n
                      ? _TrophyNode(
                          earned: current == -1,
                          onTap: current == -1 ? () => _open(0) : null,
                        )
                      : _StationNode(
                          spec: _stations[i],
                          state: done[i]
                              ? _NodeState.done
                              : i == current
                              ? _NodeState.current
                              : _NodeState.locked,
                          onTap: () {
                            if (done[i] || i == current) {
                              _open(i);
                            } else {
                              showFeedback(
                                context,
                                'أكمل المحطات السابقة أولًا لفتح «${_stations[i].title}»',
                                tone: FeedbackTone.hint,
                              );
                            }
                          },
                        ),
                ),
            ],
          ),
        ),
        const SliverPadding(
          padding: EdgeInsets.fromLTRB(16, 24, 16, 32),
          sliver: SliverList(
            delegate: SliverChildListDelegate.fixed([
              _LockedUnit(number: 2, title: 'التاء المربوطة والتاء المفتوحة'),
              _LockedUnit(number: 3, title: 'همزة الوصل وهمزة القطع'),
              _LockedUnit(number: 4, title: 'الألف اللينة'),
              _LockedUnit(number: 5, title: 'الهمزة المتوسطة والمتطرفة'),
            ]),
          ),
        ),
      ],
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.app});
  final AppState app;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          const Mascot(size: 40, mood: MascotMood.happy, animate: false),
          const SizedBox(width: 8),
          Text(
            'إملائي',
            style: t.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
          const Spacer(),
          _StatChip(
            emoji: '🔥',
            value: app.streak,
            color: app.learnedToday ? AppColors.streak : AppColors.muted,
            tooltip: 'أيام متتالية',
          ),
          const SizedBox(width: 6),
          _StatChip(
            emoji: '⭐',
            value: app.points,
            color: AppColors.sandDark,
            tooltip: 'النقاط',
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.emoji,
    required this.value,
    required this.color,
    required this.tooltip,
  });

  final String emoji;
  final int value;
  final Color color;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.line, width: 2),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 4),
            Text(
              arDigits(value),
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UnitBanner extends StatelessWidget {
  const _UnitBanner({
    required this.done,
    required this.total,
    required this.onGuide,
  });

  final int done;
  final int total;
  final VoidCallback onGuide;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.only(bottom: 5),
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 16, 14, 16),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'الوحدة ١ · الدرس ١',
                    style: t.labelLarge?.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    lamLessonTitle,
                    style: t.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ChunkyProgress(
                    value: done / total,
                    height: 12,
                    color: AppColors.sand,
                    track: Colors.white.withValues(alpha: 0.22),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${arDigits(done)} من ${arDigits(total)} محطات',
                    style: t.labelMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Column(
              children: [
                Pressable(
                  onTap: onGuide,
                  color: Colors.white.withValues(alpha: 0.18),
                  edgeColor: AppColors.primaryDark,
                  radius: 16,
                  child: const SizedBox(
                    width: 52,
                    height: 52,
                    child: Icon(
                      Icons.menu_book_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'القاعدة',
                  style: t.labelSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

enum _NodeState { done, current, locked }

class _Side {
  const _Side.mascot(this.happy);
  final bool happy;
}

class _PathRow extends StatelessWidget {
  const _PathRow({required this.offset, required this.child, this.side});

  final double offset;
  final Widget child;
  final _Side? side;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 162,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (side != null)
            Align(
              alignment: Alignment(offset > 0 ? -0.95 : 0.95, 0),
              child: Mascot(
                size: 92,
                mood: side!.happy ? MascotMood.happy : MascotMood.thinking,
              ),
            ),
          Align(alignment: Alignment(offset, 0), child: child),
        ],
      ),
    );
  }
}

class _StationNode extends StatefulWidget {
  const _StationNode({
    required this.spec,
    required this.state,
    required this.onTap,
  });

  final LessonPageSpec spec;
  final _NodeState state;
  final VoidCallback onTap;

  @override
  State<_StationNode> createState() => _StationNodeState();
}

class _StationNodeState extends State<_StationNode>
    with SingleTickerProviderStateMixin {
  late final _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(_StationNode old) {
    super.didUpdateWidget(old);
    _sync();
  }

  void _sync() {
    if (widget.state == _NodeState.current &&
        !MediaQuery.disableAnimationsOf(context)) {
      if (!_pulse.isAnimating) _pulse.repeat();
    } else {
      _pulse.stop();
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final state = widget.state;
    final (color, edge) = switch (state) {
      _NodeState.done => (AppColors.sand, AppColors.sandDark),
      _NodeState.current => (AppColors.primary, AppColors.primaryDark),
      _NodeState.locked => (AppColors.locked, AppColors.lineDark),
    };
    const size = 72.0;

    final node = Pressable(
      onTap: widget.onTap,
      color: color,
      edgeColor: edge,
      shape: BoxShape.circle,
      depth: 6,
      child: SizedBox(
        width: size,
        height: size,
        child: Center(
          child: switch (state) {
            _NodeState.done => const Icon(
              Icons.check_rounded,
              color: Colors.white,
              size: 38,
            ),
            _NodeState.locked => Opacity(
              opacity: 0.45,
              child: Text(
                widget.spec.emoji,
                style: const TextStyle(fontSize: 30),
              ),
            ),
            _NodeState.current => Text(
              widget.spec.emoji,
              style: const TextStyle(fontSize: 32),
            ),
          },
        ),
      ),
    );

    return Semantics(
      label:
          '${widget.spec.title} — ${switch (state) {
            _NodeState.done => 'منجزة',
            _NodeState.current => 'المحطة الحالية',
            _NodeState.locked => 'مقفلة',
          }}',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // فقاعة «ابدأ» داخل حدود المحطة لتبقى قابلة للضغط.
            SizedBox(
              height: 36,
              child: state == _NodeState.current
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.line, width: 2),
                      ),
                      child: Text(
                        'ابدأ',
                        style: t.titleSmall?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    )
                  : null,
            ),
            SizedBox(
              width: size + 28,
              height: size + 28,
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  if (state == _NodeState.current)
                    AnimatedBuilder(
                      animation: _pulse,
                      builder: (context, _) {
                        final v = _pulse.value;
                        return Container(
                          width: size + 10 + 18 * v,
                          height: size + 10 + 18 * v,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primary.withValues(
                                alpha: 0.45 * (1 - v),
                              ),
                              width: 4,
                            ),
                          ),
                        );
                      },
                    ),
                  node,
                ],
              ),
            ),
            Text(
              widget.spec.title,
              style: t.labelLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: state == _NodeState.locked
                    ? AppColors.muted
                    : AppColors.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrophyNode extends StatelessWidget {
  const _TrophyNode({required this.earned, this.onTap});
  final bool earned;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Pressable(
          onTap: onTap ?? () {},
          color: earned ? AppColors.sand : AppColors.locked,
          edgeColor: earned ? AppColors.sandDark : AppColors.lineDark,
          radius: 22,
          depth: 6,
          child: SizedBox(
            width: 84,
            height: 76,
            child: Center(
              child: Opacity(
                opacity: earned ? 1 : 0.5,
                child: const Text('🏆', style: TextStyle(fontSize: 38)),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          earned ? 'أتممت الدرس! أعده' : 'نهاية الدرس',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: earned ? AppColors.sandDark : AppColors.muted,
          ),
        ),
      ],
    );
  }
}

class _LockedUnit extends StatelessWidget {
  const _LockedUnit({required this.number, required this.title});
  final int number;
  final String title;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.line, width: 2),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: const BoxDecoration(
                color: AppColors.locked,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.lock_rounded, color: AppColors.muted),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'الوحدة ${arDigits(number)}',
                    style: t.labelMedium?.copyWith(color: AppColors.muted),
                  ),
                  Text(
                    title,
                    style: t.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              'قريبًا',
              style: t.labelLarge?.copyWith(
                color: AppColors.sandDark,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
