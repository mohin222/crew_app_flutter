import 'package:flutter/material.dart';
import '../../../notifications/data/fcm_repository.dart';
import '../../../notifications/data/push_notification_service.dart';

class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key});

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  bool _pushNotifications = true;
  bool _emailAlerts = true;
  bool _darkMode = false;
  bool _biometricLogin = true;
  bool _isUpdatingPush = false;

  final _fcmRepository = FcmRepository();

  static const Color darkNavy = Color(0xFF072D62);
  static const Color lightNavy = Color(0xFF114995);

  /// Toggling this calls DELETE /fcm-token/ when turned off, and
  /// re-registers via POST /fcm-token/ when turned back on, per the
  /// document: "Remove FCM Token... When the user disables push
  /// notifications in app settings."
  Future<void> _onPushToggled(bool value) async {
    setState(() {
      _pushNotifications = value;
      _isUpdatingPush = true;
    });

    if (value) {
      await PushNotificationService().initialize();
    } else {
      await _fcmRepository.removeToken();
    }

    if (!mounted) return;
    setState(() => _isUpdatingPush = false);
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F8),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.3159, 1.0],
                colors: [Color(0xFF072D62), Color(0xFF114995)],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            padding: EdgeInsets.fromLTRB(16, topPad + 14, 16, 24),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.arrow_back_ios,
                      color: Colors.white, size: 18),
                ),
                const SizedBox(width: 12),
                const Text('Preferences',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Customise your app experiences',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: darkNavy)),
                  const SizedBox(height: 16),
                  _toggle(
                      'Push Notifications',
                      _isUpdatingPush
                          ? 'Updating...'
                          : 'Receive alerts for duty changes',
                      _pushNotifications,
                      _isUpdatingPush ? null : _onPushToggled),
                  const SizedBox(height: 10),
                  _toggle('Email Alerts', 'Get updates via email',
                      _emailAlerts, (v) => setState(() => _emailAlerts = v)),
                  const SizedBox(height: 10),
                  _toggle('Dark Mode', 'Switch app appearance', _darkMode,
                          (v) => setState(() => _darkMode = v)),
                  const SizedBox(height: 10),
                  _toggle('Biometric Login', 'Use fingerprint / Face ID',
                      _biometricLogin,
                          (v) => setState(() => _biometricLogin = v)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _toggle(String title, String subtitle, bool value,
      ValueChanged<bool>? onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2)),
        ],
      ),
      child: SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(title,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: darkNavy)),
        subtitle: Text(subtitle,
            style: const TextStyle(
                fontSize: 12, color: Color(0xFF9CA3AF))),
        value: value,
        activeColor: lightNavy,
        onChanged: onChanged,
      ),
    );
  }
}