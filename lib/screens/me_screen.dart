import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/app_provider.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/add_task_modal.dart';
import 'auth_screen.dart';

class MeScreen extends StatefulWidget {
  const MeScreen({super.key});

  @override
  State<MeScreen> createState() => _MeScreenState();
}

class _MeScreenState extends State<MeScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  void _confirm(BuildContext ctx, String msg, VoidCallback action) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text('⚠️ Confirm'),
        content: Text(msg),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              action();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('Confirm',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Consumer<AppProvider>(
      builder: (ctx, p, _) {
        final templates = p.templates;
        final grouped = <String, List<dynamic>>{};
        for (final t in templates) {
          grouped.putIfAbsent(t.category, () => []).add(t);
        }
        for (final k in grouped.keys) {
          grouped[k]!.sort((a, b) => a.time.compareTo(b.time));
        }
        final isLoggedIn = !p.isGuest;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('👤 ME',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5)),
            const SizedBox(height: 14),

            // Account section
            const _SectionLabel('Account'),
            _Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ProfileRow('Name', p.profileName.isNotEmpty ? p.profileName : 'Not set'),
                  const SizedBox(height: 10),
                  _ProfileRow('Email', p.profileEmail),
                ],
              ),
            ),
            const SizedBox(height: 8),
            _OutlinedBtn(
              label: '✏️ Edit Profile',
              onTap: () => _showEditProfile(context, p),
            ),
            const SizedBox(height: 8),
            if (!isLoggedIn)
              _OutlinedBtn(
                label: '🔑 Sign In / Sign Up',
                onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AuthScreen())),
              ),
            if (isLoggedIn)
              ElevatedButton(
                onPressed: () => _confirm(
                    context, 'Sign out from your account?', () async {
                  await AuthService.signOut();
                  p.setUser(
                      email: 'guest@progress.app', name: '', guest: true);
                  _showSnack('👋 Signed out!');
                }),
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.danger,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 44),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10))),
                child: const Text('🚪 Sign Out',
                    style: TextStyle(fontWeight: FontWeight.w700)),
              ),

            const Divider(height: 32),

            // My Tasks
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const _SectionLabel('My Tasks'),
                ElevatedButton(
                  onPressed: () => showAddTaskModal(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 7),
                  ),
                  child: const Text('+ Add Task',
                      style: TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
            Text('${templates.length} task${templates.length != 1 ? 's' : ''}',
                style: const TextStyle(
                    fontSize: 12, color: AppColors.muted)),
            const SizedBox(height: 10),
            if (templates.isEmpty)
              const Padding(
                padding: EdgeInsets.all(20),
                child: Center(
                  child: Column(
                    children: [
                      Text('📋', style: TextStyle(fontSize: 32)),
                      SizedBox(height: 8),
                      Text('No tasks yet.',
                          style: TextStyle(color: AppColors.muted)),
                      Text('Tap "+ Add Task" to create one.',
                          style: TextStyle(
                              color: AppColors.muted, fontSize: 12)),
                    ],
                  ),
                ),
              )
            else
              ...grouped.entries.map((entry) {
                final catIcon = entry.key == 'personal' ? '👤' : '💼';
                final catLabel =
                    entry.key[0].toUpperCase() + entry.key.substring(1);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Text(
                        '$catIcon $catLabel (${entry.value.length})',
                        style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.muted,
                            letterSpacing: 0.6),
                      ),
                    ),
                    ...entry.value.map((t) {
                      final inst = p.allTasks.firstWhere(
                        (x) =>
                            x.isInstance &&
                            x.baseId == t.id &&
                            x.date == AppProvider.todayKey(),
                        orElse: () => t,
                      );
                      final isDone = inst.isInstance && inst.done;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: const Border(
                              left: BorderSide(
                                  color: AppColors.primary, width: 4)),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 6,
                                offset: const Offset(0, 2))
                          ],
                        ),
                        child: Opacity(
                          opacity: isDone ? 0.55 : 1,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(t.name,
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13,
                                              decoration: isDone
                                                  ? TextDecoration.lineThrough
                                                  : null)),
                                      if (t.desc.isNotEmpty)
                                        Text(t.desc,
                                            style: const TextStyle(
                                                fontSize: 11,
                                                color: AppColors.muted)),
                                      const SizedBox(height: 4),
                                      Wrap(
                                        spacing: 4,
                                        children: [
                                          _SmallBadge(t.recurring,
                                              AppColors.secondary),
                                          _SmallBadge(
                                              '${t.duration}m',
                                              const Color(0xFF475569)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Text('✏️',
                                      style: TextStyle(fontSize: 15)),
                                  onPressed: () =>
                                      showAddTaskModal(context, editTask: t),
                                  constraints: const BoxConstraints(),
                                  padding: const EdgeInsets.all(4),
                                ),
                                IconButton(
                                  icon: const Text('🗑️',
                                      style: TextStyle(fontSize: 15)),
                                  onPressed: () => _confirm(
                                      context, 'Delete "${t.name}"?',
                                      () => p.deleteTask(t.id)),
                                  constraints: const BoxConstraints(),
                                  padding: const EdgeInsets.all(4),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                );
              }),

            const Divider(height: 32),

            // Preferences
            const _SectionLabel('Preferences'),
            _ToggleItem(
              label: '🌙 Dark Mode',
              value: p.darkMode,
              onChanged: (_) => p.toggleDarkMode(),
            ),

            const Divider(height: 32),

            // Notifications
            const _SectionLabel('Notifications'),
            _ToggleItem(
              label: '🔔 Task Reminders',
              value: p.notifEnabled,
              onChanged: p.toggleNotif,
            ),
            const SizedBox(height: 8),
            _ToggleItem(
              label: '🔊 Sound Effects',
              value: p.soundEnabled,
              onChanged: p.toggleSound,
            ),

            const Divider(height: 32),

            // Feedback
            const _SectionLabel('Feedback'),
            _ArrowItem(
              label: '📤 Share App',
              onTap: () => Share.share(
                  'Check out PROgress ⬆️ - Level up your productivity! https://progress.app'),
            ),
            _ArrowItem(
              label: '⭐ Rate App',
              onTap: () => _showRating(context),
            ),
            _ArrowItem(
              label: '💬 Send Feedback',
              onTap: () => _showFeedback(context),
            ),

            const Divider(height: 32),

            // About
            const _SectionLabel('About'),
            _Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('PROgress v2.0.0',
                      style: TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 13)),
                  SizedBox(height: 3),
                  Text('Professional Task & Productivity Manager',
                      style:
                          TextStyle(fontSize: 11, color: AppColors.muted)),
                ],
              ),
            ),

            const Divider(height: 32),

            // Danger Zone
            const _SectionLabel('Danger Zone'),
            _Card(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _confirm(
                      context, '⚠️ Delete ALL data?', () {
                    p.clearAllData();
                    _showSnack('✓ All data cleared!');
                  }),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.danger,
                      foregroundColor: Colors.white),
                  child: const Text('🗑️ Clear All Data'),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        );
      },
    );
  }

  void _showEditProfile(BuildContext ctx, AppProvider p) {
    final nameCtrl = TextEditingController(text: p.profileName);
    final dobCtrl = TextEditingController(text: p.profileDob);
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text('✏️ Edit Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                  labelText: 'Name', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: dobCtrl,
              readOnly: true,
              decoration: const InputDecoration(
                  labelText: 'Date of Birth',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today)),
              onTap: () async {
                final d = await showDatePicker(
                  context: ctx,
                  initialDate: DateTime(2000),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                );
                if (d != null) {
                  dobCtrl.text = AppProvider.dateKey(d);
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.isEmpty || dobCtrl.text.isEmpty) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(content: Text('⚠️ Fill all fields')));
                return;
              }
              p.updateProfile(nameCtrl.text, dobCtrl.text, p.profileEmail);
              Navigator.pop(ctx);
              _showSnack('✓ Profile saved!');
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    nameCtrl.dispose();
    dobCtrl.dispose();
  }

  void _showRating(BuildContext ctx) {
    const emojis = ['😞', '😕', '😐', '😊', '😍'];
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text('⭐ Rate PROgress'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('⭐⭐⭐⭐⭐',
                style: TextStyle(fontSize: 32)),
            const SizedBox(height: 10),
            const Text('How would you rate us?',
                style: TextStyle(color: AppColors.muted)),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: emojis
                  .asMap()
                  .entries
                  .map((e) => GestureDetector(
                        onTap: () {
                          Navigator.pop(ctx);
                          _showSnack('${emojis[e.key]} Thanks for rating!');
                        },
                        child: Text(e.value,
                            style: const TextStyle(fontSize: 28)),
                      ))
                  .toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Close')),
        ],
      ),
    );
  }

  void _showFeedback(BuildContext ctx) {
    final ctrl = TextEditingController();
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text('💬 Send Feedback'),
        content: TextField(
          controller: ctrl,
          maxLines: 4,
          decoration: const InputDecoration(
              hintText: 'Tell us what you think…',
              border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (ctrl.text.trim().isEmpty) return;
              Navigator.pop(ctx);
              _showSnack('💬 Thanks for the feedback!');
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white),
            child: const Text('Send'),
          ),
        ],
      ),
    );
    ctrl.dispose();
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.muted,
            letterSpacing: 0.5),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
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
      child: child,
    );
  }
}

class _ProfileRow extends StatelessWidget {
  final String label;
  final String value;
  const _ProfileRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(),
            style: const TextStyle(
                fontSize: 10,
                color: AppColors.muted,
                fontWeight: FontWeight.w700)),
        const SizedBox(height: 3),
        Text(value,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _ToggleItem extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _ToggleItem(
      {required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(10),
        border: const Border(
            left: BorderSide(color: AppColors.primary, width: 4)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 1))
        ],
      ),
      child: ListTile(
        title: Text(label,
            style:
                const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.success,
        ),
        onTap: () => onChanged(!value),
      ),
    );
  }
}

class _ArrowItem extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _ArrowItem({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(10),
        border: const Border(
            left: BorderSide(color: AppColors.primary, width: 4)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 1))
        ],
      ),
      child: ListTile(
        title: Text(label,
            style:
                const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.arrow_forward_ios,
            size: 14, color: AppColors.muted),
        onTap: onTap,
      ),
    );
  }
}

class _OutlinedBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _OutlinedBtn({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 44),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
    );
  }
}

class _SmallBadge extends StatelessWidget {
  final String text;
  final Color color;
  const _SmallBadge(this.text, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
          color: color, borderRadius: BorderRadius.circular(10)),
      child: Text(text,
          style: const TextStyle(
              color: Colors.white, fontSize: 9, fontWeight: FontWeight.w600)),
    );
  }
}
