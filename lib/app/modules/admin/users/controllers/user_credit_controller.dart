import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:airbar_backend_client/airbar_backend_client.dart';
import '../../../../data/repositories/user_repository.dart';
import 'users_controller.dart';

class UserCreditController extends GetxController {
  final UserRepository _userRepository = Get.find();

  final amountController = TextEditingController();
  final notesController = TextEditingController();

  final isLoading = false.obs;

  User? user;

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments;
    if (args != null) {
      user = args['user'];
    }
  }

  @override
  void onClose() {
    amountController.dispose();
    notesController.dispose();
    super.onClose();
  }

  /// Credit or debit user account
  Future<void> creditAccount() async {
    if (user == null) return;

    final amount = double.tryParse(amountController.text);
    if (amount == null || amount == 0) {
      Get.snackbar(
        'Erreur',
        'Veuillez entrer un montant valide (positif pour créditer, négatif pour débiter)',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isLoading.value = true;

      await _userRepository.creditAccount(
        userId: user!.id!,
        amount: amount,
        notes: notesController.text.trim().isEmpty
            ? null
            : notesController.text.trim(),
      );

      // Reload users list
      try {
        Get.find<UsersController>().loadUsers();
      } catch (e) {
        // UsersController might not be in memory, ignore
      }

      // Return to previous screen
      Get.back(result: true);

      // Show success message
      final operation = amount > 0 ? 'crédité de' : 'débité de';
      Get.snackbar(
        'Succès',
        'Compte $operation ${amount.abs().toStringAsFixed(2)} €',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de modifier le compte: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
