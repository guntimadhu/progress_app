import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/add_task_modal.dart';
import '../widgets/streak_modal.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  String _filter = 'all';
  String _sort = 'time';
  final _searchCtrl = TextEditingController();
  bool _showUndo = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _deleteTask(BuildContext ctx, String id, AppProvider p) {
    p.deleteTask(id);
    setState(() => _showUndo = true);
    Future.delayed(const Duration(seconds: 7), () {
      if (mounted) setState(() => _showUndo = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Consumer<AppProvider>(
      builder: (ctx, p, _) {
        final pct = p.todayPct;
        final streak = p.calcStreak();
        final focus = p.focusTask;
        final tasks = p.getTodayTasks(
          filter: _filter,
          sort: _sort,
          search: _searchCtrl.text,
        );

        return Stack(
          children: [
            ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Progress Card
                _ProgressCard(
                  pct: pct,
                  personalDone: p.todayPersonalDone,
                  personalTotal: p.todayPersonalTotal,
                  proDone: p.todayProfessionalDone,
                  proTotal: p.todayProfessionalTotal,
                  streak: streak,
                  onStreakTap: () => showStreakModal(context),
                  streakLevel: p.getStreakLevel(streak),
                ),
                const SizedBox(height: 12),

                // Focus Banner
                if (focus != null)
                  _FocusBanner(task: focus),

                const SizedBox(height: 12),

                // Search + Sort
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchCtrl,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: '🔍 Search tasks…',
                          hintStyle: const TextStyle(fontSize: 13),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24)),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: const BorderSide(color: AppColors.border, width: 2),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          isDense: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    DropdownButton<String>(
                      value: _sort,
                      underline: const SizedBox(),
                      borderRadius: BorderRadius.circular(10),
                      items: const [
                        DropdownMenuItem(value: 'time', child: Text('⏰ Time', style: TextStyle(fontSize: 12))),
                        DropdownMenuItem(value: 'pending', child: Text('⏳ Pending', style: TextStyle(fontSize: 12))),
                        DropdownMenuItem(value: 'done', child: Text('✅ Done', style: TextStyle(fontSize: 12))),
                      ],
                      onChanged: (v) => setState(() => _sort = v!),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Filter chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _Chip('📋 All', 'all', _filter, (f) => setState(() => _filter = f)),
                      _Chip('👤 Personal', 'personal', _filter, (f) => setState(() => _filter = f)),
                      _Chip('💼 Professional', 'professional', _filter, (f) => setState(() => _filter = f)),
                      _Chip('⏳ Pending', 'pending', _filter, (f) => setState(() => _filter = f)),
                      _Chip('✅ Done', 'completed', _filter, (f) => setState(() => _filter = f)),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Task list
                if (tasks.isEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: const Column(
                      children: [
                        Text('📭', style: TextStyle(fontSize: 36)),
                        SizedBox(height: 8),
                        Text('No tasks today',
                            style: TextStyle(color: AppColors.muted, fontSize: 15)),
                        SizedBox(height: 4),
                        Text('Tap + to add your first task',
                            style: TextStyle(color: AppColors.muted, fontSize: 12)),
                      ],
                    ),
                  )
                else
                  ...tasks.map((t) => _TaskItem(
                        task: t,
                        onToggle: () => p.toggleTask(t.id),
                        onEdit: () {
                          final tmpl = p.allTasks.firstWhere(
                            (x) => !x.isInstance && x.id == (t.baseId ?? t.id),
                            orElse: () => t,
                          );
                          showAddTaskModal(context, editTask: tmpl);
                        },
                        onDelete: () => _deleteTask(context, t.baseId ?? t.id, p),
                      )),
                const SizedBox(height: 80),
              ],
            ),

            // Undo toast
            if (_showUndo)
              Positioned(
                bottom: 90,
                left: 16,
                right: 16,
                child: _UndoToast(
                  onUndo: () {
                    p.undoDelete();
                    setState(() => _showUndo = false);
                  },
                  onDismiss: () => setState(() => _showUndo = false),
                ),
              ),
          ],
        );
      },
    );
  }
}

// ── Progress Circle ───────────────────────────────────────────────────────────

class _ProgressCard extends StatelessWidget {
  final double pct;
  final int personalDone, personalTotal, proDone, proTotal, streak;
  final VoidCallback onStreakTap;
  final Map<String, dynamic> streakLevel;

  const _ProgressCard({
    required this.pct,
    required this.personalDone,
    required this.personalTotal,
    required this.proDone,
    required this.proTotal,
    required this.streak,
    required this.onStreakTap,
    required this.streakLevel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.gradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'TODAY',
            style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.85),
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5),
          ),
          const SizedBox(height: 6),
          _AnimatedProgressCircle(pct: pct),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: _StatPill(
                    '👤 $personalDone/$personalTotal'),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatPill('💼 $proDone/$proTotal'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: onStreakTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${streakLevel['emoji']} $streak day streak',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedProgressCircle extends StatefulWidget {
  final double pct;
  const _AnimatedProgressCircle({required this.pct});

  @override
  State<_AnimatedProgressCircle> createState() =>
      _AnimatedProgressCircleState();
}

class _AnimatedProgressCircleState extends State<_AnimatedProgressCircle>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _anim = Tween<double>(begin: 0, end: widget.pct)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));
    _ctrl.forward();
  }

  @override
  void didUpdateWidget(_AnimatedProgressCircle old) {
    super.didUpdateWidget(old);
    _anim = Tween<double>(begin: _anim.value, end: widget.pct)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));
    _ctrl
      ..reset()
      ..forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => SizedBox(
        width: 120,
        height: 120,
        child: CustomPaint(
          painter: _CirclePainter(_anim.value),
          child: Center(
            child: Text(
              '${(_anim.value * 100).round()}%',
              style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0f172a)),
            ),
          ),
        ),
      ),
    );
  }
}

class _CirclePainter extends CustomPainter {
  final double pct;
  _CirclePainter(this.pct);

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2 - 6;
    final bg = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;
    final fg = Paint()
      ..color = const Color(0xFFfbbf24)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(c, r, bg);
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r),
      -math.pi / 2,
      2 * math.pi * pct,
      false,
      fg,
    );
  }

  @override
  bool shouldRepaint(_CirclePainter old) => old.pct != pct;
}

class _StatPill extends StatelessWidget {
  final String text;
  const _StatPill(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(text,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600)),
      ),
    );
  }
}

class _FocusBanner extends StatelessWidget {
  final Task task;
  const _FocusBanner({required this.task});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [Color(0xFFf59e0b), Color(0xFFef4444)]),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFef4444).withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Text('🎯', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Focus Task',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 13)),
                Text(task.name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12)),
              ],
            ),
          ),
          Text(AppProvider.to12(task.time),
              style: const TextStyle(
                  color: Colors.white, fontSize: 11)),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final String value;
  final String current;
  final ValueChanged<String> onTap;

  const _Chip(this.label, this.value, this.current, this.onTap);

  @override
  Widget build(BuildContext context) {
    final active = current == value;
    return GestureDetector(
      onTap: () => onTap(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          gradient: active ? AppColors.gradient : null,
          border: Border.all(
              color: active ? AppColors.primary : AppColors.border,
              width: 1.5),
          borderRadius: BorderRadius.circular(20),
          color: active ? null : Theme.of(context).cardColor,
        ),
        child: Text(
          label,
          style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: active ? Colors.white : AppColors.muted),
        ),
      ),
    );
  }
}

class _TaskItem extends StatelessWidget {
  final Task task;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _TaskItem({
    required this.task,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final nowMin = now.hour * 60 + now.minute;
    final parts = task.time.split(':');
    final taskMin = int.parse(parts[0]) * 60 + int.parse(parts[1]);
    final isOverdue = !task.done && taskMin < nowMin;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedSlide(
      offset: Offset.zero,
      duration: const Duration(milliseconds: 300),
      child: Container(
        margin: const EdgeInsets.only(bottom: 9),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border(
            left: BorderSide(
              color: isOverdue ? AppColors.danger : AppColors.primary,
              width: 4,
            ),
          ),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ],
        ),
        child: Opacity(
          opacity: task.done ? 0.55 : 1,
          child: Padding(
            padding: const EdgeInsets.all(13),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 66,
                  child: Text(
                    AppProvider.to12(task.time),
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                        fontSize: 12),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_catIcon(task.category)} ${task.name}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          decoration:
                              task.done ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      if (task.desc.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(task.desc,
                            style: const TextStyle(
                                fontSize: 11, color: AppColors.muted)),
                      ],
                      const SizedBox(height: 5),
                      Wrap(
                        spacing: 4,
                        children: [
                          _Badge(task.recurring, AppColors.secondary),
                          if (isOverdue) _Badge('Overdue', AppColors.danger),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Checkbox
                GestureDetector(
                  onTap: onToggle,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 350),
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: AppColors.primary, width: 2.5),
                      gradient: task.done ? AppColors.gradient : null,
                      color: task.done ? null : (isDark ? AppColors.darkCard : Colors.white),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 6)
                      ],
                    ),
                    child: task.done
                        ? const Icon(Icons.check,
                            color: Colors.white, size: 18)
                        : null,
                  ),
                ),
                const SizedBox(width: 4),
                Column(
                  children: [
                    IconButton(
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(3),
                      icon: const Text('✏️', style: TextStyle(fontSize: 15)),
                      onPressed: onEdit,
                    ),
                    IconButton(
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(3),
                      icon: const Text('🗑️', style: TextStyle(fontSize: 15)),
                      onPressed: onDelete,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _catIcon(String cat) =>
      cat == 'personal' ? '👤' : cat == 'professional' ? '💼' : '📌';
}

class _Badge extends StatelessWidget {
  final String text;
  final Color color;
  const _Badge(this.text, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(text,
          style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w600)),
    );
  }
}

class _UndoToast extends StatelessWidget {
  final VoidCallback onUndo;
  final VoidCallback onDismiss;
  const _UndoToast({required this.onUndo, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1e293b),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8))
        ],
      ),
      child: Row(
        children: [
          const Text('Task deleted',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13)),
          const Spacer(),
          TextButton(
            onPressed: onUndo,
            style: TextButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Undo',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 12)),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onDismiss,
            child: const Icon(Icons.close, color: Colors.white54, size: 16),
          ),
        ],
      ),
    );
  }
}

