import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service de gestion de la configuration du serveur Serverpod
///
/// Permet de modifier dynamiquement l'hôte et le port du serveur
/// sans recompiler l'application. Configuration persistée via SharedPreferences.
class ServerConfigService extends GetxService {
  static const String _keyServerHost = 'server_host';
  static const String _keyServerPort = 'server_port';

  // Valeurs par défaut (localhost:8080)
  static const String defaultHost = 'localhost';
  static const int defaultPort = 8080;

  late SharedPreferences _prefs;

  /// Hôte du serveur (observable)
  final _serverHost = defaultHost.obs;

  /// Port du serveur (observable)
  final _serverPort = defaultPort.obs;

  /// Getter pour l'hôte actuel
  String get serverHost => _serverHost.value;

  /// Getter pour le port actuel
  int get serverPort => _serverPort.value;

  /// URL complète du serveur (format: http://host:port/)
  String get serverUrl => 'http://$serverHost:$serverPort/';

  @override
  Future<void> onInit() async {
    super.onInit();
    _prefs = await SharedPreferences.getInstance();
    // Chargement de la configuration sauvegardée
    await _loadConfig();
  }

  /// Charge la configuration sauvegardée depuis SharedPreferences
  ///
  /// Utilise les valeurs par défaut si aucune configuration n'existe.
  Future<void> _loadConfig() async {
    _serverHost.value = _prefs.getString(_keyServerHost) ?? defaultHost;
    _serverPort.value = _prefs.getInt(_keyServerPort) ?? defaultPort;
  }

  /// Sauvegarde la configuration du serveur
  ///
  /// [host] Adresse IP ou nom de domaine du serveur
  /// [port] Port du serveur Serverpod
  ///
  /// La configuration est persistée et active immédiatement.
  Future<void> saveServerConfig({
    required String host,
    required int port,
  }) async {
    await _prefs.setString(_keyServerHost, host);
    await _prefs.setInt(_keyServerPort, port);

    _serverHost.value = host;
    _serverPort.value = port;
  }

  /// Réinitialise la configuration aux valeurs par défaut
  ///
  /// Restaure localhost:8080 comme configuration serveur.
  Future<void> resetToDefault() async {
    await saveServerConfig(host: defaultHost, port: defaultPort);
  }

  /// Vérifie si la configuration actuelle est celle par défaut
  ///
  /// Returns: `true` si host=localhost et port=8080
  bool get isDefaultConfig {
    return serverHost == defaultHost && serverPort == defaultPort;
  }
}
