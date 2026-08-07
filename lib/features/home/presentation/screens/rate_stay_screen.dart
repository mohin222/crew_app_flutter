import 'package:flutter/material.dart';
import '../../data/feedback_repository.dart';

class RateStayScreen extends StatefulWidget {
  final String? hotelName;
  final String? bookingId;
  final String? hotelId;
  final String? crewId;

  const RateStayScreen({
    super.key,
    this.hotelName,
    this.bookingId,
    this.hotelId,
    this.crewId,
  });

  @override
  State<RateStayScreen> createState() => _RateStayScreenState();
}

class _RateStayScreenState extends State<RateStayScreen> {
  // These 5 categories exactly match the Feedback API's ratings_by_category fields.
  final Map<String, int> _ratings = {
    'Cleanliness': 0,
    'Service Quality': 0,
    'Safety': 0,
    'Food Quality': 0,
    'Transport': 0,
  };

  final Map<String, IconData> _icons = {
    'Cleanliness': Icons.cleaning_services_outlined,
    'Service Quality': Icons.support_agent_outlined,
    'Safety': Icons.shield_outlined,
    'Food Quality': Icons.restaurant_outlined,
    'Transport': Icons.directions_car_outlined,
  };

  final TextEditingController _commentsController = TextEditingController();
  final _feedbackRepository = FeedbackRepository();

  bool _isSubmitting = false;
  String? _errorMessage;
  bool _isSafetyIssue = false;

  static const Color darkNavy = Color(0xFF072D62);
  static const Color lightNavy = Color(0xFF114995);
  static const Color gold = Color(0xFFE2B741);

  @override
  void dispose() {
    _commentsController.dispose();
    super.dispose();
  }

  Future<void> _submitFeedback() async {
    if (widget.bookingId == null || widget.hotelId == null || widget.crewId == null ||
        widget.bookingId!.isEmpty || widget.hotelId!.isEmpty || widget.crewId!.isEmpty) {
      setState(() => _errorMessage = 'Missing booking details. Cannot submit feedback.');
      return;
    }

    if (_ratings.values.any((v) => v == 0)) {
      setState(() => _errorMessage = 'Please rate all 5 categories before submitting.');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final overall = ((_ratings['Cleanliness']! +
        _ratings['Service Quality']! +
        _ratings['Safety']! +
        _ratings['Food Quality']! +
        _ratings['Transport']!) /
        5)
        .round()
        .clamp(1, 5);

    final result = await _feedbackRepository.submitFeedback(
      bookingId: widget.bookingId!,
      crewId: widget.crewId!,
      hotelId: widget.hotelId!,
      ratingOverall: overall,
      cleanliness: _ratings['Cleanliness']!,
      serviceQuality: _ratings['Service Quality']!,
      safety: _ratings['Safety']!,
      foodQuality: _ratings['Food Quality']!,
      transport: _ratings['Transport']!,
      comment: _commentsController.text.trim(),
      categoryTags: _isSafetyIssue ? const ['SAFETY'] : const [],
      severity: _isSafetyIssue ? 'CRITICAL' : (overall <= 2 ? 'CONCERN' : 'INFO'),
    );

    if (!mounted) return;

    setState(() => _isSubmitting = false);

    if (result.success) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isSafetyIssue
              ? 'Safety issue reported — will be handled within 12 hours'
              : 'Feedback submitted successfully'),
        ),
      );
    } else {
      setState(() => _errorMessage = result.errorMessage);
    }
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
                    'How was your experience?',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: darkNavy,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Rate all 5 categories below.',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      fontStyle: FontStyle.italic,
                      color: darkNavy,
                    ),
                  ),
                  const SizedBox(height: 16),

                  ..._ratings.entries.map((e) => _ratingRow(e.key, e.value)),

                  const SizedBox(height: 6),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: _isSafetyIssue ? const Color(0xFFFFEDED) : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _isSafetyIssue ? const Color(0xFFC62828) : const Color(0xFFDADADA),
                        width: _isSafetyIssue ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.warning_amber_rounded,
                            color: _isSafetyIssue ? const Color(0xFFC62828) : Colors.black45,
                            size: 22),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'This is a Safety Issue',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: _isSafetyIssue ? const Color(0xFFC62828) : darkNavy,
                                ),
                              ),
                              const Text(
                                'Marks this as CRITICAL — handled with a 12-hour SLA',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _isSafetyIssue,
                          activeColor: const Color(0xFFC62828),
                          onChanged: (v) => setState(() => _isSafetyIssue = v),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

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
                            "We'd love to know what made your stay memorable — or what could have made it even better.",
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

                  if (_errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ],

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 49,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitFeedback,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isSafetyIssue ? const Color(0xFFC62828) : lightNavy,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2.5),
                      )
                          : Text(
                        _isSafetyIssue ? 'Report Safety Issue' : 'Submit Feedback',
                        style: const TextStyle(
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