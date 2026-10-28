import 'package:get/get.dart';
import 'package:airbar/app/core/utils/trace_logger.dart';
import '../controllers/checkout_controller.dart';

/// Injection de dépendances pour le module Checkout (Paiement)
///
/// Initialise le CheckoutController nécessaire pour traiter le paiement
/// des achats avec validation du code PIN et débit du compte.
///
/// Pattern GetX: Le controller est créé à la demande (lazy) et libéré
/// automatiquement à la sortie de l'écran de paiement.
class CheckoutBinding extends Bindings {
  CheckoutBinding() {
    Trace.create('CheckoutBinding');
  }

  @override
  void dependencies() {
    Trace.call('CheckoutBinding', 'dependencies');
    // Enregistrement lazy du controller de paiement
    Get.lazyPut<CheckoutController>(() => CheckoutController());
  }
}
