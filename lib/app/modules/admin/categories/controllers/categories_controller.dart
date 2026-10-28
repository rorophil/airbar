import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:airbar_backend_client/airbar_backend_client.dart';
import 'package:airbar/app/core/utils/trace_logger.dart';
import '../../../../data/repositories/category_repository.dart';
import '../../../../routes/app_routes.dart';
import '../../../../core/values/app_strings.dart';

/// Controller du module de gestion des catégories (Admin)
///
/// Permet aux administrateurs d'organiser le catalogue de produits par catégories.
///
/// Fonctionnalités principales:
/// - Liste complète des catégories avec recherche
/// - Création de nouvelles catégories (nom, description, icône, ordre d'affichage)
/// - Modification de catégories existantes
/// - Suppression de catégories (avec protection "Sans catégorie")
/// - Recherche par nom ou description
/// - Cache local avec forceRefresh
///
/// Règles métier importantes:
/// - La catégorie "Sans catégorie" est spéciale et non supprimable
/// - Lors de la suppression d'une catégorie, ses produits sont déplacés vers "Sans catégorie"
/// - displayOrder détermine l'ordre d'affichage dans la boutique
/// - Icônes Material Design disponibles pour personnalisation
///
/// Workflow suppression:
/// - Confirmation utilisateur requise
/// - Backend déplace automatiquement les produits orphelins
/// - Empêche la suppression de "Sans catégorie"
class CategoriesController extends GetxController {
  final CategoryRepository _categoryRepository = Get.find();

  // Observables
  final isLoading = false.obs;
  final categories = <ProductCategory>[].obs;
  final searchQuery = ''.obs;
  final filteredCategories = <ProductCategory>[].obs;

  CategoriesController() {
    Trace.create('CategoriesController');
  }

  @override
  void onInit() {
    Trace.call('CategoriesController', 'onInit');
    super.onInit();
    loadData(forceRefresh: true);
  }

  @override
  void onClose() {
    Trace.dispose('CategoriesController');
    super.onClose();
  }

  /// Load categories
  Future<void> loadData({bool forceRefresh = false}) async {
    Trace.call('CategoriesController', 'loadData');
    if (isLoading.value) return;

    try {
      isLoading.value = true;

      final result = await _categoryRepository.getAllCategories(
        forceRefresh: forceRefresh,
      );

      categories.value = List<ProductCategory>.from(result);
      filterCategories();
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de charger les catégories: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Filter categories by search query
  void filterCategories() {
    Trace.call('CategoriesController', 'filterCategories');
    if (searchQuery.value.isEmpty) {
      filteredCategories.value = categories;
    } else {
      final query = searchQuery.value.toLowerCase();
      filteredCategories.value = categories.where((category) {
        return category.name.toLowerCase().contains(query) ||
            (category.description?.toLowerCase().contains(query) ?? false);
      }).toList();
    }
  }

  /// Update search query
  void updateSearchQuery(String query) {
    Trace.call('CategoriesController', 'updateSearchQuery');
    searchQuery.value = query;
    filterCategories();
  }

  /// Navigate to create category
  void createCategory() {
    Trace.call('CategoriesController', 'createCategory');
    Get.toNamed(
      AppRoutes.ADMIN_CATEGORY_FORM,
      arguments: {'isEdit': false},
    )?.then((result) {
      if (result == true) {
        loadData(forceRefresh: true);
      }
    });
  }

  /// Navigate to edit category
  void editCategory(ProductCategory category) {
    Trace.call('CategoriesController', 'editCategory');
    Get.toNamed(
      AppRoutes.ADMIN_CATEGORY_FORM,
      arguments: {'isEdit': true, 'category': category},
    )?.then((result) {
      if (result == true) {
        loadData(forceRefresh: true);
      }
    });
  }

  /// Delete category
  Future<void> deleteCategory(ProductCategory category) async {
    Trace.call('CategoriesController', 'deleteCategory');
    // Prevent deletion of "Sans catégorie"
    if (category.name == 'Sans catégorie') {
      Get.snackbar(
        'Erreur',
        'La catégorie "Sans catégorie" ne peut pas être supprimée',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Supprimer la catégorie'),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer "${category.name}" ?\n\nLes produits de cette catégorie seront déplacés vers "Sans catégorie".',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _categoryRepository.deleteCategory(category.id!);

        Get.snackbar(
          'Succès',
          'Catégorie supprimée',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );

        await loadData(forceRefresh: true);
      } catch (e) {
        Get.snackbar(
          'Erreur',
          'Impossible de supprimer la catégorie: $e',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }

  /// Refresh data
  Future<void> refresh() async {
    Trace.call('CategoriesController', 'refresh');
    await loadData(forceRefresh: true);
  }
}
