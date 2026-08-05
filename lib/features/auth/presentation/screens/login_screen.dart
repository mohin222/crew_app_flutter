import 'package:flutter/material.dart';
import '../../../../features/home/presentation/screens/main_screen.dart';
import 'signup_screen.dart';
import 'forgot_password_screen.dart';
import '../../../../shared/widgets/plane_icon.dart';
import '../../../../shared/widgets/bowl_shape.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _emailController    = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  late AnimationController _animController;
  late Animation<double> _slideAnim;
  bool _formVisible = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _slideAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showForm() {
    setState(() => _formVisible = true);
    _animController.forward();
    FocusScope.of(context).unfocus();
  }

  void _hideForm() {
    _animController.reverse().then((_) {
      setState(() => _formVisible = false);
      FocusScope.of(context).unfocus();
    });
  }

  void _login() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size   = MediaQuery.of(context).size;
    final topPad = MediaQuery.of(context).padding.top;
    final botPad = MediaQuery.of(context).padding.bottom;
    // Get font from theme
    final font = Theme.of(context).textTheme.bodyMedium?.fontFamily ?? 'Montserrat';

    return Scaffold(
      backgroundColor: const Color(0xFF114995),
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        onVerticalDragEnd: (details) {
          if (details.primaryVelocity != null) {
            if (details.primaryVelocity! < -300 && !_formVisible) _showForm();
            if (details.primaryVelocity! > 300 && _formVisible) _hideForm();
          }
        },
        child: Stack(
          children: [

            // SPLASH SCREEN
            Column(
              children: [
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(50),
                        bottomRight: Radius.circular(50),
                      ),
                    ),
                    child: Column(
                      children: [
                        const Spacer(),
                        const PlaneIcon(width: 22, height: 18, color: Color(0xFF072D62)),
                        const SizedBox(height: 10),
                        const Text(
                          'Crew Schedule',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF072D62),
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'THE LAYOVER HUB',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF114995),
                            letterSpacing: 2,
                          ),
                        ),
                        const Spacer(),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 24),
                          child: BowlShape(width: 65, height: 14),
                        ),
                      ],
                    ),
                  ),
                ),

                // BLUE bottom bar
                Container(
                  width: double.infinity,
                  color: const Color(0xFF114995),
                  padding: EdgeInsets.fromLTRB(0, 0, 0, botPad + 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: _showForm,
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Center(
                              child: Text(
                                'Sign In',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(width: 1, height: 24, color: Colors.white38),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {},
                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Center(
                              child: Text(
                                'Login with SSO',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // SLIDING SIGN IN FORM
            AnimatedBuilder(
              animation: _slideAnim,
              builder: (context, child) {
                final offset = size.height * (1 - _slideAnim.value);
                return Transform.translate(
                  offset: Offset(0, offset),
                  child: child,
                );
              },
              child: Container(
                width: size.width,
                height: size.height,
                color: Colors.white,
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      height: topPad + 260,
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
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(height: topPad + 20),
                              const PlaneIcon(width: 22, height: 18, color: Colors.white),
                              const SizedBox(height: 12),
                              const Text(
                                'Crew Schedule',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'THE LAYOVER HUB',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFFF2F2F2),
                                  letterSpacing: 2,
                                ),
                              ),
                            ],
                          ),
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 18,
                            child: Center(child: BowlShape(width: 65, height: 14)),
                          ),
                        ],
                      ),
                    ),

                    // Drag handle
                    GestureDetector(
                      onTap: _hideForm,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: const Color(0xFFDADADA),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),

                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.only(bottom: 40),
                        child: Column(
                          children: [
                            const Text(
                              'Sign In Your Account',
                              style: TextStyle(
                                fontSize: 21,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF072D62),
                                letterSpacing: 0.42,
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Email
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 28),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(color: const Color(0xFFFFE6A2)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 1,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                                child: TextField(
                                  controller: _emailController,
                                  style: const TextStyle(fontSize: 16),
                                  decoration: const InputDecoration(
                                    hintText: 'Enter Your Email/Phone No.',
                                    hintStyle: TextStyle(
                                      fontSize: 16,
                                      color: Color(0xFF909090),
                                    ),
                                    prefixIcon: Icon(Icons.email_outlined,
                                        color: Color(0xFF909090), size: 20),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 14),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 14),

                            // Password
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 28),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(color: const Color(0xFFFFE6A2)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 1,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                                child: TextField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  style: const TextStyle(fontSize: 16),
                                  decoration: InputDecoration(
                                    hintText: 'Enter Your Password',
                                    hintStyle: const TextStyle(
                                      fontSize: 16,
                                      color: Color(0xFF909090),
                                    ),
                                    prefixIcon: const Icon(Icons.lock_outline,
                                        color: Color(0xFF909090), size: 20),
                                    suffixIcon: GestureDetector(
                                      onTap: () => setState(
                                              () => _obscurePassword = !_obscurePassword),
                                      child: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                        color: const Color(0xFF909090),
                                        size: 20,
                                      ),
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 14),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 10),

                            // Forgot Password
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 28),
                              child: Row(
                                children: [
                                  const Icon(Icons.info, size: 18, color: Color(0xFF918D8D)),
                                  const SizedBox(width: 8),
                                  GestureDetector(
                                    onTap: () => Navigator.push(context,
                                        MaterialPageRoute(
                                            builder: (_) => const ForgotPasswordScreen())),
                                    child: const Text(
                                      'Forgot Password?',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontStyle: FontStyle.italic,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF918D8D),
                                        letterSpacing: 0.84,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Sign In button
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 28),
                              child: SizedBox(
                                width: double.infinity,
                                height: 49,
                                child: ElevatedButton(
                                  onPressed: _login,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF114995),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15)),
                                  ),
                                  child: const Text(
                                    'Sign In',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      letterSpacing: 0.36,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Sign Up with SSO — font from theme
                            GestureDetector(
                              onTap: () {},
                              child: RichText(
                                text: TextSpan(
                                  style: TextStyle(fontFamily: font, fontSize: 14, color: Colors.black),
                                  children: [
                                    const TextSpan(text: 'Or '),
                                    TextSpan(
                                      text: 'Sign Up with SSO',
                                      style: TextStyle(fontFamily: font, fontWeight: FontWeight.w700, color: const Color(0xFF0093E9)),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 28),
                              child: Divider(color: Colors.grey.shade300),
                            ),

                            const SizedBox(height: 16),

                            // Don't have account — font from theme
                            GestureDetector(
                              onTap: () => Navigator.push(context,
                                  MaterialPageRoute(builder: (_) => const SignUpScreen())),
                              child: RichText(
                                text: TextSpan(
                                  style: TextStyle(fontFamily: font, fontSize: 14, color: Colors.black),
                                  children: [
                                    const TextSpan(text: "Don't Have an Account? "),
                                    TextSpan(
                                      text: 'Sign Up',
                                      style: TextStyle(fontFamily: font, fontWeight: FontWeight.w700, color: const Color(0xFF0093E9)),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}