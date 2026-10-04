import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:airbar_backend_client/airbar_backend_client.dart';
import '../../../../data/repositories/cart_repository.dart';
import '../../../../data/repositories/product_repository.dart';
import '../../../../data/repositories/product_portion_repository.dart';
import '../../../../data/repositories/transaction_repository.dart';
import '../../../../services/auth_service.dart';
import '../../../../core/values/app_colors.dart';
import 'users_controller.dart';

/// Associe un CartItem brut à son produit/portion pour l'affichage admin
class AdminCartItemWithProduct {
  final CartItem cartItem;
  final Product? product;
  final ProductPortion? portion;

  AdminCartItemWithProduct(this.cartItem, this.product, this.portion);

  int get quantity => cartItem.quantity;

  double get effectivePrice => portion?.price ?? product?.price ?? 0.0;

  String get displayName {
    if (product == null) return 'Produit inconnu';
    if (portion != null) return '${product!.name} - ${portion!.name}';
    return product!.name;
  }

  double get subtotal => effectivePrice * quantity;
}

/// Controller de la vue admin "Panier d'un utilisateur"
///
/// Permet à un administrateur de consulter le panier d'un membre et de:
/// - Vider entièrement ce panier
/// - Forcer le checkout (débit du compte, même en solde négatif) via son propre PIN admin
class UserCartController extends GetxController {
  final CartRepository _cartRepository = Get.find();
  final ProductRepository _productRepository = Get.find();
  final ProductPortionRepository _portionRepository = Get.find();
  final TransactionRepository _transactionRepository = Get.find();
  final AuthService _authService = Get.find();

  User? targetUser;

  final isLoading = false.obs;
  final isProcessing = false.obs;
  final cartItems = <AdminCartItemWithProduct>[].obs;
  final total = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    targetUser = Get.arguments?['user'];
    loadCart();
  }

  Future<void> refresh() => loadCart();

  Future<void> loadCart() async {
    if (targetUser?.id == null) return;

    try {
      isLoading.value = true;

      final items = await _cartRepository.getUserCart(targetUser!.id!);

      final enrichedItems = <AdminCartItemWithProduct>[];
      for (var item in items) {
        try {
          final product = await _productRepository.getProductById(
            item.productId,
          );

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

          enrichedItems.add(AdminCartItemWithProduct(item, product, portion));
        } catch (e) {
          print('Error loading product ${item.productId}: $e');
          enrichedItems.add(AdminCartItemWithProduct(item, null, null));
        }
      }

      cartItems.value = enrichedItems;
      total.value = enrichedItems.fold(0.0, (sum, item) => sum + item.subtotal);
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

  /// Vide entièrement le panier du membre
  Future<void> clearCart() async {
    if (targetUser?.id == null) return;

    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Vider le panier'),
        content: Text(
          'Êtes-vous sûr de vouloir vider le panier de ${targetUser!.firstName} ${targetUser!.lastName} ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Vider', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      isProcessing.value = true;
      await _cartRepository.clearCart(targetUser!.id!);

      _refreshUsersListIfPresent();

      Get.back(result: true);
      Get.snackbar(
        'Succès',
        'Panier vidé',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de vider le panier: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isProcessing.value = false;
    }
  }

  /// Force l'exécution du panier (débit du compte, PIN admin requis)
  Future<void> forceCheckout() async {
    if (targetUser?.id == null || cartItems.isEmpty) return;

    final admin = _authService.currentUser.value;
    if (admin?.id == null) {
      Get.snackbar(
        'Erreur',
        'Administrateur non identifié',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final pinController = TextEditingController();
    final resultingBalance = targetUser!.balance - total.value;

    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Forcer l\'exécution du panier'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Membre: ${targetUser!.firstName} ${targetUser!.lastName}'),
            const SizedBox(height: 8),
            Text('Montant à débiter: ${total.value.toStringAsFixed(2)} €'),
            Text('Solde actuel: ${targetUser!.balance.toStringAsFixed(2)} €'),
            Text(
              'Solde après débit: ${resultingBalance.toStringAsFixed(2)} €',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: resultingBalance >= 0
                    ? AppColors.success
                    : AppColors.error,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: pinController,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 4,
              decoration: const InputDecoration(
                labelText: 'Votre code PIN administrateur',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              if (pinController.text.isEmpty) {
                Get.snackbar(
                  'Erreur',
                  'Veuillez saisir votre code PIN',
                  snackPosition: SnackPosition.BOTTOM,
                );
                return;
              }
              Get.back(result: true);
            },
            child: const Text(
              'Forcer',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      isProcessing.value = true;

      await _transactionRepository.adminForceCheckout(
        userId: targetUser!.id!,
        adminId: admin!.id!,
        adminPin: pinController.text,
      );

      _refreshUsersListIfPresent();

      Get.back(result: true);
      Get.snackbar(
        'Succès',
        'Panier exécuté, compte débité de ${total.value.toStringAsFixed(2)} €',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      // Message renvoyé par le serveur (BusinessException) si disponible,
      // sinon message générique
      String errorMessage = 'Impossible de forcer le paiement';
      if (e is BusinessException) {
        errorMessage = e.message;
      }

      Get.snackbar(
        'Erreur',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 5),
      );
    } finally {
      isProcessing.value = false;
    }
  }

  void _refreshUsersListIfPresent() {
    try {
      Get.find<UsersController>().loadUsers();
      Get.find<UsersController>().loadCartCounts();
    } catch (e) {
      // UsersController peut ne pas être en mémoire, ignorer
    }
  }
}
