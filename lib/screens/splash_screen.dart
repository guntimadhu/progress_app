import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'auth_screen.dart';
import 'main_screen.dart';
import 'onboarding_screen.dart';
import '../theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _bounce;
  late Animation<double> _bounceAnim;

  @override
  void initState() {
    super.initState();
    _bounce = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _bounceAnim = Tween<double>(begin: 0, end: -10).animate(
      CurvedAnimation(parent: _bounce, curve: Curves.easeInOut),
    );

    Future.delayed(const Duration(milliseconds: 2600), _navigate);
  }

  void _navigate() {
    if (!mounted) return;
    final box = Hive.box<dynamic>('settings');
    final isGuest = box.get('isGuest', defaultValue: true) as bool;
    final onboardingDone =
        box.get('onboardingDone', defaultValue: false) as bool;

    if (!onboardingDone) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
    } else if (!isGuest) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const AuthScreen()),
      );
    }
  }

  @override
  void dispose() {
    _bounce.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.gradient),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'PROgress',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(width: 6),
                  AnimatedBuilder(
                    animation: _bounceAnim,
                    builder: (_, __) => Transform.translate(
                      offset: Offset(0, _bounceAnim.value),
                      child: const Text('⬆️', style: TextStyle(fontSize: 30)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Level up everyday',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
