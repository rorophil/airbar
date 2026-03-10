import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:airbar_backend_client/airbar_backend_client.dart';
import '../../../../data/repositories/user_repository.dart';
import '../../../../core/values/app_strings.dart';
import 'users_controller.dart';

class UserFormController extends GetxController {
  final UserRepository _userRepository = Get.find();

  // Form controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final pinController = TextEditingController();

  // Observables
  final isLoading = false.obs;
  final isEdit = false.obs;
  final selectedRole = UserRole.user.obs;
  final obscurePassword = true.obs;
  final obscurePin = true.obs;

  // Form key
  final formKey = GlobalKey<FormState>();

  User? userToEdit;

  @override
  void onInit() {
    super.onInit();

    // Check if editing
    final args = Get.arguments;
    if (args != null) {
      isEdit.value = args['isEdit'] ?? false;
      userToEdit = args['user'];

      if (userToEdit != null) {
        emailController.text = userToEdit!.email;
        firstNameController.text = userToEdit!.firstName;
        lastNameController.text = userToEdit!.lastName;
        selectedRole.value = userToEdit!.role;
      }
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    pinController.dispose();
    super.onClose();
  }

  /// Toggle password visibility
  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  /// Toggle PIN visibility
  void togglePinVisibility() {
    obscurePin.value = !obscurePin.value;
  }

  /// Validate and submit form
  Future<void> submit() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    try {
      isLoading.value = true;

      if (isEdit.value && userToEdit != null) {
        // Update user
        await _userRepository.updateUser(
          userId: userToEdit!.id!,
          email: emailController.text.trim(),
          firstName: firstNameController.text.trim(),
          lastName: lastNameController.text.trim(),
          role: selectedRole.value,
        );

        // Return to previous screen
        Get.back(result: true);

        // Reload users list
        try {
          Get.find<UsersController>().loadUsers();
        } catch (e) {
          // UsersController might not be in memory, ignore
        }

        // Show success message
        Get.snackbar(
          'Succès',
          AppStrings.successUpdate,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        // Create user
        await _userRepository.createUser(
          email: emailController.text.trim(),
          password: passwordController.text,
          firstName: firstNameController.text.trim(),
          lastName: lastNameController.text.trim(),
          pin: pinController.text,
          role: selectedRole.value,
        );

        // Return to previous screen
        Get.back(result: true);

        // Reload users list
        try {
          Get.find<UsersController>().loadUsers();
        } catch (e) {
          // UsersController might not be in memory, ignore
        }

        // Show success message
        Get.snackbar(
          'Succès',
          'Utilisateur créé avec succès',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      // Extract error message from exception
      String errorMessage = e.toString();

      // Try to extract the actual error message from Serverpod exceptions
      if (errorMessage.contains('InvalidParametersException:')) {
        errorMessage = errorMessage
            .split('InvalidParametersException:')
            .last
            .trim()
            .split('\n')
            .first;
      } else if (errorMessage.contains('Exception:')) {
        errorMessage = errorMessage
            .split('Exception:')
            .last
            .trim()
            .split('\n')
            .first;
      }

      Get.snackbar(
        'Erreur',
        errorMessage,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Validate email
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email requis';
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value)) {
      return 'Email invalide';
    }
    return null;
  }

  /// Validate password
  String? validatePassword(String? value) {
    if (isEdit.value) return null; // Password not required for edit
    if (value == null || value.isEmpty) {
      return 'Mot de passe requis';
    }
    if (value.length < 6) {
      return 'Au moins 6 caractères';
    }
    return null;
  }

  /// Validate name
  String? validateName(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName requis';
    }
    return null;
  }

  /// Validate PIN
  String? validatePin(String? value) {
    if (isEdit.value) return null; // PIN not required for edit
    if (value == null || value.isEmpty) {
      return 'Code PIN requis';
    }
    if (value.length != 4) {
      return 'Le PIN doit contenir 4 chiffres';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'Le PIN doit contenir uniquement des chiffres';
    }
    return null;
  }
}
