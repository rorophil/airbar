import 'package:get/get.dart';
import 'package:airbar/app/core/utils/trace_logger.dart';
import '../controllers/splash_controller.dart';

/// Injection de dépendances pour le module Splash
///
/// Initialise et enregistre le SplashController nécessaire pour gérer
/// l'écran de démarrage et la redirection vers la bonne route.
///
/// Pattern GetX: Utilise put() au lieu de lazyPut() car le controller
/// doit être initialisé immédiatement au démarrage de l'app.
class SplashBinding extends Bindings {
  SplashBinding() {
    Trace.create('SplashBinding');
  }

  @override
  void dependencies() {
    Trace.call('SplashBinding', 'dependencies');
    // Enregistrement immédiat du controller splash (pas lazy)
    Get.put<SplashController>(SplashController());
  }
}
