import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:surf_mobile/providers/class_pack_provider.dart';

import 'package:surf_mobile/screens/home/PackCard.dart';
import 'package:surf_mobile/screens/home/PackDetailScreen.dart';

class HomeLightScreen extends StatelessWidget {
  const HomeLightScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final packProvider = context.watch<ClassPackProvider>();

    if (packProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          packProvider.headline,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 12),
        ...packProvider.visiblePacks.map(
          (pack) => PackCard(
            pack: pack,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PackDetailScreen(pack: pack),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
