import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'new_password_screen.dart';

class ForgotPasswordVerificationScreen extends StatefulWidget {
  final String contact;

  const ForgotPasswordVerificationScreen({super.key, required this.contact});

  @override
  State<ForgotPasswordVerificationScreen> createState() =>
      _ForgotPasswordVerificationScreenState();
}

class _ForgotPasswordVerificationScreenState
    extends State<ForgotPasswordVerificationScreen> {
  static const Color darkNavy   = Color(0xFF072D62);
  static const Color lightNavy  = Color(0xFF114995);
  static const Color fieldBorder = Color(0xFFFFE6A2);
  static const Color reportRed  = Color(0xFFD50D27);

  final List<TextEditingController> _controllers =
  List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  Timer? _timer;
  int _secondsRemaining = 340;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _secondsRemaining = 340);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining <= 0) {
        timer.cancel();
      } else {
        setState(() => _secondsRemaining--);
      }
    });
  }

  String get _formattedTime {
    final minutes = (_secondsRemaining ~/ 60).toString().padLeft(2, '0');
    final seconds = (_secondsRemaining % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    super.dispose();
  }

  void _onDigitChanged(String value, int index) {
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  void _verify() {
    final code = _controllers.map((c) => c.text).join();
    if (code.length < 6) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const NewPasswordScreen()),
    );
  }

  void _resend() {
    for (final c in _controllers) c.clear();
    _focusNodes[0].requestFocus();
    _startTimer();
  }

  String get _maskedContact {
    if (widget.contact.isEmpty) return 'your registered contact';
    return widget.contact;
  }

  @override
  Widget build(BuildContext context) {
    // Get font from theme
    final font = Theme.of(context).textTheme.bodyMedium?.fontFamily ?? 'Montserrat';

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.chevron_left, color: darkNavy, size: 30),
              ),
              const SizedBox(height: 12),
              const Text('Enter your',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: darkNavy, height: 1.2)),
              const Text('Verification Code',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: darkNavy, height: 1.2)),
              const SizedBox(height: 28),

              // OTP boxes
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) {
                  return SizedBox(
                    width: 46,
                    height: 56,
                    child: TextField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: darkNavy),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        counterText: '',
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.zero,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: fieldBorder),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: fieldBorder),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: lightNavy, width: 2),
                        ),
                      ),
                      onChanged: (value) => _onDigitChanged(value, index),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 24),

              // Timer
              Text(_formattedTime,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: darkNavy)),
              const SizedBox(height: 12),

              // Description
              Text(
                "We've sent a One-Time Password (OTP) to $_maskedContact. Please enter the OTP above to continue.",
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF0A0A0A), height: 1.4),
              ),
              const SizedBox(height: 28),

              // Verify button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _verify,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: lightNavy,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Verify',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 20),

              // Resend ← font from theme
              Center(
                child: GestureDetector(
                  onTap: _secondsRemaining == 0 ? _resend : null,
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(fontFamily: font, fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFF0A0A0A)),
                      children: [
                        const TextSpan(text: "Didn't receive the OTP? "),
                        TextSpan(
                          text: 'Resend',
                          style: TextStyle(
                            fontFamily: font,
                            fontWeight: FontWeight.w800,
                            color: _secondsRemaining == 0 ? reportRed : reportRed.withOpacity(0.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}