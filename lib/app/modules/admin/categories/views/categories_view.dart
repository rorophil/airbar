import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:airbar_backend_client/airbar_backend_client.dart';
import '../controllers/categories_controller.dart';
import '../../../../core/values/app_colors.dart';

/// Vue du module de gestion des catégories (Admin)
///
/// Interface d'organisation des catégories de produits.
///
/// Composants principaux:
/// - AppBar: Titre "Catégories"
/// - Champ de recherche: filtre par nom ou description
/// - Liste des catégories: cards avec icône, nom, description
/// - FloatingActionButton: "+" pour nouvelle catégorie
///
/// Informations affichées par catégorie:
/// - Icône Material Design personnalisée
/// - Nom de la catégorie
/// - Description (si présente)
/// - Ordre d'affichage (displayOrder)
/// - Boutons actions: Modifier, Supprimer
///
/// Règles d'affichage:
/// - Tri par displayOrder croissant
/// - "Sans catégorie" toujours en dernier (displayOrder: 999)
/// - Icône colorée selon thème
///
/// Actions disponibles:
/// - Modifier: édition nom, description, icône, ordre
/// - Supprimer: confirmation + déplacement produits vers "Sans catégorie"
/// - Protection: "Sans catégorie" non supprimable
///
/// Interactions:
/// - Tap card → Menu ou édition directe
/// - Recherche → Filtrage instantané
/// - FAB → Création nouvelle catégorie
class CategoriesView extends GetView<CategoriesController> {
  const CategoriesView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catégories'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textWhite,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: controller.createCategory,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: AppColors.textWhite),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search bar
            Padding(
              padding: EdgeInsets.all(16.w),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Rechercher...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: Obx(
                    () => controller.searchQuery.value.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () => controller.updateSearchQuery(''),
                          )
                        : const SizedBox.shrink(),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                onChanged: controller.updateSearchQuery,
              ),
            ),

            // Categories list
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.filteredCategories.isEmpty) {
                  return Center(
                    child: Text(
                      'Aucune catégorie trouvée',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: controller.refresh,
                  child: ListView.builder(
                    padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
                    itemCount: controller.filteredCategories.length,
                    itemBuilder: (context, index) {
                      final category = controller.filteredCategories[index];
                      return _CategoryCard(
                        category: category,
                        onEdit: () => controller.editCategory(category),
                        onDelete: () => controller.deleteCategory(category),
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final ProductCategory category;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CategoryCard({
    required this.category,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Row(
          children: [
            // Icon
            Container(
              width: 60.w,
              height: 60.h,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                _getIconData(category.iconName),
                size: 30.sp,
                color: AppColors.primary,
              ),
            ),

            SizedBox(width: 16.w),

            // Category info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.name,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (category.description != null &&
                      category.description!.isNotEmpty) ...[
                    SizedBox(height: 4.h),
                    Text(
                      category.description!,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  SizedBox(height: 8.h),
                  Text(
                    'Ordre: ${category.displayOrder}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.textHint,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(width: 16.w),

            // Actions
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Edit button
                OutlinedButton(
                  onPressed: onEdit,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 8.h,
                    ),
                  ),
                  child: const Text('Modifier'),
                ),
                SizedBox(height: 8.h),
                // Delete button
                OutlinedButton(
                  onPressed: onDelete,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 8.h,
                    ),
                  ),
                  child: const Text('Supprimer'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconData(String? iconName) {
    if (iconName == null) return Icons.category;

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
