import 'package:flutter/material.dart';

/// Couleurs de l'écran Rapports restaurant — alignées sur la maquette
/// (accents rouges, tendances vertes, icônes KPI multicolores).
abstract final class ReportColors {
  static const accent = Color(0xFFE53935);
  static const accentSoft = Color(0xFFFFEBEE);
  static const accentMuted = Color(0xFFFFCDD2);

  static const trendUp = Color(0xFF2E7D32);
  static const trendDown = Color(0xFFC62828);

  static const kpiRevenue = Color(0xFF43A047);
  static const kpiOrders = Color(0xFF1E88E5);
  static const kpiBasket = Color(0xFFFB8C00);
  static const kpiClients = Color(0xFF8E24AA);

  static const pageBackground = Color(0xFFF5F6FA);
  static const cardBackground = Colors.white;
  static const textPrimary = Color(0xFF101529);
  static const textMuted = Color(0xFF7B819B);
}
