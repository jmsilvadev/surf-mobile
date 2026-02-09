import 'package:flutter/material.dart';

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
          onTap: () => Navigator.pushNamed(context, '/packs'),
        ),
        _Action(
          icon: Icons.surfing,
          label: 'Classes',
          onTap: () => Navigator.pushNamed(context, '/classes'),
        ),
        _Action(
          icon: Icons.inventory,
          label: 'Rent',
          onTap: () => Navigator.pushNamed(context, '/rentals'),
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
