import 'package:get/get.dart';
import '../controllers/login_controller.dart';

/// Binding for login module
class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LoginController>(() => LoginController());
  }
}
