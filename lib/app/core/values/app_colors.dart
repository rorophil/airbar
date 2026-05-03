import 'package:flutter/material.dart';

/// Palette de couleurs de l'application AirBar
///
/// Définit toutes les couleurs utilisées dans l'interface utilisateur
/// pour garantir une cohérence visuelle à travers l'application.
class AppColors {
  // === Primary Colors ===
  /// Couleur primaire principale (Bleu Material)
  static const Color primary = Color(0xFF2196F3);

  /// Variante sombre de la couleur primaire
  static const Color primaryDark = Color(0xFF1976D2);

  /// Variante claire de la couleur primaire
  static const Color primaryLight = Color(0xFF64B5F6);

  // === Accent Colors ===
  /// Couleur d'accentuation (Orange Material)
  static const Color accent = Color(0xFFFF9800);

  /// Variante sombre de la couleur d'accentuation
  static const Color accentDark = Color(0xFFF57C00);

  /// Variante claire de la couleur d'accentuation
  static const Color accentLight = Color(0xFFFFB74D);

  // === Status Colors ===
  /// Couleur pour les états de succès (Vert Material)
  static const Color success = Color(0xFF4CAF50);

  /// Couleur pour les états d'erreur (Rouge Material)
  static const Color error = Color(0xFFF44336);

  /// Couleur pour les avertissements (Orange Material)
  static const Color warning = Color(0xFFFF9800);

  /// Couleur pour les informations (Bleu Material)
  static const Color info = Color(0xFF2196F3);

  // === Background Colors ===
  /// Couleur de fond principale de l'application
  static const Color background = Color(0xFFF5F5F5);

  /// Couleur de surface pour les cartes et composants
  static const Color surface = Color(0xFFFFFFFF);

  /// Couleur de surface pour le thème sombre
  static const Color surfaceDark = Color(0xFF424242);

  // === Text Colors ===
  /// Couleur de texte principale (noir foncé)
  static const Color textPrimary = Color(0xFF212121);

  /// Couleur de texte secondaire (gris moyen)
  static const Color textSecondary = Color(0xFF757575);

  /// Couleur pour les textes d'indication/placeholder (gris clair)
  static const Color textHint = Color(0xFFBDBDBD);

  /// Couleur de texte blanc (pour fonds sombres)
  static const Color textWhite = Color(0xFFFFFFFF);

  // === Stock Status Colors ===
  /// Couleur pour indiquer un stock suffisant (Vert)
  static const Color stockOk = Color(0xFF4CAF50);

  /// Couleur pour indiquer un stock faible (Orange)
  static const Color stockLow = Color(0xFFFF9800);

  /// Couleur pour indiquer une rupture de stock (Rouge)
  static const Color stockOut = Color(0xFFF44336);
}
