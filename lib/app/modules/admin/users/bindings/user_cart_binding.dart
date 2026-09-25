import 'package:get/get.dart';
import '../controllers/user_cart_controller.dart';

/// Injection de dépendances pour le module UserCart (Panier d'un membre, vue admin)
class UserCartBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UserCartController>(() => UserCartController());
  }
}
