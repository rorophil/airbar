import 'package:get/get.dart';
import 'package:airbar/app/core/utils/trace_logger.dart';
import '../controllers/categories_controller.dart';

/// Injection de dépendances pour le module Categories Admin (Liste catégories)
///
/// Initialise le CategoriesController pour la gestion des catégories de produits.
/// Permet affichage, création, modification, suppression et réordonnancement.
class CategoriesBinding extends Bindings {
  CategoriesBinding() {
    Trace.create('CategoriesBinding');
  }

  @override
  void dependencies() {
    Trace.call('CategoriesBinding', 'dependencies');
    Get.lazyPut<CategoriesController>(() => CategoriesController());
  }
}
