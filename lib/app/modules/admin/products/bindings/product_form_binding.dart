import 'package:get/get.dart';
import '../controllers/product_form_controller.dart';

/// Injection de dépendances pour le module ProductForm (Création/Édition produit)
///
/// Initialise le ProductFormController pour la création de nouveaux produits
/// ou la modification des produits existants (nom, prix, stock, portions en vrac).
class ProductFormBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProductFormController>(() => ProductFormController());
  }
}
