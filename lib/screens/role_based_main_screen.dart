import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:surf_mobile/screens/admin/admin_main_screen.dart';
import 'package:surf_mobile/screens/main_screen.dart';
import 'package:surf_mobile/screens/teacher_main_screen.dart';
import 'package:surf_mobile/services/auth_service.dart';

class RoleBasedMainScreen extends StatelessWidget {
  const RoleBasedMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final role = auth.session?.user.role;

    if (role == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (role == 'admin') {
      return const AdminMainScreen();
    }

    if (role == 'teacher') {
      return const TeacherMainScreen();
    }

    return const MainScreen();
  }
}
