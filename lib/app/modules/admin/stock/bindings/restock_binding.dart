import 'package:get/get.dart';
import '../controllers/restock_controller.dart';

class RestockBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RestockController>(() => RestockController());
  }
}
