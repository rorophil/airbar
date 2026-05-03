import 'package:get/get.dart';
import '../controllers/cart_controller.dart';

/// Injection de dépendances pour le module Cart (Panier)
///
/// Initialise le CartController nécessaire pour gérer le panier d'achat
/// de l'utilisateur (affichage, modification, suppression d'articles).
///
/// Pattern GetX: Le controller est créé à la demande (lazy) et libéré
/// automatiquement à la sortie du panier.
class CartBinding extends Bindings {
  @override
  void dependencies() {
    // Enregistrement lazy du controller du panier
    Get.lazyPut<CartController>(() => CartController());
  }
}
