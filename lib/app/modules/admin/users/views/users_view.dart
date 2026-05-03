import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:airbar_backend_client/airbar_backend_client.dart';
import '../controllers/users_controller.dart';
import '../../../../core/values/app_colors.dart';
import '../../../../core/values/app_strings.dart';

/// Vue du module de gestion des utilisateurs (Admin)
///
/// Interface de gestion des membres de l'aéro-club.
///
/// Composants principaux:
/// - AppBar: Titre + retour dashboard
/// - Champ de recherche: filtre par nom, prénom, email (temps réel)
/// - Liste des utilisateurs: cards avec avatar, nom, email, solde, rôle
/// - FloatingActionButton: "Nouvel utilisateur"
///
/// Actions disponibles par utilisateur (menu contextuel):
/// - Modifier: édition des informations (UserFormView)
/// - Ajuster solde: crédit/débit de compte (UserCreditView)
/// - Réinitialiser PIN: génération nouveau code
/// - Réinitialiser mot de passe: génération nouveau password
/// - Activer/Désactiver: toggle isActive (soft delete)
/// - Supprimer: suppression définitive (confirmation requise)
///
/// Indicateurs visuels:
/// - Solde positif: texte vert
/// - Solde négatif: texte rouge
/// - Badge rôle: "Admin" (orange) ou "User" (bleu)
/// - Compte désactivé: opacité réduite + badge "Désactivé"
///
/// Interactions:
/// - Tap card → Menu contextuel actions
/// - Recherche → Filtrage instantané de la liste
/// - FAB → Création nouvel utilisateur
class UsersView extends GetView<UsersController> {
  const UsersView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.users),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textWhite,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: controller.createUser,
        icon: const Icon(Icons.person_add),
        label: const Text('Nouvel utilisateur'),
        backgroundColor: AppColors.primary,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: EdgeInsets.all(16.w),
            child: TextField(
              decoration: InputDecoration(
                hintText: AppStrings.search,
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
                filled: true,
                fillColor: AppColors.surface,
              ),
              onChanged: controller.updateSearchQuery,
            ),
          ),

          // Users list
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.filteredUsers.isEmpty) {
                return Center(
                  child: Text(
                    'Aucun utilisateur trouvé',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: controller.refresh,
                child: ListView.separated(
                  padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 100.h),
                  itemCount: controller.filteredUsers.length,
                  separatorBuilder: (context, index) => SizedBox(height: 12.h),
                  itemBuilder: (context, index) {
                    final user = controller.filteredUsers[index];
                    return _UserCard(user: user);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _UserCard extends GetView<UsersController> {
  final User user;

  const _UserCard({required this.user});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: user.isActive ? 1.0 : 0.5,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        color: user.isActive ? AppColors.surface : Colors.grey.shade200,
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Inactive badge
              if (!user.isActive)
                Container(
                  margin: EdgeInsets.only(bottom: 8.h),
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.block,
                        size: 14.sp,
                        color: AppColors.textWhite,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        'Utilisateur désactivé',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textWhite,
                        ),
                      ),
                    ],
                  ),
                ),
              Row(
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 28.r,
                    backgroundColor: user.role == UserRole.admin
                        ? AppColors.primary
                        : AppColors.accent,
                    child: Text(
                      '${user.firstName[0]}${user.lastName[0]}'.toUpperCase(),
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textWhite,
                      ),
                    ),
                  ),

                  SizedBox(width: 16.w),

                  // User info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${user.firstName} ${user.lastName}',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          user.email,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Role badge
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: user.role == UserRole.admin
                          ? AppColors.primary
                          : AppColors.accent,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      user.role == UserRole.admin ? 'Admin' : 'User',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textWhite,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 12.h),

              // Balance
              Row(
                children: [
                  Icon(
                    Icons.account_balance_wallet,
                    size: 18.sp,
                    color: AppColors.success,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Solde: ${user.balance.toStringAsFixed(2)} €',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 12.h),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: user.isActive
                          ? () => controller.creditAccount(user)
                          : null,
                      icon: Icon(Icons.add_circle_outline, size: 18.sp),
                      label: const Text('Créditer'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.success,
                        side: const BorderSide(color: AppColors.success),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => controller.editUser(user),
                      icon: Icon(Icons.edit, size: 18.sp),
                      label: const Text('Modifier'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  if (user.isActive)
                    IconButton(
                      onPressed: () => controller.deactivateUser(user),
                      icon: const Icon(Icons.block),
                      color: AppColors.error,
                      tooltip: 'Désactiver',
                    )
                  else
                    IconButton(
                      onPressed: () => controller.reactivateUser(user),
                      icon: const Icon(Icons.check_circle),
                      color: AppColors.success,
                      tooltip: 'Réactiver',
                    ),
                  IconButton(
                    onPressed: () => controller.deleteUser(user),
                    icon: const Icon(Icons.delete_forever),
                    color: Colors.red.shade700,
                    tooltip: 'Supprimer définitivement',
                  ),
                ],
              ),

              SizedBox(height: 8.h),

              // Second row of actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => controller.resetPassword(user),
                      icon: Icon(Icons.lock_reset, size: 18.sp),
                      label: const Text('Réinitialiser mot de passe'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.orange,
                        side: const BorderSide(color: Colors.orange),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => controller.resetPin(user),
                      icon: Icon(Icons.pin, size: 18.sp),
                      label: const Text('Réinitialiser code PIN'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.deepOrange,
                        side: const BorderSide(color: Colors.deepOrange),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
