import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../services/server_config_service.dart';
import '../controllers/settings_controller.dart';

class ServerConfigView extends GetView<SettingsController> {
  const ServerConfigView({super.key});

  @override
  Widget build(BuildContext context) {
    final configService = Get.find<ServerConfigService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuration du serveur'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Info card
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.blue.shade700,
                      size: 24.sp,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        'Configurez l\'adresse IP et le port du serveur AirBar',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 32.h),

            // Host field
            Text(
              'Adresse du serveur',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8.h),
            TextField(
              controller: controller.hostController,
              decoration: InputDecoration(
                hintText: 'Ex: 192.168.1.100 ou localhost',
                prefixIcon: const Icon(Icons.dns),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              keyboardType: TextInputType.text,
            ),

            SizedBox(height: 24.h),

            // Port field
            Text(
              'Port',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8.h),
            TextField(
              controller: controller.portController,
              decoration: InputDecoration(
                hintText: 'Ex: 8080',
                prefixIcon: const Icon(Icons.settings_ethernet),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(5),
              ],
            ),

            SizedBox(height: 32.h),

            // Test connection button
            Obx(
              () => OutlinedButton.icon(
                onPressed: controller.isLoading.value
                    ? null
                    : controller.testConnection,
                icon: controller.isLoading.value
                    ? SizedBox(
                        width: 20.w,
                        height: 20.h,
                        child: const CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.wifi_find),
                label: Text(
                  controller.isLoading.value
                      ? 'Test en cours...'
                      : 'Tester la connexion',
                ),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
            ),

            SizedBox(height: 16.h),

            // Save button
            Obx(
              () => ElevatedButton.icon(
                onPressed: controller.isSaving.value
                    ? null
                    : controller.saveConfiguration,
                icon: controller.isSaving.value
                    ? SizedBox(
                        width: 20.w,
                        height: 20.h,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save),
                label: Text(
                  controller.isSaving.value ? 'Sauvegarde...' : 'Sauvegarder',
                ),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
            ),

            SizedBox(height: 16.h),

            // Reset button
            TextButton.icon(
              onPressed: controller.resetToDefault,
              icon: const Icon(Icons.refresh),
              label: const Text('Réinitialiser par défaut'),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16.h),
              ),
            ),

            SizedBox(height: 32.h),

            // Current config display
            Card(
              color: Colors.grey.shade100,
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Configuration actuelle',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Obx(
                      () => Text(
                        'URL: ${configService.serverUrl}',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontFamily: 'monospace',
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
