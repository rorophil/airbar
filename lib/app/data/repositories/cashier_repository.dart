import '../providers/serverpod_client_provider.dart';
import 'package:airbar_backend_client/airbar_backend_client.dart';

/// Repository pour les opérations de caisse
///
/// Gère les ventes aux clients de passage (non-membres) avec paiement
/// direct (espèces ou carte bancaire).
///
/// Fonctionnalités:
/// - Vente caisse (processCashSale)
/// - Consultation des ventes effectuées par un vendeur
///
/// Caractéristiques des ventes caisse:
/// - Client anonyme (pas de compte utilisateur)
/// - Paiement immédiat (espèces ou carte)
/// - Traçabilité du vendeur
/// - Déduction automatique du stock
/// - Génération de reçu
class CashierRepository {
  /// Client Serverpod pour les appels API
  Client get _client => ServerpodClientProvider.client;

  /// Traite une vente caisse
  ///
  /// [sellerId] ID du membre qui effectue la vente
  /// [items] Liste des articles vendus
  /// [paymentMethod] Mode de paiement (cash ou card)
  /// [pin] Code PIN du vendeur pour validation
  ///
  /// Returns: La transaction créée avec type cashSale
  ///
  /// Throws: Exception si:
  /// - PIN vendeur incorrect
  /// - Liste d'articles vide
  /// - Stock insuffisant pour un produit
  /// - Produit inactif
  /// - Erreur serveur
  ///
  /// Processus atomique:
  /// 1. Validation du PIN vendeur (hash SHA256)
  /// 2. Validation des produits (existence, actif, stock)
  /// 3. Calcul du montant total
  /// 4. Création de la transaction (type: cashSale, userId: null)
  /// 5. Création des TransactionItems (snapshots)
  /// 6. Déduction du stock (regular vs bulk)
  /// 7. Création des StockMovements (userId: sellerId)
  ///
  /// Note: Transaction atomique - si une étape échoue, tout est annulé
  Future<Transaction> processCashSale({
    required int sellerId,
    required List<CashSaleItemData> items,
    required PaymentMethod paymentMethod,
    required String pin,
  }) async {
    try {
      return await _client.cashier.processCashSale(
        sellerId,
        items,
        paymentMethod,
        pin,
      );
    } catch (e) {
      print('Cash sale error: $e');
      rethrow;
    }
  }

  /// Récupère les transactions effectuées par un vendeur spécifique
  ///
  /// [sellerId] ID du vendeur
  /// [limit] Nombre maximum de transactions à récupérer (défaut: 50)
  /// [offset] Décalage pour la pagination (défaut: 0)
  ///
  /// Returns: Liste des transactions de type cashSale effectuées par ce vendeur
  ///
  /// Utilisé pour:
  /// - Historique des ventes d'un membre
  /// - Audit des opérations de caisse
  /// - Statistiques par vendeur
  Future<List<Transaction>> getSellerTransactions({
    required int sellerId,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      return await _client.cashier.getSellerTransactions(
        sellerId,
        limit: limit,
        offset: offset,
      );
    } catch (e) {
      print('Get seller transactions error: $e');
      rethrow;
    }
  }
}
