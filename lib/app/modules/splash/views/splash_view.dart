import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/splash_controller.dart';
import '../../../core/values/app_strings.dart';

/// Vue du module Splash
///
/// Affiche l'écran de démarrage lors du lancement de l'application.
/// Pendant 2 secondes, affiche le logo et un indicateur de chargement
/// pendant que le controller vérifie l'état d'authentification.
///
/// Composants principaux:
/// - Logo AirBar: Icône local_bar (verre de bar)
/// - Nom de l'application: "AirBar"
/// - Tagline: "Gestion de bar d'aéro-club"
/// - Indicateur de chargement: CircularProgressIndicator
///
/// Interactions:
/// Aucune interaction utilisateur - navigation automatique après 2 secondes.
///
/// Navigation automatique vers:
/// - LOGIN si non authentifié
/// - ADMIN_DASHBOARD si admin connecté
/// - USER_SHOP si utilisateur standard connecté
class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo de l'application
            Icon(
              Icons.local_bar,
              size: 100,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),

            // Nom de l'application
            Text(
              AppStrings.appName,
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),

            // Slogan de l'application
            Text(
              AppStrings.appTagLine,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 48),

            // Indicateur de chargement
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
