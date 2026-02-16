import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:surf_mobile/providers/navigation_provider.dart';
import 'package:surf_mobile/screens/calendar_screen.dart';
import 'package:surf_mobile/screens/teacher_dashboard_screen.dart';
import 'package:surf_mobile/services/auth_service.dart';

class TeacherMainScreen extends StatefulWidget {
  const TeacherMainScreen({super.key});

  @override
  State<TeacherMainScreen> createState() => _TeacherMainScreenState();
}

class _TeacherMainScreenState extends State<TeacherMainScreen> {
  final List<Widget> _screens = [
    const TeacherDashboardScreen(),
    const CalendarScreen(),
  ];

  Future<void> _handleLogout() async {
    if (!mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (!mounted) return;

    if (confirmed == true) {
      context.read<NavigationProvider>().reset();
      final authService = Provider.of<AuthService>(context, listen: false);
      await authService.signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<NavigationProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Teacher Panel'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: _screens[nav.currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: nav.currentIndex,
        onTap: (index) {
          context.read<NavigationProvider>().setIndex(index);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),
        ],
      ),
    );
  }
}
