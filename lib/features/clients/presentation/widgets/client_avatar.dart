import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/client_entity.dart';

/// Avatar à initiales — l'app ne stocke pas de photo client.
class ClientAvatar extends StatelessWidget {
  const ClientAvatar({super.key, required this.client, this.radius = 24});

  final ClientEntity client;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.zuriPink.withValues(alpha: 0.14),
      child: Text(
        _initials(client.name),
        style: TextStyle(
          color: AppColors.zuriRed,
          fontWeight: FontWeight.w800,
          fontSize: radius * 0.72,
        ),
      ),
    );
  }

  String _initials(String name) {
    final parts =
        name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }
}
