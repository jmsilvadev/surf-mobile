import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:surf_mobile/features/models/student_pack_dashboard_item.dart';
import 'package:surf_mobile/providers/class_pack_provider.dart';

class PacksSection extends StatelessWidget {
  final List<StudentPackDashboardItem> packs;

  const PacksSection({super.key, required this.packs});

  @override
  Widget build(BuildContext context) {
    final classPackProvider = context.watch<ClassPackProvider>();

    final packs = classPackProvider.dashboardItems;

    if (packs.isEmpty) {
      return const Text('No active packs');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('My Packs', style: TextStyle(fontSize: 18)),
        const SizedBox(height: 8),
        ...packs.map(
          (p) => Card(
            child: ListTile(
              title: Text(p.packName),
              subtitle: Text(
                'Balance: ${p.lessonsBalance}'
                '${p.expiresAt != null ? ' • Expires: ${_fmt(p.expiresAt!)}' : ''}',
              ),
              trailing: Chip(
                label: Text(p.status),
                backgroundColor:
                    p.status == 'active' ? Colors.green[100] : null,
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _fmt(DateTime date) => '${date.day}/${date.month}/${date.year}';
}
