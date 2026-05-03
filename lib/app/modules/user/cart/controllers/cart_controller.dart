import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:airbar_backend_client/airbar_backend_client.dart';
import '../../../../data/repositories/cart_repository.dart';
import '../../../../data/repositories/product_repository.dart';
import '../../../../data/repositories/product_portion_repository.dart';
import '../../../../services/auth_service.dart';
import '../../../../routes/app_routes.dart';
import '../../../../core/values/app_colors.dart';

/// Classe helper pour associer un CartItem avec ses détails produit
///
/// Enrichit les données brutes du panier avec:
/// - Le produit complet (nom, prix, etc.)
/// - La portion sélectionnée (si produit en vrac)
///
/// Facilite l'affichage dans l'UI et le calcul du prix effectif.
class CartItemWithProduct {
  /// L'item du panier (quantité, IDs)
  final CartItem cartItem;

  /// Le produit associé (peut être null si supprimé)
  final Product? product;

  /// La portion sélectionnée (null pour produits réguliers)
  final ProductPortion? portion;

  CartItemWithProduct(this.cartItem, this.product, this.portion);

  /// ID du produit
  int get productId => cartItem.productId;

  /// Quantité commandée
  int get quantity => cartItem.quantity;

  /// Récupérer le prix effectif
  ///
  /// Si une portion est sélectionnée, utilise le prix de la portion,
  /// sinon utilise le prix du produit.
  double get effectivePrice {
    if (portion != null) {
      return portion!.price;
    }
    return product?.price ?? 0.0;
  }

  /// Récupérer le nom d'affichage
  ///
  /// Format:
  /// - Avec portion: "Bière - 50cl"
  /// - Sans portion: "Coca-Cola"
  String get displayName {
    if (product == null) return 'Produit inconnu';
    if (portion != null) {
      return '${product!.name} - ${portion!.name}';
    }
    return product!.name;
  }
}

/// Controller du module Cart (Panier utilisateur)
///
/// Gère l'affichage et la modification du panier d'achat avant validation.
/// Permet de modifier les quantités, supprimer des articles et procéder au paiement.
///
/// État géré:
/// - [isLoading]: Indicateur de chargement du panier
/// - [cartItems]: Liste enrichie des articles (avec produit et portion)
/// - [total]: Montant total du panier
///
/// Opérations principales:
/// - [loadCart()]: Charge le panier avec enrichissement des données
/// - [updateQuantity()]: Modifie la quantité avec validation de stock
/// - [removeItem()]: Supprime un article du panier
/// - [goToCheckout()]: Navigue vers le paiement
class CartController extends GetxController {
  /// Repository pour les opérations sur le panier
  final CartRepository _cartRepository = Get.find();

  /// Repository pour les détails des produits
  final ProductRepository _productRepository = Get.find();

  /// Repository pour les portions de produits en vrac
  final ProductPortionRepository _portionRepository = Get.find();

  /// Service d'authentification (utilisateur connecté)
  final AuthService _authService = Get.find();

  /// Indicateur de chargement du panier
  final isLoading = false.obs;

  /// Liste des articles du panier avec leurs détails enrichis
  final cartItems = <CartItemWithProduct>[].obs;

  /// Montant total du panier (calculé automatiquement)
  final total = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    // Rafraîchissement du solde utilisateur à l'ouverture du panier
    _authService.refreshUser();
    loadCart();
  }

  /// Charger les articles du panier avec enrichissement des données
  ///
  /// Processus:
  /// 1. Récupération des CartItem bruts via CartRepository
  /// 2. Pour chaque item, chargement:
  ///    - Du produit complet (Product)
  ///    - De la portion si spécifiée (ProductPortion)
  /// 3. Création des CartItemWithProduct (classe helper)
  /// 4. Calcul du total
  ///
  /// L'enrichissement permet d'afficher nom, prix, description sans
  /// stocker ces données dans la table cart_item.
  Future<void> loadCart() async {
    try {
      isLoading.value = true;

      final userId = _authService.currentUser.value?.id;
      if (userId == null) return;

      final items = await _cartRepository.getUserCart(userId);

      // Enrichissement des données: chargement des détails produit et portions
      final enrichedItems = <CartItemWithProduct>[];
      for (var item in items) {
        try {
          // Chargement du produit complet
          final product = await _productRepository.getProductById(
            item.productId,
          );

          // Chargement de la portion si spécifiée
          ProductPortion? portion;
          if (item.productPortionId != null) {
            try {
              portion = await _portionRepository.getPortionById(
                item.productPortionId!,
              );
            } catch (e) {
              print('Error loading portion ${item.productPortionId}: $e');
            }
          }

          enrichedItems.add(CartItemWithProduct(item, product, portion));
        } catch (e) {
          // En cas d'erreur (produit supprimé), ajoute quand même l'item
          print('Error loading product ${item.productId}: $e');
          enrichedItems.add(CartItemWithProduct(item, null, null));
        }
      }

      cartItems.value = enrichedItems;
      _calculateTotal(); // Recalcul du total
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de charger le panier: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Calculer le montant total du panier
  ///
  /// Somme: Σ (prix effectif × quantité) pour chaque article.
  /// Le prix effectif est celui de la portion si présente, sinon du produit.
  void _calculateTotal() {
    total.value = cartItems.fold(
      0.0,
      (sum, item) => sum + item.effectivePrice * item.quantity,
    );
  }

  /// Mettre à jour la quantité d'un article
  ///
  /// [item] L'article à modifier
  /// [newQuantity] Nouvelle quantité (si ≤ 0, l'article est supprimé)
  ///
  /// Processus:
  /// 1. Si newQuantity ≤ 0 → Suppression de l'article
  /// 2. Validation du stock disponible:
  ///    - Produits en vrac: stock total = (stockQuantity × bulkTotalQuantity) + currentUnitRemaining
  ///    - Produits réguliers: stock total = stockQuantity
  /// 3. Mise à jour via CartRepository
  /// 4. Rechargement du panier
  ///
  /// IMPORTANT: Pour les produits avec portions, requiredStock = newQuantity × portion.quantity
  Future<void> updateQuantity(CartItemWithProduct item, int newQuantity) async {
    try {
      final userId = _authService.currentUser.value?.id;
      if (userId == null) return;

      // Si quantité ≤ 0, supprimer l'article
      if (newQuantity <= 0) {
        await removeItem(item);
        return;
      }

      // Validation du stock disponible
      if (item.product != null) {
        // Calcul du stock requis
        double requiredStock = newQuantity.toDouble();

        if (item.portion != null) {
          // Pour produits en vrac: quantité × portion
          // Ex: 3 portions de 50cl = 3 × 0.5 = 1.5L requis
          requiredStock = newQuantity * item.portion!.quantity;
        }

        // Calcul du stock total disponible
        double availableStock = 0.0;

        if (item.product!.isBulkProduct &&
            item.product!.bulkTotalQuantity != null) {
          // Produits en vrac: total = (unités complètes × capacité) + unité entamée
          availableStock =
              (item.product!.stockQuantity * item.product!.bulkTotalQuantity!) +
              (item.product!.currentUnitRemaining ?? 0.0);

          if (availableStock < requiredStock) {
            Get.snackbar(
              'Stock insuffisant',
              'Il ne reste que ${availableStock.toStringAsFixed(2)} ${item.product!.bulkUnit ?? "L"} en stock',
              snackPosition: SnackPosition.BOTTOM,
            );
            return;
          }
        } else {
          // Produits réguliers: validation directe sur stockQuantity
          if (item.product!.stockQuantity < newQuantity) {
            Get.snackbar(
              'Stock insuffisant',
              'Il ne reste que ${item.product!.stockQuantity} unité(s) en stock',
              snackPosition: SnackPosition.BOTTOM,
            );
            return;
          }
        }
      }

      // Mise à jour dans la base de données
      await _cartRepository.updateCartItem(
        userId: userId,
        productId: item.productId,
        quantity: newQuantity,
        productPortionId: item.cartItem.productPortionId,
      );

      // Rechargement du panier pour refléter les changements
      await loadCart();
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de modifier la quantité: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Retirer un article du panier
  ///
  /// [item] L'article à supprimer
  ///
  /// Suppression via CartRepository puis rechargement du panier.
  Future<void> removeItem(CartItemWithProduct item) async {
    try {
      final userId = _authService.currentUser.value?.id;
      if (userId == null) return;

      await _cartRepository.removeFromCart(
        userId: userId,
        productId: item.productId,
        productPortionId: item.cartItem.productPortionId,
      );

      await loadCart();

      Get.snackbar(
        'Succès',
        'Article retiré du panier',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de retirer l\'article: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Vider entièrement le panier
  ///
  /// Supprime tous les articles du panier de l'utilisateur connecté.
  /// Utile en cas d'abandon d'achat.
  Future<void> clearCart() async {
    try {
      final userId = _authService.currentUser.value?.id;
      if (userId == null) return;

      await _cartRepository.clearCart(userId);
      await loadCart();

      Get.snackbar(
        'Succès',
        'Panier vidé',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de vider le panier: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Procéder au paiement (checkout)
  ///
  /// Processus:
  /// 1. Vérification que le panier n'est pas vide
  /// 2. Rafraîchissement du solde utilisateur
  /// 3. Vérification du solde suffisant
  /// 4. Navigation vers CheckoutView avec le total en argument
  ///
  /// En cas de solde insuffisant, affiche un snackbar spécifique.
  Future<void> goToCheckout() async {
    // Vérification panier non vide
    if (cartItems.isEmpty) {
      Get.snackbar(
        'Panier vide',
        'Ajoutez des articles avant de passer commande',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Rafraîchissement du solde avant vérification
    await _authService.refreshUser();

    // Vérification du solde
    final user = _authService.currentUser.value;
    if (user != null && user.balance < total.value) {
      Get.snackbar(
        'Solde insuffisant',
        'Votre solde (${user.balance.toStringAsFixed(2)} €) est insuffisant.\nTotal: ${total.value.toStringAsFixed(2)} €',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 7),
        backgroundColor: AppColors.error,
        colorText: AppColors.textWhite,
        icon: const Icon(
          Icons.warning_amber_rounded,
          color: AppColors.textWhite,
          size: 32,
        ),
        shouldIconPulse: true,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      return;
    }

    Get.toNamed(AppRoutes.USER_CHECKOUT, arguments: {'total': total.value});
  }

  /// Refresh cart
  Future<void> refresh() async {
    await loadCart();
  }
}
