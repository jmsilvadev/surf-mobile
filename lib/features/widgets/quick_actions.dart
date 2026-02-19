import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:surf_mobile/providers/navigation_provider.dart';

class QuickActions extends StatelessWidget {
  const QuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _Action(
          icon: Icons.shopping_cart,
          label: 'Buy Pack',
          onTap: () => context
              .read<NavigationProvider>()
              .setIndex(2), // Navigate to HomeLightScreen
        ),
        _Action(
          icon: Icons.surfing,
          label: 'Classes',
          onTap: () => context
              .read<NavigationProvider>()
              .setIndex(1), // Navigate to CalendarScreen
        ),
        _Action(
          icon: Icons.inventory,
          label: 'Rent',
          onTap: () => context
              .read<NavigationProvider>()
              .setIndex(3), // Navigate to RentalsScreen
        ),
      ],
    );
  }
}

class _Action extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _Action({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 24,
            child: Icon(icon),
          ),
          const SizedBox(height: 4),
          Text(label),
        ],
      ),
    );
  }
}
