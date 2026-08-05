import 'package:flutter/material.dart';

class RateStayScreen extends StatefulWidget {
  const RateStayScreen({super.key});

  @override
  State<RateStayScreen> createState() => _RateStayScreenState();
}

class _RateStayScreenState extends State<RateStayScreen> {
  final Map<String, int> _ratings = {
    'Staff Behaviour': 4,
    'Service Quality': 4,
    'Food': 5,
    'Room Amenities': 3,
  };

  final Map<String, IconData> _icons = {
    'Staff Behaviour': Icons.support_agent_outlined,
    'Service Quality': Icons.star_outline,
    'Food': Icons.restaurant_outlined,
    'Room Amenities': Icons.bed_outlined,
  };

  final TextEditingController _commentsController = TextEditingController();

  static const Color darkNavy = Color(0xFF072D62);
  static const Color lightNavy = Color(0xFF114995);
  static const Color gold = Color(0xFFE2B741);

  @override
  void dispose() {
    _commentsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F8),
      body: Column(
        children: [
          // Header
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
                const Text(
                  'Rate your stay',
                  style: TextStyle(
                    
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),

                  // Hotel card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: lightNavy,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.location_on_outlined,
                            color: Colors.white, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Crowne Plaza, Melbourne',
                                style: TextStyle(
                                  
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Crowne Plaza Melbourne, 1-5 Spencer St, Docklands VIC 3008, Australia',
                                style: TextStyle(
                                  
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // How was your experience
                  const Text(
                    'How was your experience?',
                    style: TextStyle(
                      
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: darkNavy,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'You have already submitted for this stay.',
                    style: TextStyle(
                      
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      fontStyle: FontStyle.italic,
                      color: darkNavy,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Rating rows - tap a star to set that rating by hand
                  ..._ratings.entries.map((e) => _ratingRow(e.key, e.value)),

                  const SizedBox(height: 6),

                  // Additional Comments
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Additional Comments',
                          style: TextStyle(
                            
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: darkNavy,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _commentsController,
                          maxLines: 4,
                          style: const TextStyle(
                              
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87),
                          decoration: const InputDecoration(
                            hintText:
                            "We'd love to know what made your stay memorable ? or what could have made it even better.",
                            hintStyle: TextStyle(
                              
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.black54,
                              height: 1.6,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    height: 49,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Feedback submitted successfully'),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: lightNavy,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: const Text(
                        'Submit Feedback',
                        style: TextStyle(
                          
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _ratingRow(String label, int rating) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFF0F4FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(_icons[label], color: darkNavy, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: darkNavy,
              ),
            ),
          ),
          // Each star is individually tappable, so the rating for this
          // row is set by hand (1-5) rather than being fixed.
          Row(
            children: List.generate(5, (i) {
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => setState(() => _ratings[label] = i + 1),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 1),
                  child: Icon(
                    i < rating ? Icons.star : Icons.star_border,
                    color: gold,
                    size: 20,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}