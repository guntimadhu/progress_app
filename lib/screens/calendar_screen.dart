import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/reminder.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen>
    with AutomaticKeepAliveClientMixin {
  late DateTime _month;
  DateTime? _selectedDay;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _month = DateTime(DateTime.now().year, DateTime.now().month);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Consumer<AppProvider>(
      builder: (ctx, p, _) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('📅 CALENDAR',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5)),
            const SizedBox(height: 14),

            // Month navigation
            Row(
              children: [
                _NavBtn('←', () => setState(() => _month =
                    DateTime(_month.year, _month.month - 1))),
                Expanded(
                  child: Text(
                    DateFormat('MMM yyyy').format(_month).toUpperCase(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                ),
                _NavBtn('→', () => setState(() => _month =
                    DateTime(_month.year, _month.month + 1))),
              ],
            ),
            const SizedBox(height: 10),

            // Day labels
            Row(
              children: ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa']
                  .map((d) => Expanded(
                        child: Center(
                          child: Text(d,
                              style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.muted)),
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 6),

            // Calendar grid
            _CalendarGrid(
              month: _month,
              provider: p,
              selectedDay: _selectedDay,
              onDayTap: (d) => setState(() => _selectedDay = d),
            ),

            // Day panel
            if (_selectedDay != null) ...[
              const SizedBox(height: 16),
              _DayPanel(
                date: _selectedDay!,
                provider: p,
                onClose: () => setState(() => _selectedDay = null),
              ),
            ],

            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('🔔 REMINDERS',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5)),
                ElevatedButton(
                  onPressed: () => _showAddReminder(context, p),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8)),
                  child: const Text('+ Add Reminder',
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Reminders list
            if (p.reminders.isEmpty)
              const Padding(
                padding: EdgeInsets.all(20),
                child: Center(
                  child: Text('🔔 No reminders yet',
                      style: TextStyle(color: AppColors.muted)),
                ),
              )
            else
              ...p.reminders.map((r) => _ReminderItem(
                    r: r,
                    onDelete: () => p.deleteReminder(r.id),
                  )),
          ],
        );
      },
    );
  }

  void _showAddReminder(BuildContext ctx, AppProvider p) {
    showDialog(
      context: ctx,
      builder: (_) => _AddReminderDialog(provider: p),
    );
  }
}

class _NavBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _NavBtn(this.label, this.onTap);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }
}

class _CalendarGrid extends StatelessWidget {
  final DateTime month;
  final AppProvider provider;
  final DateTime? selectedDay;
  final ValueChanged<DateTime> onDayTap;

  const _CalendarGrid({
    required this.month,
    required this.provider,
    required this.selectedDay,
    required this.onDayTap,
  });

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime(month.year, month.month, 1);
    final daysInMonth = DateUtils.getDaysInMonth(month.year, month.month);
    final startWeekday = firstDay.weekday % 7; // Sun=0
    final today = DateTime.now();

    final cells = <Widget>[];
    for (int i = 0; i < startWeekday; i++) {
      cells.add(const SizedBox());
    }
    for (int d = 1; d <= daysInMonth; d++) {
      final date = DateTime(month.year, month.month, d);
      final dk = AppProvider.dateKey(date);
      final instances =
          provider.allTasks.where((t) => t.date == dk && t.isInstance).toList();
      final total = instances.length;
      final done = instances.where((t) => t.done).length;
      final isToday = DateUtils.isSameDay(date, today);
      final isSelected = selectedDay != null && DateUtils.isSameDay(date, selectedDay!);

      cells.add(_CalDay(
        day: d,
        total: total,
        done: done,
        isToday: isToday,
        isSelected: isSelected,
        onTap: () => onDayTap(date),
      ));
    }

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 7,
      mainAxisSpacing: 5,
      crossAxisSpacing: 5,
      children: cells,
    );
  }
}

class _CalDay extends StatelessWidget {
  final int day, total, done;
  final bool isToday, isSelected;
  final VoidCallback onTap;

  const _CalDay({
    required this.day,
    required this.total,
    required this.done,
    required this.isToday,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color? bgColor;
    Color textColor = Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black;
    Border? border;

    if (total > 0) {
      if (done == total) {
        // All done - green
        bgColor = AppColors.success;
        textColor = Colors.white;
      } else if (done > 0) {
        // Partial - orange
        bgColor = AppColors.warning;
        textColor = Colors.white;
      } else {
        // None done - red border
        border = Border.all(color: AppColors.danger, width: 2);
        bgColor = Colors.white;
      }
    } else {
      bgColor = Colors.white;
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: bgColor,
          border: border ??
              (isToday
                  ? Border.all(color: AppColors.primary, width: 2)
                  : isSelected
                      ? Border.all(color: AppColors.secondary, width: 2)
                      : null),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 4,
                offset: const Offset(0, 1))
          ],
        ),
        child: Center(
          child: Text(
            '$day',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isToday && bgColor == Colors.white
                  ? AppColors.primary
                  : textColor,
            ),
          ),
        ),
      ),
    );
  }
}

class _DayPanel extends StatelessWidget {
  final DateTime date;
  final AppProvider provider;
  final VoidCallback onClose;

  const _DayPanel(
      {required this.date,
      required this.provider,
      required this.onClose});

  @override
  Widget build(BuildContext context) {
    final dk = AppProvider.dateKey(date);
    var tasks =
        provider.allTasks.where((t) => t.date == dk && t.isInstance).toList();

    // If no stored instances, show virtual tasks for future dates
    if (tasks.isEmpty) {
      tasks = provider.getVirtualTasksForDate(date);
    }
    tasks.sort((a, b) => a.time.compareTo(b.time));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                DateFormat('EEEE, MMM d, yyyy').format(date),
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w700),
              ),
            ),
            IconButton(
              onPressed: onClose,
              icon: const Icon(Icons.close, size: 18),
            ),
          ],
        ),
        if (tasks.isEmpty)
          const Padding(
            padding: EdgeInsets.all(12),
            child: Text('📭 No tasks this day',
                style: TextStyle(color: AppColors.muted, fontSize: 13)),
          )
        else
          ...tasks.map((t) {
            final isVirtual = t.id.startsWith('virtual_');
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border(
                    left: BorderSide(color: AppColors.primary, width: 4)),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 6,
                      offset: const Offset(0, 2))
                ],
              ),
              child: Row(
                children: [
                  Text(AppProvider.to12(t.time),
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                          fontSize: 11)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${t.category == 'personal' ? '👤' : '💼'} ${t.name}',
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 3),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                              color: AppColors.secondary,
                              borderRadius: BorderRadius.circular(10)),
                          child: Text(t.recurring,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 9)),
                        ),
                      ],
                    ),
                  ),
                  if (!isVirtual)
                    GestureDetector(
                      onTap: () => provider.toggleTask(t.id),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: t.done ? AppColors.gradient : null,
                          border: Border.all(
                              color: AppColors.primary, width: 2.5),
                        ),
                        child: t.done
                            ? const Icon(Icons.check,
                                color: Colors.white, size: 16)
                            : null,
                      ),
                    )
                  else
                    const SizedBox(width: 28),
                ],
              ),
            );
          }),
      ],
    );
  }
}

class _ReminderItem extends StatelessWidget {
  final Reminder r;
  final VoidCallback onDelete;
  const _ReminderItem({required this.r, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: const Border(
            left: BorderSide(color: AppColors.primary, width: 4)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(r.msg,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 13)),
                Text('${r.date} at ${AppProvider.to12(r.time)}',
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.muted)),
              ],
            ),
          ),
          TextButton(
            onPressed: onDelete,
            style: TextButton.styleFrom(
                foregroundColor: AppColors.danger,
                padding: const EdgeInsets.symmetric(horizontal: 8)),
            child: const Text('Delete', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }
}

class _AddReminderDialog extends StatefulWidget {
  final AppProvider provider;
  const _AddReminderDialog({required this.provider});

  @override
  State<_AddReminderDialog> createState() => _AddReminderDialogState();
}

class _AddReminderDialogState extends State<_AddReminderDialog> {
  DateTime _date = DateTime.now();
  int _hour = 8;
  int _minute = 0;
  String _period = 'AM';
  final _msgCtrl = TextEditingController();

  @override
  void dispose() {
    _msgCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (_msgCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('⚠️ Enter a message')));
      return;
    }
    if (_date.isBefore(DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day))) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('⚠️ Select today or later')));
      return;
    }
    final r = Reminder(
      id: 'r_${DateTime.now().millisecondsSinceEpoch}',
      date: AppProvider.dateKey(_date),
      time: AppProvider.to24(_hour, _minute, _period),
      msg: _msgCtrl.text.trim(),
    );
    widget.provider.addReminder(r);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('🔔 Add Reminder'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Text(DateFormat('yyyy-MM-dd').format(_date)),
            leading: const Icon(Icons.calendar_today),
            contentPadding: EdgeInsets.zero,
            onTap: () async {
              final d = await showDatePicker(
                context: context,
                initialDate: _date,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (d != null) setState(() => _date = d);
            },
          ),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<int>(
                  value: _hour,
                  items: List.generate(12, (i) => i + 1)
                      .map((h) => DropdownMenuItem(value: h, child: Text('$h')))
                      .toList(),
                  onChanged: (v) => setState(() => _hour = v!),
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(), labelText: 'HH'),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: DropdownButtonFormField<int>(
                  value: _minute,
                  items: [0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55]
                      .map((m) => DropdownMenuItem(
                          value: m, child: Text(m.toString().padLeft(2, '0'))))
                      .toList(),
                  onChanged: (v) => setState(() => _minute = v!),
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(), labelText: 'MM'),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _period,
                  items: const [
                    DropdownMenuItem(value: 'AM', child: Text('AM')),
                    DropdownMenuItem(value: 'PM', child: Text('PM')),
                  ],
                  onChanged: (v) => setState(() => _period = v!),
                  decoration: const InputDecoration(
                      border: OutlineInputBorder()),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _msgCtrl,
            decoration: const InputDecoration(
                hintText: 'Reminder message',
                border: OutlineInputBorder()),
          ),
        ],
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel')),
        ElevatedButton(
            onPressed: _save,
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white),
            child: const Text('Save')),
      ],
    );
  }
}
