import '../providers/serverpod_client_provider.dart';
import 'package:airbar_backend_client/airbar_backend_client.dart';

/// Repository de gestion du stock
///
/// Implémente le pattern Repository pour abstraire l'accès aux opérations
/// de gestion du stock des produits.
///
/// Ce repository gère:
/// - Réapprovisionnement des produits
/// - Ajustements de stock (corrections manuelles)
/// - Historique des mouvements de stock
/// - Alertes de stock faible
///
/// Types de mouvements de stock:
/// - `restock`: Réapprovisionnement (ajout de stock)
/// - `sale`: Vente (déduction automatique lors du checkout)
/// - `adjustment`: Ajustement manuel (correction)
///
/// Note: Ce repository ne gère PAS de cache car le stock change
/// fréquemment et doit toujours être à jour.
class StockRepository {
  /// Client Serverpod pour les appels API
  Client get _client => ServerpodClientProvider.client;

  /// Réapprovisionne un produit
  ///
  /// [productId] L'ID du produit à réapprovisionner
  /// [quantity] Quantité à ajouter (unités ou contenants selon le type de produit)
  /// [adminUserId] L'ID de l'administrateur effectuant l'opération
  /// [notes] Notes optionnelles (fournisseur, numéro de facture, etc.)
  ///
  /// Returns: Le mouvement de stock créé
  ///
  /// Throws: Exception si:
  /// - Produit inexistant ou trackStock = false
  /// - Quantité invalide (≤ 0)
  /// - Erreur serveur
  ///
  /// Processus:
  /// 1. Validation du produit et de trackStock
  /// 2. Ajout de la quantité au stock actuel
  /// 3. Création d'un mouvement de stock de type 'restock'
  ///
  /// Note: Opération réservée aux administrateurs uniquement.
  /// Crée un mouvement de stock traçable pour l'audit.
  Future<dynamic> restockProduct({
    required int productId,
    required int quantity,
    required int adminUserId,
    String? notes,
  }) async {
    try {
      return await _client.stock.restockProduct(
        productId,
        quantity,
        adminUserId,
        notes,
      );
    } catch (e) {
      print('Restock product error: $e');
      rethrow;
    }
  }

  /// Ajuste manuellement le stock d'un produit
  ///
  /// [productId] L'ID du produit à ajuster
  /// [adjustment] Ajustement à appliquer (positif ou négatif)
  /// [adminUserId] L'ID de l'administrateur effectuant l'opération
  /// [reason] Raison de l'ajustement (obligatoire pour audit)
  ///
  /// Exemples:
  /// - adjustment = +5: Ajoute 5 unités (correction après inventaire)
  /// - adjustment = -3: Retire 3 unités (casse, péremption)
  ///
  /// Returns: Le mouvement de stock créé
  ///
  /// Throws: Exception si:
  /// - Produit inexistant ou trackStock = false
  /// - Ajustement invalide (0 ou résultat < 0)
  /// - Reason vide
  /// - Erreur serveur
  ///
  /// Note: Utilisé pour les corrections manuelles uniquement.
  /// Préférer [restockProduct] pour les réapprovisionnements normaux.
  /// Opération réservée aux administrateurs uniquement.
  Future<dynamic> adjustStock({
    required int productId,
    required int adjustment,
    required int adminUserId,
    required String reason,
  }) async {
    try {
      return await _client.stock.adjustStock(
        productId,
        adjustment,
        adminUserId,
        reason,
      );
    } catch (e) {
      print('Adjust stock error: $e');
      rethrow;
    }
  }

  /// Récupère l'historique des mouvements de stock d'un produit
  ///
  /// [productId] L'ID du produit
  /// [startDate] Date de début optionnelle (filtre)
  /// [endDate] Date de fin optionnelle (filtre)
  ///
  /// Returns: Liste des mouvements de stock triés par date décroissante
  ///
  /// Throws: Exception si le produit n'existe pas ou erreur serveur
  ///
  /// Exemple:
  /// ```dart
  /// // Tous les mouvements
  /// getStockHistory(productId: 5);
  ///
  /// // Mouvements du dernier mois
  /// getStockHistory(
  ///   productId: 5,
  ///   startDate: DateTime.now().subtract(Duration(days: 30)),
  /// );
  /// ```
  Future<List<dynamic>> getStockHistory({
    required int productId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      return await _client.stock.getStockHistory(
        productId,
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      print('Get stock history error: $e');
      rethrow;
    }
  }

  /// Récupère tous les mouvements de stock du système
  ///
  /// [type] Filtre optionnel par type (StockMovementType.restock, sale, adjustment)
  /// [startDate] Date de début optionnelle (filtre)
  /// [endDate] Date de fin optionnelle (filtre)
  /// [limit] Nombre maximum de mouvements à retourner (défaut: 50)
  /// [offset] Nombre de mouvements à ignorer (pagination)
  ///
  /// Returns: Liste de tous les mouvements de stock triés par date décroissante
  ///
  /// Throws: Exception si l'utilisateur n'a pas les droits admin ou erreur serveur
  ///
  /// Note: Opération réservée aux administrateurs uniquement.
  /// Utilisé pour la vue d'ensemble de la gestion du stock et l'audit.
  Future<List<dynamic>> getAllStockMovements({
    dynamic type,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      return await _client.stock.getAllStockMovements(
        type: type,
        startDate: startDate,
        endDate: endDate,
        limit: limit,
        offset: offset,
      );
    } catch (e) {
      print('Get all stock movements error: $e');
      rethrow;
    }
  }

  /// Récupère les produits avec un stock faible
  ///
  /// Returns: Liste des produits dont le stock est inférieur ou égal
  /// à leur seuil d'alerte (minStockAlert)
  ///
  /// Throws: Exception en cas d'erreur serveur
  ///
  /// Note: Utilisé pour afficher des alertes et rappeler aux admins
  /// de réapprovisionner certains produits.
  /// Exclut les produits avec trackStock = false.
  Future<List<dynamic>> getLowStockProducts() async {
    try {
      return await _client.stock.getLowStockProducts();
    } catch (e) {
      print('Get low stock products error: $e');
      rethrow;
    }
  }
}
