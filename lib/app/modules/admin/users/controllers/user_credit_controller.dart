import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:airbar_backend_client/airbar_backend_client.dart';
import '../../../../data/repositories/user_repository.dart';
import 'users_controller.dart';

/// Controller d'ajustement de solde utilisateur (Admin)
///
/// Permet aux administrateurs de créditer ou débiter le compte d'un membre.
/// Support des montants positifs (crédit) et négatifs (débit).
///
/// Fonctionnalités principales:
/// - Crédit de compte: montant positif (ex: +50€)
/// - Débit de compte: montant négatif (ex: -20€)
/// - Notes optionnelles pour justifier l'opération (ex: "Remboursement", "Pénalité")
/// - Validation: montant != 0 requis
/// - Rechargement automatique de la liste utilisateurs
///
/// Workflow:
/// 1. Récupération de l'utilisateur depuis arguments de navigation
/// 2. Saisie du montant (+ ou -) et notes optionnelles
/// 3. Validation et appel repository.creditAccount()
/// 4. Création automatique d'une transaction (type: credit)
/// 5. Rechargement de UsersController
/// 6. Message succès avec opération ("crédité de" ou "débité de")
///
/// Note: L'endpoint backend vérifie que le solde final ne soit pas négatif.
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
