import 'package:flutter/material.dart';

import '../app_state.dart';
import '../lesson/lesson_screen.dart';
import '../lesson/lessons.dart';
import '../lesson/page_handle.dart';
import '../lesson/rule_content.dart';
import '../theme.dart';
import '../utils/arabic.dart';
import '../widgets/common.dart';
import '../widgets/mascot.dart';
import '../widgets/pressable.dart';

/// مسار التعلّم: محطات الدرس مربعات على خط واحد، والحالية تنبض بزر «ابدأ».
class LearnTab extends StatefulWidget {
  const LearnTab({super.key});

  @override
  State<LearnTab> createState() => _LearnTabState();
}

class _LearnTabState extends State<LearnTab> {
  /// للعرض فقط (العناوين والأيقونات)؛ يُبنى الدرس من جديد عند فتحه.
  final Map<String, List<LessonPageSpec>> _stations = {
    for (final l in lessons) l.id: l.build(),
  };

  void _open(LessonDef lesson, int page) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LessonScreen(
          lessonId: lesson.id,
          title: lesson.title,
          pages: lesson.build(),
          initialPage: page,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    // الدرس المعروض بمحطاته (آخر وحدة اختارها الطالب)؛ بقية الدروس بطاقات
    // مختصرة تُفتح بالضغط.
    final selected = lessonById(app.selectedLesson ?? lessons.first.id).id;
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _TopBar(app: app)),
        for (final lesson in lessons)
          SliverToBoxAdapter(
            child: lesson.id == selected
                ? _LessonSection(
                    key: ValueKey(lesson.id),
                    lesson: lesson,
                    stations: _stations[lesson.id]!,
                    onOpen: (page) => _open(lesson, page),
                  )
                : Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: _UnitCard(
                      key: ValueKey('unit-${lesson.id}'),
                      number: lesson.unit,
                      title: lesson.title,
                      onTap: () => app.selectLesson(lesson.id),
                    ),
                  ),
          ),
        const SliverPadding(
          padding: EdgeInsets.fromLTRB(16, 12, 16, 32),
          sliver: SliverList(
            delegate: SliverChildListDelegate.fixed([
              _UnitCard(number: 3, title: 'همزة الوصل وهمزة القطع'),
              _UnitCard(number: 4, title: 'الألف اللينة'),
              _UnitCard(number: 5, title: 'الهمزة المتوسطة والمتطرفة'),
            ]),
          ),
        ),
      ],
    );
  }
}

/// درس في المسار: بطاقة الدرس، ثم شريط المحطات، ثم زر البدء.
class _LessonSection extends StatelessWidget {
  const _LessonSection({
    super.key,
    required this.lesson,
    required this.stations,
    required this.onOpen,
  });

  final LessonDef lesson;
  final List<LessonPageSpec> stations;
  final void Function(int page) onOpen;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final n = stations.length;
    final done = [for (var i = 0; i < n; i++) app.isPageDone(lesson.id, i)];
    final current = done.indexOf(false); // -1 = أنهى الدرس كله
    final doneCount = done.where((d) => d).length;
    final t = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: _UnitBanner(
            title: lesson.title,
            done: doneCount,
            total: n,
            onGuide: () => showRuleSheet(context, content: lesson.rule),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 22, 16, 4),
          // يصغر العنوان مع خط الجهاز الكبير جدًا بدل أن يتجاوز السطر.
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              'محطات الدرس',
              style: t.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
        ),
        // ارتفاع المحطات ثابت، فلا يكبر خط عناوينها مع تكبير خط الجهاز.
        MediaQuery.withClampedTextScaling(
          maxScaleFactor: 1,
          child: _StationStrip(
            count: n,
            current: current,
            nodeAt: (i) => i == n
                ? Padding(
                    // محاذاة مركز الكأس مع مراكز المربعات.
                    padding: const EdgeInsets.only(top: 33),
                    child: _TrophyNode(
                      earned: current == -1,
                      onTap: current == -1 ? () => onOpen(0) : null,
                    ),
                  )
                : _StationNode(
                    spec: stations[i],
                    state: done[i]
                        ? _NodeState.done
                        : i == current
                        ? _NodeState.current
                        : _NodeState.locked,
                    onTap: () {
                      if (done[i] || i == current) {
                        onOpen(i);
                      } else {
                        showFeedback(
                          context,
                          'أكمل المحطات السابقة أولًا لفتح «${stations[i].title}»',
                          tone: FeedbackTone.hint,
                        );
                      }
                    },
                  ),
            reached: (i) => i < n && (done[i] || i == current),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: _NextUp(
            finished: current == -1,
            started: doneCount > 0,
            onTap: () => onOpen(current == -1 ? 0 : current),
          ),
        ),
      ],
    );
  }
}

/// شريط المحطات الأفقي: يبدأ من اليمين على خط مستقيم، ويتأرجح قليلًا يمينًا
/// ويسارًا إشارةً إلى إمكانية السحب حتى يسحبه الطالب.
class _StationStrip extends StatefulWidget {
  const _StationStrip({
    required this.count,
    required this.current,
    required this.nodeAt,
    required this.reached,
  });

  /// عدد المحطات (تُضاف بعدها كأس نهاية الدرس).
  final int count;
  final int current;
  final Widget Function(int index) nodeAt;

  /// هل وصل الطالب إلى المحطة (منجزة أو حالية) لتلوين الخط قبلها.
  final bool Function(int index) reached;

  static const itemWidth = 98.0;
  static const slotHeight = 144.0;
  static const pad = 12.0;

  /// مسافة التأرجح من كل جانب.
  static const sway = 10.0;

  /// مركز المربع من أعلى الخانة: فقاعة «ابدأ» ٣٤ + نصف المربع مع حافته.
  static const nodeCenter = 34 + 40.0;

  @override
  State<_StationStrip> createState() => _StationStripState();
}

class _StationStripState extends State<_StationStrip>
    with SingleTickerProviderStateMixin {
  final _scroll = ScrollController();
  int? _scrolledTo;

  late final _sway = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  );

  /// يتوقف التأرجح نهائيًا بعد أول سحب من الطالب.
  bool _dragged = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncSway();
  }

  void _syncSway() {
    if (!_dragged && !MediaQuery.disableAnimationsOf(context)) {
      if (!_sway.isAnimating) _sway.repeat(reverse: true);
    } else {
      _sway.stop();
      _sway.value = 0.5;
    }
  }

  bool _onScroll(ScrollStartNotification n) {
    if (n.dragDetails != null && !_dragged) {
      _dragged = true;
      _syncSway();
    }
    return false;
  }

  @override
  void dispose() {
    _sway.dispose();
    _scroll.dispose();
    super.dispose();
  }

  /// إظهار المحطة الحالية في منتصف الشريط.
  void _revealCurrent() {
    final target = widget.current == -1 ? widget.count : widget.current;
    if (_scrolledTo == target || !_scroll.hasClients) return;
    _scrolledTo = target;
    final viewport = _scroll.position.viewportDimension;
    final offset =
        _StationStrip.pad +
        target * _StationStrip.itemWidth -
        (viewport - _StationStrip.itemWidth) / 2;
    _scroll.jumpTo(offset.clamp(0.0, _scroll.position.maxScrollExtent));
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _revealCurrent());
    final items = widget.count + 1;
    final width = _StationStrip.pad * 2 + items * _StationStrip.itemWidth;
    const height = _StationStrip.slotHeight + 8;
    final rtl = Directionality.of(context) == TextDirection.rtl;

    final centers = [
      for (var i = 0; i < items; i++)
        Offset(() {
          final fromStart =
              _StationStrip.pad +
              i * _StationStrip.itemWidth +
              _StationStrip.itemWidth / 2;
          return rtl ? width - fromStart : fromStart;
        }(), _StationStrip.nodeCenter),
    ];

    return NotificationListener<ScrollStartNotification>(
      onNotification: _onScroll,
      child: SingleChildScrollView(
        controller: _scroll,
        scrollDirection: Axis.horizontal,
        child: AnimatedBuilder(
          animation: _sway,
          builder: (context, child) => Transform.translate(
            offset: Offset(
              _StationStrip.sway *
                  (2 * Curves.easeInOut.transform(_sway.value) - 1),
              0,
            ),
            child: child,
          ),
          child: SizedBox(
            width: width,
            height: height,
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _ConnectorPainter(
                      centers: centers,
                      reached: [
                        for (var i = 0; i < items; i++) widget.reached(i),
                      ],
                    ),
                  ),
                ),
                for (var i = 0; i < items; i++)
                  PositionedDirectional(
                    start: _StationStrip.pad + i * _StationStrip.itemWidth,
                    top: 0,
                    width: _StationStrip.itemWidth,
                    height: _StationStrip.slotHeight,
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: widget.nodeAt(i),
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

class _ConnectorPainter extends CustomPainter {
  _ConnectorPainter({required this.centers, required this.reached});
  final List<Offset> centers;
  final List<bool> reached;

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i < centers.length - 1; i++) {
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round
        ..color = reached[i + 1] ? AppColors.sand : AppColors.locked;
      canvas.drawLine(centers[i], centers[i + 1], paint);
    }
  }

  @override
  bool shouldRepaint(_ConnectorPainter old) =>
      old.centers != centers || old.reached.toString() != reached.toString();
}

/// بطاقة القلم وزر البدء.
class _NextUp extends StatelessWidget {
  const _NextUp({
    required this.finished,
    required this.started,
    required this.onTap,
  });

  final bool finished;
  final bool started;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.line, width: 2),
      ),
      child: Row(
        children: [
          Mascot(
            size: 84,
            mood: finished ? MascotMood.happy : MascotMood.thinking,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (finished) ...[
                  Text(
                    'أحسنت! أتممت الدرس 🎉',
                    style: t.labelLarge?.copyWith(color: AppColors.muted),
                  ),
                  const SizedBox(height: 10),
                ],
                AppButton(
                  label: finished
                      ? 'أعد الدرس'
                      : started
                      ? 'تابع'
                      : 'ابدأ الآن',
                  icon: finished
                      ? Icons.replay_rounded
                      : Icons.play_arrow_rounded,
                  height: 46,
                  onTap: onTap,
                ),
              ],
            ),
          ),
        ],
      ),
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
    required this.title,
    required this.done,
    required this.total,
    required this.onGuide,
  });

  final String title;
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
                    'الدرس ١',
                    style: t.labelLarge?.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    // لا تنقسم كلمات العنوان مع خط الجهاز الكبير جدًا.
                    textScaler: MediaQuery.textScalerOf(
                      context,
                    ).clamp(maxScaleFactor: 1.5),
                    style: t.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Semantics(
                    label: '${arDigits(done)} من ${arDigits(total)}',
                    child: ChunkyProgress(
                      value: done / total,
                      height: 12,
                      color: AppColors.sand,
                      track: Colors.white.withValues(alpha: 0.22),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Tooltip(
              message: 'القاعدة',
              child: Pressable(
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
            ),
          ],
        ),
      ),
    );
  }
}

enum _NodeState { done, current, locked }

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
    const size = 68.0;

    final node = Pressable(
      onTap: widget.onTap,
      color: color,
      edgeColor: edge,
      radius: 18,
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
              height: 34,
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
              width: size + 12,
              height: size + 12,
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
                          width: size + 8 + 12 * v,
                          height: size + 8 + 12 * v,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(22 + 4 * v),
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

/// بطاقة وحدة: مقفلة «قريبًا»، أو مفتوحة ([onTap]) تعرض محطات الدرس.
class _UnitCard extends StatelessWidget {
  const _UnitCard({
    super.key,
    required this.number,
    required this.title,
    this.onTap,
  });
  final int number;
  final String title;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final open = onTap != null;
    final card = Container(
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
            decoration: BoxDecoration(
              color: open ? AppColors.primarySoft : AppColors.locked,
              shape: BoxShape.circle,
            ),
            child: Icon(
              open ? Icons.lock_open_rounded : Icons.lock_rounded,
              color: open ? AppColors.primary : AppColors.muted,
            ),
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
                    color: open ? AppColors.ink : AppColors.muted,
                  ),
                ),
              ],
            ),
          ),
          if (open)
            // يُعكس في الكتابة من اليمين فيشير إلى الأمام.
            const Icon(Icons.chevron_right_rounded, color: AppColors.muted)
          else
            Text(
              'قريبًا',
              style: t.labelLarge?.copyWith(
                color: AppColors.sandDark,
                fontWeight: FontWeight.w800,
              ),
            ),
        ],
      ),
    );
    return Padding(
      padding: EdgeInsets.only(bottom: open ? 0 : 12),
      child: open
          ? Semantics(
              button: true,
              child: GestureDetector(onTap: onTap, child: card),
            )
          : card,
    );
  }
}
