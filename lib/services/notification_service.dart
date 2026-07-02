import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    tz.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    await _plugin.initialize(
      settings: const InitializationSettings(android: android, iOS: ios),
    );

    await requestPermissions();

    _initialized = true;
  }

  /// Solicita los permisos de notificación necesarios en cada plataforma.
  ///
  /// - Android 13+ (API 33) requiere el permiso runtime POST_NOTIFICATIONS.
  /// - iOS requiere solicitar alert/badge/sound.
  ///
  /// Si la implementación específica de la plataforma es null (p. ej. en
  /// plataformas no soportadas) simplemente no hace nada.
  static Future<void> requestPermissions() async {
    final androidImpl = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidImpl != null) {
      await androidImpl.requestNotificationsPermission();
    }

    final iosImpl = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (iosImpl != null) {
      await iosImpl.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  /// Programa una notificación para el día anterior a la fecha de la vacuna.
  static Future<void> scheduleVaccineReminder({
    required int id,
    required String catName,
    required String vaccineName,
    required DateTime dueDate,
  }) async {
    await init();
    final reminderDate = dueDate.subtract(const Duration(days: 1));
    if (reminderDate.isBefore(DateTime.now())) return;

    final scheduledDate = tz.TZDateTime.from(reminderDate, tz.local);

    await _plugin.zonedSchedule(
      id: id,
      scheduledDate: scheduledDate,
      title: '💉 Vacuna mañana — $catName',
      body: '$vaccineName vence mañana. ¡No olvides la cita!',
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'vaccines_channel',
          'Recordatorios de vacunas',
          channelDescription: 'Alertas de próximas vacunas',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  static Future<void> cancelVaccineReminder(int id) async {
    await _plugin.cancel(id: id);
  }

  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}
