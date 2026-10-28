import 'package:get/get.dart';
import 'package:airbar/app/core/utils/trace_logger.dart';
import '../controllers/export_controller.dart';

/// Injection de dépendances pour le module Export Admin
///
/// Initialise le ExportController pour la génération de rapports.
/// Permet l'export CSV/Excel des utilisateurs, produits et transactions.
class ExportBinding extends Bindings {
  ExportBinding() {
    Trace.create('ExportBinding');
  }

  @override
  void dependencies() {
    Trace.call('ExportBinding', 'dependencies');
    Get.lazyPut<ExportController>(() => ExportController());
  }
}
