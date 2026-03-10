import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service pour gérer la configuration du serveur
class ServerConfigService extends GetxService {
  static const String _keyServerHost = 'server_host';
  static const String _keyServerPort = 'server_port';

  // Valeurs par défaut
  static const String defaultHost = 'localhost';
  static const int defaultPort = 8080;

  late SharedPreferences _prefs;

  final _serverHost = defaultHost.obs;
  final _serverPort = defaultPort.obs;

  String get serverHost => _serverHost.value;
  int get serverPort => _serverPort.value;

  /// URL complète du serveur
  String get serverUrl => 'http://$serverHost:$serverPort/';

  @override
  Future<void> onInit() async {
    super.onInit();
    _prefs = await SharedPreferences.getInstance();
    await _loadConfig();
  }

  /// Charger la configuration sauvegardée
  Future<void> _loadConfig() async {
    _serverHost.value = _prefs.getString(_keyServerHost) ?? defaultHost;
    _serverPort.value = _prefs.getInt(_keyServerPort) ?? defaultPort;
  }

  /// Sauvegarder la configuration du serveur
  Future<void> saveServerConfig({
    required String host,
    required int port,
  }) async {
    await _prefs.setString(_keyServerHost, host);
    await _prefs.setInt(_keyServerPort, port);

    _serverHost.value = host;
    _serverPort.value = port;
  }

  /// Réinitialiser à la configuration par défaut
  Future<void> resetToDefault() async {
    await saveServerConfig(host: defaultHost, port: defaultPort);
  }

  /// Vérifier si la configuration est celle par défaut
  bool get isDefaultConfig {
    return serverHost == defaultHost && serverPort == defaultPort;
  }
}
