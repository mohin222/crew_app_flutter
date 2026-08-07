import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'fcm_repository.dart';
import '../../../app.dart';

/// Background handler must be a top-level function, exactly as documented.
@pragma('vm:entry-point')
Future<void> firebaseBackgroundMessageHandler(RemoteMessage message) async {
  // Background message received - per document, log/handle here.
  // No UI work is possible at this point.
}

class PushNotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FcmRepository _fcmRepository = FcmRepository();

  /// Callback the app can set to navigate when a notification is tapped
  /// and contains a booking_id, per the document's "On Notification Tap"
  /// flow.
  void Function(String bookingId)? onBookingNotificationTapped;

  Future<void> initialize() async {
    // Wire the tap callback to navigate, per the document's
    // "On Notification Tap" flow.
    onBookingNotificationTapped = navigateToBookingFromNotification;

    // Request permission (iOS; harmless no-op on most Android versions,
    // required on Android 13+).
    final settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    final authorized = settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;

    debugPrint('FCM PERMISSION STATUS: ${settings.authorizationStatus}');

    if (!authorized) {
      debugPrint('FCM NOT AUTHORIZED - permission denied or not determined');
      return;
    }

    // Get FCM token and register with backend.
    final token = await _fcm.getToken();
    debugPrint('FCM TOKEN: $token');
    if (token != null) {
      final result = await _fcmRepository.registerToken(token);
      debugPrint('FCM REGISTER RESULT: success=${result.success} message=${result.message} error=${result.errorMessage}');
    } else {
      debugPrint('FCM TOKEN WAS NULL - could not get token from device');
    }

    // Listen for token refresh - re-register with backend per document.
    _fcm.onTokenRefresh.listen((newToken) {
      debugPrint('FCM TOKEN REFRESHED: $newToken');
      _fcmRepository.registerToken(newToken);
    });

    // Handle foreground messages.
    FirebaseMessaging.onMessage.listen(_handleMessage);

    // Handle background messages.
    FirebaseMessaging.onBackgroundMessage(firebaseBackgroundMessageHandler);

    // Handle notification tap (app was in background).
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // Handle cold start (app opened from a terminated state via notification).
    final initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }
  }

  void _handleMessage(RemoteMessage message) {
    debugPrint('FCM FOREGROUND MESSAGE RECEIVED: ${message.data}');
    final data = message.data;
    // BOOKING_CONFIRMED / BOOKING_CANCELLED per document's data.type field.
    if (data['type'] == 'BOOKING_CONFIRMED' || data['type'] == 'BOOKING_CANCELLED') {
      // Foreground message received; UI layer can show a snackbar/banner
      // if desired. Left as a hook for the screen layer to react to.
    }
  }

  void _handleNotificationTap(RemoteMessage message) {
    debugPrint('FCM NOTIFICATION TAPPED: ${message.data}');
    final bookingId = message.data['booking_id'];
    if (bookingId != null && onBookingNotificationTapped != null) {
      onBookingNotificationTapped!(bookingId);
    }
  }

  /// Called on logout, per document's "On User Logout" flow.
  Future<void> removeToken() async {
    final result = await _fcmRepository.removeToken();
    debugPrint('FCM REMOVE TOKEN RESULT: success=${result.success} message=${result.message} error=${result.errorMessage}');
  }
}
