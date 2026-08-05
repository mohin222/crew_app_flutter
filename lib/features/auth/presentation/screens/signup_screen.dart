import 'package:flutter/material.dart';
import 'verification_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _fullNameController = TextEditingController();
  final _airportController = TextEditingController();
  final _emailController = TextEditingController();
  final _staffIdController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _reEnterPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureReEnterPassword = true;

  static const Color darkNavy = Color(0xFF072D62);
  static const Color fieldBorder = Color(0xFFFFE6A2);
  static const Color hintGrey = Color(0xFF909090);
  static const Color bgColor = Color(0xFFFAFAFA);

  @override
  void dispose() {
    _fullNameController.dispose();
    _airportController.dispose();
    _emailController.dispose();
    _staffIdController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _reEnterPasswordController.dispose();
    super.dispose();
  }

  void _signUp() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const VerificationScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get font from theme so it changes with app.dart
    final font = Theme.of(context).textTheme.bodyMedium?.fontFamily ?? 'Montserrat';

    return Scaffold(
      backgroundColor: bgColor,
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
              const Text('Sign Up',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: darkNavy, height: 1.2)),
              const Text('To Your Account',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: darkNavy, height: 1.2)),
              const SizedBox(height: 28),
              _field(controller: _fullNameController, icon: Icons.person_outline, hint: 'Full Name'),
              const SizedBox(height: 14),
              _field(controller: _airportController, icon: Icons.flight, hint: 'Airport'),
              const SizedBox(height: 14),
              _field(controller: _emailController, icon: Icons.email_outlined, hint: 'Official Email Id'),
              const SizedBox(height: 14),
              _field(controller: _staffIdController, icon: Icons.badge_outlined, hint: 'Staff Id'),
              const SizedBox(height: 14),
              _field(controller: _phoneController, icon: Icons.call_outlined, hint: 'Phone Number'),
              const SizedBox(height: 14),
              _passwordField(
                controller: _passwordController,
                hint: 'Enter Your Password',
                obscure: _obscurePassword,
                onToggle: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
              const SizedBox(height: 14),
              _passwordField(
                controller: _reEnterPasswordController,
                hint: 'Re-enter Password',
                obscure: _obscureReEnterPassword,
                onToggle: () => setState(() => _obscureReEnterPassword = !_obscureReEnterPassword),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _signUp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: darkNavy,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Sign Up',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 0.36)),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: RichText(
                    text: TextSpan(
                      // ← font from theme
                      style: TextStyle(fontFamily: font, fontSize: 14, color: Colors.black),
                      children: [
                        const TextSpan(text: 'Already Have an Account? '),
                        TextSpan(
                          text: 'Sign In',
                          style: TextStyle(fontFamily: font, fontWeight: FontWeight.w700, color: const Color(0xFF0093E9)),
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

  Widget _field({required TextEditingController controller, required IconData icon, required String hint}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: fieldBorder),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 2, offset: const Offset(0, 1))],
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 16, color: hintGrey),
          prefixIcon: Icon(icon, color: hintGrey, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _passwordField({
    required TextEditingController controller,
    required String hint,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: fieldBorder),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 2, offset: const Offset(0, 1))],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 16, color: hintGrey),
          prefixIcon: const Icon(Icons.lock_outline, color: hintGrey, size: 20),
          suffixIcon: GestureDetector(
            onTap: onToggle,
            child: Icon(obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: hintGrey, size: 20),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}