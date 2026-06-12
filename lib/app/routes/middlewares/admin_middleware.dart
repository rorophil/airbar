import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:airbar_backend_client/airbar_backend_client.dart';
import '../../services/auth_service.dart';
import '../app_routes.dart';

/// Middleware de protection des routes administrateur
///
/// Vérifie si l'utilisateur est connecté ET possède le rôle admin.
/// Si non connecté, redirige vers login.
/// Si connecté mais non admin, redirige vers la boutique utilisateur.
///
/// Usage: Ajouter `middlewares: [AdminMiddleware()]` dans GetPage
class AdminMiddleware extends GetMiddleware {
  @override
  int? get priority => 2;

  @override
  RouteSettings? redirect(String? route) {
    final authService = Get.find<AuthService>();

    // Si non authentifié, rediriger vers login
    if (!authService.isAuthenticated.value) {
      Get.snackbar(
        'Accès refusé',
        'Vous devez être connecté pour accéder à cette page',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return const RouteSettings(name: AppRoutes.LOGIN);
    }

    // Si authentifié mais pas admin, rediriger vers la boutique
    if (authService.currentUser.value?.role != UserRole.admin) {
      Get.snackbar(
        'Accès refusé',
        'Cette section est réservée aux administrateurs',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return const RouteSettings(name: AppRoutes.USER_SHOP);
    }

    // Si admin, autoriser l'accès
    return null;
  }
}
