import 'package:airbar_backend_client/airbar_backend_client.dart';
import 'package:serverpod_auth_client/serverpod_auth_client.dart';
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';
import '../../core/constants/app_constants.dart';
import '../../services/server_config_service.dart';

/// Gestionnaire de clés d'authentification personnalisé utilisant GetStorage
///
/// Implémente [AuthenticationKeyManager] de Serverpod pour persister
/// le token d'authentification localement via GetStorage.
///
/// Le token est automatiquement ajouté aux en-têtes HTTP de toutes
/// les requêtes vers le serveur Serverpod.
class LocalAuthenticationKeyManager extends AuthenticationKeyManager {
  final GetStorage _storage = GetStorage();

  /// Récupère le token d'authentification depuis le stockage local
  ///
  /// Returns: Token stocké ou null si non connecté
  @override
  Future<String?> get() async {
    return _storage.read<String>(AppConstants.storageKeyToken);
  }

  /// Sauvegarde le token d'authentification dans le stockage local
  ///
  /// [key] Token d'authentification reçu du serveur
  @override
  Future<void> put(String key) async {
    await _storage.write(AppConstants.storageKeyToken, key);
  }

  /// Supprime le token d'authentification (déconnexion)
  @override
  Future<void> remove() async {
    await _storage.remove(AppConstants.storageKeyToken);
  }

  /// Convertit le token en valeur d'en-tête HTTP
  ///
  /// [authKey] Token à convertir
  /// Returns: Token inchangé (pas de transformation nécessaire)
  @override
  Future<String?> toHeaderValue(String? authKey) async {
    return authKey;
  }
}

/// Provider singleton pour l'instance du client Serverpod
///
/// Gère la création et le cycle de vie du client Serverpod.
/// Le client est configuré avec l'URL du serveur depuis [ServerConfigService]
/// et utilise [LocalAuthenticationKeyManager] pour la persistance du token.
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
  /// Le client est configuré avec:
  /// - L'URL du serveur depuis [ServerConfigService]
  /// - Le gestionnaire d'authentification [LocalAuthenticationKeyManager]
  static Future<void> initialize() async {
    // Vérification que GetStorage est initialisé
    await GetStorage.init();

    // Récupération de l'URL du serveur depuis la configuration
    final serverConfig = Get.find<ServerConfigService>();
    final serverUrl = serverConfig.serverUrl;

    // Création du client Serverpod avec gestionnaire d'authentification
    _client = Client(
      serverUrl,
      authenticationKeyManager: LocalAuthenticationKeyManager(),
    );
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
