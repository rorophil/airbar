import 'package:get/get.dart';
import 'package:airbar/app/core/utils/trace_logger.dart';
import '../controllers/product_form_controller.dart';

/// Injection de dépendances pour le module ProductForm (Création/Édition produit)
///
/// Initialise le ProductFormController pour la création de nouveaux produits
/// ou la modification des produits existants (nom, prix, stock, portions en vrac).
class ProductFormBinding extends Bindings {
  ProductFormBinding() {
    Trace.create('ProductFormBinding');
  }

  @override
  void dependencies() {
    Trace.call('ProductFormBinding', 'dependencies');
    Get.lazyPut<ProductFormController>(() => ProductFormController());
  }
}
