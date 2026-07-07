import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../theme/app_theme.dart';
import 'auth_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _slide = 0;

  final _slides = const [
    _Slide(
      icon: '⬆️',
      title: 'Welcome to PROgress',
      desc:
          'Your personal productivity companion. Level up everyday — one task at a time.',
    ),
    _Slide(
      icon: '✅',
      title: 'Track Your Tasks',
      desc:
          'Add personal and professional tasks, set priorities, and mark them done as you go through your day.',
    ),
    _Slide(
      icon: '🔥',
      title: 'Build Streaks',
      desc:
          'Complete all your daily tasks to keep your streak alive. Earn Bronze, Silver and Gold badges!',
    ),
    _Slide(
      icon: '📊',
      title: 'See Your Progress',
      desc:
          'Analytics, calendar heatmaps, and smart insights show you how productive you really are.',
    ),
  ];

  void _done() {
    Hive.box<dynamic>('settings').put('onboardingDone', true);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const AuthScreen()),
    );
  }

  void _next() {
    if (_slide >= _slides.length - 1) {
      _done();
    } else {
      setState(() => _slide++);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = _slides[_slide];
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.gradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  transitionBuilder: (child, anim) => SlideTransition(
                    position: Tween<Offset>(
                            begin: const Offset(0, 0.2), end: Offset.zero)
                        .animate(anim),
                    child: FadeTransition(opacity: anim, child: child),
                  ),
                  child: Column(
                    key: ValueKey(_slide),
                    children: [
                      Text(s.icon,
                          style: const TextStyle(fontSize: 72)),
                      const SizedBox(height: 20),
                      Text(
                        s.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        s.desc,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.white,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                // Dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_slides.length, (i) {
                    final active = i == _slide;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: active ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: active
                            ? Colors.white
                            : Colors.white.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _next,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 4,
                    ),
                    child: Text(
                      _slide == _slides.length - 1 ? 'Get Started' : 'Next',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _done,
                  child: const Text(
                    'Skip',
                    style: TextStyle(
                        color: Colors.white70, fontSize: 13),
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

class _Slide {
  final String icon;
  final String title;
  final String desc;
  const _Slide({required this.icon, required this.title, required this.desc});
}
