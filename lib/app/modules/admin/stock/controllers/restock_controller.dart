import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:airbar_backend_client/airbar_backend_client.dart';
import '../../../../data/repositories/stock_repository.dart';
import '../../../../services/auth_service.dart';
import 'stock_controller.dart';

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
