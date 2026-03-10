import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../controllers/dashboard_controller.dart';
import '../../../../core/values/app_colors.dart';
import '../../../../core/values/app_strings.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.admin),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textWhite,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: controller.logout,
            tooltip: AppStrings.logout,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome message
              Text(
                'Bienvenue,',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                controller.adminName,
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),

              SizedBox(height: 32.h),

              // Management sections grid
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 8.h,
                crossAxisSpacing: 8.w,
                childAspectRatio: 1.6,
                children: [
                  _DashboardCard(
                    icon: Icons.shopping_bag,
                    title: 'Boutique',
                    subtitle: 'Acheter des produits',
                    color: AppColors.accent,
                    onTap: controller.goToShop,
                  ),
                  _DashboardCard(
                    icon: Icons.people,
                    title: AppStrings.users,
                    subtitle: 'Gérer les utilisateurs',
                    color: AppColors.primaryLight,
                    onTap: controller.goToUsers,
                  ),
                  _DashboardCard(
                    icon: Icons.inventory_2,
                    title: AppStrings.products,
                    subtitle: 'Gérer les produits',
                    color: AppColors.accentLight,
                    onTap: controller.goToProducts,
                  ),
                  _DashboardCard(
                    icon: Icons.category,
                    title: AppStrings.categories,
                    subtitle: 'Gérer les catégories',
                    color: AppColors.success,
                    onTap: controller.goToCategories,
                  ),
                  _DashboardCard(
                    icon: Icons.warehouse,
                    title: AppStrings.stock,
                    subtitle: 'Gérer les stocks',
                    color: AppColors.warning,
                    onTap: controller.goToStock,
                  ),
                  _DashboardCard(
                    icon: Icons.receipt_long,
                    title: AppStrings.transactions,
                    subtitle: 'Voir les transactions',
                    color: AppColors.info,
                    onTap: controller.goToTransactions,
                  ),
                  _DashboardCard(
                    icon: Icons.file_download,
                    title: AppStrings.export,
                    subtitle: 'Exporter les données',
                    color: AppColors.primary,
                    onTap: controller.goToExport,
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

class _DashboardCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color.withOpacity(0.8), color],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 28.sp, color: AppColors.textWhite),
              SizedBox(height: 6.h),
              Text(
                title,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textWhite,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 2.h),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 9.sp,
                  color: AppColors.textWhite.withOpacity(0.9),
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
