import 'package:get/get.dart';
import '../controllers/cart_controller.dart';
import 'package:airbar/app/core/utils/trace_logger.dart';

/// Injection de dépendances pour le module Cart (Panier)
///
/// Initialise le CartController nécessaire pour gérer le panier d'achat
/// de l'utilisateur (affichage, modification, suppression d'articles).
///
/// Pattern GetX: Le controller est créé à la demande (lazy) et libéré
/// automatiquement à la sortie du panier.
class CartBinding extends Bindings {
  CartBinding() {
    Trace.create('CartBinding');
  }

  @override
  void dependencies() {
    Trace.call('CartBinding', 'dependencies');
    // Enregistrement lazy du controller du panier
    Get.lazyPut<CartController>(() => CartController());
  }
}
