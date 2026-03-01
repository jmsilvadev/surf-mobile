import 'package:flutter/material.dart';
import 'package:surf_mobile/config/app_config.dart';

class UserAvatar extends StatelessWidget {
  final String? photoUrl;
  final String? name;
  final double radius;

  const UserAvatar({
    super.key,
    this.photoUrl,
    this.name,
    this.radius = 18,
  });

  @override
  Widget build(BuildContext context) {
    if (photoUrl != null && photoUrl!.isNotEmpty) {
      final resolvedUrl = _resolvePhotoUrl(photoUrl!);
      return CircleAvatar(
        radius: radius,
        backgroundColor: Colors.grey.shade200,
        child: ClipOval(
          child: Image.network(
            resolvedUrl,
            width: radius * 2,
            height: radius * 2,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _buildInitials(context),
          ),
        ),
      );
    }

    return _buildInitials(context);
  }

  Widget _buildInitials(BuildContext context) {
    final initials = _getInitials(name);
    return CircleAvatar(
      radius: radius,
      backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.8),
      child: Text(
        initials,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _resolvePhotoUrl(String url) {
    if (url.startsWith('http://') || url.startsWith('https://')) {
      if (url.contains('localhost')) {
        return url.replaceFirst('localhost', '10.0.2.2');
      }
      return url;
    }

    final base = AppConfig.apiBaseUrl;
    if (base.endsWith('/') && url.startsWith('/')) {
      return '${base.substring(0, base.length - 1)}$url';
    }
    if (!base.endsWith('/') && !url.startsWith('/')) {
      return '$base/$url';
    }
    return '$base$url';
  }

  String _getInitials(String? name) {
    if (name == null || name.trim().isEmpty) {
      return '?';
    }

    final parts = name.trim().split(' ');
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }

    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }
}
