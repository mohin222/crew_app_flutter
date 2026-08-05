import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const Color darkNavy = Color(0xFF072D62);
  static const Color lightNavy = Color(0xFF114995);

  // Controllers hold the editable text for each field.
  // TODO: replace these initial values with real user data (e.g. from your auth/user model).
  final _nameController = TextEditingController(text: 'Durgesh Shanbagh');
  final _emailController =
  TextEditingController(text: 'durgesh@rezolvhospitality.com');
  final _phoneController = TextEditingController(text: '+91 9876543210');
  final _empIdController = TextEditingController(text: 'EMP-10293');

  @override
  void dispose() {
    // Always dispose controllers to avoid memory leaks.
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _empIdController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    // TODO: replace this with your real save logic
    // (e.g. call an API / update local storage / update auth provider).
    final name = _nameController.text;
    final email = _emailController.text;
    final phone = _phoneController.text;
    final empId = _empIdController.text;

    debugPrint('Saving profile: $name, $email, $phone, $empId');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated successfully')),
    );
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
                const Text('Profile',
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
                  const Text('Edit your Personal Information',
                      style: TextStyle(
                          
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: darkNavy)),
                  const SizedBox(height: 20),
                  _field('Full Name', _nameController),
                  const SizedBox(height: 14),
                  _field('Email', _emailController,
                      keyboardType: TextInputType.emailAddress),
                  const SizedBox(height: 14),
                  _field('Phone Number', _phoneController,
                      keyboardType: TextInputType.phone),
                  const SizedBox(height: 14),
                  _field('Employee ID', _empIdController),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 49,
                    child: ElevatedButton(
                      onPressed: _saveChanges,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: lightNavy,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                      ),
                      child: const Text('Save Changes',
                          style: TextStyle(
                              
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Now an actual editable text field, not a static Text() label.
  Widget _field(String label, TextEditingController controller,
      {TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280))),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: const TextStyle(
                 fontSize: 14, color: darkNavy),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding:
              EdgeInsets.symmetric(horizontal: 10, vertical: 14),
            ),
          ),
        ),
      ],
    );
  }
}