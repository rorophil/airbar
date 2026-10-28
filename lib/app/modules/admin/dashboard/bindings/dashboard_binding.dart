import 'package:get/get.dart';
import 'package:airbar/app/core/utils/trace_logger.dart';
import '../controllers/dashboard_controller.dart';

/// Injection de dépendances pour le module Dashboard Admin
///
/// Initialise le DashboardController pour le tableau de bord administrateur.
/// Point d'entrée principal de l'interface admin avec accès à tous les modules.
///
/// Pattern GetX: Controller créé à la demande (lazy) et libéré automatiquement.
class DashboardBinding extends Bindings {
  DashboardBinding() {
    Trace.create('DashboardBinding');
  }

  @override
  void dependencies() {
    Trace.call('DashboardBinding', 'dependencies');
    // Enregistrement lazy du controller dashboard
    Get.lazyPut<DashboardController>(() => DashboardController());
  }
}
