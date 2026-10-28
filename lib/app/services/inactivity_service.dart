import 'dart:async';
import 'package:get/get.dart';
import '../core/utils/trace_logger.dart';
import 'auth_service.dart';
import 'server_config_service.dart';
import '../routes/app_routes.dart';

/// Service de déconnexion automatique après une période d'inactivité
///
/// Le minuteur n'est actif que si un utilisateur est authentifié. Toute
/// interaction utilisateur (voir le `Listener` global dans main.dart) doit
/// appeler [resetTimer] pour repousser la déconnexion.
class InactivityService extends GetxService {
  final AuthService _authService = Get.find<AuthService>();
  final ServerConfigService _configService = Get.find<ServerConfigService>();

  Timer? _timer;

  InactivityService() {
    Trace.create('InactivityService');
  }

  /// Réinitialise (ou démarre) le minuteur d'inactivité
  ///
  /// Sans effet si aucun utilisateur n'est connecté ou si le délai est
  /// désactivé (0 minute).
  void resetTimer() {
    Trace.call('InactivityService', 'resetTimer');
    _timer?.cancel();

    final minutes = _configService.inactivityTimeoutMinutes;
    if (!_authService.isAuthenticated.value || minutes <= 0) {
      return;
    }

    _timer = Timer(Duration(minutes: minutes), _onTimeout);
  }

  /// Arrête le minuteur (ex: à la déconnexion manuelle)
  void cancelTimer() {
    Trace.call('InactivityService', 'cancelTimer');
    _timer?.cancel();
    _timer = null;
  }

  /// Déconnexion automatique déclenchée par l'expiration du délai
  void _onTimeout() {
    Trace.call('InactivityService', '_onTimeout');
    if (!_authService.isAuthenticated.value) return;

    _authService.clearUser();
    Get.offAllNamed(AppRoutes.LOGIN);
    Get.snackbar(
      'Session expirée',
      'Vous avez été déconnecté après une période d\'inactivité',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  @override
  void onClose() {
    Trace.dispose('InactivityService');
    _timer?.cancel();
    super.onClose();
  }
}
