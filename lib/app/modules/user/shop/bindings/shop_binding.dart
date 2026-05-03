import 'package:get/get.dart';
import '../controllers/shop_controller.dart';

/// Injection de dépendances pour le module Shop (Boutique)
///
/// Initialise le ShopController nécessaire au fonctionnement de la
/// boutique où les utilisateurs peuvent parcourir et acheter des produits.
///
/// Pattern GetX: Le controller est créé à la demande (lazy) et libéré
/// automatiquement à la sortie de la boutique.
class ShopBinding extends Bindings {
  @override
  void dependencies() {
    // Enregistrement lazy du controller de la boutique
    Get.lazyPut<ShopController>(() => ShopController());
  }
}
