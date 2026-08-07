import 'package:flutter/material.dart';

abstract final class AppColors {
  static const violetPrincipal = Color(0xFF6B21F3);
  static const violetClair = Color(0xFF8B5CF6);
  static const bleuRoyal = Color(0xFF2563EB);
  static const bleuSaas = Color(0xFF3B82F6);
  static const cyan = Color(0xFF22C7F5);
  static const cyanClair = Color(0xFF60D8FF);
  static const vertPrincipal = Color(0xFF1F5D3B);

  /// Palette neutre partagée par les barres de recherche et chips de filtre
  /// — même apparence sur tous les écrans (Prestations/Commandes, Clients,
  /// Produits).
  static const textPrimary = Color(0xFF101529);
  static const textMuted = Color(0xFF7B819B);
  static const borderSubtle = Color(0xFFE6E8EF);
  static const chipBackground = Color(0xFFF4F5F9);
}
