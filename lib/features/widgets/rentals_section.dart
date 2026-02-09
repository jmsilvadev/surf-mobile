import 'package:flutter/material.dart';
import 'package:surf_mobile/models/rental_model.dart';

class RentalsSection extends StatelessWidget {
  final List<RentalModel> rentals;

  const RentalsSection({
    super.key,
    required this.rentals,
  });

  @override
  Widget build(BuildContext context) {
    if (rentals.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(title: 'Rentals'),
        const SizedBox(height: 8),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: rentals.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final rental = rentals[index];

            return Card(
              child: ListTile(
                leading: const Icon(Icons.surfing),
                title: Text(rental.equipmentName ?? 'Equipment'),
                subtitle: Text(
                  '${_formatDate(rental.startDate)} → ${_formatDate(rental.endDate)}',
                ),
                trailing: _StatusChip(status: rental.status),
              ),
            );
          },
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

/* ---------- UI Helpers ---------- */

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge,
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      'active' => Colors.green,
      'returned' => Colors.blue,
      'late' => Colors.orange,
      _ => Colors.grey,
    };

    return Chip(
      label: Text(status),
      backgroundColor: color.withOpacity(0.15),
      labelStyle: TextStyle(color: color),
    );
  }
}
