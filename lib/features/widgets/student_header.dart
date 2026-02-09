import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:surf_mobile/services/user_provider.dart';

class StudentHeader extends StatelessWidget {
  const StudentHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UserProvider>();

    return Row(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundImage: provider.profile?.photoUrl != null
              ? NetworkImage(provider.profile!.photoUrl!)
              : null,
          child: provider.profile?.photoUrl == null
              ? const Icon(Icons.person, size: 32)
              : null,
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              provider.profile?.name ?? 'Student',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (provider.profile?.skillLevel?.slug != null)
              Text(
                provider.profile!.skillLevel?.slug.toUpperCase() ?? '',
                style: TextStyle(color: Colors.grey[600]),
              ),
          ],
        ),
      ],
    );
  }
}
