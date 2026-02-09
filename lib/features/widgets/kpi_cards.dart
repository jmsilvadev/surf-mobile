import 'package:flutter/material.dart';
import 'package:surf_mobile/features/models/student_pack_dashboard_item.dart';
import 'package:surf_mobile/models/class_model.dart';

class KpiCards extends StatelessWidget {
  final List<StudentPackDashboardItem> packs;
  final List<ClassModel> classes;

  const KpiCards({
    super.key,
    required this.packs,
    required this.classes,
  });

  @override
  Widget build(BuildContext context) {
    final activePacks = packs.where((p) => p.status == 'active');
    final balance =
        activePacks.fold<int>(0, (sum, p) => sum + p.lessonsBalance);

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.4,
      children: [
        _KpiCard(
          title: 'Balance',
          value: '$balance lessons',
          icon: Icons.confirmation_number,
        ),
        _KpiCard(
          title: 'Active Packs',
          value: '${activePacks.length}',
          icon: Icons.inventory_2,
        ),
        _KpiCard(
          title: 'Classes',
          value: '${classes.length}',
          icon: Icons.surfing,
        ),
        _KpiCard(
          title: 'Spent',
          value: _totalSpent(),
          icon: Icons.payments,
        ),
      ],
    );
  }

  String _totalSpent() {
    final total = packs.fold<double>(
      0,
      (s, p) => s + (p.pricePaid ?? 0),
    );
    return '€${total.toStringAsFixed(2)}';
  }
  
}

class _KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _KpiCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24, color: Theme.of(context).primaryColor),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
      ),
    );
  }
}

