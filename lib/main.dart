import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/api/api_client.dart';
import 'services/notification_service.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  ApiClient.init();
  await NotificationService.init();

  // Verificar si el onboarding ya se mostró
  final onboardingDone = await isOnboardingDone();

  runApp(
    ProviderScope(
      child: MiMichiApp(showOnboarding: !onboardingDone),
    ),
  );
}
