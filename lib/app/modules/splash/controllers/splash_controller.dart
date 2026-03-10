import 'package:get/get.dart';
import '../../../routes/app_routes.dart';
import '../../../services/auth_service.dart';

class SplashController extends GetxController {
  final AuthService _authService = Get.find();

  @override
  void onInit() {
    super.onInit();
    print('💦 [SPLASH] SplashController initialized');
    _navigateToNextScreen();
  }

  /// Navigate to appropriate screen after splash
  Future<void> _navigateToNextScreen() async {
    try {
      print('⏱️ [SPLASH] Waiting 2 seconds...');
      // Wait for 2 seconds to show splash screen
      await Future.delayed(const Duration(seconds: 2));

      print('🔐 [SPLASH] Checking authentication...');
      // Check if user is authenticated
      if (_authService.isAuthenticated.value) {
        print('✅ [SPLASH] User is authenticated');
        // Navigate to appropriate home based on role
        if (_authService.isAdmin) {
          print('🔑 [SPLASH] User is admin, navigating to ADMIN_DASHBOARD');
          Get.offAllNamed(AppRoutes.ADMIN_DASHBOARD);
        } else {
          print('👤 [SPLASH] User is regular, navigating to USER_SHOP');
          Get.offAllNamed(AppRoutes.USER_SHOP);
        }
      } else {
        print('❌ [SPLASH] User not authenticated, navigating to LOGIN');
        // Navigate to login
        Get.offAllNamed(AppRoutes.LOGIN);
        print('✅ [SPLASH] Navigation to LOGIN completed');
      }
    } catch (e, stackTrace) {
      print('🚨 [SPLASH] ERROR during navigation: $e');
      print('📝 [SPLASH] StackTrace: $stackTrace');
    }
  }
}
