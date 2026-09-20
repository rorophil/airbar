import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/constants/app_constants.dart';
import 'storage_service.dart';

/// Service de gestion du thème de l'application (clair, sombre, automatique)
///
/// Persiste le choix de l'utilisateur via [StorageService] et applique
/// immédiatement le changement à l'application via `Get.changeThemeMode`.
class ThemeService extends GetxService {
  final StorageService _storage = Get.find<StorageService>();

  /// Mode de thème actuellement sélectionné
  final themeMode = ThemeMode.system.obs;

  @override
  void onInit() {
    super.onInit();
    // Chargement du mode sauvegardé (par défaut: automatique/système)
    final saved = _storage.read<String>(AppConstants.storageKeyThemeMode);
    themeMode.value = _fromStorageValue(saved);
  }

  /// Change le thème de l'application et sauvegarde le choix
  Future<void> changeThemeMode(ThemeMode mode) async {
    themeMode.value = mode;
    Get.changeThemeMode(mode);
    _storage.write(AppConstants.storageKeyThemeMode, _toStorageValue(mode));
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
