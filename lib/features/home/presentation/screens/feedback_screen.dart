import 'package:flutter/material.dart';
import 'rate_stay_screen.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  static const Color darkNavy = Color(0xFF072D62);
  static const Color lightNavy = Color(0xFF114995);

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
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
                  'Your Feedback',
                  style: TextStyle(
                    
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                // + button
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => RateStayScreen()),
                  ),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.add,
                      color: Color(0xFF072D62),
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Body
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

                  // Previous Experiences
                  const Text(
                    'Your Previous Experiences',
                    style: TextStyle(
                      
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: darkNavy,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Review all your previous feedback and experiences.',
                    style: TextStyle(
                      
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      fontStyle: FontStyle.italic,
                      color: darkNavy,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Empty state
                  Center(
                    child: Column(
                      children: [
                        SizedBox(
                          width: 90,
                          height: 90,
                          child: CustomPaint(
                              painter: _DocumentSearchPainter()),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'No Feedback Yet',
                          style: TextStyle(
                            
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF072D62),
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "You haven't provided any feedback for\nthis hotel yet. Tap the + button to share\nyour experience!",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                            height: 1.6,
                          ),
                        ),
                      ],
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
}

class _DocumentSearchPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final docPath = Path();
    docPath.moveTo(size.width * 0.18, size.height * 0.05);
    docPath.lineTo(size.width * 0.62, size.height * 0.05);
    docPath.lineTo(size.width * 0.82, size.height * 0.22);
    docPath.lineTo(size.width * 0.82, size.height * 0.78);
    docPath.lineTo(size.width * 0.18, size.height * 0.78);
    docPath.close();
    canvas.drawPath(docPath, paint);

    final foldPath = Path();
    foldPath.moveTo(size.width * 0.62, size.height * 0.05);
    foldPath.lineTo(size.width * 0.62, size.height * 0.22);
    foldPath.lineTo(size.width * 0.82, size.height * 0.22);
    canvas.drawPath(foldPath, paint);

    canvas.drawLine(Offset(size.width * 0.30, size.height * 0.38),
        Offset(size.width * 0.68, size.height * 0.38), paint);
    canvas.drawLine(Offset(size.width * 0.30, size.height * 0.50),
        Offset(size.width * 0.68, size.height * 0.50), paint);
    canvas.drawLine(Offset(size.width * 0.30, size.height * 0.62),
        Offset(size.width * 0.55, size.height * 0.62), paint);

    canvas.drawCircle(
      Offset(size.width * 0.72, size.height * 0.72),
      size.width * 0.14,
      Paint()
        ..color = Colors.grey.shade300
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    canvas.drawLine(
      Offset(size.width * 0.82, size.height * 0.82),
      Offset(size.width * 0.94, size.height * 0.94),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}