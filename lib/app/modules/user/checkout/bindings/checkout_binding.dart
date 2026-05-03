import 'package:get/get.dart';
import '../controllers/checkout_controller.dart';

/// Injection de dépendances pour le module Checkout (Paiement)
///
/// Initialise le CheckoutController nécessaire pour traiter le paiement
/// des achats avec validation du code PIN et débit du compte.
///
/// Pattern GetX: Le controller est créé à la demande (lazy) et libéré
/// automatiquement à la sortie de l'écran de paiement.
class CheckoutBinding extends Bindings {
  @override
  void dependencies() {
    // Enregistrement lazy du controller de paiement
    Get.lazyPut<CheckoutController>(() => CheckoutController());
  }
}
