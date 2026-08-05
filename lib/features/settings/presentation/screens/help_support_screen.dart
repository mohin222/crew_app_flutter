import 'package:flutter/material.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  static const Color darkNavy = Color(0xFF072D62);
  static const Color lightNavy = Color(0xFF114995);

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
                Text('Help & Support',
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
                  Text('Get assistance and support',
                      style: TextStyle( 
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: darkNavy)),
                  const SizedBox(height: 16),
                  _item(Icons.call_outlined, 'Call Support',
                      '+91 9876543210'),
                  const SizedBox(height: 10),
                  _item(Icons.email_outlined, 'Email Us',
                      'support@rezolvhospitality.com'),
                  const SizedBox(height: 10),
                  _item(Icons.chat_bubble_outline, 'Live Chat',
                      'Chat with our support team'),
                  const SizedBox(height: 10),
                  _item(Icons.help_outline, 'FAQs',
                      'Find answers to common questions'),
                  const SizedBox(height: 20),
                  Text('Frequently Asked Questions',
                      style: TextStyle( 
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: darkNavy)),
                  const SizedBox(height: 10),
                  _faq('How do I view my upcoming duties?',
                      'Go to the Upcoming tab from the bottom navigation bar.'),
                  _faq('How do I report a hotel issue?',
                      'Open Home screen and tap "Report an Issue" button.'),
                  _faq('How can I share OTP with hotel staff?',
                      'Tap the eye icon next to the OTP on Check-In/Check-Out card.'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _item(IconData icon, String title, String subtitle) {
    return Container(
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
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFF0F4FF),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: lightNavy, size: 20),
        ),
        title: Text(title,
            style: TextStyle( 
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: darkNavy)),
        subtitle: Text(subtitle,
            style: TextStyle( 
                fontSize: 12, color: const Color(0xFF9CA3AF))),
        trailing: const Icon(Icons.chevron_right, color: darkNavy),
        onTap: () {},
      ),
    );
  }

  Widget _faq(String q, String a) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        title: Text(q,
            style: TextStyle( 
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: darkNavy)),
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(a,
                style: TextStyle( 
                    fontSize: 12, color: const Color(0xFF6B7280))),
          ),
        ],
      ),
    );
  }
}
