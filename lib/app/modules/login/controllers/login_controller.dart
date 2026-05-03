import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../routes/app_routes.dart';
import '../../../services/auth_service.dart';

/// Controller du module Login
///
/// Gère la logique d'authentification des utilisateurs de l'application AirBar.
/// Permet aux membres et administrateurs de se connecter avec leur email et mot de passe.
///
/// État géré:
/// - [isLoading]: Indicateur de chargement pendant l'authentification
/// - [obscurePassword]: Visibilité du mot de passe (masqué/visible)
/// - [errorMessage]: Message d'erreur à afficher en cas d'échec
///
/// Opérations principales:
/// - [login()]: Authentification via AuthRepository et navigation selon le rôle
/// - [validateEmail()]: Validation du format email
/// - [validatePassword()]: Validation de la longueur du mot de passe
/// - [togglePasswordVisibility()]: Basculer la visibilité du mot de passe
class LoginController extends GetxController {
  /// Repository pour les opérations d'authentification
  final AuthRepository _authRepository = AuthRepository();

  /// Service d'authentification global (utilisateur connecté)
  final _authService = Get.find<AuthService>();

  /// Controller du champ email
  final emailController = TextEditingController();

  /// Controller du champ mot de passe
  final passwordController = TextEditingController();

  /// Indicateur de chargement pendant la requête de connexion
  final isLoading = false.obs;

  /// Visibilité du mot de passe (true = masqué, false = visible)
  final obscurePassword = true.obs;

  /// Message d'erreur à afficher en cas d'échec de connexion
  final errorMessage = ''.obs;

  /// Clé du formulaire pour la validation
  final formKey = GlobalKey<FormState>();

  @override
  void onClose() {
    // Libération des controllers de texte
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  /// Basculer la visibilité du mot de passe
  ///
  /// Permet à l'utilisateur de voir/masquer son mot de passe lors de la saisie.
  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  /// Validation du champ email
  ///
  /// Vérifie que:
  /// - Le champ n'est pas vide
  /// - Le format respecte la structure standard d'une adresse email
  ///
  /// [value] La valeur du champ à valider
  ///
  /// Retourne un message d'erreur si invalide, null si valide.
  String? validateEmail(String? value) {
    // Vérification présence
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer votre email';
    }
    // Vérification format avec regex
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value)) {
      return 'Email invalide';
    }
    return null;
  }

  /// Validation du champ mot de passe
  ///
  /// Vérifie que:
  /// - Le champ n'est pas vide
  /// - La longueur est d'au moins 6 caractères
  ///
  /// [value] La valeur du champ à valider
  ///
  /// Retourne un message d'erreur si invalide, null si valide.
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer votre mot de passe';
    }
    if (value.length < 6) {
      return 'Le mot de passe doit contenir au moins 6 caractères';
    }
    return null;
  }

  /// Authentification de l'utilisateur
  ///
  /// Processus:
  /// 1. Validation du formulaire (email + mot de passe)
  /// 2. Appel à l'API via AuthRepository
  /// 3. Navigation selon le rôle:
  ///    - Admin → Dashboard admin (gestion complète)
  ///    - Utilisateur → Boutique (achat uniquement)
  /// 4. Affichage d'un message de succès ou d'erreur
  ///
  /// En cas de succès, l'utilisateur est stocké dans AuthService
  /// et les routes sont nettoyées (offAllNamed).
  Future<void> login() async {
    // Validation du formulaire
    if (!formKey.currentState!.validate()) {
      return;
    }

    // Réinitialisation de l'erreur précédente
    errorMessage.value = '';
    isLoading.value = true;

    try {
      // Appel au repository pour l'authentification
      final result = await _authRepository.login(
        emailController.text.trim(),
        passwordController.text,
      );

      if (result['success'] == true) {
        final user = result['user'];

        // Navigation basée sur le rôle de l'utilisateur
        if (_authService.isAdmin) {
          // Admin → Dashboard (accès complet: users, produits, stock, transactions)
          Get.offAllNamed(AppRoutes.ADMIN_DASHBOARD);
        } else {
          // Utilisateur standard → Boutique (achat uniquement)
          Get.offAllNamed(AppRoutes.USER_SHOP);
        }

        Get.snackbar(
          'Connexion réussie',
          'Bienvenue ${user.firstName} ${user.lastName}',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        errorMessage.value = result['error'] ?? 'Erreur de connexion';

        Get.snackbar(
          'Erreur',
          errorMessage.value,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      errorMessage.value = 'Une erreur est survenue: ${e.toString()}';

      Get.snackbar(
        'Erreur',
        errorMessage.value,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
