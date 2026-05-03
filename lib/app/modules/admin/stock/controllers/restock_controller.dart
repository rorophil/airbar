import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:airbar_backend_client/airbar_backend_client.dart';
import '../../../../data/repositories/stock_repository.dart';
import '../../../../services/auth_service.dart';
import 'stock_controller.dart';

/// Controller de réapprovisionnement produit (Admin)
///
/// Gère le réapprovisionnement du stock pour un produit spécifique.
///
/// Fonctionnalités principales:
/// - Ajout de quantité au stock existant d'un produit
/// - Notes optionnelles pour traçabilité (ex: "Livraison Fournisseur X")
/// - Validation: produit doit avoir trackStock = true
/// - Création automatique de StockMovement (type: restock)
/// - Enregistrement de l'admin ayant effectué le réapprovisionnement
/// - Rechargement automatique de StockController
///
/// Workflow:
/// 1. Réception du produit via arguments de navigation
/// 2. Vérification que trackStock = true (sinon retour immédiat)
/// 3. Saisie de la quantité à ajouter (entier positif)
/// 4. Notes optionnelles pour justification
/// 5. Appel repository.restockProduct() avec adminUserId
/// 6. Backend crée StockMovement + incrémente product.stockQuantity
/// 7. Rechargement StockController
/// 8. Message succès avec quantité ajoutée
///
/// Validation:
/// - Quantité > 0 requise
/// - Produit avec trackStock = true requis
/// - AdminUser connecté requis
///
/// Note: Pour les produits en vrac, le réapprovisionnement ajoute des unités complètes
/// (ex: +2 fûts de 6L chacun = stockQuantity += 2).
class RestockController extends GetxController {
  final StockRepository _stockRepository = Get.find();
  final AuthService _authService = Get.find();

  // Form controllers
  final quantityController = TextEditingController();
  final notesController = TextEditingController();

  // Observables
  final isLoading = false.obs;

  // Form key
  final formKey = GlobalKey<FormState>();

  Product? product;

  @override
  void onInit() {
    super.onInit();

    // Get product from arguments
    final args = Get.arguments;
    if (args != null) {
      product = args['product'];

      // Check if stock tracking is enabled for this product
      if (product != null && !product!.trackStock) {
        Get.back();
        Get.snackbar(
          'Erreur',
          'La gestion de stock est désactivée pour ce produit',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[100],
        );
      }
    }
  }

  @override
  void onClose() {
    quantityController.dispose();
    notesController.dispose();
    super.onClose();
  }

  /// Validate and submit restock
  Future<void> submit() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    if (product == null) {
      Get.snackbar(
        'Erreur',
        'Produit non spécifié',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isLoading.value = true;

      final adminUser = _authService.currentUser.value;
      if (adminUser == null) {
        Get.snackbar(
          'Erreur',
          'Utilisateur non connecté',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      final quantity = int.parse(quantityController.text);

      await _stockRepository.restockProduct(
        productId: product!.id!,
        quantity: quantity,
        adminUserId: adminUser.id!,
        notes: notesController.text.trim().isNotEmpty
            ? notesController.text.trim()
            : null,
      );

      // Reload stock list
      try {
        Get.find<StockController>().loadData(forceRefresh: true);
      } catch (e) {
        // StockController might not be in memory, ignore
      }

      // Return to previous screen
      Get.back(result: true);

      // Show success message
      Get.snackbar(
        'Succès',
        'Réapprovisionnement effectué avec succès',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de réapprovisionner: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Validate quantity
  String? validateQuantity(String? value) {
    if (value == null || value.isEmpty) {
      return 'Quantité requise';
    }
    final quantity = int.tryParse(value);
    if (quantity == null || quantity <= 0) {
      return 'Quantité invalide';
    }
    return null;
  }
}
