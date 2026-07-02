import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/api/api_client.dart';
import 'services/notification_service.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'app.dart';

void main() {
  // Captura los errores del framework de Flutter para que un fallo aislado
  // no tumbe la app y quede registrado en los logs.
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('FlutterError capturado: ${details.exceptionAsString()}');
  };

  // runZonedGuarded envuelve toda la inicialización y el arranque de la app,
  // de modo que cualquier excepción no controlada se loguee sin crashear.
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Firebase es opcional en el arranque: si falla (config ausente, sin red,
    // etc.) la app debe seguir funcionando.
    try {
      await Firebase.initializeApp();
    } catch (e, st) {
      debugPrint('Error inicializando Firebase (se continúa sin él): $e');
      debugPrint('$st');
    }

    // ApiClient.init() es síncrono pero lo protegemos igualmente.
    try {
      ApiClient.init();
    } catch (e, st) {
      debugPrint('Error inicializando ApiClient: $e');
      debugPrint('$st');
    }

    // Las notificaciones no son críticas para arrancar la app.
    try {
      await NotificationService.init();
    } catch (e, st) {
      debugPrint('Error inicializando NotificationService: $e');
      debugPrint('$st');
    }

    // Verificar si el onboarding ya se mostró.
    bool onboardingDone = false;
    try {
      onboardingDone = await isOnboardingDone();
    } catch (e, st) {
      debugPrint('Error leyendo estado de onboarding: $e');
      debugPrint('$st');
    }

    runApp(
      ProviderScope(
        child: MiMichiApp(showOnboarding: !onboardingDone),
      ),
    );
  }, (error, stack) {
    debugPrint('Error no controlado en la app: $error');
    debugPrint('$stack');
  });
}
