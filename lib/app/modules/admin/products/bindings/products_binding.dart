import 'package:get/get.dart';
import 'package:airbar/app/core/utils/trace_logger.dart';
import '../controllers/products_controller.dart';

/// Injection de dépendances pour le module Products Admin (Liste produits)
///
/// Initialise le ProductsController pour la gestion du catalogue de produits.
/// Permet affichage, filtrage, création, modification, activation/désactivation.
class ProductsBinding extends Bindings {
  ProductsBinding() {
    Trace.create('ProductsBinding');
  }

  @override
  void dependencies() {
    Trace.call('ProductsBinding', 'dependencies');
    Get.lazyPut<ProductsController>(() => ProductsController());
  }
}
