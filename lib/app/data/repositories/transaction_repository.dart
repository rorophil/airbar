import '../providers/serverpod_client_provider.dart';
import 'package:airbar_backend_client/airbar_backend_client.dart';

/// Repository de gestion des transactions
///
/// Implémente le pattern Repository pour abstraire l'accès aux opérations
/// de transactions financières.
///
/// Ce repository gère:
/// - Checkout (création de transaction d'achat)
/// - Consultation de l'historique des transactions
/// - Remboursements (admin uniquement)
/// - Détails des articles d'une transaction
///
/// Types de transactions:
/// - `purchase`: Achat de produits (débit du compte)
/// - `credit`: Crédit du compte par un admin
/// - `debit`: Débit du compte par un admin
/// - `refund`: Remboursement d'un achat
///
/// Note: Ce repository ne gère PAS de cache car les transactions
/// sont des données financières sensibles qui doivent toujours être
/// à jour et traçables.
class TransactionRepository {
  /// Client Serverpod pour les appels API
  Client get _client => ServerpodClientProvider.client;

  /// Effectue le checkout (achat)
  ///
  /// [userId] L'ID de l'utilisateur qui achète
  /// [pin] Le code PIN de l'utilisateur pour confirmation
  ///
  /// Returns: La transaction créée avec tous ses détails
  ///
  /// Throws: Exception si:
  /// - PIN incorrect
  /// - Panier vide
  /// - Solde insuffisant
  /// - Stock insuffisant pour un ou plusieurs produits
  /// - Erreur serveur
  ///
  /// Processus atomique:
  /// 1. Validation du PIN (hash SHA256)
  /// 2. Récupération du panier
  /// 3. Validation du stock pour CHAQUE article
  /// 4. Calcul du montant total
  /// 5. Vérification du solde
  /// 6. Débit du compte
  /// 7. Création de la transaction
  /// 8. Création des TransactionItems
  /// 9. Déduction du stock (avec gestion produits en vrac)
  /// 10. Création des mouvements de stock
  /// 11. Vidage du panier
  ///
  /// Note: Si une étape échoue, TOUT est annulé (transaction atomique)
  Future<dynamic> checkout({required int userId, required String pin}) async {
    try {
      return await _client.transaction.checkout(userId, pin);
    } catch (e) {
      print('Checkout error: $e');
      rethrow;
    }
  }

  /// Récupère l'historique des transactions d'un utilisateur
  ///
  /// [userId] L'ID de l'utilisateur
  /// [limit] Nombre maximum de transactions à retourner (défaut: 50)
  /// [offset] Nombre de transactions à ignorer (pagination)
  ///
  /// Returns: Liste des transactions triées par date décroissante (plus récent en premier)
  ///
  /// Throws: Exception si l'utilisateur n'existe pas ou erreur serveur
  ///
  /// Exemple de pagination:
  /// ```dart
  /// // Page 1 (0-50)
  /// getUserTransactions(userId, limit: 50, offset: 0);
  ///
  /// // Page 2 (50-100)
  /// getUserTransactions(userId, limit: 50, offset: 50);
  /// ```
  Future<List<dynamic>> getUserTransactions(
    int userId, {
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      return await _client.transaction.getUserTransactions(
        userId,
        limit: limit,
        offset: offset,
      );
    } catch (e) {
      print('Get user transactions error: $e');
      rethrow;
    }
  }

  /// Récupère toutes les transactions du système
  ///
  /// [type] Filtre optionnel par type (TransactionType.purchase, credit, etc.)
  /// [limit] Nombre maximum de transactions à retourner (défaut: 50)
  /// [offset] Nombre de transactions à ignorer (pagination)
  ///
  /// Returns: Liste de toutes les transactions triées par date décroissante
  ///
  /// Throws: Exception si l'utilisateur n'a pas les droits admin ou erreur serveur
  ///
  /// Note: Opération réservée aux administrateurs uniquement.
  /// Utilisé pour la vue d'ensemble des ventes et la comptabilité.
  Future<List<dynamic>> getAllTransactions({
    dynamic type,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      return await _client.transaction.getAllTransactions(
        limit: limit,
        offset: offset,
        type: type,
      );
    } catch (e) {
      print('Get all transactions error: $e');
      rethrow;
    }
  }

  /// Rembourse une transaction d'achat
  ///
  /// [transactionId] L'ID de la transaction à rembourser
  /// [notes] Notes expliquant la raison du remboursement (obligatoire pour audit)
  ///
  /// Returns: La transaction de remboursement créée
  ///
  /// Throws: Exception si:
  /// - Transaction inexistante ou déjà remboursée
  /// - Transaction n'est pas de type 'purchase'
  /// - Erreur serveur
  ///
  /// Processus:
  /// 1. Vérification de la transaction originale
  /// 2. Crédit du compte utilisateur du montant total
  /// 3. Création d'une nouvelle transaction de type 'refund'
  /// 4. Pas de réajout au stock (gestion manuelle recommandée)
  ///
  /// Note: Opération réservée aux administrateurs uniquement.
  /// Le remboursement est traçable via les notes et la transaction créée.
  Future<dynamic> refundTransaction({
    required int transactionId,
    required String notes,
  }) async {
    try {
      return await _client.transaction.refundTransaction(transactionId, notes);
    } catch (e) {
      print('Refund transaction error: $e');
      rethrow;
    }
  }

  /// Récupère les articles d'une transaction
  ///
  /// [transactionId] L'ID de la transaction
  ///
  /// Returns: Liste des articles achetés avec leurs détails
  /// (produit, portion, quantité, prix unitaire, sous-total)
  ///
  /// Throws: Exception si la transaction n'existe pas ou erreur serveur
  ///
  /// Note: Utilisé pour afficher le détail d'une transaction dans l'historique
  Future<List<dynamic>> getTransactionItems(int transactionId) async {
    try {
      return await _client.transaction.getTransactionItems(transactionId);
    } catch (e) {
      print('Get transaction items error: $e');
      rethrow;
    }
  }
}
