import 'package:airbar_backend_client/airbar_backend_client.dart';
import 'package:serverpod_auth_client/serverpod_auth_client.dart';
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';
import '../../core/constants/app_constants.dart';
import '../../services/server_config_service.dart';

/// Custom authentication key manager using GetStorage
class LocalAuthenticationKeyManager extends AuthenticationKeyManager {
  final GetStorage _storage = GetStorage();

  @override
  Future<String?> get() async {
    return _storage.read<String>(AppConstants.storageKeyToken);
  }

  @override
  Future<void> put(String key) async {
    await _storage.write(AppConstants.storageKeyToken, key);
  }

  @override
  Future<void> remove() async {
    await _storage.remove(AppConstants.storageKeyToken);
  }

  @override
  Future<String?> toHeaderValue(String? authKey) async {
    return authKey;
  }
}

/// Provider for Serverpod client instance
class ServerpodClientProvider {
  static Client? _client;

  /// Get the Serverpod client instance
  static Client get client {
    if (_client == null) {
      throw Exception(
        'ServerpodClient not initialized. Call initialize() first.',
      );
    }
    return _client!;
  }

  /// Initialize the Serverpod client
  static Future<void> initialize() async {
    // Ensure GetStorage is initialized
    await GetStorage.init();

    // Get server URL from config service
    final serverConfig = Get.find<ServerConfigService>();
    final serverUrl = serverConfig.serverUrl;

    _client = Client(
      serverUrl,
      authenticationKeyManager: LocalAuthenticationKeyManager(),
    );
  }

  /// Reinitialize the client with new server configuration
  static Future<void> reinitialize() async {
    dispose();
    await initialize();
  }

  /// Dispose the client
  static void dispose() {
    _client = null;
  }
}
