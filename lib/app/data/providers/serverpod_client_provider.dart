import 'package:airbar_backend_client/airbar_backend_client.dart';
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';
import '../../services/server_config_service.dart';

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

    _client = Client(serverUrl);
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
