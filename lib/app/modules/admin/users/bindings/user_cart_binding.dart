import 'package:get/get.dart';
import 'package:airbar/app/core/utils/trace_logger.dart';
import '../controllers/user_cart_controller.dart';

/// Injection de dépendances pour le module UserCart (Panier d'un membre, vue admin)
class UserCartBinding extends Bindings {
  UserCartBinding() {
    Trace.create('UserCartBinding');
  }

  @override
  void dependencies() {
    Trace.call('UserCartBinding', 'dependencies');
    Get.lazyPut<UserCartController>(() => UserCartController());
  }
}
