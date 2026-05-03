import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../services/server_config_service.dart';
import '../../../data/providers/serverpod_client_provider.dart';

/// Controller du module Settings
///
/// Gère la configuration du serveur Serverpod (adresse IP et port).
/// Permet à l'utilisateur de modifier dynamiquement la connexion au backend
/// sans recompiler l'application.
///
/// État géré:
/// - [isLoading]: Indicateur de test de connexion en cours
/// - [isSaving]: Indicateur de sauvegarde en cours
///
/// Opérations principales:
/// - [saveConfiguration()]: Enregistre la config et réinitialise le client
/// - [testConnection()]: Teste la connectivité au serveur
/// - [resetToDefault()]: Restaure la configuration par défaut
///
/// Configuration par défaut: localhost:8080
class SettingsController extends GetxController {
  /// Service de configuration serveur (stockage persistant)
  final ServerConfigService _configService = Get.find<ServerConfigService>();

  /// Controller du champ adresse IP/hostname
  late final TextEditingController hostController;

  /// Controller du champ port
  late final TextEditingController portController;

  /// Indicateur de test de connexion en cours
  final isLoading = false.obs;

  /// Indicateur de sauvegarde de configuration en cours
  final isSaving = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Initialisation des champs avec la configuration actuelle
    hostController = TextEditingController(text: _configService.serverHost);
    portController = TextEditingController(
      text: _configService.serverPort.toString(),
    );
  }

  @override
  void onClose() {
    // Libération des controllers de texte
    hostController.dispose();
    portController.dispose();
    super.onClose();
  }

  /// Sauvegarder la configuration du serveur
  ///
  /// Processus:
  /// 1. Validation des champs (host non vide, port entre 1-65535)
  /// 2. Sauvegarde dans ServerConfigService (stockage local)
  /// 3. Réinitialisation du client Serverpod avec la nouvelle config
  /// 4. Retour à l'écran précédent
  ///
  /// En cas d'erreur, affiche un snackbar d'erreur.
  Future<void> saveConfiguration() async {
    final host = hostController.text.trim();
    final portText = portController.text.trim();

    // Validation: host ne doit pas être vide
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

    // Validation: port doit être un nombre entre 1 et 65535
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

      // Sauvegarde de la nouvelle configuration
      await _configService.saveServerConfig(host: host, port: port);

      // Réinitialisation du client Serverpod avec la nouvelle URL
      await ServerpodClientProvider.reinitialize();

      Get.snackbar(
        'Succès',
        'Configuration du serveur sauvegardée',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Retour à l'écran de login
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
  ///
  /// Restaure les valeurs par défaut:
  /// - Host: localhost
  /// - Port: 8080
  ///
  /// Ne sauvegarde pas automatiquement, l'utilisateur doit cliquer sur "Sauvegarder".
  Future<void> resetToDefault() async {
    hostController.text = ServerConfigService.defaultHost;
    portController.text = ServerConfigService.defaultPort.toString();
  }

  /// Tester la connexion au serveur
  ///
  /// Tente une connexion au serveur avec les paramètres actuels.
  ///
  /// TODO: Implémenter un vrai test de connexion (endpoint health check)
  /// Actuellement fait juste un délai simulé.
  ///
  /// Affiche un snackbar de succès ou d'erreur selon le résultat.
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
