import '../providers/serverpod_client_provider.dart';
import 'package:airbar_backend_client/airbar_backend_client.dart';

/// Repository de gestion des portions de produits
///
/// Les portions définissent les tailles de service pour les produits en vrac.
/// Par exemple, pour une bière pression:
/// - Portion "25cl" = 0.25L à 2.50€
/// - Portion "50cl" = 0.50L à 4.50€
///
/// Ce repository gère:
/// - CRUD des portions
/// - Association aux produits
/// - Ordre d'affichage (displayOrder)
/// - Activation/désactivation des portions
///
/// Note: Ce repository ne gère PAS de cache car les portions changent rarement
/// et sont toujours chargées avec leur produit parent.
class ProductPortionRepository {
  /// Client Serverpod pour les appels API
  Client get _client => ServerpodClientProvider.client;

  /// Récupère toutes les portions d'un produit
  ///
  /// [productId] L'ID du produit parent
  /// [activeOnly] Si `true`, retourne uniquement les portions actives (défaut)
  ///
  /// Returns: Liste des portions triées par displayOrder
  ///
  /// Throws: Exception si le produit n'existe pas ou erreur serveur
  ///
  /// Note: Utilisé principalement pour les produits en vrac (isBulkProduct = true)
  Future<List<dynamic>> getProductPortions(
    int productId, {
    bool activeOnly = true,
  }) async {
    try {
      return await _client.productPortion.getProductPortions(
        productId,
        activeOnly: activeOnly,
      );
    } catch (e) {
      print('Get product portions error: $e');
      rethrow;
    }
  }

  /// Récupère une portion par son ID
  ///
  /// [portionId] L'ID de la portion
  ///
  /// Returns: La portion si elle existe, `null` sinon
  ///
  /// Throws: Exception en cas d'erreur serveur
  Future<ProductPortion?> getPortionById(int portionId) async {
    try {
      return await _client.productPortion.getPortionById(portionId);
    } catch (e) {
      print('Get portion by ID error: $e');
      rethrow;
    }
  }

  /// Crée une nouvelle portion pour un produit
  ///
  /// [productId] L'ID du produit parent (doit être isBulkProduct = true)
  /// [name] Nom de la portion (ex: "25cl", "Pinte", "Demi")
  /// [quantity] Quantité en unité du produit (ex: 0.25 pour 25cl si bulkUnit = "litres")
  /// [price] Prix de cette portion en euros
  /// [displayOrder] Ordre d'affichage (défaut: 0)
  ///
  /// Returns: La portion créée avec son ID
  ///
  /// Throws: Exception si le produit n'existe pas, n'est pas en vrac,
  /// ou erreur serveur
  ///
  /// Exemple:
  /// ```dart
  /// createPortion(
  ///   productId: 5, // Bière pression
  ///   name: "25cl",
  ///   quantity: 0.25, // litres
  ///   price: 2.50,
  ///   displayOrder: 1,
  /// );
  /// ```
  Future<dynamic> createPortion({
    required int productId,
    required String name,
    required double quantity,
    required double price,
    int displayOrder = 0,
  }) async {
    try {
      return await _client.productPortion.createPortion(
        productId,
        name,
        quantity,
        price,
        displayOrder: displayOrder,
      );
    } catch (e) {
      print('Create portion error: $e');
      rethrow;
    }
  }

  /// Met à jour une portion existante
  ///
  /// Tous les paramètres sont identiques à [createPortion].
  /// [portionId] est requis pour identifier la portion à modifier.
  ///
  /// Returns: La portion mise à jour
  ///
  /// Throws: Exception si la portion n'existe pas ou erreur serveur
  Future<dynamic> updatePortion({
    required int portionId,
    required String name,
    required double quantity,
    required double price,
    int? displayOrder,
  }) async {
    try {
      return await _client.productPortion.updatePortion(
        portionId,
        name,
        quantity,
        price,
        displayOrder: displayOrder,
      );
    } catch (e) {
      print('Update portion error: $e');
      rethrow;
    }
  }

  /// Supprime/Désactive une portion
  ///
  /// [portionId] L'ID de la portion à supprimer
  ///
  /// Note: Il s'agit d'un soft delete (isActive = false) pour préserver
  /// l'historique des transactions utilisant cette portion.
  ///
  /// Throws: Exception si la portion n'existe pas ou erreur serveur
  Future<void> deletePortion(int portionId) async {
    try {
      await _client.productPortion.deletePortion(portionId);
    } catch (e) {
      print('Delete portion error: $e');
      rethrow;
    }
  }
}
