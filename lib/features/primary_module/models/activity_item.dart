import 'package:flutter/material.dart';

/// Une ligne générique de l'activité principale (commande, prestation,
/// collecte...). Le même modèle sert tous les métiers — seul le contenu
/// change, jamais la forme.
class ActivityItem {
  const ActivityItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.statusKey,
    required this.statusLabel,
    required this.statusColor,
    required this.leadingIcon,
    this.amount,
    this.metaLabel,
    this.badgeCount,
  });

  final String id;
  final String title;
  final String subtitle;
  final DateTime time;
  final String statusKey;
  final String statusLabel;
  final Color statusColor;
  final IconData leadingIcon;
  final double? amount;
  final String? metaLabel;
  final int? badgeCount;
}
