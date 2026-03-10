import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/repositories/transaction_repository.dart';
import '../../../../services/auth_service.dart';
import '../../../../routes/app_routes.dart';
import '../../../../core/values/app_colors.dart';

class CheckoutController extends GetxController {
  final TransactionRepository _transactionRepository = Get.find();
  final AuthService _authService = Get.find();

  // Observables
  final isProcessing = false.obs;
  final pin = ''.obs;
  final showPin = false.obs;

  // Cart total passed from cart page
  double cartTotal = 0.0;

  @override
  void onInit() {
    super.onInit();
    // Get cart total from arguments if provided
    cartTotal = Get.arguments?['total'] ?? 0.0;
  }

  /// Toggle PIN visibility
  void togglePinVisibility() {
    showPin.value = !showPin.value;
  }

  /// Update PIN value
  void updatePin(String value) {
    pin.value = value;
  }

  /// Process checkout
  Future<void> processCheckout() async {
    if (pin.value.isEmpty) {
      Get.snackbar(
        'Erreur',
        'Veuillez entrer votre code PIN',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (pin.value.length != 4) {
      Get.snackbar(
        'Erreur',
        'Le code PIN doit contenir 4 chiffres',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isProcessing.value = true;

      final userId = _authService.currentUser.value?.id;
      if (userId == null) {
        throw Exception('Utilisateur non connecté');
      }

      // Call checkout endpoint (atomic transaction)
      await _transactionRepository.checkout(userId: userId, pin: pin.value);

      // Clear PIN for security
      pin.value = '';

      // Show success
      Get.snackbar(
        'Succès',
        'Achat effectué avec succès !',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );

      // Refresh user balance
      await _authService.refreshUser();

      // Navigate back to shop and clear cart view from stack
      Get.offAllNamed(AppRoutes.USER_SHOP);
    } catch (e) {
      String errorMessage = 'Erreur lors du paiement';

      if (e.toString().contains('PIN')) {
        errorMessage = 'Code PIN incorrect';
      } else if (e.toString().contains('balance') ||
          e.toString().contains('insufficient')) {
        errorMessage = 'Solde insuffisant';
      } else if (e.toString().contains('stock')) {
        errorMessage = 'Stock insuffisant pour un ou plusieurs articles';
      }

      // Style spécial pour solde insuffisant
      if (errorMessage == 'Solde insuffisant') {
        Get.snackbar(
          'Solde insuffisant',
          'Votre solde est insuffisant pour effectuer cet achat',
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
      } else {
        Get.snackbar(
          'Erreur',
          errorMessage,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 4),
        );
      }
    } finally {
      isProcessing.value = false;
    }
  }

  /// Cancel checkout
  void cancel() {
    Get.back();
  }
}
