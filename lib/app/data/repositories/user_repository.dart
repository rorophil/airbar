import '../providers/serverpod_client_provider.dart';
import 'package:airbar_backend_client/airbar_backend_client.dart';

/// Repository de gestion des utilisateurs
///
/// Implémente le pattern Repository pour abstraire l'accès aux opérations
/// de gestion des utilisateurs. Ce repository gère:
/// - CRUD des utilisateurs (création, lecture, mise à jour, suppression)
/// - Activation/désactivation des comptes
/// - Réinitialisation des mots de passe et codes PIN
/// - Crédit/débit des comptes utilisateurs
///
/// Note: La plupart de ces opérations nécessitent des privilèges administrateur.
/// Ce repository ne gère PAS de cache car les données utilisateur doivent
/// toujours être à jour (solde de compte, statut, etc.).
class UserRepository {
  /// Client Serverpod pour les appels API
  Client get _client => ServerpodClientProvider.client;

  /// Récupère tous les utilisateurs du système
  ///
  /// Returns: Liste de tous les utilisateurs (actifs et inactifs)
  ///
  /// Throws: Exception si l'utilisateur n'a pas les droits admin ou erreur serveur
  ///
  /// Note: Opération réservée aux administrateurs uniquement
  Future<List<dynamic>> getAllUsers() async {
    try {
      return await _client.user.getAllUsers();
    } catch (e) {
      print('Get all users error: $e');
      rethrow;
    }
  }

  /// Récupère un utilisateur par son ID
  ///
  /// [userId] L'ID de l'utilisateur à récupérer
  ///
  /// Returns: Les données complètes de l'utilisateur
  ///
  /// Throws: Exception si l'utilisateur n'existe pas ou erreur serveur
  Future<dynamic> getUserById(int userId) async {
    try {
      return await _client.user.getUserById(userId);
    } catch (e) {
      print('Get user by ID error: $e');
      rethrow;
    }
  }

  /// Crée un nouveau compte utilisateur
  ///
  /// [email] Adresse email (doit être unique)
  /// [password] Mot de passe en clair (sera hashé côté backend)
  /// [firstName] Prénom de l'utilisateur
  /// [lastName] Nom de famille de l'utilisateur
  /// [pin] Code PIN à 4-6 chiffres (sera hashé côté backend avec SHA256)
  /// [role] Rôle de l'utilisateur (UserRole.user ou UserRole.admin)
  ///
  /// Returns: L'utilisateur créé avec son ID et solde initial (0.0€)
  ///
  /// Throws: Exception si l'email existe déjà, PIN invalide, ou erreur serveur
  ///
  /// Note: Opération réservée aux administrateurs uniquement
  Future<dynamic> createUser({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String pin,
    required UserRole role,
  }) async {
    try {
      return await _client.user.createUser(
        email,
        password,
        firstName,
        lastName,
        pin,
        role,
      );
    } catch (e) {
      print('Create user error: $e');
      rethrow;
    }
  }

  /// Met à jour les informations d'un utilisateur existant
  ///
  /// [userId] L'ID de l'utilisateur à modifier
  /// [email] Nouvelle adresse email (doit rester unique)
  /// [firstName] Nouveau prénom
  /// [lastName] Nouveau nom de famille
  /// [role] Nouveau rôle
  ///
  /// Returns: L'utilisateur mis à jour
  ///
  /// Throws: Exception si l'email existe déjà pour un autre utilisateur,
  /// utilisateur introuvable, ou erreur serveur
  ///
  /// Note: Cette méthode ne permet PAS de changer le mot de passe ou le PIN.
  /// Utiliser [resetPassword] et [resetPin] pour ces opérations.
  /// Opération réservée aux administrateurs uniquement.
  Future<dynamic> updateUser({
    required int userId,
    required String email,
    required String firstName,
    required String lastName,
    required UserRole role,
  }) async {
    try {
      return await _client.user.updateUser(
        userId,
        email,
        firstName,
        lastName,
        role,
      );
    } catch (e) {
      print('Update user error: $e');
      rethrow;
    }
  }

  /// Désactive un compte utilisateur
  ///
  /// [userId] L'ID de l'utilisateur à désactiver
  ///
  /// L'utilisateur désactivé ne pourra plus se connecter mais ses données
  /// sont préservées (historique transactions, solde, etc.).
  ///
  /// Throws: Exception si l'utilisateur n'existe pas ou erreur serveur
  ///
  /// Note: Opération réservée aux administrateurs uniquement.
  /// Préférer la désactivation à la suppression pour préserver l'historique.
  Future<void> deactivateUser(int userId) async {
    try {
      await _client.user.deactivateUser(userId);
    } catch (e) {
      print('Deactivate user error: $e');
      rethrow;
    }
  }

  /// Réactive un compte utilisateur précédemment désactivé
  ///
  /// [userId] L'ID de l'utilisateur à réactiver
  ///
  /// Permet à l'utilisateur de se reconnecter avec ses identifiants existants.
  ///
  /// Throws: Exception si l'utilisateur n'existe pas ou erreur serveur
  ///
  /// Note: Opération réservée aux administrateurs uniquement
  Future<void> reactivateUser(int userId) async {
    try {
      await _client.user.reactivateUser(userId);
    } catch (e) {
      print('Reactivate user error: $e');
      rethrow;
    }
  }

  /// Réinitialise le mot de passe d'un utilisateur
  ///
  /// [userId] L'ID de l'utilisateur
  /// [newPassword] Le nouveau mot de passe (sera hashé côté backend)
  ///
  /// Utilisé lorsqu'un utilisateur a oublié son mot de passe.
  ///
  /// Throws: Exception si l'utilisateur n'existe pas ou erreur serveur
  ///
  /// Note: Opération réservée aux administrateurs uniquement
  Future<void> resetPassword(int userId, String newPassword) async {
    try {
      await _client.user.resetPassword(userId, newPassword);
    } catch (e) {
      print('Reset password error: $e');
      rethrow;
    }
  }

  /// Réinitialise le code PIN d'un utilisateur
  ///
  /// [userId] L'ID de l'utilisateur
  /// [newPin] Le nouveau code PIN (sera hashé côté backend avec SHA256)
  ///
  /// Utilisé lorsqu'un utilisateur a oublié son code PIN.
  ///
  /// Throws: Exception si l'utilisateur n'existe pas, PIN invalide,
  /// ou erreur serveur
  ///
  /// Note: Opération réservée aux administrateurs uniquement
  Future<void> resetPin(int userId, String newPin) async {
    try {
      await _client.user.resetPin(userId, newPin);
    } catch (e) {
      print('Reset PIN error: $e');
      rethrow;
    }
  }

  /// Supprime définitivement un utilisateur
  ///
  /// [userId] L'ID de l'utilisateur à supprimer
  ///
  /// ⚠️ ATTENTION: Suppression définitive, non réversible!
  /// Préférer [deactivateUser] pour préserver l'historique.
  ///
  /// Throws: Exception si l'utilisateur n'existe pas ou erreur serveur
  ///
  /// Note: Opération réservée aux administrateurs uniquement
  Future<void> deleteUser(int userId) async {
    try {
      await _client.user.deleteUser(userId);
    } catch (e) {
      print('Delete user error: $e');
      rethrow;
    }
  }

  /// Crédite ou débite le compte d'un utilisateur
  ///
  /// [userId] L'ID de l'utilisateur
  /// [amount] Montant à ajouter (positif) ou retirer (négatif) en euros
  /// [notes] Notes optionnelles expliquant la raison de l'opération
  ///
  /// Exemples:
  /// - Crédit: amount = 50.0 (ajoute 50€)
  /// - Débit: amount = -20.0 (retire 20€)
  ///
  /// Returns: La transaction créée avec le nouveau solde
  ///
  /// Throws: Exception si:
  /// - Montant = 0 (invalide)
  /// - Débit supérieur au solde disponible
  /// - Utilisateur introuvable ou erreur serveur
  ///
  /// Note: Crée automatiquement une transaction de type 'credit' ou 'debit'.
  /// Opération réservée aux administrateurs uniquement.
  Future<dynamic> creditAccount({
    required int userId,
    required double amount,
    String? notes,
  }) async {
    try {
      return await _client.user.creditAccount(userId, amount, notes);
    } catch (e) {
      print('Credit account error: $e');
      rethrow;
    }
  }
}
