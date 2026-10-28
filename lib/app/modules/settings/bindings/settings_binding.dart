import 'package:get/get.dart';
import 'package:airbar/app/core/utils/trace_logger.dart';
import '../controllers/settings_controller.dart';

/// Injection de dépendances pour le module Settings
///
/// Initialise et enregistre le SettingsController pour la configuration
/// du serveur Serverpod (adresse IP et port).
///
/// Pattern GetX: Le controller est créé à la demande (lazy) et libéré
/// automatiquement à la sortie de l'écran de configuration.
class SettingsBinding extends Bindings {
  SettingsBinding() {
    Trace.create('SettingsBinding');
  }

  @override
  void dependencies() {
    Trace.call('SettingsBinding', 'dependencies');
    // Enregistrement lazy du controller de configuration serveur
    Get.lazyPut<SettingsController>(() => SettingsController());
  }
}
