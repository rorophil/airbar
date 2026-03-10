import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../services/server_config_service.dart';
import '../../../data/providers/serverpod_client_provider.dart';

class SettingsController extends GetxController {
  final ServerConfigService _configService = Get.find<ServerConfigService>();

  late final TextEditingController hostController;
  late final TextEditingController portController;

  final isLoading = false.obs;
  final isSaving = false.obs;

  @override
  void onInit() {
    super.onInit();
    hostController = TextEditingController(text: _configService.serverHost);
    portController = TextEditingController(
      text: _configService.serverPort.toString(),
    );
  }

  @override
  void onClose() {
    hostController.dispose();
    portController.dispose();
    super.onClose();
  }

  /// Sauvegarder la configuration du serveur
  Future<void> saveConfiguration() async {
    final host = hostController.text.trim();
    final portText = portController.text.trim();

    if (host.isEmpty) {
      Get.snackbar(
        'Erreur',
        'Veuillez entrer l\'adresse du serveur',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final port = int.tryParse(portText);
    if (port == null || port < 1 || port > 65535) {
      Get.snackbar(
        'Erreur',
        'Veuillez entrer un port valide (1-65535)',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isSaving.value = true;

      // Sauvegarder la configuration
      await _configService.saveServerConfig(host: host, port: port);

      // Réinitialiser le client Serverpod
      await ServerpodClientProvider.reinitialize();

      Get.snackbar(
        'Succès',
        'Configuration du serveur sauvegardée',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Retourner à l'écran précédent
      Get.back();
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Erreur lors de la sauvegarde: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isSaving.value = false;
    }
  }

  /// Réinitialiser à la configuration par défaut
  Future<void> resetToDefault() async {
    hostController.text = ServerConfigService.defaultHost;
    portController.text = ServerConfigService.defaultPort.toString();
  }

  /// Tester la connexion au serveur
  Future<void> testConnection() async {
    try {
      isLoading.value = true;

      // TODO: Implémenter un test de connexion réel
      await Future.delayed(const Duration(seconds: 1));

      Get.snackbar(
        'Succès',
        'Connexion au serveur réussie',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de se connecter au serveur',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
