import 'package:get/get.dart';
import '../../../routes/app_routes.dart';
import '../../../services/auth_service.dart';

/// Controller du module Splash
///
/// Gère l'écran de démarrage (splash screen) et la navigation initiale
/// vers la route appropriée selon l'état d'authentification.
///
/// Navigation automatique après 2 secondes:
/// - Utilisateur non connecté → LOGIN
/// - Utilisateur connecté admin → ADMIN_DASHBOARD
/// - Utilisateur connecté standard → USER_SHOP
///
/// Ce controller est initialisé immédiatement au démarrage de l'app.
class SplashController extends GetxController {
  /// Service d'authentification global
  final AuthService _authService = Get.find();

  @override
  void onInit() {
    super.onInit();
    print('💦 [SPLASH] SplashController initialized');
    // Lancer la navigation automatique
    _navigateToNextScreen();
  }

  /// Naviguer vers l'écran approprié après l'écran splash
  ///
  /// Processus:
  /// 1. Attendre 2 secondes (affichage du logo et chargement)
  /// 2. Vérifier l'état d'authentification via AuthService
  /// 3. Rediriger selon le rôle:
  ///    - Non authentifié → Page de login
  ///    - Admin → Dashboard administrateur
  ///    - Utilisateur → Boutique
  ///
  /// Utilise offAllNamed pour nettoyer la pile de navigation.
  Future<void> _navigateToNextScreen() async {
    try {
      print('⏱️ [SPLASH] Waiting 2 seconds...');
      // Pause de 2 secondes pour afficher le splash screen
      await Future.delayed(const Duration(seconds: 2));

      print('🔐 [SPLASH] Checking authentication...');
      // Vérification de l'état d'authentification
      if (_authService.isAuthenticated.value) {
        print('✅ [SPLASH] User is authenticated');
        // Navigation basée sur le rôle
        if (_authService.isAdmin) {
          print('🔑 [SPLASH] User is admin, navigating to ADMIN_DASHBOARD');
          Get.offAllNamed(AppRoutes.ADMIN_DASHBOARD);
        } else {
          print('👤 [SPLASH] User is regular, navigating to USER_SHOP');
          Get.offAllNamed(AppRoutes.USER_SHOP);
        }
      } else {
        print('❌ [SPLASH] User not authenticated, navigating to LOGIN');
        // Redirection vers le login
        Get.offAllNamed(AppRoutes.LOGIN);
        print('✅ [SPLASH] Navigation to LOGIN completed');
      }
    } catch (e, stackTrace) {
      print('🚨 [SPLASH] ERROR during navigation: $e');
      print('📝 [SPLASH] StackTrace: $stackTrace');
    }
  }
}
