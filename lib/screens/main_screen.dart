import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:surf_mobile/features/student_dashboard_screen.dart';
import 'package:surf_mobile/providers/class_pack_provider.dart';
import 'package:surf_mobile/providers/navigation_provider.dart';
import 'package:surf_mobile/screens/home/home_light_screen.dart';
import 'package:surf_mobile/services/auth_service.dart';
import 'package:surf_mobile/screens/calendar_screen.dart';
//import 'package:surf_mobile/screens/registrations_screen.dart';
import 'package:surf_mobile/screens/rentals_screen.dart';
import 'package:surf_mobile/services/user_provider.dart';
import 'package:surf_mobile/widgets/user_avatar.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // int _currentIndex = 0;

  final List<Widget> _screens = [
    const StudentDashboardPage(),
    const CalendarScreen(),
    const HomeLightScreen(),
    // const RegistrationsScreen(),
    const RentalsScreen(),
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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = Provider.of<UserProvider>(context, listen: false);
      if (user.schoolId != null) {
        Provider.of<ClassPackProvider>(context, listen: false)
            .load(user.schoolId!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<NavigationProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('OceanDojo'),
        actions: [
          Consumer<UserProvider>(
            builder: (context, userProvider, _) {
              final student = userProvider.profile;

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: UserAvatar(
                  photoUrl: student?.photoUrl,
                  name: student?.name,
                  radius: 18,
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: _screens[nav.currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor:
            Theme.of(context).bottomNavigationBarTheme.backgroundColor,
        selectedItemColor:
            Theme.of(context).bottomNavigationBarTheme.selectedItemColor,
        unselectedItemColor:
            Theme.of(context).bottomNavigationBarTheme.unselectedItemColor,
        currentIndex: nav.currentIndex,
        onTap: (index) {
          context.read<NavigationProvider>().setIndex(index);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'My Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory),
            label: 'Packs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'Rentals',
          ),
        ],
      ),
    );
  }
}
