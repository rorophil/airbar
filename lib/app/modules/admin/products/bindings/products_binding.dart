import 'package:get/get.dart';
import '../controllers/products_controller.dart';

/// Injection de dépendances pour le module Products Admin (Liste produits)
///
/// Initialise le ProductsController pour la gestion du catalogue de produits.
/// Permet affichage, filtrage, création, modification, activation/désactivation.
class ProductsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProductsController>(() => ProductsController());
  }
}
