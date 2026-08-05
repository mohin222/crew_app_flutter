import 'package:flutter/material.dart';
import 'login_screen.dart';

class NewPasswordScreen extends StatefulWidget {
  const NewPasswordScreen({super.key});

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  final _passwordController = TextEditingController();
  final _reEnterController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureReEnter = true;
  String? _errorText;

  static const Color darkNavy = Color(0xFF072D62);
  static const Color lightNavy = Color(0xFF114995);
  static const Color fieldBorder = Color(0xFFFFE6A2);
  static const Color hintGrey = Color(0xFF909090);
  static const Color reportRed = Color(0xFFD50D27);

  @override
  void dispose() {
    _passwordController.dispose();
    _reEnterController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_passwordController.text.isEmpty ||
        _reEnterController.text.isEmpty) {
      setState(() => _errorText = 'Please fill in both fields');
      return;
    }
    if (_passwordController.text != _reEnterController.text) {
      setState(() => _errorText = 'Passwords do not match');
      return;
    }

    setState(() => _errorText = null);

    // TODO: hook up actual "set new password" API call here.

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
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
                child: const Icon(Icons.chevron_left,
                    color: darkNavy, size: 30),
              ),
              const SizedBox(height: 12),
              const Text(
                'Create New',
                style: TextStyle(
                  
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: darkNavy,
                  height: 1.2,
                ),
              ),
              const Text(
                'Password',
                style: TextStyle(
                  
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: darkNavy,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Your new password must be different from previously used passwords.',
                style: TextStyle(
                  
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF555555),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 28),
              _passwordField(
                controller: _passwordController,
                hint: 'Enter New Password',
                obscure: _obscurePassword,
                onToggle: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
              const SizedBox(height: 14),
              _passwordField(
                controller: _reEnterController,
                hint: 'Re-enter Password',
                obscure: _obscureReEnter,
                onToggle: () =>
                    setState(() => _obscureReEnter = !_obscureReEnter),
              ),
              if (_errorText != null) ...[
                const SizedBox(height: 10),
                Text(
                  _errorText!,
                  style: const TextStyle(
                    
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: reportRed,
                  ),
                ),
              ],
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: lightNavy,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Reset Password',
                    style: TextStyle(
                      
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: const TextStyle( fontSize: 16),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            
            fontSize: 16,
            color: hintGrey,
          ),
          prefixIcon: const Icon(Icons.lock_outline,
              color: hintGrey, size: 20),
          suffixIcon: GestureDetector(
            onTap: onToggle,
            child: Icon(
              obscure
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: hintGrey,
              size: 20,
            ),
          ),
          border: InputBorder.none,
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}