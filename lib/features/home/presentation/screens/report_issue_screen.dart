import 'package:flutter/material.dart';
import 'report_incident_screen.dart';

class ReportIssueScreen extends StatefulWidget {
  const ReportIssueScreen({super.key});

  @override
  State<ReportIssueScreen> createState() => _ReportIssueScreenState();
}

class _ReportIssueScreenState extends State<ReportIssueScreen> {
  int _selectedTab = 0;
  final List<String> _tabs = ['All', 'Open', 'Closed'];

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
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
                const Text(
                  'Incident',
                  style: TextStyle(
                    
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ReportIncidentScreen(),
                    ),
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

          // Status tabs
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Text(
                  'Status:',
                  style: TextStyle(
                    
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(width: 8),
                ...List.generate(_tabs.length, (i) {
                  final selected = _selectedTab == i;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedTab = i),
                    child: Container(
                      margin: const EdgeInsets.only(right: 4),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: selected
                                ? const Color(0xFFE2B741)
                                : Colors.transparent,
                            width: 2.5,
                          ),
                        ),
                      ),
                      child: Text(
                        _tabs[i],
                        style: TextStyle(
                          
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: selected
                              ? const Color(0xFF072D62)
                              : Colors.black87,
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),

          Container(height: 1, color: Colors.grey.shade200),

          // Empty state
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 90,
                    height: 90,
                    child: CustomPaint(painter: _DocumentSearchPainter()),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'No Incident Found',
                    style: TextStyle(
                      
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
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