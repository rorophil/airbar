import 'package:get/get.dart';
import 'package:airbar/app/core/utils/trace_logger.dart';
import '../controllers/category_form_controller.dart';

/// Injection de dépendances pour le module CategoryForm (Création/Édition catégorie)
///
/// Initialise le CategoryFormController pour la création de nouvelles catégories
/// ou la modification des catégories existantes (nom, icône, ordre d'affichage).
class CategoryFormBinding extends Bindings {
  CategoryFormBinding() {
    Trace.create('CategoryFormBinding');
  }

  @override
  void dependencies() {
    Trace.call('CategoryFormBinding', 'dependencies');
    Get.lazyPut<CategoryFormController>(() => CategoryFormController());
  }
}
