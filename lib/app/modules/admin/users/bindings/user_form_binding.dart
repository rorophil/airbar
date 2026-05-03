import 'package:get/get.dart';
import '../controllers/user_form_controller.dart';

/// Injection de dépendances pour le module UserForm (Création/Édition utilisateur)
///
/// Initialise le UserFormController pour la création de nouveaux membres
/// ou la modification des membres existants (nom, email, rôle, PIN).
class UserFormBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UserFormController>(() => UserFormController());
  }
}
