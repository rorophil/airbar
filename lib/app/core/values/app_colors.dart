import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/theme_service.dart';

/// Palette de couleurs de l'application AirBar
///
/// Définit toutes les couleurs utilisées dans l'interface utilisateur
/// pour garantir une cohérence visuelle à travers l'application.
///
/// Les couleurs de fond et de texte sont exposées via des getters qui
/// s'adaptent automatiquement au thème actif ([ThemeService.isDarkMode]), afin
/// d'éviter les fonds blancs ou textes foncés illisibles en thème sombre.
class AppColors {
  /// Lecture directe du booléen sombre résolu par [ThemeService], sans
  /// passer par `Theme.of(Get.context)` (évite un décalage d'une frame
  /// au moment du changement de thème, ex: fond des TextField).
  static bool get _isDarkMode => Get.find<ThemeService>().isDarkMode.value;

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
  /// Couleur de fond principale en thème clair
  static const Color backgroundLight = Color(0xFFF5F5F5);

  /// Couleur de fond principale en thème sombre
  static const Color backgroundDark = Color(0xFF121212);

  /// Couleur de surface (cartes, champs) en thème clair
  static const Color surfaceLight = Color(0xFFFFFFFF);

  /// Couleur de surface (cartes, champs) en thème sombre
  static const Color surfaceDark = Color(0xFF1E1E1E);

  /// Couleur de fond principale, adaptée au thème actif
  static Color get background => _isDarkMode ? backgroundDark : backgroundLight;

  /// Couleur de surface pour les cartes et composants, adaptée au thème actif
  static Color get surface => _isDarkMode ? surfaceDark : surfaceLight;

  // === Text Colors ===
  /// Couleur de texte principale, adaptée au thème actif (foncée en clair, claire en sombre)
  static Color get textPrimary =>
      _isDarkMode ? const Color(0xFFF5F5F5) : const Color(0xFF212121);

  /// Couleur de texte secondaire, adaptée au thème actif
  static Color get textSecondary =>
      _isDarkMode ? const Color(0xFFBDBDBD) : const Color(0xFF757575);

  /// Couleur pour les textes d'indication/placeholder, adaptée au thème actif
  static Color get textHint =>
      _isDarkMode ? const Color(0xFF9E9E9E) : const Color(0xFFBDBDBD);

  /// Couleur de texte blanc (pour fonds colorés type boutons/FAB)
  static const Color textWhite = Color(0xFFFFFFFF);

  // === Stock Status Colors ===
  /// Couleur pour indiquer un stock suffisant (Vert)
  static const Color stockOk = Color(0xFF4CAF50);

  /// Couleur pour indiquer un stock faible (Orange)
  static const Color stockLow = Color(0xFFFF9800);

  /// Couleur pour indiquer une rupture de stock (Rouge)
  static const Color stockOut = Color(0xFFF44336);
}
