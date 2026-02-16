import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:surf_mobile/models/class_model.dart';
import 'package:surf_mobile/providers/teacher_dashboard_provider.dart';
import 'package:surf_mobile/services/user_provider.dart';

class TeacherDashboardScreen extends StatefulWidget {
  const TeacherDashboardScreen({super.key});

  @override
  State<TeacherDashboardScreen> createState() => _TeacherDashboardScreenState();
}

class _TeacherDashboardScreenState extends State<TeacherDashboardScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TeacherDashboardProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TeacherDashboardProvider>();
    final user = context.watch<UserProvider>();
    final teacher = user.teacherProfile;

    if (provider.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (provider.error != null) {
      return Scaffold(
        body: Center(child: Text(provider.error!)),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hello ${teacher?.name ?? 'Teacher'} 👋',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 20),

          /// PRIMEIRA ROW (somente dois cards)
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: 'Classes Given',
                  value: provider.totalClassesGiven.toString(),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatCard(
                  title: 'To Give',
                  value: provider.totalClassesToGive.toString(),
                  icon: Icons.check_circle_outline,
                  color: Colors.green,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          /// TERCEIRO CARD FORA DA ROW
          _StatCard(
            title: 'Students Taught',
            value: provider.totalUniqueStudents.toString(),
            icon: Icons.group_outlined,
            color: Colors.blue,
          ),

          const SizedBox(height: 30),

          /// SEÇÕES FORA DA ROW
          ClassSection(
            title: 'Upcoming Classes',
            classes: provider.upcoming,
          ),

          const SizedBox(height: 30),

          ClassSection(
            title: 'Completed Classes',
            classes: provider.completed,
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData? icon;
  final Color? color;

  const _StatCard({
    required this.title,
    required this.value,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseColor = color ?? theme.primaryColor;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            if (icon != null)
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: baseColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: baseColor,
                  size: 24,
                ),
              ),
            if (icon != null) const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    value,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ClassSection extends StatelessWidget {
  final String title;
  final List<ClassModel> classes;

  const ClassSection({
    required this.title,
    required this.classes,
  });

  @override
  Widget build(BuildContext context) {
    if (classes.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text('No classes found'),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...classes.map((c) => _ClassCard(classModel: c)),
      ],
    );
  }
}

class _ClassCard extends StatelessWidget {
  final ClassModel classModel;

  const _ClassCard({required this.classModel});

  @override
  Widget build(BuildContext context) {
    final students = classModel.students ?? [];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              classModel.price.type,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Status: ${classModel.status}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 10),
            const Text(
              'Students:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            if (students.isEmpty)
              const Text('No students enrolled')
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: students
                    .map(
                      (s) => Chip(
                        label: Text(s.name),
                        avatar: const Icon(
                          Icons.person,
                          size: 18,
                        ),
                      ),
                    )
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }
}
