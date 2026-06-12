import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/auth_service.dart';
import '../app_routes.dart';

/// Middleware de protection des routes nécessitant une authentification
///
/// Vérifie si l'utilisateur est connecté avant d'accéder à la route.
/// Si non connecté, redirige vers la page de login.
///
/// Usage: Ajouter `middlewares: [AuthMiddleware()]` dans GetPage
class AuthMiddleware extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    final authService = Get.find<AuthService>();

    // Si l'utilisateur n'est pas authentifié, rediriger vers login
    if (!authService.isAuthenticated.value) {
      return const RouteSettings(name: AppRoutes.LOGIN);
    }

    // Sinon, autoriser l'accès
    return null;
  }
}
