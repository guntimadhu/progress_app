import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/add_task_modal.dart';
import 'home_screen.dart';
import 'calendar_screen.dart';
import 'analytics_screen.dart';
import 'me_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _idx = 0;

  final _screens = const [
    HomeScreen(),
    CalendarScreen(),
    AnalyticsScreen(),
    MeScreen(),
  ];

  void _goToMe() => setState(() => _idx = 3);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppColors.gradient),
        ),
        title: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Row(
                  children: [
                    Text(
                      'PROgress',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(width: 4),
                    Text('⬆️', style: TextStyle(fontSize: 17)),
                  ],
                ),
                Text(
                  'Level up everyday',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _goToMe,
            icon: const Text('⚙️', style: TextStyle(fontSize: 18)),
          ),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: IndexedStack(index: _idx, children: _screens),
      floatingActionButton: _idx == 0
          ? FloatingActionButton(
              onPressed: () => showAddTaskModal(context),
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.add, color: Colors.white, size: 28),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _idx,
        onDestinationSelected: (i) => setState(() => _idx = i),
        indicatorColor: AppColors.primary.withOpacity(0.15),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const [
          NavigationDestination(icon: Text('🏠', style: TextStyle(fontSize: 20)), label: 'Home'),
          NavigationDestination(icon: Text('📅', style: TextStyle(fontSize: 20)), label: 'Cal'),
          NavigationDestination(icon: Text('📊', style: TextStyle(fontSize: 20)), label: 'Stats'),
          NavigationDestination(icon: Text('👤', style: TextStyle(fontSize: 20)), label: 'ME'),
        ],
      ),
    );
  }
}
