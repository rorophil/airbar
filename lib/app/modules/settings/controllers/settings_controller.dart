import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../../services/server_config_service.dart';
import '../../../services/connectivity_service.dart';
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

  /// Controller du champ délai d'inactivité (minutes, 0 = désactivé)
  late final TextEditingController inactivityController;

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
    inactivityController = TextEditingController(
      text: _configService.inactivityTimeoutMinutes.toString(),
    );
  }

  @override
  void onClose() {
    // Libération des controllers de texte
    hostController.dispose();
    portController.dispose();
    inactivityController.dispose();
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

    // Validation: délai d'inactivité entre 0 (désactivé) et 120 minutes
    final inactivityMinutes = int.tryParse(inactivityController.text.trim());
    if (inactivityMinutes == null ||
        inactivityMinutes < 0 ||
        inactivityMinutes > 120) {
      Get.snackbar(
        'Erreur',
        'Veuillez entrer un délai d\'inactivité valide (0-120)',
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
      await _configService.saveInactivityTimeout(inactivityMinutes);

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
    inactivityController.text = ServerConfigService
        .defaultInactivityTimeoutMinutes
        .toString();
  }

  /// Tester la connexion au serveur
  ///
  /// Tente une connexion au serveur avec les paramètres actuels du formulaire.
  ///
  /// Vérifie d'abord la connectivité réseau de l'appareil, puis effectue une
  /// vraie requête HTTP vers la racine du serveur avec un timeout de 10s.
  ///
  /// Affiche un snackbar de succès ou d'erreur selon le résultat.
  Future<void> testConnection() async {
    final host = hostController.text.trim();
    final port = int.tryParse(portController.text.trim());

    if (host.isEmpty || port == null || port < 1 || port > 65535) {
      Get.snackbar(
        'Erreur',
        'Adresse ou port invalide',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Vérification de la connectivité réseau avant tout appel (évite un blocage hors-ligne)
    if (!Get.find<ConnectivityService>().requiresConnection(
      'tester la connexion',
    )) {
      return;
    }

    try {
      isLoading.value = true;

      final response = await http
          .get(Uri.parse('http://$host:$port/'))
          .timeout(const Duration(seconds: 10));

      // Le serveur Serverpod a répondu, peu importe le code de statut exact
      Get.snackbar(
        'Succès',
        'Connexion au serveur réussie (code ${response.statusCode})',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } on TimeoutException {
      Get.snackbar(
        'Erreur',
        'Le serveur ne répond pas (délai dépassé)',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de joindre le serveur à cette adresse',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
