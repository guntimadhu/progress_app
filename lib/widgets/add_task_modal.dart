import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';

void showAddTaskModal(BuildContext context, {Task? editTask}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => AddTaskModal(editTask: editTask),
  );
}

class AddTaskModal extends StatefulWidget {
  final Task? editTask;
  const AddTaskModal({super.key, this.editTask});

  @override
  State<AddTaskModal> createState() => _AddTaskModalState();
}

class _AddTaskModalState extends State<AddTaskModal> {
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String _category = 'personal';
  String _recurring = 'once';
  int _hour = 8;
  int _minute = 0;
  String _period = 'AM';
  int _duration = 30;
  String? _recurEndDate;
  int _intervalDays = 2;
  final Set<String> _selectedDays = {};
  final Set<int> _selectedDates = {};

  static const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  void initState() {
    super.initState();
    final t = widget.editTask;
    if (t != null) {
      _nameCtrl.text = t.name;
      _descCtrl.text = t.desc;
      _category = t.category;
      _recurring = t.recurring;
      _duration = t.duration;
      _recurEndDate = t.recurEndDate;
      _intervalDays = t.intervalDays ?? 2;
      if (t.days != null) _selectedDays.addAll(t.days!);
      if (t.dates != null) _selectedDates.addAll(t.dates!);
      final parts = t.time.split(':');
      int h = int.parse(parts[0]);
      _period = h >= 12 ? 'PM' : 'AM';
      h = h % 12 == 0 ? 12 : h % 12;
      _hour = h;
      _minute = (int.parse(parts[1]) / 5).round() * 5;
      if (_minute >= 60) _minute = 55;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('⚠️ Enter task name')));
      return;
    }
    final time = AppProvider.to24(_hour, _minute, _period);
    final provider = context.read<AppProvider>();

    if (widget.editTask != null) {
      final updated = widget.editTask!.copyWith(
        name: name,
        desc: _descCtrl.text.trim(),
        time: time,
        duration: _duration,
        category: _category,
        recurring: _recurring,
        days: _selectedDays.isNotEmpty ? _selectedDays.toList() : null,
        dates: _selectedDates.isNotEmpty
            ? (_selectedDates.toList()..sort())
            : null,
        intervalDays: _intervalDays,
        recurEndDate: _recurEndDate,
      );
      provider.updateTask(updated);
    } else {
      final id = 't_${DateTime.now().millisecondsSinceEpoch}';
      final t = Task(
        id: id,
        isInstance: false,
        name: name,
        desc: _descCtrl.text.trim(),
        time: time,
        duration: _duration,
        category: _category,
        priority: 'medium',
        recurring: _recurring,
        days: _selectedDays.isNotEmpty ? _selectedDays.toList() : null,
        dates: _selectedDates.isNotEmpty
            ? (_selectedDates.toList()..sort())
            : null,
        intervalDays: _intervalDays,
        recurEndDate: _recurEndDate,
        date: AppProvider.todayKey(),
        done: false,
      );
      provider.addTask(t);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkCard : Colors.white;

    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize: 0.5,
      maxChildSize: 0.97,
      builder: (_, ctrl) => Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.editTask != null ? '✏️ Edit Task' : '➕ Add Task',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                controller: ctrl,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                children: [
                  _section('Category'),
                  _dropdown(
                    value: _category,
                    items: const {'personal': '👤 Personal', 'professional': '💼 Professional'},
                    onChanged: (v) => setState(() => _category = v!),
                  ),
                  _section('Recurring'),
                  _dropdown(
                    value: _recurring,
                    items: const {
                      'once': 'Once (Today)',
                      'daily': 'Daily',
                      'weekday': 'Weekdays (Mon–Fri)',
                      'weekend': 'Weekends (Sat–Sun)',
                      'weekly': 'Weekly — Select Days',
                      'monthly': 'Monthly — Select Dates',
                      'interval': 'Every X Days',
                    },
                    onChanged: (v) => setState(() => _recurring = v!),
                  ),
                  if (_recurring != 'once') ...[
                    if (_recurring == 'weekly') ...[
                      _section('Days of Week'),
                      Wrap(
                        spacing: 6,
                        children: _days.map((d) {
                          final sel = _selectedDays.contains(d);
                          return GestureDetector(
                            onTap: () => setState(() => sel
                                ? _selectedDays.remove(d)
                                : _selectedDays.add(d)),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              margin: const EdgeInsets.only(bottom: 6),
                              decoration: BoxDecoration(
                                gradient: sel ? AppColors.gradient : null,
                                border: Border.all(
                                    color: sel
                                        ? AppColors.primary
                                        : AppColors.border,
                                    width: 2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(d,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                      color: sel ? Colors.white : null)),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                    if (_recurring == 'monthly') ...[
                      _section('Dates of Month'),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 7,
                                crossAxisSpacing: 4,
                                mainAxisSpacing: 4),
                        itemCount: 31,
                        itemBuilder: (_, i) {
                          final d = i + 1;
                          final sel = _selectedDates.contains(d);
                          return GestureDetector(
                            onTap: () => setState(() => sel
                                ? _selectedDates.remove(d)
                                : _selectedDates.add(d)),
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                gradient: sel ? AppColors.gradient : null,
                                border: Border.all(
                                    color: sel
                                        ? AppColors.primary
                                        : AppColors.border),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text('$d',
                                  style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: sel ? Colors.white : null)),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                    ],
                    if (_recurring == 'interval') ...[
                      _section('Every how many days?'),
                      TextFormField(
                        initialValue: '$_intervalDays',
                        keyboardType: TextInputType.number,
                        onChanged: (v) =>
                            _intervalDays = int.tryParse(v) ?? 2,
                        decoration: const InputDecoration(
                            hintText: 'e.g. 3', border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 8),
                    ],
                    _section('End Date (optional)'),
                    InkWell(
                      onTap: () async {
                        final d = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now()
                              .add(const Duration(days: 365 * 3)),
                        );
                        if (d != null) {
                          setState(() =>
                              _recurEndDate = AppProvider.dateKey(d));
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.border, width: 2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 16),
                            const SizedBox(width: 8),
                            Text(_recurEndDate ?? 'No end date'),
                            const Spacer(),
                            if (_recurEndDate != null)
                              GestureDetector(
                                onTap: () =>
                                    setState(() => _recurEndDate = null),
                                child: const Icon(Icons.clear, size: 16),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  _section('Time'),
                  Row(
                    children: [
                      Expanded(child: _numDropdown(
                        value: _hour,
                        values: List.generate(12, (i) => i + 1),
                        label: 'Hour',
                        onChanged: (v) => setState(() => _hour = v!),
                      )),
                      const SizedBox(width: 8),
                      Expanded(child: _numDropdown(
                        value: _minute,
                        values: [0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55],
                        label: 'Min',
                        display: (v) => v.toString().padLeft(2, '0'),
                        onChanged: (v) => setState(() => _minute = v!),
                      )),
                      const SizedBox(width: 8),
                      Expanded(child: DropdownButtonFormField<String>(
                        value: _period,
                        items: const [
                          DropdownMenuItem(value: 'AM', child: Text('AM')),
                          DropdownMenuItem(value: 'PM', child: Text('PM')),
                        ],
                        onChanged: (v) => setState(() => _period = v!),
                        decoration: const InputDecoration(
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          border: OutlineInputBorder(),
                        ),
                      )),
                    ],
                  ),
                  _section('Duration (minutes)'),
                  TextFormField(
                    initialValue: '$_duration',
                    keyboardType: TextInputType.number,
                    onChanged: (v) => _duration = int.tryParse(v) ?? 30,
                    decoration: const InputDecoration(
                        hintText: '30', border: OutlineInputBorder()),
                  ),
                  _section('Task Name'),
                  TextField(
                    controller: _nameCtrl,
                    decoration: const InputDecoration(
                        hintText: 'Task name',
                        border: OutlineInputBorder()),
                  ),
                  _section('Description'),
                  TextField(
                    controller: _descCtrl,
                    maxLines: 2,
                    decoration: const InputDecoration(
                        hintText: 'Notes…', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Save',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _section(String label) => Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 6),
        child: Text(
          label.toUpperCase(),
          style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.muted,
              letterSpacing: 0.5),
        ),
      );

  Widget _dropdown({
    required String value,
    required Map<String, String> items,
    required ValueChanged<String?> onChanged,
  }) =>
      DropdownButtonFormField<String>(
        value: value,
        items: items.entries
            .map((e) =>
                DropdownMenuItem(value: e.key, child: Text(e.value)))
            .toList(),
        onChanged: onChanged,
        decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 14, vertical: 12)),
      );

  Widget _numDropdown({
    required int value,
    required List<int> values,
    required String label,
    required ValueChanged<int?> onChanged,
    String Function(int)? display,
  }) =>
      DropdownButtonFormField<int>(
        value: values.contains(value) ? value : values.first,
        hint: Text(label),
        items: values
            .map((v) => DropdownMenuItem(
                value: v,
                child: Text(display != null ? display(v) : '$v')))
            .toList(),
        onChanged: onChanged,
        decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 12, vertical: 12)),
      );
}
