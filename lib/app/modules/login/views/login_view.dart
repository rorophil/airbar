import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controllers/login_controller.dart';
import '../../../core/values/app_colors.dart';
import '../../../core/values/app_strings.dart';
import '../../../routes/app_routes.dart';

/// Vue du module Login
///
/// Affiche l'écran de connexion pour les membres et administrateurs de l'aéro-club.
/// Permet la saisie de l'email et du mot de passe avec validation en temps réel.
///
/// Composants principaux:
/// - Logo AirBar: Identité visuelle de l'application
/// - Champ Email: Validation du format email
/// - Champ Mot de passe: Masquage/affichage avec icône
/// - Bouton Connexion: Désactivé pendant le chargement
/// - Message d'erreur: Affichage en cas d'échec
/// - Bouton Config serveur: Accès à la configuration Serverpod
///
/// Interactions:
/// - Tap bouton connexion → Validation + Authentification + Navigation
/// - Enter sur mot de passe → Déclenchement de la connexion
/// - Tap icône œil → Basculer visibilité mot de passe
/// - Tap config serveur → Ouvre ServerConfigView
///
/// Responsive: Utilise FlutterScreenUtil pour l'adaptation multi-écrans.
class LoginView extends GetView<LoginController> {
  const LoginView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 60.h),

                // Logo de l'application (icône verre de bar)
                Icon(Icons.local_bar, size: 80.sp, color: AppColors.primary),

                SizedBox(height: 16.h),

                // Titre de l'application
                Text(
                  AppStrings.appName,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),

                SizedBox(height: 8.h),

                // Sous-titre
                Text(
                  'Gestion du bar d\'aéro-club',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: AppColors.textSecondary,
                  ),
                ),

                SizedBox(height: 60.h),

                // Champ email avec validation
                TextFormField(
                  controller: controller.emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: AppStrings.email,
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  validator: controller.validateEmail,
                ),

                SizedBox(height: 16.h),

                // Champ mot de passe avec basculement de visibilité
                Obx(
                  () => TextFormField(
                    controller: controller.passwordController,
                    obscureText: controller.obscurePassword.value,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) =>
                        controller.login(), // Enter → Connexion
                    decoration: InputDecoration(
                      labelText: AppStrings.password,
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          controller.obscurePassword.value
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: controller.togglePasswordVisibility,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    validator: controller.validatePassword,
                  ),
                ),

                SizedBox(height: 32.h),

                // Message d'erreur (affiché uniquement si présent)
                Obx(() {
                  if (controller.errorMessage.value.isEmpty) {
                    return const SizedBox.shrink(); // Pas d'erreur = widget vide
                  }
                  // Affichage du message d'erreur dans un encadré rouge
                  return Container(
                    padding: EdgeInsets.all(12.w),
                    margin: EdgeInsets.only(bottom: 16.h),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: AppColors.error),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: AppColors.error,
                          size: 20.sp,
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            controller.errorMessage.value,
                            style: TextStyle(
                              color: AppColors.error,
                              fontSize: 14.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),

                // Bouton de connexion (désactivé pendant le chargement)
                Obx(
                  () => ElevatedButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : controller.login,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: controller.isLoading.value
                        ? SizedBox(
                            height: 20.h,
                            width: 20.h,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            AppStrings.login,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                SizedBox(height: 24.h),

                // Texte d'aide pour obtenir des identifiants
                Text(
                  'Contactez l\'administrateur pour obtenir vos identifiants',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                  ),
                ),

                SizedBox(height: 32.h),

                // Bouton de configuration du serveur Serverpod
                Center(
                  child: OutlinedButton.icon(
                    onPressed: () => Get.toNamed(AppRoutes.SERVER_CONFIG),
                    icon: const Icon(Icons.settings_ethernet),
                    label: const Text('Configuration serveur'),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: 24.w,
                        vertical: 12.h,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
