import 'package:get/get.dart';
import 'package:airbar/app/core/utils/trace_logger.dart';
import '../controllers/user_form_controller.dart';

/// Injection de dépendances pour le module UserForm (Création/Édition utilisateur)
///
/// Initialise le UserFormController pour la création de nouveaux membres
/// ou la modification des membres existants (nom, email, rôle, PIN).
class UserFormBinding extends Bindings {
  UserFormBinding() {
    Trace.create('UserFormBinding');
  }

  @override
  void dependencies() {
    Trace.call('UserFormBinding', 'dependencies');
    Get.lazyPut<UserFormController>(() => UserFormController());
  }
}
