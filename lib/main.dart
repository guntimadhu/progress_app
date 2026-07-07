import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/app_provider.dart';
import 'screens/splash_screen.dart';
import 'services/notification_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
  } catch (e) {
    debugPrint('Firebase init failed (guest mode): $e');
  }

  await Hive.initFlutter();
  await Hive.openBox<dynamic>('tasks');
  await Hive.openBox<dynamic>('reminders');
  await Hive.openBox<dynamic>('settings');

  await NotificationService.init();

  runApp(
    ChangeNotifierProvider(
      create: (_) => AppProvider()..init(),
      child: const ProgressApp(),
    ),
  );
}

class ProgressApp extends StatefulWidget {
  const ProgressApp({super.key});

  @override
  State<ProgressApp> createState() => _ProgressAppState();
}

class _ProgressAppState extends State<ProgressApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      context.read<AppProvider>().checkMidnight();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (ctx, provider, _) {
        return MaterialApp(
          title: 'PROgress',
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: provider.themeMode,
          debugShowCheckedModeBanner: false,
          home: const SplashScreen(),
        );
      },
    );
  }
}
