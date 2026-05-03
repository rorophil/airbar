import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../controllers/category_form_controller.dart';
import '../../../../core/values/app_colors.dart';
import '../../../../core/values/app_strings.dart';

/// Vue du formulaire catégorie (Admin)
///
/// Formulaire de création ou modification d'une catégorie de produits.
///
/// Champs du formulaire:
/// - Nom: texte obligatoire, identifiant de la catégorie
/// - Description: texte optionnel, détails supplémentaires
/// - Ordre d'affichage: entier >= 0, détermine position dans liste
/// - Icône: sélection parmi 11 icônes Material Design
///
/// Sélection d'icône:
/// - Grille de 11 icônes cliquables
/// - Icônes disponibles: category, local_bar, local_cafe, local_drink,
///   fastfood, restaurant, wine_bar, lunch_dining, local_pizza, icecream, liquor
/// - Icône sélectionnée mise en évidence (bordure colorée)
/// - Prévisualisation en temps réel
///
/// Validation:
/// - Nom: non vide requis
/// - Ordre d'affichage: entier >= 0 requis
/// - Description: optionnelle
/// - Icône: sélection obligatoire (défaut: "category")
///
/// Modes:
/// - Création: tous champs vides, titre "Nouvelle catégorie"
/// - Édition: champs pré-remplis, titre "Modifier catégorie"
///
/// Workflow:
/// - Remplissage → Validation → Sauvegarde → Retour liste
class CategoryFormView extends GetView<CategoryFormController> {
  const CategoryFormView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(
          () => Text(
            controller.isEdit.value
                ? 'Modifier catégorie'
                : 'Nouvelle catégorie',
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
              // Name
              TextFormField(
                controller: controller.nameController,
                decoration: InputDecoration(
                  labelText: 'Nom de la catégorie',
                  prefixIcon: const Icon(Icons.category),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                validator: controller.validateName,
              ),

              SizedBox(height: 16.h),

              // Description
              TextFormField(
                controller: controller.descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  prefixIcon: const Icon(Icons.description),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                maxLines: 3,
              ),

              SizedBox(height: 16.h),

              // Display order
              TextFormField(
                controller: controller.displayOrderController,
                decoration: InputDecoration(
                  labelText: 'Ordre d\'affichage',
                  prefixIcon: const Icon(Icons.format_list_numbered),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: controller.validateDisplayOrder,
              ),

              SizedBox(height: 24.h),

              // Icon selector
              Text(
                'Icône',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12.h),

              Obx(
                () => Wrap(
                  spacing: 12.w,
                  runSpacing: 12.h,
                  children: controller.availableIcons.map((iconName) {
                    final isSelected =
                        controller.selectedIcon.value == iconName;
                    return GestureDetector(
                      onTap: () => controller.selectedIcon.value = iconName,
                      child: Container(
                        width: 60.w,
                        height: 60.h,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary.withOpacity(0.1)
                              : AppColors.background,
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textHint,
                            width: isSelected ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Icon(
                          _getIconData(iconName),
                          size: 30.sp,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textSecondary,
                        ),
                      ),
                    );
                  }).toList(),
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

  IconData _getIconData(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'local_bar':
        return Icons.local_bar;
      case 'local_cafe':
        return Icons.local_cafe;
      case 'local_drink':
        return Icons.local_drink;
      case 'fastfood':
        return Icons.fastfood;
      case 'restaurant':
        return Icons.restaurant;
      case 'wine_bar':
        return Icons.wine_bar;
      case 'lunch_dining':
        return Icons.lunch_dining;
      case 'local_pizza':
        return Icons.local_pizza;
      case 'icecream':
        return Icons.icecream;
      case 'liquor':
        return Icons.liquor;
      default:
        return Icons.category;
    }
  }
}
