import 'dart:io';
import 'package:airbar_backend_client/airbar_backend_client.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';
import '../../services/server_config_service.dart';

/// Chemins des certificats de CA racine épinglés (certificate pinning)
///
/// Un certificat par environnement sécurisé (staging/production), chacun avec
/// sa propre CA locale Caddy. Le chargement est tolérant aux fichiers absents
/// (ex: la CA de production n'existe pas encore tant que ce serveur n'a pas
/// été déployé) pour ne jamais faire planter l'application.
const List<String> _pinnedCaAssetPaths = [
  'assets/certs/staging_root_ca.pem',
  'assets/certs/production_root_ca.pem',
];

/// Provider singleton pour l'instance du client Serverpod
///
/// Gère la création et le cycle de vie du client Serverpod.
/// Le client est configuré avec l'URL du serveur depuis [ServerConfigService].
///
/// Usage:
/// ```dart
/// final client = ServerpodClientProvider.client;
/// final products = await client.product.getAllProducts();
/// ```
class ServerpodClientProvider {
  static Client? _client;
  static SecurityContext? _pinnedSecurityContext;

  /// Récupère l'instance singleton du client Serverpod
  ///
  /// Throws: Exception si le client n'est pas initialisé
  /// (appeler [initialize] d'abord)
  static Client get client {
    if (_client == null) {
      throw Exception(
        'ServerpodClient not initialized. Call initialize() first.',
      );
    }
    return _client!;
  }

  /// Construit (et met en cache) le [SecurityContext] épinglé sur les CA
  /// locales connues, en excluant les CA publiques (`withTrustedRoots: false`).
  ///
  /// Réutilisable par d'autres parties de l'app (ex: test de connexion dans
  /// les réglages) qui doivent établir une connexion HTTPS avec le même
  /// niveau de confiance que le client Serverpod.
  static Future<SecurityContext> get pinnedSecurityContext async {
    if (_pinnedSecurityContext != null) {
      return _pinnedSecurityContext!;
    }

    final context = SecurityContext(withTrustedRoots: false);
    for (final assetPath in _pinnedCaAssetPaths) {
      try {
        final bytes = await rootBundle.load(assetPath);
        context.setTrustedCertificatesBytes(
          bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes),
        );
      } catch (_) {
        // Certificat pas encore disponible (ex: CA de production pas encore
        // déployée) : on continue avec les autres CA déjà chargées.
      }
    }

    _pinnedSecurityContext = context;
    return context;
  }

  /// Initialise le client Serverpod avec la configuration actuelle
  ///
  /// Doit être appelé au démarrage de l'application (dans main.dart)
  /// après l'initialisation de GetStorage et ServerConfigService.
  ///
  /// Le client est configuré avec l'URL du serveur depuis [ServerConfigService].
  static Future<void> initialize() async {
    // Vérification que GetStorage est initialisé
    await GetStorage.init();

    // Récupération de l'URL du serveur depuis la configuration
    final serverConfig = Get.find<ServerConfigService>();
    final serverUrl = serverConfig.serverUrl;

    if (serverConfig.useHttps) {
      final context = await pinnedSecurityContext;
      _client = Client(serverUrl, securityContext: context);
    } else {
      _client = Client(serverUrl);
    }
  }

  /// Réinitialise le client avec une nouvelle configuration serveur
  ///
  /// Utilisé après un changement de configuration serveur (IP/port).
  /// Dispose l'ancien client et en crée un nouveau.
  static Future<void> reinitialize() async {
    dispose();
    await initialize();
  }

  /// Libère les ressources du client Serverpod
  ///
  /// Met l'instance à null pour forcer une réinitialisation.
  static void dispose() {
    _client = null;
  }
}
