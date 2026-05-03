import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:airbar_backend_client/airbar_backend_client.dart';
import '../controllers/user_form_controller.dart';
import '../../../../core/values/app_colors.dart';
import '../../../../core/values/app_strings.dart';

/// Vue du formulaire utilisateur (Admin)
///
/// Formulaire de création ou modification d'un membre.
///
/// Champs du formulaire:
/// - Email: validation regex, obligatoire
/// - Prénom: texte obligatoire
/// - Nom: texte obligatoire
/// - Rôle: sélection Admin/User (DropdownButton)
/// - Password: obligatoire création uniquement, min 6 caractères, toggle visibilité
/// - Code PIN: obligatoire création uniquement, 4-6 chiffres, toggle visibilité
///
/// Modes:
/// - Création: tous les champs requis, titre "Nouvel utilisateur"
/// - Édition: password/PIN masqués, titre "Modifier utilisateur"
///
/// Composants:
/// - AppBar: Titre dynamique selon mode
/// - TextFormFields: tous avec validation
/// - DropdownButton: sélection rôle
/// - IconButton: toggle visibilité password/PIN (œil)
/// - ElevatedButton: soumission formulaire
///
/// Validation:
/// - Email: format valide requis
/// - Password: min 6 caractères (création uniquement)
/// - Noms: non vides
/// - PIN: format numérique (création uniquement)
///
/// Workflow:
/// - Remplissage champs → Validation → Soumission → Message succès → Retour liste
class UserFormView extends GetView<UserFormController> {
  const UserFormView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(
          () => Text(
            controller.isEdit.value
                ? 'Modifier utilisateur'
                : 'Nouvel utilisateur',
          ),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textWhite,
      ),
      body: SafeArea(
        child: Form(
          key: controller.formKey,
          child: ListView(
            padding: EdgeInsets.all(24.w),
            children: [
              // Email
              TextFormField(
                controller: controller.emailController,
                decoration: InputDecoration(
                  labelText: AppStrings.email,
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: controller.validateEmail,
              ),

              SizedBox(height: 16.h),

              // Password (only for create)
              Obx(() {
                if (controller.isEdit.value) return const SizedBox.shrink();
                return Column(
                  children: [
                    TextFormField(
                      controller: controller.passwordController,
                      decoration: InputDecoration(
                        labelText: AppStrings.password,
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            controller.obscurePassword.value
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: controller.togglePasswordVisibility,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      obscureText: controller.obscurePassword.value,
                      validator: controller.validatePassword,
                    ),
                    SizedBox(height: 16.h),
                  ],
                );
              }),

              // First name
              TextFormField(
                controller: controller.firstNameController,
                decoration: InputDecoration(
                  labelText: 'Prénom',
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                validator: (value) => controller.validateName(value, 'Prénom'),
              ),

              SizedBox(height: 16.h),

              // Last name
              TextFormField(
                controller: controller.lastNameController,
                decoration: InputDecoration(
                  labelText: 'Nom',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                validator: (value) => controller.validateName(value, 'Nom'),
              ),

              SizedBox(height: 16.h),

              // PIN (only for create)
              Obx(() {
                if (controller.isEdit.value) return const SizedBox.shrink();
                return Column(
                  children: [
                    TextFormField(
                      controller: controller.pinController,
                      decoration: InputDecoration(
                        labelText: 'Code PIN (4 chiffres)',
                        prefixIcon: const Icon(Icons.pin),
                        suffixIcon: IconButton(
                          icon: Icon(
                            controller.obscurePin.value
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: controller.togglePinVisibility,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      maxLength: 4,
                      obscureText: controller.obscurePin.value,
                      validator: controller.validatePin,
                    ),
                    SizedBox(height: 16.h),
                  ],
                );
              }),

              // Role selection
              Obx(
                () => DropdownButtonFormField<UserRole>(
                  value: controller.selectedRole.value,
                  decoration: InputDecoration(
                    labelText: 'Rôle',
                    prefixIcon: const Icon(Icons.admin_panel_settings),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: UserRole.user,
                      child: Text('Utilisateur'),
                    ),
                    DropdownMenuItem(
                      value: UserRole.admin,
                      child: Text('Administrateur'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      controller.selectedRole.value = value;
                    }
                  },
                ),
              ),

              SizedBox(height: 32.h),

              // Submit button
              Obx(
                () => SizedBox(
                  height: 50.h,
                  child: ElevatedButton.icon(
                    onPressed: controller.isLoading.value
                        ? null
                        : controller.submit,
                    icon: controller.isLoading.value
                        ? SizedBox(
                            width: 20.w,
                            height: 20.w,
                            child: const CircularProgressIndicator(
                              color: AppColors.textWhite,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.save),
                    label: Text(
                      controller.isLoading.value
                          ? 'Enregistrement...'
                          : AppStrings.save,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.textWhite,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
