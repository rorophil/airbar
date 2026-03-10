import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:airbar_backend_client/airbar_backend_client.dart';
import '../../../../data/repositories/cart_repository.dart';
import '../../../../data/repositories/product_repository.dart';
import '../../../../data/repositories/product_portion_repository.dart';
import '../../../../services/auth_service.dart';
import '../../../../routes/app_routes.dart';
import '../../../../core/values/app_colors.dart';

/// Helper class to associate cart item with product details
class CartItemWithProduct {
  final CartItem cartItem;
  final Product? product;
  final ProductPortion? portion;

  CartItemWithProduct(this.cartItem, this.product, this.portion);

  int get productId => cartItem.productId;
  int get quantity => cartItem.quantity;

  /// Get the effective price (portion price if available, otherwise product price)
  double get effectivePrice {
    if (portion != null) {
      return portion!.price;
    }
    return product?.price ?? 0.0;
  }

  /// Get display name (product name + portion name if available)
  String get displayName {
    if (product == null) return 'Produit inconnu';
    if (portion != null) {
      return '${product!.name} - ${portion!.name}';
    }
    return product!.name;
  }
}

class CartController extends GetxController {
  final CartRepository _cartRepository = Get.find();
  final ProductRepository _productRepository = Get.find();
  final ProductPortionRepository _portionRepository = Get.find();
  final AuthService _authService = Get.find();

  // Observables
  final isLoading = false.obs;
  final cartItems = <CartItemWithProduct>[].obs;
  final total = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    // Refresh user balance when cart is opened
    _authService.refreshUser();
    loadCart();
  }

  /// Load cart items with product details
  Future<void> loadCart() async {
    try {
      isLoading.value = true;

      final userId = _authService.currentUser.value?.id;
      if (userId == null) return;

      final items = await _cartRepository.getUserCart(userId);

      // Load product details and portions for each cart item
      final enrichedItems = <CartItemWithProduct>[];
      for (var item in items) {
        try {
          final product = await _productRepository.getProductById(
            item.productId,
          );

          // Load portion if specified
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
          print('Error loading product ${item.productId}: $e');
          enrichedItems.add(CartItemWithProduct(item, null, null));
        }
      }

      cartItems.value = enrichedItems;
      _calculateTotal();
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

  /// Calculate total price
  void _calculateTotal() {
    total.value = cartItems.fold(
      0.0,
      (sum, item) => sum + item.effectivePrice * item.quantity,
    );
  }

  /// Update item quantity
  Future<void> updateQuantity(CartItemWithProduct item, int newQuantity) async {
    try {
      final userId = _authService.currentUser.value?.id;
      if (userId == null) return;

      if (newQuantity <= 0) {
        await removeItem(item);
        return;
      }

      // Check stock availability with actual quantity needed
      if (item.product != null) {
        double requiredStock = newQuantity.toDouble();

        if (item.portion != null) {
          // For bulk products with portions, calculate actual stock needed
          requiredStock = newQuantity * item.portion!.quantity;
        }

        // Calculate total available stock
        double availableStock = 0.0;

        if (item.product!.isBulkProduct &&
            item.product!.bulkTotalQuantity != null) {
          // For bulk products: total = (complete units × capacity) + opened unit remaining
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
          // For regular products: just check unit count
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

      await _cartRepository.updateCartItem(
        userId: userId,
        productId: item.productId,
        quantity: newQuantity,
        productPortionId: item.cartItem.productPortionId,
      );

      await loadCart();
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de modifier la quantité: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Remove item from cart
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

  /// Clear entire cart
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

  /// Proceed to checkout
  Future<void> goToCheckout() async {
    if (cartItems.isEmpty) {
      Get.snackbar(
        'Panier vide',
        'Ajoutez des articles avant de passer commande',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Refresh user balance before checking
    await _authService.refreshUser();

    // Check user balance
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
