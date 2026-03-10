import 'package:get/get.dart';
import '../controllers/user_credit_controller.dart';

class UserCreditBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UserCreditController>(() => UserCreditController());
  }
}
