import '../providers/serverpod_client_provider.dart';
import 'package:airbar_backend_client/airbar_backend_client.dart';

/// Repository de gestion du panier d'achat
///
/// Implémente le pattern Repository pour abstraire l'accès aux opérations
/// du panier utilisateur.
///
/// Ce repository gère:
/// - Récupération du panier utilisateur
/// - Ajout/modification/suppression d'articles
/// - Vidage complet du panier
/// - Calcul du montant total
///
/// Note: Le panier est stocké côté serveur pour permettre la synchronisation
/// multi-appareils. Chaque utilisateur a son propre panier identifié par userId.
/// Ce repository ne gère PAS de cache car le panier change fréquemment.
class CartRepository {
  /// Client Serverpod pour les appels API
  Client get _client => ServerpodClientProvider.client;

  /// Récupère le panier d'un utilisateur
  ///
  /// [userId] L'ID de l'utilisateur
  ///
  /// Returns: Liste des articles du panier avec leurs données complètes
  /// (produit, portion, quantité, prix unitaire, etc.)
  ///
  /// Throws: Exception si l'utilisateur n'existe pas ou erreur serveur
  Future<List<dynamic>> getUserCart(int userId) async {
    try {
      return await _client.cart.getCart(userId);
    } catch (e) {
      print('Get user cart error: $e');
      rethrow;
    }
  }

  /// Ajoute un article au panier
  ///
  /// [userId] L'ID de l'utilisateur
  /// [productId] L'ID du produit à ajouter
  /// [quantity] Quantité à ajouter (doit être > 0)
  /// [productPortionId] ID de la portion si produit en vrac (optionnel)
  ///
  /// Returns: L'article ajouté ou mis à jour
  ///
  /// Throws: Exception si:
  /// - Produit inexistant ou inactif
  /// - Quantité invalide
  /// - Stock insuffisant
  /// - Erreur serveur
  ///
  /// Note: Si l'article existe déjà dans le panier (même produit + même portion),
  /// la quantité est incrémentée au lieu de créer un doublon.
  Future<dynamic> addToCart({
    required int userId,
    required int productId,
    required int quantity,
    int? productPortionId,
  }) async {
    try {
      return await _client.cart.addToCart(
        userId,
        productId,
        quantity,
        productPortionId: productPortionId,
      );
    } catch (e) {
      print('Add to cart error: $e');
      rethrow;
    }
  }

  /// Met à jour la quantité d'un article du panier
  ///
  /// [userId] L'ID de l'utilisateur
  /// [productId] L'ID du produit à modifier
  /// [quantity] Nouvelle quantité (doit être > 0)
  /// [productPortionId] ID de la portion si produit en vrac (optionnel)
  ///
  /// Returns: L'article mis à jour
  ///
  /// Throws: Exception si:
  /// - Article inexistant dans le panier
  /// - Quantité invalide
  /// - Stock insuffisant
  /// - Erreur serveur
  ///
  /// Note: Pour supprimer un article, utiliser [removeFromCart] plutôt
  /// que de passer quantity = 0
  Future<dynamic> updateCartItem({
    required int userId,
    required int productId,
    required int quantity,
    int? productPortionId,
  }) async {
    try {
      return await _client.cart.updateCartItem(
        userId,
        productId,
        quantity,
        productPortionId: productPortionId,
      );
    } catch (e) {
      print('Update cart item error: $e');
      rethrow;
    }
  }

  /// Supprime un article du panier
  ///
  /// [userId] L'ID de l'utilisateur
  /// [productId] L'ID du produit à supprimer
  /// [productPortionId] ID de la portion si produit en vrac (optionnel)
  ///
  /// Throws: Exception si:
  /// - Article inexistant dans le panier
  /// - Erreur serveur
  Future<void> removeFromCart({
    required int userId,
    required int productId,
    int? productPortionId,
  }) async {
    try {
      await _client.cart.removeFromCart(
        userId,
        productId,
        productPortionId: productPortionId,
      );
    } catch (e) {
      print('Remove from cart error: $e');
      rethrow;
    }
  }

  /// Vide complètement le panier d'un utilisateur
  ///
  /// [userId] L'ID de l'utilisateur
  ///
  /// Supprime tous les articles du panier. Cette opération est irréversible.
  ///
  /// Throws: Exception en cas d'erreur serveur
  ///
  /// Note: Appelé automatiquement après un checkout réussi
  Future<void> clearCart(int userId) async {
    try {
      await _client.cart.clearCart(userId);
    } catch (e) {
      print('Clear cart error: $e');
      rethrow;
    }
  }

  /// Calcule le montant total du panier
  ///
  /// [cartItems] Liste des articles du panier
  ///
  /// Returns: Montant total en euros
  ///
  /// Note: Cette méthode effectue un calcul local côté client.
  /// Le serveur recalcule toujours le montant lors du checkout pour
  /// des raisons de sécurité (éviter la manipulation des prix côté client).
  Future<double> calculateCartTotal(List<dynamic> cartItems) async {
    try {
      double total = 0.0;

      // Calcul du total en itérant sur tous les articles
      for (var item in cartItems) {
        // Prix unitaire × quantité
        total += (item.product?.price ?? 0.0) * item.quantity;
      }

      return total;
    } catch (e) {
      // En cas d'erreur, retourner 0.0 plutôt que de bloquer l'UI
      print('Calculate cart total error: $e');
      return 0.0;
    }
  }
}
