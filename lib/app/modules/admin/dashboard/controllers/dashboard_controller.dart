import 'package:get/get.dart';
import '../../../../routes/app_routes.dart';
import '../../../../services/auth_service.dart';

class DashboardController extends GetxController {
  final AuthService _authService = Get.find();

  /// Navigate to Users Management
  void goToUsers() {
    Get.toNamed(AppRoutes.ADMIN_USERS);
  }

  /// Navigate to Products Management
  void goToProducts() {
    Get.toNamed(AppRoutes.ADMIN_PRODUCTS);
  }

  /// Navigate to Categories Management
  void goToCategories() {
    Get.toNamed(AppRoutes.ADMIN_CATEGORIES);
  }

  /// Navigate to Stock Management
  void goToStock() {
    Get.toNamed(AppRoutes.ADMIN_STOCK);
  }

  /// Navigate to Transactions
  void goToTransactions() {
    Get.toNamed(AppRoutes.ADMIN_TRANSACTIONS);
  }

  /// Navigate to Export
  void goToExport() {
    Get.toNamed(AppRoutes.ADMIN_EXPORT);
  }

  /// Navigate to Shop (as user)
  void goToShop() {
    Get.toNamed(AppRoutes.USER_SHOP);
  }

  /// Logout
  void logout() {
    Get.defaultDialog(
      title: 'Déconnexion',
      middleText: 'Êtes-vous sûr de vouloir vous déconnecter ?',
      textCancel: 'Annuler',
      textConfirm: 'Déconnexion',
      onConfirm: () {
        _authService.clearUser();
        Get.offAllNamed(AppRoutes.LOGIN);
      },
    );
  }

  /// Get admin name
  String get adminName {
    final user = _authService.currentUser.value;
    return user != null ? '${user.firstName} ${user.lastName}' : 'Admin';
  }
}
