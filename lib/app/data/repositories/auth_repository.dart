import 'package:get/get.dart';
import '../../services/auth_service.dart';
import '../providers/serverpod_client_provider.dart';
import 'package:airbar_backend_client/airbar_backend_client.dart';

/// Repository de gestion de l'authentification
///
/// Implémente le pattern Repository pour abstraire l'accès aux opérations
/// d'authentification. Gère la connexion, déconnexion, validation du code PIN,
/// et la vérification de l'état d'authentification.
///
/// Ce repository ne gère PAS de cache car les données d'authentification
/// sont sensibles et gérées par [AuthService].
class AuthRepository {
  /// Client Serverpod pour les appels API
  Client get _client => ServerpodClientProvider.client;

  /// Service d'authentification global
  final _authService = Get.find<AuthService>();

  /// Authentifie un utilisateur avec son email et mot de passe
  ///
  /// [email] L'adresse email de l'utilisateur
  /// [password] Le mot de passe en clair (sera hashé côté backend)
  ///
  /// Returns: Map contenant:
  /// - `success` (bool): true si connexion réussie
  /// - `user` (User): données utilisateur si succès
  /// - `error` (String): message d'erreur si échec
  ///
  /// Note: En cas de succès, l'utilisateur est automatiquement enregistré
  /// dans [AuthService] pour un accès global.
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      // Appel à l'endpoint d'authentification backend
      final user = await _client.auth.login(email, password);

      if (user != null) {
        // Enregistrement de l'utilisateur dans le service global
        // Cela rend l'utilisateur accessible partout via AuthService.to.currentUser
        _authService.setUser(user);

        return {'success': true, 'user': user};
      }

      // User est null = identifiants incorrects ou compte désactivé
      return {
        'success': false,
        'error': 'Email ou mot de passe incorrect, ou compte désactivé',
      };
    } catch (e) {
      // Capture les erreurs réseau ou serveur
      print('Login error: $e');
      return {
        'success': false,
        'error': 'Erreur de connexion. Veuillez réessayer.',
      };
    }
  }

  /// Déconnecte l'utilisateur actuel
  ///
  /// Supprime la clé d'authentification du gestionnaire de sessions
  /// et efface les données utilisateur de [AuthService].
  ///
  /// Note: Ne lance pas d'exception en cas d'erreur pour éviter
  /// de bloquer le processus de déconnexion.
  Future<void> logout() async {
    try {
      // Suppression de la clé d'authentification Serverpod
      await _client.authenticationKeyManager!.remove();

      // Nettoyage des données utilisateur du service global
      _authService.clearUser();
    } catch (e) {
      // Log de l'erreur mais on ne bloque pas le processus de déconnexion
      print('Logout error: $e');
    }
  }

  /// Valide le code PIN d'un utilisateur
  ///
  /// Utilisé principalement lors du checkout pour confirmer l'identité
  /// de l'utilisateur avant de débiter son compte.
  ///
  /// [userId] L'ID de l'utilisateur
  /// [pin] Le code PIN à valider (sera hashé côté backend)
  ///
  /// Returns: `true` si le PIN est correct, `false` sinon
  Future<bool> validatePin(int userId, String pin) async {
    try {
      return await _client.auth.validatePin(userId, pin);
    } catch (e) {
      print('Validate PIN error: $e');
      return false;
    }
  }

  /// Modifie le code PIN d'un utilisateur
  ///
  /// [userId] L'ID de l'utilisateur
  /// [oldPin] L'ancien code PIN pour validation
  /// [newPin] Le nouveau code PIN (sera hashé côté backend)
  ///
  /// Returns: `true` si le changement a réussi, `false` en cas d'erreur
  ///
  /// Throws: Exception si l'ancien PIN est incorrect (capturée et retourne false)
  Future<bool> changePin(int userId, String oldPin, String newPin) async {
    try {
      await _client.auth.changePin(userId, oldPin, newPin);
      return true;
    } catch (e) {
      print('Change PIN error: $e');
      return false;
    }
  }

  /// Vérifie si un utilisateur est actuellement authentifié
  ///
  /// Returns: `true` si une clé d'authentification valide existe,
  /// `false` sinon
  Future<bool> isAuthenticated() async {
    try {
      // Récupération de la clé d'authentification stockée
      final authKey = await _client.authenticationKeyManager!.get();
      return authKey != null;
    } catch (e) {
      // En cas d'erreur, considérer comme non authentifié
      return false;
    }
  }

  /// Récupère la clé d'authentification actuelle
  ///
  /// Returns: La clé d'authentification si elle existe, `null` sinon
  ///
  /// Note: Cette méthode est rarement utilisée directement. Préférer
  /// [isAuthenticated] pour vérifier l'état d'authentification.
  Future<String?> getAuthKey() async {
    try {
      return await _client.authenticationKeyManager!.get();
    } catch (e) {
      return null;
    }
  }
}
