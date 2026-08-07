import 'package:flutter/material.dart';
import 'rate_stay_screen.dart';
import '../../data/feedback_repository.dart';

class FeedbackScreen extends StatefulWidget {
  final String? hotelName;
  final String? bookingId;
  final String? hotelId;
  final String? crewId;

  const FeedbackScreen({
    super.key,
    this.hotelName,
    this.bookingId,
    this.hotelId,
    this.crewId,
  });

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  static const Color darkNavy = Color(0xFF072D62);
  static const Color lightNavy = Color(0xFF114995);

  final _feedbackRepository = FeedbackRepository();
  bool _isLoading = true;
  String? _errorMessage;
  List<FeedbackItem> _feedbacks = [];

  @override
  void initState() {
    super.initState();
    _loadFeedbacks();
  }

  Future<void> _loadFeedbacks() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _feedbackRepository.getMyFeedbacks(hotelId: widget.hotelId);

    if (!mounted) return;

    if (result.success) {
      setState(() {
        _feedbacks = result.feedbacks;
        _isLoading = false;
      });
    } else {
      setState(() {
        _errorMessage = result.errorMessage;
        _isLoading = false;
      });
    }
  }

  Future<void> _openRateStay() async {
    final submitted = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RateStayScreen(
          hotelName: widget.hotelName,
          bookingId: widget.bookingId,
          hotelId: widget.hotelId,
          crewId: widget.crewId,
        ),
      ),
    );
    // Refresh the list in case new feedback was submitted.
    if (submitted != false) {
      _loadFeedbacks();
    }
  }

  String _fmtDate(DateTime dt) {
    final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final local = dt.toLocal();
    return '${months[local.month - 1]} ${local.day}, ${local.year}';
  }

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
                  'Your Feedback',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: _openRateStay,
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

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),

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
                          child: Text(
                            widget.hotelName ?? 'Hotel details unavailable',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

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

                  const SizedBox(height: 24),

                  if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.only(top: 40),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Column(
                        children: [
                          Text(_errorMessage!,
                              style: const TextStyle(color: Colors.red),
                              textAlign: TextAlign.center),
                          const SizedBox(height: 12),
                          ElevatedButton(
                              onPressed: _loadFeedbacks,
                              child: const Text('Retry')),
                        ],
                      ),
                    )
                  else if (_feedbacks.isEmpty)
                      Center(
                        child: Column(
                          children: [
                            const SizedBox(height: 16),
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
                      )
                    else
                      ..._feedbacks.map((f) => _feedbackCard(f)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _feedbackCard(FeedbackItem f) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
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
          Row(
            children: [
              Row(
                children: List.generate(5, (i) => Icon(
                  i < f.ratingOverall ? Icons.star : Icons.star_border,
                  color: const Color(0xFFE2B741),
                  size: 16,
                )),
              ),
              const Spacer(),
              Text(
                _fmtDate(f.submittedAt),
                style: const TextStyle(
                    fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black54),
              ),
            ],
          ),
          if (f.comment.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              f.comment,
              style: const TextStyle(fontSize: 13, color: Colors.black87),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            'Status: ${f.status}',
            style: const TextStyle(
                fontSize: 11, fontWeight: FontWeight.w700, color: darkNavy),
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