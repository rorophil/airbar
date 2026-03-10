import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:airbar_backend_client/airbar_backend_client.dart';
import '../../../../data/repositories/category_repository.dart';
import '../../../../core/values/app_strings.dart';
import 'categories_controller.dart';

class CategoryFormController extends GetxController {
  final CategoryRepository _categoryRepository = Get.find();

  // Form controllers
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final displayOrderController = TextEditingController();

  // Observables
  final isLoading = false.obs;
  final isEdit = false.obs;
  final selectedIcon = 'category'.obs;

  // Form key
  final formKey = GlobalKey<FormState>();

  ProductCategory? categoryToEdit;

  // Available icons
  final availableIcons = [
    'category',
    'local_bar',
    'local_cafe',
    'local_drink',
    'fastfood',
    'restaurant',
    'wine_bar',
    'lunch_dining',
    'local_pizza',
    'icecream',
    'liquor',
  ];

  @override
  void onInit() {
    super.onInit();

    // Check if editing
    final args = Get.arguments;
    if (args != null) {
      isEdit.value = args['isEdit'] ?? false;
      categoryToEdit = args['category'];

      if (categoryToEdit != null) {
        nameController.text = categoryToEdit!.name;
        descriptionController.text = categoryToEdit!.description ?? '';
        displayOrderController.text = categoryToEdit!.displayOrder.toString();
        selectedIcon.value = categoryToEdit!.iconName ?? 'category';
      }
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    descriptionController.dispose();
    displayOrderController.dispose();
    super.onClose();
  }

  /// Validate and submit form
  Future<void> submit() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    try {
      isLoading.value = true;

      final displayOrder = int.parse(displayOrderController.text);

      if (isEdit.value && categoryToEdit != null) {
        // Update category
        await _categoryRepository.updateCategory(
          categoryId: categoryToEdit!.id!,
          name: nameController.text.trim(),
          description: descriptionController.text.trim(),
          displayOrder: displayOrder,
          iconName: selectedIcon.value,
        );

        // Reload categories list
        try {
          Get.find<CategoriesController>().loadData(forceRefresh: true);
        } catch (e) {
          // CategoriesController might not be in memory, ignore
        }

        // Return to previous screen
        Get.back(result: true);

        // Show success message
        Get.snackbar(
          'Succès',
          AppStrings.successUpdate,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        // Create category
        await _categoryRepository.createCategory(
          name: nameController.text.trim(),
          description: descriptionController.text.trim(),
          displayOrder: displayOrder,
          iconName: selectedIcon.value,
        );

        // Reload categories list
        try {
          Get.find<CategoriesController>().loadData(forceRefresh: true);
        } catch (e) {
          // CategoriesController might not be in memory, ignore
        }

        // Return to previous screen
        Get.back(result: true);

        // Show success message
        Get.snackbar(
          'Succès',
          'Catégorie créée avec succès',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de sauvegarder la catégorie: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Validate name
  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nom requis';
    }
    return null;
  }

  /// Validate display order
  String? validateDisplayOrder(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ordre requis';
    }
    final order = int.tryParse(value);
    if (order == null || order < 0) {
      return 'Ordre invalide';
    }
    return null;
  }
}
