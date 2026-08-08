import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Couleurs de l'écran Rapports restaurant — charte Zuri Business.
abstract final class ReportColors {
  static const accent = AppColors.zuriRed;
  static const accentSoft = Color(0xFFFFE8EE);
  static const accentMuted = Color(0xFFFFCDD2);
  static const accentGradientEnd = AppColors.zuriMagenta;

  static const trendUp = Color(0xFF2E7D32);
  static const trendDown = Color(0xFFC62828);

  static const kpiRevenue = AppColors.zuriPink;
  static const kpiRevenueSoft = Color(0xFFFFE4EF);
  static const kpiOrders = Color(0xFF1E88E5);
  static const kpiOrdersSoft = Color(0xFFE3F2FD);
  static const kpiBasket = Color(0xFFFB8C00);
  static const kpiBasketSoft = Color(0xFFFFF3E0);
  static const kpiClients = Color(0xFF8E24AA);
  static const kpiClientsSoft = Color(0xFFF3E5F5);

  static const pageBackground = AppColors.zuriWhite;
  static const cardBackground = AppColors.zuriWhite;
  static const textPrimary = AppColors.zuriNavy;
  static const textMuted = Color(0xFF8A90A5);
  static const border = Color(0xFFE8EAF0);
}
