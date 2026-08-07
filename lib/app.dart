import 'package:flutter/material.dart';
import 'features/auth/presentation/screens/splash_screen.dart';
import 'features/home/presentation/screens/main_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class App extends StatelessWidget {
  const App({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Crew App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: false,
        fontFamily: 'Montserrat',
        primaryColor: const Color(0xFF072D62),
        scaffoldBackgroundColor: const Color(0xFFF2F4F8),
      ),
      home: const SplashScreen(),
    );
  }
}

/// Navigates to the Home screen when a notification with a booking_id
/// is tapped, per the Push Notifications document's "On Notification Tap"
/// flow: "Extract booking_id from notification data, Navigate to booking
/// details screen." Home screen shows the crew's current booking.
void navigateToBookingFromNotification(String bookingId) {
  navigatorKey.currentState?.push(
    MaterialPageRoute(builder: (_) => const MainScreen()),
  );
}