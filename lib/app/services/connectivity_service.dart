import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Service de surveillance de la connectivité réseau
///
/// Surveille l'état de la connexion internet et notifie l'utilisateur
/// en cas de changement (perte ou rétablissement de la connexion).
class ConnectivityService extends GetxService {
  /// Indique si l'appareil est connecté à internet
  final RxBool isOnline = true.obs;

  @override
  void onInit() {
    super.onInit();
    // Vérification initiale de la connectivité
    _initConnectivity();
    // Écoute des changements de connectivité
    _setupConnectivityListener();
  }

  /// Initialise l'état de connectivité au démarrage
  Future<void> _initConnectivity() async {
    try {
      final result = await Connectivity().checkConnectivity();
      _updateConnectionStatus(result.first);
    } catch (e) {
      print('Error checking connectivity: $e');
    }
  }

  /// Configure l'écoute des changements de connectivité
  ///
  /// Utilise connectivity_plus pour surveiller les changements en temps réel.
  void _setupConnectivityListener() {
    Connectivity().onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      if (results.isNotEmpty) {
        _updateConnectionStatus(results.first);
      }
    });
  }

  /// Met à jour l'état de connexion et notifie l'utilisateur si nécessaire
  ///
  /// [result] Résultat de connectivité (wifi, mobile, none, etc.)
  ///
  /// Affiche un snackbar lors du passage online ↔ offline.
  void _updateConnectionStatus(ConnectivityResult result) {
    final wasOnline = isOnline.value;
    // Considéré offline uniquement si aucune connexion
    isOnline.value = result != ConnectivityResult.none;

    // Affichage d'un snackbar lors des changements d'état
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

  /// Vérifie si une opération nécessitant le réseau peut être effectuée
  ///
  /// [operation] Nom de l'opération (pour le message d'erreur)
  ///
  /// Returns: `true` si online, `false` si offline (+ snackbar d'avertissement)
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
