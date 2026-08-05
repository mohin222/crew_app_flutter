import 'package:flutter/material.dart';
import 'features/auth/presentation/screens/splash_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
