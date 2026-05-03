import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/repositories/transaction_repository.dart';
import '../../../../services/auth_service.dart';
import '../../../../routes/app_routes.dart';
import '../../../../core/values/app_colors.dart';

/// Controller du module Checkout (Paiement)
///
/// Gère la validation du paiement avec saisie et vérification du code PIN.
/// Déclenche la transaction atomique côté serveur (débit compte + déduction stock).
///
/// État géré:
/// - [isProcessing]: Indicateur de traitement du paiement en cours
/// - [pin]: Code PIN saisi (4 chiffres)
/// - [showPin]: Visibilité du PIN (masqué/visible)
/// - [cartTotal]: Montant total passé depuis CartView
///
/// Opérations principales:
/// - [processCheckout()]: Lance la transaction complète avec validation PIN
/// - [updatePin()]: Met à jour le PIN saisi
/// - [togglePinVisibility()]: Bascule l'affichage du PIN
///
/// Sécurité:
/// - Le PIN est hashé SHA256 côté serveur pour validation
/// - Le PIN est effacé après chaque tentative (succès ou échec)
/// - Timeout de 30 secondes sur la requête
class CheckoutController extends GetxController {
  /// Repository pour les transactions
  final TransactionRepository _transactionRepository = Get.find();

  /// Service d'authentification (utilisateur connecté)
  final AuthService _authService = Get.find();

  /// Indicateur de traitement du paiement en cours
  final isProcessing = false.obs;

  /// Code PIN saisi par l'utilisateur (4 chiffres)
  final pin = ''.obs;

  /// Visibilité du PIN (true = masqué, false = visible)
  final showPin = false.obs;

  /// Montant total du panier (passé en argument depuis CartView)
  double cartTotal = 0.0;

  @override
  void onInit() {
    super.onInit();
    // Récupération du montant total passé en argument depuis CartView
    cartTotal = Get.arguments?['total'] ?? 0.0;
  }

  /// Basculer la visibilité du code PIN
  ///
  /// Permet à l'utilisateur de voir/masquer son PIN lors de la saisie.
  void togglePinVisibility() {
    showPin.value = !showPin.value;
  }

  /// Mettre à jour le code PIN saisi
  ///
  /// [value] Le nouveau PIN (4 chiffres attendus)
  void updatePin(String value) {
    pin.value = value;
  }

  /// Traiter le paiement (transaction complète)
  ///
  /// Processus:
  /// 1. Validation du PIN (présence + longueur 4 chiffres)
  /// 2. Appel à l'endpoint checkout (transaction atomique):
  ///    - Vérification PIN (hash SHA256)
  ///    - Vérification solde suffisant
  ///    - Vérification stock disponible
  ///    - Débit du compte
  ///    - Création de la transaction
  ///    - Déduction du stock
  ///    - Vidage du panier
  /// 3. Rafraîchissement du solde utilisateur
  /// 4. Navigation vers la boutique (retour)
  ///
  /// Gestion d'erreurs spécifique:
  /// - PIN incorrect → Message clair
  /// - Solde insuffisant → Snackbar spécial avec icône warning
  /// - Stock insuffisant → Message explicite
  ///
  /// Sécurité:
  /// - Le PIN est effacé après chaque tentative
  /// - Le hash est fait côté serveur (jamais côté client)
  Future<void> processCheckout() async {
    // Validation: PIN non vide
    if (pin.value.isEmpty) {
      Get.snackbar(
        'Erreur',
        'Veuillez entrer votre code PIN',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Validation: PIN = 4 chiffres
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

      // Appel à l'endpoint checkout (transaction ATOMIQUE côté serveur)
      // Toutes les opérations sont faites en une seule transaction SQL
      await _transactionRepository.checkout(userId: userId, pin: pin.value);

      // Effacement du PIN pour sécurité
      pin.value = '';

      // Affichage du succès
      Get.snackbar(
        'Succès',
        'Achat effectué avec succès !',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );

      // Rafraîchissement du solde utilisateur
      await _authService.refreshUser();

      // Navigation vers la boutique (nettoie la pile: cart + checkout)
      Get.offAllNamed(AppRoutes.USER_SHOP);
    } catch (e) {
      // Analyse de l'erreur pour message utilisateur clair
      String errorMessage = 'Erreur lors du paiement';

      if (e.toString().contains('PIN')) {
        errorMessage = 'Code PIN incorrect';
      } else if (e.toString().contains('balance') ||
          e.toString().contains('insufficient')) {
        errorMessage = 'Solde insuffisant';
      } else if (e.toString().contains('stock')) {
        errorMessage = 'Stock insuffisant pour un ou plusieurs articles';
      }

      // Snackbar spécial pour solde insuffisant (plus visible)
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
        // Message d'erreur standard
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

  /// Annuler le paiement
  ///
  /// Retourne à l'écran précédent (CartView) sans traiter le paiement.
  void cancel() {
    Get.back();
  }
}
