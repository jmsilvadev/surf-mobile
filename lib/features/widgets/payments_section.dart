import 'package:flutter/material.dart';
import 'package:surf_mobile/models/student_deposit_model.dart';

class PaymentsSection extends StatelessWidget {
  final List<StudentDeposit> deposits;

  const PaymentsSection({
    super.key,
    required this.deposits,
  });

  @override
  Widget build(BuildContext context) {
    if (deposits.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(title: 'Payments'),
        const SizedBox(height: 8),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: deposits.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final deposit = deposits[index];

            return Card(
              child: ListTile(
                leading: const Icon(Icons.payments),
                title: Text(
                  '${deposit.currency.toUpperCase()} ${deposit.amount.toStringAsFixed(2)}',
                ),
                subtitle: Text(
                  '${deposit.sourceType} • ${_formatDate(deposit.createdAt)}',
                ),
                trailing: _PaymentStatusChip(status: deposit.status),
                onTap: deposit.invoiceUrl != null
                    ? () {
                        // futuramente: abrir invoice
                      }
                    : null,
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

class _PaymentStatusChip extends StatelessWidget {
  final String status;

  const _PaymentStatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      'succeeded' => Colors.green,
      'pending' => Colors.orange,
      'failed' => Colors.red,
      'refunded' => Colors.blueGrey,
      _ => Colors.grey,
    };

    return Chip(
      label: Text(status),
      backgroundColor: color.withOpacity(0.15),
      labelStyle: TextStyle(color: color),
    );
  }
}
