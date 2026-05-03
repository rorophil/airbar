import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:airbar_backend_client/airbar_backend_client.dart';
import '../../../../data/repositories/user_repository.dart';
import '../../../../routes/app_routes.dart';
import '../../../../core/values/app_strings.dart';

/// Controller du module de gestion des utilisateurs (Admin)
///
/// Permet aux administrateurs de gérer les membres de l'aéro-club:
/// - Créer / modifier / supprimer des utilisateurs
/// - Activer / désactiver des comptes
/// - Ajuster les soldes (créditer / débiter)
/// - Réinitialiser mots de passe et codes PIN
/// - Rechercher et filtrer les utilisateurs
///
/// Fonctionnalités principales:
/// - Liste complète des utilisateurs avec recherche
/// - Gestion des rôles (admin / user)
/// - Ajustement de compte (crédit/débit avec notes)
/// - Soft delete (désactivation) et réactivation
/// - Hard delete (suppression définitive)
/// - Réinitialisation sécurisée des identifiants
///
/// Note: Les utilisateurs désactivés restent en base mais ne peuvent plus se connecter.
class UsersController extends GetxController {
  /// Repository d'accès aux données utilisateurs
  final UserRepository _userRepository = Get.find();

  /// Indicateur de chargement en cours
  final RxBool isLoading = false.obs;

  /// Liste complète de tous les utilisateurs
  final RxList<User> users = <User>[].obs;

  /// Liste filtrée des utilisateurs (selon recherche)
  final RxList<User> filteredUsers = <User>[].obs;

  /// Requête de recherche actuelle
  final RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Chargement initial des utilisateurs au démarrage du controller
    loadUsers();
  }

  /// Charger tous les utilisateurs depuis le serveur
  ///
  /// Récupère la liste complète des utilisateurs (admin + user, actifs + inactifs)
  /// et applique automatiquement le filtre de recherche actif.
  ///
  /// En cas d'erreur, affiche un snackbar mais ne crash pas l'application.
  Future<void> loadUsers() async {
    try {
      isLoading.value = true;
      final result = await _userRepository.getAllUsers();
      users.value = List<User>.from(result);
      // Application automatique du filtre de recherche
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

  /// Filtrer les utilisateurs par recherche textuelle
  ///
  /// Recherche insensible à la casse dans:
  /// - Prénom (firstName)
  /// - Nom (lastName)
  /// - Email
  ///
  /// Si la recherche est vide, affiche tous les utilisateurs.
  void filterUsers() {
    if (searchQuery.value.isEmpty) {
      // Aucune recherche = affiche tous les utilisateurs
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

  /// Mettre à jour la requête de recherche et filtrer
  ///
  /// Appelée automatiquement lors de la saisie dans le champ de recherche.
  /// Déclenche le filtrage immédiat de la liste.
  void updateSearchQuery(String query) {
    searchQuery.value = query;
    filterUsers();
  }

  /// Naviguer vers le formulaire de création d'utilisateur
  ///
  /// Ouvre l'écran UserFormView en mode création.
  /// Si l'utilisateur est créé (result == true), recharge la liste.
  void createUser() async {
    final result = await Get.toNamed(AppRoutes.ADMIN_USER_FORM);
    if (result == true) {
      await loadUsers();
    }
  }

  /// Naviguer vers le formulaire d'édition d'utilisateur
  ///
  /// Ouvre l'écran UserFormView en mode édition avec les données du [user].
  /// Si l'utilisateur est modifié (result == true), recharge la liste.
  void editUser(User user) async {
    final result = await Get.toNamed(
      AppRoutes.ADMIN_USER_FORM,
      arguments: {'user': user, 'isEdit': true},
    );
    if (result == true) {
      loadUsers();
    }
  }

  /// Naviguer vers l'ajustement de compte (crédit/débit)
  ///
  /// Ouvre l'écran UserCreditView pour créditer ou débiter le compte du [user].
  /// Permet d'ajouter un montant positif (crédit) ou négatif (débit).
  /// Si le compte est modifié (result == true), recharge la liste.
  void creditAccount(User user) async {
    final result = await Get.toNamed(
      AppRoutes.ADMIN_USER_CREDIT,
      arguments: {'user': user},
    );
    if (result == true) {
      loadUsers();
    }
  }

  /// Désactiver un utilisateur (soft delete)
  ///
  /// Désactive le compte de l'[user] en appelant userRepository.deactivateUser().
  /// L'utilisateur reste en base de données mais ne peut plus se connecter.
  /// Affiche une confirmation avant l'action.
  ///
  /// Cas d'usage: suspension de compte, départ du club, non-paiement cotisation.
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

  /// Réactiver un utilisateur précédemment désactivé
  ///
  /// Réactive le compte de l'[user] en appelant userRepository.reactivateUser().
  /// L'utilisateur peut à nouveau se connecter et acheter des produits.
  /// Affiche une confirmation avant l'action.
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

  /// Réinitialiser le code PIN de connexion d'un utilisateur
  ///
  /// Permet à l'admin de définir un nouveau code PIN pour l'[user].
  /// Affiche un dialog avec 2 champs (nouveau PIN + confirmation).
  /// Valide que les 2 codes correspondent avant de sauvegarder.
  ///
  /// Le PIN est haché en SHA256 côté serveur avant stockage.
  /// Utilisé pour: PIN oublié, compromission du code, nouveaux utilisateurs.
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

  /// Supprimer définitivement un utilisateur (hard delete)
  ///
  /// ⚠️ ATTENTION: Suppression DÉFINITIVE de l'[user] de la base de données.
  /// Cette action est IRRÉVERSIBLE.
  ///
  /// Affiche une confirmation avec avertissement avant suppression.
  /// À utiliser avec précaution (préférer deactivateUser dans la plupart des cas).
  ///
  /// Cas d'usage exceptionnels: données de test, RGPD (droit à l'oubli), erreur de saisie.
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
