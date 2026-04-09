import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:airbar_backend_client/airbar_backend_client.dart';
import '../../../../data/repositories/user_repository.dart';
import '../../../../routes/app_routes.dart';
import '../../../../core/values/app_strings.dart';

class UsersController extends GetxController {
  final UserRepository _userRepository = Get.find();

  // Observables
  final isLoading = false.obs;
  final users = <User>[].obs;
  final searchQuery = ''.obs;
  final filteredUsers = <User>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadUsers();
  }

  /// Load all users
  Future<void> loadUsers() async {
    try {
      isLoading.value = true;
      final result = await _userRepository.getAllUsers();
      users.value = List<User>.from(result);
      filterUsers();
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de charger les utilisateurs: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Filter users by search query
  void filterUsers() {
    if (searchQuery.value.isEmpty) {
      filteredUsers.value = List<User>.from(users);
    } else {
      final query = searchQuery.value.toLowerCase();
      filteredUsers.value = users.where((user) {
        return user.firstName.toLowerCase().contains(query) ||
            user.lastName.toLowerCase().contains(query) ||
            user.email.toLowerCase().contains(query);
      }).toList();
    }
  }

  /// Update search query
  void updateSearchQuery(String query) {
    searchQuery.value = query;
    filterUsers();
  }

  /// Navigate to create user
  void createUser() async {
    final result = await Get.toNamed(AppRoutes.ADMIN_USER_FORM);
    if (result == true) {
      await loadUsers();
    }
  }

  /// Navigate to edit user
  void editUser(User user) async {
    final result = await Get.toNamed(
      AppRoutes.ADMIN_USER_FORM,
      arguments: {'user': user, 'isEdit': true},
    );
    if (result == true) {
      loadUsers();
    }
  }

  /// Navigate to credit account
  void creditAccount(User user) async {
    final result = await Get.toNamed(
      AppRoutes.ADMIN_USER_CREDIT,
      arguments: {'user': user},
    );
    if (result == true) {
      loadUsers();
    }
  }

  /// Deactivate user
  Future<void> deactivateUser(User user) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Désactiver l\'utilisateur'),
        content: Text(
          'Êtes-vous sûr de vouloir désactiver ${user.firstName} ${user.lastName} ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text(
              AppStrings.confirm,
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _userRepository.deactivateUser(user.id!);
        Get.snackbar(
          'Succès',
          'Utilisateur désactivé',
          snackPosition: SnackPosition.BOTTOM,
        );
        await loadUsers();
      } catch (e) {
        Get.snackbar(
          'Erreur',
          'Impossible de désactiver l\'utilisateur: $e',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }

  /// Reactivate user
  Future<void> reactivateUser(User user) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Réactiver l\'utilisateur'),
        content: Text(
          'Êtes-vous sûr de vouloir réactiver ${user.firstName} ${user.lastName} ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text(
              AppStrings.confirm,
              style: TextStyle(color: Colors.green),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _userRepository.reactivateUser(user.id!);
        Get.snackbar(
          'Succès',
          'Utilisateur réactivé',
          snackPosition: SnackPosition.BOTTOM,
        );
        await loadUsers();
      } catch (e) {
        Get.snackbar(
          'Erreur',
          'Impossible de réactiver l\'utilisateur: $e',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }

  /// Reset user password
  Future<void> resetPassword(User user) async {
    final TextEditingController passwordController = TextEditingController();
    final TextEditingController confirmPasswordController =
        TextEditingController();

    // Local state for password visibility
    bool isPasswordVisible = false;
    bool isConfirmPasswordVisible = false;

    final confirmed = await Get.dialog<bool>(
      StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Réinitialiser le mot de passe'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Nouveau mot de passe pour ${user.firstName} ${user.lastName}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  obscureText: !isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'Nouveau mot de passe',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        isPasswordVisible
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          isPasswordVisible = !isPasswordVisible;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: confirmPasswordController,
                  obscureText: !isConfirmPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'Confirmer le mot de passe',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        isConfirmPasswordVisible
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          isConfirmPasswordVisible = !isConfirmPasswordVisible;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: const Text(AppStrings.cancel),
              ),
              TextButton(
                onPressed: () {
                  if (passwordController.text.isEmpty) {
                    Get.snackbar(
                      'Erreur',
                      'Le mot de passe ne peut pas être vide',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                    return;
                  }
                  if (passwordController.text !=
                      confirmPasswordController.text) {
                    Get.snackbar(
                      'Erreur',
                      'Les mots de passe ne correspondent pas',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                    return;
                  }
                  Get.back(result: true);
                },
                child: const Text(
                  'Réinitialiser',
                  style: TextStyle(color: Colors.orange),
                ),
              ),
            ],
          );
        },
      ),
    );

    if (confirmed == true) {
      try {
        await _userRepository.resetPassword(user.id!, passwordController.text);
        Get.snackbar(
          'Succès',
          'Mot de passe réinitialisé avec succès',
          snackPosition: SnackPosition.BOTTOM,
        );
      } catch (e) {
        Get.snackbar(
          'Erreur',
          'Impossible de réinitialiser le mot de passe: $e',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }

    passwordController.dispose();
    confirmPasswordController.dispose();
  }

  /// Reset user PIN code
  Future<void> resetPin(User user) async {
    final TextEditingController pinController = TextEditingController();
    final TextEditingController confirmPinController = TextEditingController();

    // Local state for PIN visibility
    bool isPinVisible = false;
    bool isConfirmPinVisible = false;

    final confirmed = await Get.dialog<bool>(
      StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Réinitialiser le code PIN'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Nouveau code PIN pour ${user.firstName} ${user.lastName}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: pinController,
                  obscureText: !isPinVisible,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  decoration: InputDecoration(
                    labelText: 'Nouveau code PIN',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        isPinVisible ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          isPinVisible = !isPinVisible;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: confirmPinController,
                  obscureText: !isConfirmPinVisible,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  decoration: InputDecoration(
                    labelText: 'Confirmer le code PIN',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        isConfirmPinVisible
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          isConfirmPinVisible = !isConfirmPinVisible;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: const Text(AppStrings.cancel),
              ),
              TextButton(
                onPressed: () {
                  if (pinController.text.isEmpty) {
                    Get.snackbar(
                      'Erreur',
                      'Le code PIN ne peut pas être vide',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                    return;
                  }
                  if (pinController.text != confirmPinController.text) {
                    Get.snackbar(
                      'Erreur',
                      'Les codes PIN ne correspondent pas',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                    return;
                  }
                  Get.back(result: true);
                },
                child: const Text(
                  'Réinitialiser',
                  style: TextStyle(color: Colors.orange),
                ),
              ),
            ],
          );
        },
      ),
    );

    if (confirmed == true) {
      try {
        await _userRepository.resetPin(user.id!, pinController.text);
        Get.snackbar(
          'Succès',
          'Code PIN réinitialisé avec succès',
          snackPosition: SnackPosition.BOTTOM,
        );
      } catch (e) {
        Get.snackbar(
          'Erreur',
          'Impossible de réinitialiser le code PIN: $e',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }

    pinController.dispose();
    confirmPinController.dispose();
  }

  /// Delete user permanently
  Future<void> deleteUser(User user) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Supprimer l\'utilisateur'),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer définitivement ${user.firstName} ${user.lastName} ?\n\nCette action est irréversible.',
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
        await _userRepository.deleteUser(user.id!);
        Get.snackbar(
          'Succès',
          'Utilisateur supprimé',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        await loadUsers();
      } catch (e) {
        // Extract error message from exception
        String errorMessage = e.toString();

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
      }
    }
  }

  /// Refresh users list
  Future<void> refresh() async {
    await loadUsers();
  }
}
