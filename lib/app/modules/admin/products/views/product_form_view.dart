import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../controllers/product_form_controller.dart';
import '../../../../core/values/app_colors.dart';
import '../../../../core/values/app_strings.dart';

class ProductFormView extends GetView<ProductFormController> {
  const ProductFormView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(
          () => Text(
            controller.isEdit.value ? 'Modifier produit' : 'Nouveau produit',
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
                  labelText: 'Nom du produit',
                  prefixIcon: const Icon(Icons.shopping_bag),
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

              // Category
              Obx(
                () => DropdownButtonFormField<int>(
                  value: controller.selectedCategory.value,
                  decoration: InputDecoration(
                    labelText: 'Catégorie',
                    prefixIcon: const Icon(Icons.category),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  items: controller.categories
                      .map(
                        (cat) => DropdownMenuItem(
                          value: cat.id,
                          child: Text(cat.name),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    controller.selectedCategory.value = value;
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Catégorie requise';
                    }
                    return null;
                  },
                ),
              ),

              SizedBox(height: 16.h),

              // Bulk product section (moved before price for better UX)
              Obx(
                () => SwitchListTile(
                  title: const Text('Produit au détail / en vrac'),
                  subtitle: Text(
                    controller.isBulkProduct.value
                        ? 'Portions multiples (ex: bière en fût)'
                        : 'Produit unitaire standard',
                  ),
                  value: controller.isBulkProduct.value,
                  onChanged: (value) {
                    controller.isBulkProduct.value = value;
                  },
                  activeColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    side: const BorderSide(color: AppColors.textHint),
                  ),
                ),
              ),

              SizedBox(height: 16.h),

              // Price
              Obx(
                () => TextFormField(
                  controller: controller.priceController,
                  decoration: InputDecoration(
                    labelText: controller.isBulkProduct.value
                        ? 'Prix de base (€) - optionnel'
                        : 'Prix (€)',
                    hintText: controller.isBulkProduct.value
                        ? 'Laissez vide, les prix sont définis par portions'
                        : 'Prix unitaire',
                    helperText: controller.isBulkProduct.value
                        ? 'Les portions ont leurs propres prix'
                        : null,
                    prefixIcon: const Icon(Icons.euro),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: controller.validatePrice,
                ),
              ),

              SizedBox(height: 16.h),

              // Stock quantity
              Obx(
                () => TextFormField(
                  controller: controller.stockQuantityController,
                  decoration: InputDecoration(
                    labelText: controller.isBulkProduct.value
                        ? 'Nombre d\'unités en stock'
                        : 'Quantité en stock',
                    hintText: controller.isBulkProduct.value
                        ? 'Ex: 5 (pour 5 fûts)'
                        : null,
                    helperText: controller.isBulkProduct.value
                        ? 'Nombre d\'unités complètes (ex: fûts, caisses)'
                        : null,
                    prefixIcon: const Icon(Icons.inventory),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  validator: controller.validateStock,
                ),
              ),

              SizedBox(height: 16.h),

              // Min stock alert
              Obx(
                () => TextFormField(
                  controller: controller.minStockAlertController,
                  decoration: InputDecoration(
                    labelText: controller.isBulkProduct.value
                        ? 'Seuil d\'alerte (unités)'
                        : 'Seuil d\'alerte stock',
                    hintText: controller.isBulkProduct.value
                        ? 'Ex: 2 (alerte si moins de 2 unités)'
                        : null,
                    helperText: controller.isBulkProduct.value
                        ? 'Alerte quand le nombre d\'unités descend sous ce seuil'
                        : null,
                    prefixIcon: const Icon(Icons.warning),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  validator: controller.validateMinStock,
                ),
              ),

              SizedBox(height: 24.h),

              // Bulk product fields
              Obx(
                () => controller.isBulkProduct.value
                    ? Column(
                        children: [
                          SizedBox(height: 16.h),

                          // Bulk unit
                          TextFormField(
                            controller: controller.bulkUnitController,
                            decoration: InputDecoration(
                              labelText: 'Unité de mesure',
                              hintText: 'Ex: litres, kg, ml',
                              prefixIcon: const Icon(Icons.straighten),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                          ),

                          SizedBox(height: 16.h),

                          // Bulk total quantity
                          TextFormField(
                            controller: controller.bulkTotalQuantityController,
                            decoration: InputDecoration(
                              labelText: 'Quantité totale par unité',
                              hintText: 'Ex: 6 pour un fût de 6 litres',
                              helperText:
                                  'Volume/poids total d\'une unité complète',
                              prefixIcon: const Icon(Icons.local_drink),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                          ),

                          SizedBox(height: 16.h),

                          // Current unit remaining
                          TextFormField(
                            controller:
                                controller.currentUnitRemainingController,
                            decoration: InputDecoration(
                              labelText:
                                  'Quantité dans l\'unité ouverte (optionnel)',
                              hintText:
                                  'Ex: 3.5 pour 3.5L restants dans un fût',
                              helperText:
                                  'Quantité restante dans l\'unité actuellement entamée',
                              prefixIcon: const Icon(
                                Icons.inventory_2_outlined,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                          ),

                          SizedBox(height: 16.h),

                          // Portions section
                          Card(
                            color: AppColors.surface,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(16.w),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Portions',
                                        style: TextStyle(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.add_circle),
                                        color: AppColors.primary,
                                        onPressed: () =>
                                            controller.showPortionDialog(),
                                      ),
                                    ],
                                  ),

                                  SizedBox(height: 8.h),

                                  Obx(() {
                                    if (controller.portions.isEmpty) {
                                      return Center(
                                        child: Padding(
                                          padding: EdgeInsets.all(16.w),
                                          child: Text(
                                            'Aucune portion ajoutée.\nAppuyez sur + pour en ajouter.',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: AppColors.textHint,
                                            ),
                                          ),
                                        ),
                                      );
                                    }

                                    return ListView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: controller.portions.length,
                                      itemBuilder: (context, index) {
                                        final portion =
                                            controller.portions[index];
                                        return ListTile(
                                          leading: const Icon(Icons.local_bar),
                                          title: Text(portion.name),
                                          subtitle: Text(
                                            '${portion.quantity} ${controller.bulkUnitController.text} - ${portion.price.toStringAsFixed(2)}€',
                                          ),
                                          trailing: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                icon: const Icon(Icons.edit),
                                                color: AppColors.primary,
                                                onPressed: () => controller
                                                    .showPortionDialog(
                                                      index: index,
                                                    ),
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.delete),
                                                color: AppColors.error,
                                                onPressed: () => controller
                                                    .removePortion(index),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    );
                                  }),
                                ],
                              ),
                            ),
                          ),
                        ],
                      )
                    : const SizedBox.shrink(),
              ),

              SizedBox(height: 16.h),

              // Active status
              Obx(
                () => SwitchListTile(
                  title: const Text('Produit actif'),
                  subtitle: Text(
                    controller.isActive.value
                        ? 'Visible dans la boutique'
                        : 'Masqué de la boutique',
                  ),
                  value: controller.isActive.value,
                  onChanged: (value) {
                    controller.isActive.value = value;
                  },
                  activeColor: AppColors.success,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    side: const BorderSide(color: AppColors.textHint),
                  ),
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
