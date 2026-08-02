import 'package:flutter/material.dart';

import '../../../../core/utils/avatar_colors.dart';
import '../../domain/entities/client_entity.dart';

/// Avatar à initiales — l'app ne stocke pas de photo client, la couleur de
/// fond varie par client (stable) pour distinguer les lignes de la liste.
class ClientAvatar extends StatelessWidget {
  const ClientAvatar({super.key, required this.client, this.radius = 22});

  final ClientEntity client;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final color = AvatarColors.forId(client.id);
    return CircleAvatar(
      radius: radius,
      backgroundColor: color.withValues(alpha: 0.12),
      child: Text(
        _initials(client.name),
        style: TextStyle(color: color, fontWeight: FontWeight.w600),
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
