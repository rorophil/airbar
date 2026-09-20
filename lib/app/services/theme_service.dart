import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/constants/app_constants.dart';
import 'storage_service.dart';

/// Service de gestion du thème de l'application (clair, sombre, automatique)
///
/// Persiste le choix de l'utilisateur via [StorageService] et applique
/// immédiatement le changement à l'application via `Get.changeThemeMode`.
///
/// Expose [isDarkMode], calculé de manière synchrone (sans passer par
/// `Theme.of(Get.context)`) afin que les couleurs dépendantes du thème
/// (voir [AppColors]) se mettent à jour immédiatement, sans décalage d'une frame.
class ThemeService extends GetxService with WidgetsBindingObserver {
  final StorageService _storage = Get.find<StorageService>();

  /// Mode de thème actuellement sélectionné
  final themeMode = ThemeMode.system.obs;

  /// Etat sombre effectif résolu (tient compte du mode "automatique")
  final isDarkMode = false.obs;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    // Chargement du mode sauvegardé (par défaut: automatique/système)
    final saved = _storage.read<String>(AppConstants.storageKeyThemeMode);
    themeMode.value = _fromStorageValue(saved);
    _updateIsDarkMode();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangePlatformBrightness() {
    // Ne concerne que le mode "automatique": la luminosité système a changé
    if (themeMode.value == ThemeMode.system) {
      _updateIsDarkMode();
    }
  }

  /// Change le thème de l'application et sauvegarde le choix
  Future<void> changeThemeMode(ThemeMode mode) async {
    themeMode.value = mode;
    // Résolu avant tout rebuild déclenché par themeMode, évite le décalage
    _updateIsDarkMode();
    Get.changeThemeMode(mode);
    _storage.write(AppConstants.storageKeyThemeMode, _toStorageValue(mode));
  }

  void _updateIsDarkMode() {
    switch (themeMode.value) {
      case ThemeMode.dark:
        isDarkMode.value = true;
      case ThemeMode.light:
        isDarkMode.value = false;
      case ThemeMode.system:
        isDarkMode.value = Get.isPlatformDarkMode;
    }
  }

  ThemeMode _fromStorageValue(String? value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  String _toStorageValue(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }
}
