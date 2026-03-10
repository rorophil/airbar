import 'package:get/get.dart';
import '../controllers/product_form_controller.dart';

class ProductFormBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProductFormController>(() => ProductFormController());
  }
}
