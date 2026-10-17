import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service de gestion de la configuration du serveur Serverpod
///
/// Permet de modifier dynamiquement l'hôte et le port du serveur
/// sans recompiler l'application. Configuration persistée via SharedPreferences.
class ServerConfigService extends GetxService {
  static const String _keyServerHost = 'server_host';
  static const String _keyServerPort = 'server_port';
  static const String _keyUseHttps = 'server_use_https';
  static const String _keyInactivityTimeoutMinutes =
      'inactivity_timeout_minutes';

  // Valeurs par défaut (localhost:8080 en HTTP, pour le développement local)
  static const String defaultHost = 'localhost';
  static const int defaultPort = 8080;
  static const bool defaultUseHttps = false;

  /// Délai d'inactivité par défaut avant déconnexion automatique (0 = désactivé)
  static const int defaultInactivityTimeoutMinutes = 5;

  late SharedPreferences _prefs;

  /// Hôte du serveur (observable)
  final _serverHost = defaultHost.obs;

  /// Port du serveur (observable)
  final _serverPort = defaultPort.obs;

  /// Connexion sécurisée HTTPS activée (observable)
  ///
  /// À désactiver uniquement pour le développement local (serveur Dart en HTTP).
  /// Pour les environnements staging/production (derrière Caddy), doit rester activé.
  final _useHttps = defaultUseHttps.obs;

  /// Délai d'inactivité en minutes avant déconnexion automatique (observable)
  final _inactivityTimeoutMinutes = defaultInactivityTimeoutMinutes.obs;

  /// Getter pour l'hôte actuel
  String get serverHost => _serverHost.value;

  /// Getter pour le port actuel
  int get serverPort => _serverPort.value;

  /// Getter pour l'état de la connexion sécurisée (HTTPS)
  bool get useHttps => _useHttps.value;

  /// Getter pour le délai d'inactivité actuel (minutes, 0 = désactivé)
  int get inactivityTimeoutMinutes => _inactivityTimeoutMinutes.value;

  /// URL complète du serveur (format: http(s)://host:port/)
  String get serverUrl =>
      '${useHttps ? 'https' : 'http'}://$serverHost:$serverPort/';

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
    _useHttps.value = _prefs.getBool(_keyUseHttps) ?? defaultUseHttps;
    _inactivityTimeoutMinutes.value =
        _prefs.getInt(_keyInactivityTimeoutMinutes) ??
        defaultInactivityTimeoutMinutes;
  }

  /// Sauvegarde la configuration du serveur
  ///
  /// [host] Adresse IP ou nom de domaine du serveur
  /// [port] Port du serveur Serverpod
  /// [useHttps] Active la connexion sécurisée (HTTPS + certificate pinning)
  ///
  /// La configuration est persistée et active immédiatement.
  Future<void> saveServerConfig({
    required String host,
    required int port,
    required bool useHttps,
  }) async {
    await _prefs.setString(_keyServerHost, host);
    await _prefs.setInt(_keyServerPort, port);
    await _prefs.setBool(_keyUseHttps, useHttps);

    _serverHost.value = host;
    _serverPort.value = port;
    _useHttps.value = useHttps;
  }

  /// Sauvegarde le délai d'inactivité avant déconnexion automatique
  ///
  /// [minutes] Délai en minutes (0 désactive la déconnexion automatique)
  Future<void> saveInactivityTimeout(int minutes) async {
    await _prefs.setInt(_keyInactivityTimeoutMinutes, minutes);
    _inactivityTimeoutMinutes.value = minutes;
  }

  /// Réinitialise la configuration aux valeurs par défaut
  ///
  /// Restaure localhost:8080 en HTTP comme configuration serveur.
  Future<void> resetToDefault() async {
    await saveServerConfig(
      host: defaultHost,
      port: defaultPort,
      useHttps: defaultUseHttps,
    );
  }

  /// Vérifie si la configuration actuelle est celle par défaut
  ///
  /// Returns: `true` si host=localhost, port=8080 et useHttps=false
  bool get isDefaultConfig {
    return serverHost == defaultHost &&
        serverPort == defaultPort &&
        useHttps == defaultUseHttps;
  }
}
