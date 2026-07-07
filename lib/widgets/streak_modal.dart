import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';

void showStreakModal(BuildContext context) {
  showDialog(context: context, builder: (_) => const _StreakDialog());
}

class _StreakDialog extends StatelessWidget {
  const _StreakDialog();

  @override
  Widget build(BuildContext context) {
    final provider = context.read<AppProvider>();
    final streak = provider.calcStreak();
    final level = provider.getStreakLevel(streak);
    final nextMsg = provider.streakNextLevel(streak);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '🔥 Your Streak',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    (level['color'] as Color).withOpacity(0.8),
                    level['color'] as Color,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: (level['color'] as Color).withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Center(
                child: Text(level['emoji'] as String,
                    style: const TextStyle(fontSize: 42)),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '$streak',
              style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary),
            ),
            const Text(
              'day streak',
              style: TextStyle(
                  fontSize: 14,
                  color: AppColors.muted,
                  fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              level['label'] as String,
              style: const TextStyle(fontSize: 13, color: AppColors.muted),
            ),
            const SizedBox(height: 12),
            Text(
              nextMsg,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.muted,
                  height: 1.5),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Close',
                    style:
                        TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
