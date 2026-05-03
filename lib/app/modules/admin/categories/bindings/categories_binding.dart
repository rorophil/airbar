import 'package:get/get.dart';
import '../controllers/categories_controller.dart';

/// Injection de dépendances pour le module Categories Admin (Liste catégories)
///
/// Initialise le CategoriesController pour la gestion des catégories de produits.
/// Permet affichage, création, modification, suppression et réordonnancement.
class CategoriesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CategoriesController>(() => CategoriesController());
  }
}
