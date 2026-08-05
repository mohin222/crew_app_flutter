import 'package:flutter/material.dart';
import '../../../home/presentation/screens/feedback_screen.dart';
import '../../../home/presentation/screens/view_incident_screen.dart';

class CompletedScreen extends StatelessWidget {
  const CompletedScreen({super.key});

  static const Color darkNavy   = Color(0xFF04193E); // darkened
  static const Color lightNavy  = Color(0xFF0A2E6B); // darkened
  static const Color badgeColor = Color(0xFFE2B741);
  static const Color redCode    = Color(0xFFC62828); // darkened

  final List<Map<String, String>> _duties = const [
    {
      'hotel': 'Westin, Kolkata',
      'code': 'CCU',
      'from': 'DEL',
      'to': 'JDH',
      'fromDate': 'Nov 10, 11:20',
      'toDate': 'Nov 11, 08:00',
    },
    {
      'hotel': 'Westin, Kolkata',
      'code': 'CCU',
      'from': 'DEL',
      'to': 'JDH',
      'fromDate': 'Nov 10, 11:20',
      'toDate': 'Nov 11, 08:00',
    },
    {
      'hotel': 'Westin, Kolkata',
      'code': 'CCU',
      'from': 'DEL',
      'to': 'JDH',
      'fromDate': 'Nov 10, 11:20',
      'toDate': 'Nov 11, 08:00',
    },
    {
      'hotel': 'Taj, Delhi',
      'code': 'DEL',
      'from': 'BOM',
      'to': 'DEL',
      'fromDate': 'Oct 25, 09:00',
      'toDate': 'Oct 26, 06:00',
    },
    {
      'hotel': 'Marriott, Mumbai',
      'code': 'BOM',
      'from': 'DEL',
      'to': 'BOM',
      'fromDate': 'Oct 15, 10:00',
      'toDate': 'Oct 16, 08:00',
    },
    {
      'hotel': 'Hyatt, Bangalore',
      'code': 'BLR',
      'from': 'DEL',
      'to': 'BLR',
      'fromDate': 'Oct 05, 07:00',
      'toDate': 'Oct 06, 05:00',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F8),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            height: topPad + 121,
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
            padding: EdgeInsets.fromLTRB(16, topPad + 14, 16, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: const [
                Icon(Icons.arrow_back_ios, color: Colors.white, size: 18),
                SizedBox(width: 4),
                Text(
                  'Completed',
                  style: TextStyle(
                    
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
              child: Column(
                children: _duties
                    .map((d) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildDutyCard(context, d),
                ))
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDutyCard(BuildContext context, Map<String, String> d) {
    return ClipPath(
      clipper: _TicketClipper(),
      child: GestureDetector(
        // Tapping anywhere on the card (other than the Feedback button,
        // which has its own GestureDetector and wins the gesture arena
        // for taps inside its bounds) opens the incident screen.
        behavior: HitTestBehavior.opaque,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const ViewIncidentScreen(),
          ),
        ),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hotel + code
              Row(
                children: [
                  Text(
                    d['hotel']!,
                    style: const TextStyle(
                      
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.32,
                      color: darkNavy,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '(${d['code']!})',
                    style: const TextStyle(
                      
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.32,
                      color: redCode,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // DEL ---?--- JDH
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    d['from']!,
                    style: const TextStyle(
                      
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.64,
                      color: darkNavy,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: LayoutBuilder(
                            builder: (ctx, constraints) => CustomPaint(
                              size: Size(constraints.maxWidth, 1),
                              painter: _DashedLinePainter(),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Transform.rotate(
                            angle: 1.5708,
                            child: const Icon(Icons.flight,
                                size: 16, color: lightNavy),
                          ),
                        ),
                        Expanded(
                          child: LayoutBuilder(
                            builder: (ctx, constraints) => CustomPaint(
                              size: Size(constraints.maxWidth, 1),
                              painter: _DashedLinePainter(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    d['to']!,
                    style: const TextStyle(
                      
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.64,
                      color: darkNavy,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),

              // Dates
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    d['fromDate']!,
                    style: const TextStyle(
                      
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.28,
                      color: lightNavy,
                    ),
                  ),
                  Text(
                    d['toDate']!,
                    style: const TextStyle(
                      
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.28,
                      color: lightNavy,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Buttons row
              Row(
                children: [
                  // Feedback -> FeedbackScreen (its own GestureDetector
                  // takes priority over the card-wide one above it)
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const FeedbackScreen(),
                        ),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: badgeColor,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Text(
                          'Feedback',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // View Incident label kept for visual context; the whole
                  // card (including this) already opens ViewIncidentScreen
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: redCode,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Text(
                        'View Incident',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: darkNavy,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.chevron_right,
                        color: Colors.white, size: 18),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TicketClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const r = 12.0;
    const nr = 10.0;
    final path = Path();
    path.moveTo(r, 0);
    path.lineTo(size.width - r, 0);
    path.arcToPoint(Offset(size.width, r),
        radius: const Radius.circular(r));
    path.lineTo(size.width, size.height / 2 - nr);
    path.arcToPoint(Offset(size.width, size.height / 2 + nr),
        radius: const Radius.circular(nr), clockwise: false);
    path.lineTo(size.width, size.height - r);
    path.arcToPoint(Offset(size.width - r, size.height),
        radius: const Radius.circular(r));
    path.lineTo(r, size.height);
    path.arcToPoint(Offset(0, size.height - r),
        radius: const Radius.circular(r));
    path.lineTo(0, size.height / 2 + nr);
    path.arcToPoint(Offset(0, size.height / 2 - nr),
        radius: const Radius.circular(nr), clockwise: false);
    path.lineTo(0, r);
    path.arcToPoint(Offset(r, 0), radius: const Radius.circular(r));
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFDADADA)
      ..strokeWidth = 1;
    const dashWidth = 4.0;
    const dashSpace = 3.0;
    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, size.height / 2),
        Offset(startX + dashWidth, size.height / 2),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}