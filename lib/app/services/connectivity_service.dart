import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Service for monitoring network connectivity
class ConnectivityService extends GetxService {
  final RxBool isOnline = true.obs;

  @override
  void onInit() {
    super.onInit();
    _initConnectivity();
    _setupConnectivityListener();
  }

  /// Initialize connectivity status
  Future<void> _initConnectivity() async {
    try {
      final result = await Connectivity().checkConnectivity();
      _updateConnectionStatus(result.first);
    } catch (e) {
      print('Error checking connectivity: $e');
    }
  }

  /// Setup listener for connectivity changes
  void _setupConnectivityListener() {
    Connectivity().onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      if (results.isNotEmpty) {
        _updateConnectionStatus(results.first);
      }
    });
  }

  /// Update connection status and notify user if offline
  void _updateConnectionStatus(ConnectivityResult result) {
    final wasOnline = isOnline.value;
    isOnline.value = result != ConnectivityResult.none;

    // Show snackbar when connection status changes
    if (wasOnline && !isOnline.value) {
      Get.snackbar(
        'Connexion perdue',
        'Vous êtes hors ligne. Certaines fonctionnalités ne sont pas disponibles.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    } else if (!wasOnline && isOnline.value) {
      Get.snackbar(
        'Connexion rétablie',
        'Vous êtes de nouveau en ligne.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    }
  }

  /// Check if operations requiring network can be performed
  bool requiresConnection(String operation) {
    if (!isOnline.value) {
      Get.snackbar(
        'Connexion requise',
        'Cette opération nécessite une connexion internet.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
      return false;
    }
    return true;
  }
}
