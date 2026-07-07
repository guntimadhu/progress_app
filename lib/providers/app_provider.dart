import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../models/reminder.dart';
import '../services/notification_service.dart';

class AppInsight {
  final String icon;
  final String text;
  AppInsight(this.icon, this.text);
}

class AppProvider extends ChangeNotifier {
  List<Task> _tasks = [];
  List<Reminder> _reminders = [];

  String profileName = '';
  String profileDob = '';
  String profileEmail = 'guest@progress.app';

  bool darkMode = false;
  bool notifEnabled = true;
  bool soundEnabled = true;
  bool isGuest = true;

  String taskFilter = 'all'; // all/personal/professional/pending/completed
  String statsPeriod = 'weekly';
  String? lastMidnight;
  String? startDate;

  final _player = AudioPlayer();

  ThemeMode get themeMode => darkMode ? ThemeMode.dark : ThemeMode.light;

  List<Task> get allTasks => _tasks;
  List<Reminder> get reminders => _reminders;

  List<Task> get templates => _tasks.where((t) => !t.isInstance).toList();

  // ── Helpers ──────────────────────────────────────────────────────────────

  static String dateKey(DateTime d) => DateFormat('yyyy-MM-dd').format(d);
  static String todayKey() => dateKey(DateTime.now());

  static String pad(int n) => n.toString().padLeft(2, '0');

  static String to12(String time24) {
    final parts = time24.split(':');
    int h = int.parse(parts[0]);
    final m = parts[1];
    final ap = h >= 12 ? 'PM' : 'AM';
    h = h % 12 == 0 ? 12 : h % 12;
    return '${pad(h)}:$m $ap';
  }

  static String to24(int hour, int minute, String period) {
    int h = hour;
    if (period == 'PM' && h != 12) h += 12;
    if (period == 'AM' && h == 12) h = 0;
    return '${pad(h)}:${pad(minute)}';
  }

  // ── Init / Load / Save ───────────────────────────────────────────────────

  Future<void> init() async {
    await _load();
    startDate ??= DateTime.now().toIso8601String();
    final box = Hive.box<dynamic>('settings');
    box.put('startDate', startDate);
    checkMidnight();
    notifyListeners();
  }

  Future<void> _load() async {
    final tasksBox = Hive.box<dynamic>('tasks');
    final remBox = Hive.box<dynamic>('reminders');
    final settBox = Hive.box<dynamic>('settings');

    _tasks = tasksBox.values
        .map((v) => Task.fromMap(v as Map<dynamic, dynamic>))
        .toList();
    _reminders = remBox.values
        .map((v) => Reminder.fromMap(v as Map<dynamic, dynamic>))
        .toList();

    darkMode = settBox.get('darkMode', defaultValue: false) as bool;
    notifEnabled = settBox.get('notifEnabled', defaultValue: true) as bool;
    soundEnabled = settBox.get('soundEnabled', defaultValue: true) as bool;
    profileName = settBox.get('profileName', defaultValue: '') as String;
    profileDob = settBox.get('profileDob', defaultValue: '') as String;
    profileEmail = settBox.get('profileEmail',
        defaultValue: 'guest@progress.app') as String;
    isGuest = settBox.get('isGuest', defaultValue: true) as bool;
    lastMidnight = settBox.get('lastMidnight') as String?;
    startDate = settBox.get('startDate') as String?;
  }

  void _saveTasks() {
    final box = Hive.box<dynamic>('tasks');
    box.clear();
    for (final t in _tasks) {
      box.put(t.id, t.toMap());
    }
  }

  void _saveReminders() {
    final box = Hive.box<dynamic>('reminders');
    box.clear();
    for (final r in _reminders) {
      box.put(r.id, r.toMap());
    }
  }

  void _saveSettings() {
    final box = Hive.box<dynamic>('settings');
    box.put('darkMode', darkMode);
    box.put('notifEnabled', notifEnabled);
    box.put('soundEnabled', soundEnabled);
    box.put('profileName', profileName);
    box.put('profileDob', profileDob);
    box.put('profileEmail', profileEmail);
    box.put('isGuest', isGuest);
    if (lastMidnight != null) box.put('lastMidnight', lastMidnight);
    if (startDate != null) box.put('startDate', startDate);
  }

  // ── Midnight / Recurring ─────────────────────────────────────────────────

  void checkMidnight() {
    final today = todayKey();
    if (lastMidnight == today) return;
    lastMidnight = today;
    _refreshRecurring();
    _saveSettings();
    _saveTasks();
    notifyListeners();
  }

  void _refreshRecurring() {
    final today = todayKey();
    final existing = <String>{};
    for (final t in _tasks) {
      if (t.isInstance) existing.add('${t.baseId}__${t.date}');
    }
    final toAdd = <Task>[];
    for (final t in _tasks) {
      if (t.recurring == 'once' || t.isInstance) continue;
      final key = '${t.id}__$today';
      if (existing.contains(key)) continue;
      if (t.recurEndDate != null &&
          DateTime.parse(today).isAfter(DateTime.parse(t.recurEndDate!))) {
        continue;
      }
      if (_shouldShowToday(t)) {
        toAdd.add(_makeInstance(t, today));
        existing.add(key);
      }
    }
    _tasks.addAll(toAdd);
  }

  bool _shouldShowToday(Task t) {
    final now = DateTime.now();
    final day = now.weekday; // 1=Mon ... 7=Sun
    final dayName =
        ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][day - 1];
    switch (t.recurring) {
      case 'daily':
        return true;
      case 'weekday':
        return day >= 1 && day <= 5;
      case 'weekend':
        return day == 6 || day == 7;
      case 'weekly':
        return t.days?.contains(dayName) ?? false;
      case 'monthly':
        return t.dates?.contains(now.day) ?? false;
      case 'interval':
        if (t.intervalDays == null) return false;
        final start = DateTime.parse(t.date);
        final diff = DateTime.now().difference(start).inDays;
        return diff > 0 && diff % t.intervalDays! == 0;
      default:
        return false;
    }
  }

  bool shouldShowOnDate(Task t, DateTime date) {
    final day = date.weekday;
    final dayName =
        ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][day - 1];
    switch (t.recurring) {
      case 'daily':
        return true;
      case 'weekday':
        return day >= 1 && day <= 5;
      case 'weekend':
        return day == 6 || day == 7;
      case 'weekly':
        return t.days?.contains(dayName) ?? false;
      case 'monthly':
        return t.dates?.contains(date.day) ?? false;
      case 'interval':
        if (t.intervalDays == null) return false;
        final start = DateTime.parse(t.date);
        final diff = date.difference(start).inDays;
        return diff > 0 && diff % t.intervalDays! == 0;
      default:
        return false;
    }
  }

  Task _makeInstance(Task base, String dateStr) {
    final id = 'i_${DateTime.now().millisecondsSinceEpoch}_'
        '${Random().nextInt(99999)}';
    return base.copyWith(id: id, baseId: base.id, isInstance: true, done: false, date: dateStr);
  }

  // ── Tasks ─────────────────────────────────────────────────────────────────

  void addTask(Task template) {
    _tasks.add(template);
    final today = todayKey();
    final key = '${template.id}__$today';
    final existing = _tasks
        .where((t) => t.isInstance)
        .map((t) => '${t.baseId}__${t.date}')
        .toSet();
    if (!existing.contains(key) &&
        (template.recurring == 'once' || _shouldShowToday(template))) {
      _tasks.add(_makeInstance(template, today));
    }
    _saveTasks();
    notifyListeners();
  }

  void updateTask(Task updated) {
    final idx = _tasks.indexWhere((t) => t.id == updated.id && !t.isInstance);
    if (idx < 0) return;
    _tasks[idx] = updated;
    // Also update today's instance
    final today = todayKey();
    final instIdx =
        _tasks.indexWhere((t) => t.isInstance && t.baseId == updated.id && t.date == today);
    if (instIdx >= 0) {
      _tasks[instIdx] = _tasks[instIdx].copyWith(
        name: updated.name,
        time: updated.time,
        duration: updated.duration,
        desc: updated.desc,
        category: updated.category,
      );
    }
    _saveTasks();
    notifyListeners();
  }

  List<Task>? _deletedTasks;

  void deleteTask(String id) {
    _deletedTasks = _tasks.where((t) => t.id == id || t.baseId == id).toList();
    _tasks.removeWhere((t) => t.id == id || t.baseId == id);
    _saveTasks();
    notifyListeners();
  }

  void undoDelete() {
    if (_deletedTasks == null) return;
    _tasks.addAll(_deletedTasks!);
    _deletedTasks = null;
    _saveTasks();
    notifyListeners();
  }

  void toggleTask(String id) {
    final idx = _tasks.indexWhere((t) => t.id == id);
    if (idx < 0) return;
    _tasks[idx].done = !_tasks[idx].done;
    _saveTasks();
    notifyListeners();
    if (_tasks[idx].done) {
      _playBeep();
      if (notifEnabled && _tasks[idx].duration > 0) {
        final when = DateTime.now().add(Duration(minutes: _tasks[idx].duration));
        NotificationService.scheduleReminder(
          id: id.hashCode,
          title: 'Task done! ✨',
          body: 'Great job on "${_tasks[idx].name}"!',
          when: when,
        );
      }
    }
    // End-of-day check: if it's 23:55
    final now = DateTime.now();
    if (now.hour == 23 && now.minute == 55) _endOfDayCheck();
  }

  void _endOfDayCheck() {
    final today = todayKey();
    final missed = _tasks
        .where((t) => t.date == today && t.isInstance && !t.done)
        .toList();
    if (missed.isNotEmpty && notifEnabled) {
      NotificationService.showImmediate(
        '⚠️ PROgress',
        'You have ${missed.length} incomplete task${missed.length > 1 ? 's' : ''} today!',
      );
    }
  }

  // ── Today Tasks (for Home Screen) ─────────────────────────────────────────

  List<Task> getTodayTasks({String filter = 'all', String sort = 'time', String search = ''}) {
    final today = todayKey();
    var tasks = _tasks.where((t) => t.date == today && t.isInstance).toList();

    if (filter == 'personal') {
      tasks = tasks.where((t) => t.category == 'personal').toList();
    } else if (filter == 'professional') {
      tasks = tasks.where((t) => t.category == 'professional').toList();
    } else if (filter == 'pending') {
      tasks = tasks.where((t) => !t.done).toList();
    } else if (filter == 'completed') {
      tasks = tasks.where((t) => t.done).toList();
    }

    if (search.isNotEmpty) {
      final q = search.toLowerCase();
      tasks = tasks
          .where((t) =>
              t.name.toLowerCase().contains(q) ||
              t.desc.toLowerCase().contains(q))
          .toList();
    }

    if (sort == 'time') {
      tasks.sort((a, b) => a.time.compareTo(b.time));
    } else if (sort == 'pending') {
      tasks.sort((a, b) => (a.done ? 1 : 0).compareTo(b.done ? 1 : 0));
    } else if (sort == 'done') {
      tasks.sort((a, b) => (b.done ? 1 : 0).compareTo(a.done ? 1 : 0));
    }
    return tasks;
  }

  List<Task> getInstancesForDate(String dateStr) =>
      _tasks.where((t) => t.date == dateStr && t.isInstance).toList();

  List<Task> getVirtualTasksForDate(DateTime date) {
    final dateStr = dateKey(date);
    final existing = <String>{
      for (final t in _tasks.where((t) => t.isInstance && t.date == dateStr))
        t.baseId ?? t.id
    };
    final virtual = <Task>[];
    for (final t in _tasks.where((t) => !t.isInstance && t.recurring != 'once')) {
      if (existing.contains(t.id)) continue;
      if (t.recurEndDate != null &&
          date.isAfter(DateTime.parse(t.recurEndDate!))) continue;
      if (shouldShowOnDate(t, date)) {
        virtual.add(t.copyWith(
          id: 'virtual_${t.id}_$dateStr',
          baseId: t.id,
          isInstance: true,
          date: dateStr,
          done: false,
        ));
      }
    }
    return virtual;
  }

  // ── Today stats ───────────────────────────────────────────────────────────

  int get todayTotal {
    final today = todayKey();
    return _tasks.where((t) => t.date == today && t.isInstance).length;
  }

  int get todayDone {
    final today = todayKey();
    return _tasks.where((t) => t.date == today && t.isInstance && t.done).length;
  }

  int get todayPersonalTotal {
    final today = todayKey();
    return _tasks
        .where((t) => t.date == today && t.isInstance && t.category == 'personal')
        .length;
  }

  int get todayPersonalDone {
    final today = todayKey();
    return _tasks
        .where((t) =>
            t.date == today && t.isInstance && t.category == 'personal' && t.done)
        .length;
  }

  int get todayProfessionalTotal {
    final today = todayKey();
    return _tasks
        .where((t) =>
            t.date == today && t.isInstance && t.category == 'professional')
        .length;
  }

  int get todayProfessionalDone {
    final today = todayKey();
    return _tasks
        .where((t) =>
            t.date == today &&
            t.isInstance &&
            t.category == 'professional' &&
            t.done)
        .length;
  }

  double get todayPct =>
      todayTotal == 0 ? 0 : todayDone / todayTotal;

  Task? get focusTask {
    final today = todayKey();
    final pending = _tasks
        .where((t) => t.date == today && t.isInstance && !t.done)
        .toList();
    pending.sort((a, b) => a.time.compareTo(b.time));
    return pending.isEmpty ? null : pending.first;
  }

  // ── Streak ────────────────────────────────────────────────────────────────

  int calcStreak() {
    int streak = 0;
    for (int i = 0; i < 365; i++) {
      final d = DateTime.now().subtract(Duration(days: i));
      final dk = dateKey(d);
      final dayTasks = _tasks.where((t) => t.date == dk && t.isInstance).toList();
      if (dayTasks.isEmpty) break;
      if (dayTasks.every((t) => t.done)) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  Map<String, dynamic> getStreakLevel(int streak) {
    if (streak >= 30) {
      return {'label': '🥇 Gold', 'emoji': '🥇', 'color': const Color(0xFFffd700)};
    } else if (streak >= 7) {
      return {'label': '🥈 Silver', 'emoji': '🥈', 'color': const Color(0xFFa8a9ad)};
    } else if (streak >= 3) {
      return {'label': '🥉 Bronze', 'emoji': '🥉', 'color': const Color(0xFFcd7f32)};
    }
    return {'label': 'Keep going!', 'emoji': '🔥', 'color': const Color(0xFF667eea)};
  }

  String streakNextLevel(int streak) {
    if (streak < 3) {
      final n = 3 - streak;
      return 'Complete all tasks for $n more day${n > 1 ? 's' : ''} to earn 🥉 Bronze!';
    } else if (streak < 7) {
      final n = 7 - streak;
      return '$n more day${n > 1 ? 's' : ''} to earn 🥈 Silver!';
    } else if (streak < 30) {
      final n = 30 - streak;
      return '$n more day${n > 1 ? 's' : ''} to earn 🥇 Gold!';
    }
    return 'You have reached the highest streak level! 🎉';
  }

  // ── Analytics ────────────────────────────────────────────────────────────

  List<double> getChartData() {
    final data = <double>[];
    if (statsPeriod == 'weekly') {
      for (int i = 6; i >= 0; i--) {
        final d = DateTime.now().subtract(Duration(days: i));
        final dk = dateKey(d);
        final dt = _tasks.where((t) => t.date == dk && t.isInstance).toList();
        data.add(dt.isEmpty
            ? 0
            : dt.where((t) => t.done).length / dt.length * 100);
      }
    } else if (statsPeriod == 'monthly') {
      final now = DateTime.now();
      final daysInMonth = DateUtils.getDaysInMonth(now.year, now.month);
      final step = (daysInMonth / 7).ceil();
      for (int i = 1; i <= daysInMonth; i += step) {
        final d = DateTime(now.year, now.month, i);
        final dk = dateKey(d);
        final dt = _tasks.where((t) => t.date == dk && t.isInstance).toList();
        data.add(dt.isEmpty
            ? 0
            : dt.where((t) => t.done).length / dt.length * 100);
      }
    } else {
      for (int m = 1; m <= 12; m++) {
        int done = 0, total = 0;
        final daysInMonth =
            DateUtils.getDaysInMonth(DateTime.now().year, m);
        for (int d = 1; d <= daysInMonth; d++) {
          final dt = DateTime(DateTime.now().year, m, d);
          final dk = dateKey(dt);
          final dayTasks =
              _tasks.where((t) => t.date == dk && t.isInstance).toList();
          done += dayTasks.where((t) => t.done).length;
          total += dayTasks.length;
        }
        data.add(total == 0 ? 0 : done / total * 100);
      }
    }
    return data;
  }

  double get weekAvgPct {
    double sum = 0;
    for (int i = 0; i < 7; i++) {
      final d = DateTime.now().subtract(Duration(days: i));
      final dk = dateKey(d);
      final dt = _tasks.where((t) => t.date == dk && t.isInstance).toList();
      sum += dt.isEmpty ? 0 : dt.where((t) => t.done).length / dt.length * 100;
    }
    return sum / 7;
  }

  Map<String, int> get taskDistribution {
    final dist = <String, int>{};
    for (final t in _tasks.where((t) => !t.isInstance)) {
      dist[t.category] = (dist[t.category] ?? 0) + 1;
    }
    return dist;
  }

  List<AppInsight> generateInsights() {
    final insights = <AppInsight>[];
    // Best hour
    final hourCounts = <int, int>{};
    for (final t in _tasks.where((t) => t.isInstance && t.done)) {
      final h = int.parse(t.time.split(':')[0]);
      hourCounts[h] = (hourCounts[h] ?? 0) + 1;
    }
    if (hourCounts.isNotEmpty) {
      final best = hourCounts.entries.reduce((a, b) => a.value > b.value ? a : b);
      final ap = best.key >= 12 ? 'PM' : 'AM';
      final h = best.key % 12 == 0 ? 12 : best.key % 12;
      insights.add(AppInsight('⏰',
          'You are most productive around $h $ap — that\'s when you complete the most tasks.'));
    }
    // Weekday vs weekend
    int wdDone = 0, wdTotal = 0, weDone = 0, weTotal = 0;
    for (int i = 0; i < 30; i++) {
      final d = DateTime.now().subtract(Duration(days: i));
      final dk = dateKey(d);
      final dayTasks = _tasks.where((t) => t.date == dk && t.isInstance).toList();
      if (d.weekday >= 1 && d.weekday <= 5) {
        wdDone += dayTasks.where((t) => t.done).length;
        wdTotal += dayTasks.length;
      } else {
        weDone += dayTasks.where((t) => t.done).length;
        weTotal += dayTasks.length;
      }
    }
    final wdPct = wdTotal == 0 ? 0 : (wdDone / wdTotal * 100).round();
    final wePct = weTotal == 0 ? 0 : (weDone / weTotal * 100).round();
    if (wdTotal > 0 || weTotal > 0) {
      insights.add(AppInsight('📅',
          'You complete $wdPct% of tasks on weekdays and $wePct% on weekends.'));
    }
    final streak = calcStreak();
    if (streak >= 1) {
      insights.add(AppInsight('🔥',
          'You are on a $streak-day streak. ${streak >= 7 ? 'Impressive consistency!' : 'Keep it up!'}'));
    }
    final pending = todayTotal - todayDone;
    if (pending > 0) {
      insights.add(AppInsight('📋',
          'You have $pending task${pending > 1 ? 's' : ''} left to complete today.'));
    } else if (todayTotal > 0) {
      insights.add(AppInsight('🎉', 'All tasks done for today! Excellent work!'));
    }
    if (insights.isEmpty) {
      insights.add(AppInsight('📈', 'Complete more tasks to unlock personalized insights!'));
    }
    return insights;
  }

  // ── Reminders ────────────────────────────────────────────────────────────

  void addReminder(Reminder r) {
    _reminders.add(r);
    _saveReminders();
    if (notifEnabled) {
      final parts = r.time.split(':');
      final dateParts = r.date.split('-');
      final when = DateTime(
        int.parse(dateParts[0]),
        int.parse(dateParts[1]),
        int.parse(dateParts[2]),
        int.parse(parts[0]),
        int.parse(parts[1]),
      );
      NotificationService.scheduleReminder(
        id: r.id.hashCode,
        title: '🔔 PROgress',
        body: r.msg,
        when: when,
      );
    }
    notifyListeners();
  }

  void deleteReminder(String id) {
    _reminders.removeWhere((r) => r.id == id);
    NotificationService.cancel(id.hashCode);
    _saveReminders();
    notifyListeners();
  }

  // ── Profile / Settings ───────────────────────────────────────────────────

  void updateProfile(String name, String dob, String email) {
    profileName = name;
    profileDob = dob;
    profileEmail = email;
    _saveSettings();
    notifyListeners();
  }

  void setUser({required String email, required String name, required bool guest}) {
    profileEmail = email;
    profileName = name.isNotEmpty ? name : profileName;
    isGuest = guest;
    _saveSettings();
    notifyListeners();
  }

  void toggleDarkMode() {
    darkMode = !darkMode;
    _saveSettings();
    notifyListeners();
  }

  void toggleNotif(bool val) {
    notifEnabled = val;
    _saveSettings();
    notifyListeners();
  }

  void toggleSound(bool val) {
    soundEnabled = val;
    if (val) _playBeep();
    _saveSettings();
    notifyListeners();
  }

  void clearAllData() {
    _tasks.clear();
    _reminders.clear();
    _saveTasks();
    _saveReminders();
    notifyListeners();
  }

  void setStatsPeriod(String period) {
    statsPeriod = period;
    notifyListeners();
  }

  // ── Sound ─────────────────────────────────────────────────────────────────

  Future<void> _playBeep() async {
    HapticFeedback.mediumImpact();
    if (!soundEnabled) return;
    try {
      await _player.play(AssetSource('sounds/beep.mp3'));
    } catch (_) {}
  }
}
