import 'package:flutter/material.dart';
import 'forgot_password_verification_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _contactController = TextEditingController();

  static const Color darkNavy       = Color(0xFF072D62);
  static const Color lightNavy      = Color(0xFF114995);
  static const Color otpBlue        = Color(0xFF0093E9);
  static const Color feedbackYellow = Color(0xFFE2B741);
  static const Color hintGrey       = Color(0xFF3D3D3D);

  @override
  void dispose() {
    _contactController.dispose();
    super.dispose();
  }

  void _submit() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ForgotPasswordVerificationScreen(
          contact: _contactController.text,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            children: [
              Container(
                width: 60,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFFDADADA),
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                'FORGOT PASSWORD?',
                style: TextStyle(
                  
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: darkNavy,
                  letterSpacing: 0.6,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'It happens to all of us',
                style: TextStyle(
                  
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: hintGrey,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F4F4),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: otpBlue, width: 1.2),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.lock_outline_rounded,
                          color: feedbackYellow, size: 26),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Reset via Mail/Phone',
                      style: TextStyle(
                        
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: darkNavy,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Please enter the email address or phone number linked to your account. We'll send you a message to set a new password.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF0A0A0A),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(26),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.only(left: 20, right: 6),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _contactController,
                              style: const TextStyle(
                                
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: darkNavy,
                              ),
                              decoration: const InputDecoration(
                                hintText: 'Enter your Email/ Phone No. here',
                                hintStyle: TextStyle(
                                  
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: darkNavy,
                                ),
                                border: InputBorder.none,
                                contentPadding:
                                EdgeInsets.symmetric(vertical: 14),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: _submit,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: const BoxDecoration(
                                color: lightNavy,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.send_rounded,
                                  color: Colors.white, size: 18),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}