import 'package:flutter/material.dart';
import '../../../home/data/booking_repository.dart';

class DutyDetailScreen extends StatefulWidget {
  final Map<String, String> duty;
  const DutyDetailScreen({super.key, required this.duty});

  @override
  State<DutyDetailScreen> createState() => _DutyDetailScreenState();
}

class _DutyDetailScreenState extends State<DutyDetailScreen> {
  bool _showCheckInOtp = false;
  bool _showCheckOutOtp = false;
  bool _isActionLoading = false;
  String? _actionError;
  late String _currentStatus;

  final _bookingRepository = BookingRepository();

  static const Color darkNavy     = Color(0xFF072D62);
  static const Color gold         = Color(0xFFE2B741);
  static const Color otpBlue      = Color(0xFF0093E9);
  static const Color textDarkGrey = Color(0xFF0A0A0A);
  static const Color green        = Color(0xFF14AE5C);

  final List<String> _hotelImages = [
    'https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=300',
    'https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=300',
    'https://images.unsplash.com/photo-1578683010236-d716f9a3f461?w=300',
    'https://images.unsplash.com/photo-1584132967334-10e028bd69f7?w=300',
  ];

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.duty['status'] ?? '';
  }

  bool get _canCheckIn =>
      _currentStatus == 'HOTEL_APPROVED' || _currentStatus == 'PUBLISHED_TO_CREW';

  bool get _canCheckOut => _currentStatus == 'CHECKED_IN';

  Future<void> _handleCheckIn() async {
    final bookingId = widget.duty['bookingId'];
    if (bookingId == null || bookingId.isEmpty) return;

    setState(() {
      _isActionLoading = true;
      _actionError = null;
    });

    final result = await _bookingRepository.checkIn(bookingId);

    if (!mounted) return;

    setState(() {
      _isActionLoading = false;
      if (result.success && result.booking != null) {
        _currentStatus = result.booking!.status;
      } else {
        _actionError = result.errorMessage;
      }
    });
  }

  Future<void> _handleCheckOut() async {
    final bookingId = widget.duty['bookingId'];
    if (bookingId == null || bookingId.isEmpty) return;

    setState(() {
      _isActionLoading = true;
      _actionError = null;
    });

    final result = await _bookingRepository.checkOut(bookingId);

    if (!mounted) return;

    setState(() {
      _isActionLoading = false;
      if (result.success && result.booking != null) {
        _currentStatus = result.booking!.status;
      } else {
        _actionError = result.errorMessage;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final d = widget.duty;

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
                Expanded(
                  child: Text(
                    '${d['from']} - ${d['to']}',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
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
                  // Airport card - real from/station + real status
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF114995),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                d['from'] ?? '--',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                d['code'] ?? '',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 8),
                          decoration: BoxDecoration(
                            color: gold,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _currentStatus.isNotEmpty ? _currentStatus : '--',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Real Check-In / Check-Out buttons - gated by real status
                  if (_canCheckIn || _canCheckOut) ...[
                    if (_actionError != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          _actionError!,
                          style: const TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _isActionLoading
                            ? null
                            : (_canCheckIn ? _handleCheckIn : _handleCheckOut),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _canCheckIn ? green : darkNavy,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        child: _isActionLoading
                            ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                            : Text(
                          _canCheckIn ? 'Check In' : 'Check Out',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Flight Timeline - now shows real check-in/check-out dates
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Stay Timeline',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            fontStyle: FontStyle.italic,
                            color: darkNavy,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Check-In',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black54,
                                    )),
                                const SizedBox(height: 2),
                                Text(d['fromDate'] ?? '--',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: darkNavy,
                                    )),
                              ],
                            ),
                            Expanded(
                              child: Column(
                                children: [
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: LayoutBuilder(
                                          builder: (ctx, constraints) =>
                                              CustomPaint(
                                                size: Size(constraints.maxWidth, 1),
                                                painter: _DashedLinePainter(),
                                              ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 6),
                                        child: Transform.rotate(
                                          angle: 1.5708,
                                          child: const Icon(Icons.flight,
                                              size: 20, color: darkNavy),
                                        ),
                                      ),
                                      Expanded(
                                        child: LayoutBuilder(
                                          builder: (ctx, constraints) =>
                                              CustomPaint(
                                                size: Size(constraints.maxWidth, 1),
                                                painter: _DashedLinePainter(),
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(d['duration'] ?? '',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black54,
                                      )),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text('Check-Out',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black54,
                                    )),
                                const SizedBox(height: 2),
                                Text(d['toDate'] ?? '--',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: darkNavy,
                                    )),
                              ],
                            ),
                          ],
                        ),
                        const Divider(height: 24, color: Color(0xFFEEEEEE)),

                        // Hotel name - real
                        Text(
                          d['hotel'] ?? 'Hotel details unavailable',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: darkNavy,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Hotel images - static placeholder (no real images exist in API)
                        SizedBox(
                          height: 70,
                          child: Row(
                            children: _hotelImages.asMap().entries.map((e) {
                              return Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(right: e.key < 3 ? 4 : 0),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      e.value,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        color: const Color(0xFFD9D9D9),
                                        child: const Icon(Icons.image_outlined,
                                            color: Color(0xFF9CA3AF)),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // OTP box - static (per doc: OTP handling still pending team decision)
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFFAFAFA),
                            borderRadius: BorderRadius.circular(7),
                            border: Border.all(color: const Color(0xFFDADADA), width: 0.5),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 2,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: IntrinsicHeight(
                            child: Row(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('Check-In',
                                            style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w800,
                                                color: darkNavy)),
                                        const SizedBox(height: 2),
                                        Text(d['fromDate'] ?? '--',
                                            style: const TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w700,
                                                color: textDarkGrey)),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Flexible(
                                              child: Text('OTP @ check in ',
                                                  overflow: TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      fontSize: 10,
                                                      fontStyle: FontStyle.italic,
                                                      fontWeight: FontWeight.w700,
                                                      color: textDarkGrey)),
                                            ),
                                            Text(
                                                _showCheckInOtp ? '4521' : '****',
                                                style: const TextStyle(
                                                    fontSize: 10,
                                                    fontStyle: FontStyle.italic,
                                                    fontWeight: FontWeight.w700,
                                                    color: otpBlue)),
                                            const SizedBox(width: 4),
                                            GestureDetector(
                                              onTap: () => setState(
                                                      () => _showCheckInOtp = !_showCheckInOtp),
                                              child: Icon(
                                                _showCheckInOtp
                                                    ? Icons.visibility_outlined
                                                    : Icons.visibility_off_outlined,
                                                size: 12,
                                                color: otpBlue,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Container(width: 0.5, color: const Color(0xFFDADADA)),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(8, 8, 12, 8),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('Check-Out',
                                            style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w800,
                                                color: darkNavy)),
                                        const SizedBox(height: 2),
                                        Text(d['toDate'] ?? '--',
                                            style: const TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w700,
                                                color: textDarkGrey)),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Flexible(
                                              child: Text('OTP @ check out ',
                                                  overflow: TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      fontSize: 10,
                                                      fontStyle: FontStyle.italic,
                                                      fontWeight: FontWeight.w700,
                                                      color: textDarkGrey)),
                                            ),
                                            Text(
                                                _showCheckOutOtp ? '7893' : '****',
                                                style: const TextStyle(
                                                    fontSize: 10,
                                                    fontStyle: FontStyle.italic,
                                                    fontWeight: FontWeight.w700,
                                                    color: otpBlue)),
                                            const SizedBox(width: 4),
                                            GestureDetector(
                                              onTap: () => setState(
                                                      () => _showCheckOutOtp = !_showCheckOutOtp),
                                              child: Icon(
                                                _showCheckOutOtp
                                                    ? Icons.visibility_outlined
                                                    : Icons.visibility_off_outlined,
                                                size: 12,
                                                color: otpBlue,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            '*OTP shown here is a placeholder — pending backend decision',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              fontStyle: FontStyle.italic,
                              color: otpBlue,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Amenities & Policies - static, no real data exists in API
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Amenities & Policies',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: darkNavy,
                            )),
                        const SizedBox(height: 4),
                        const Text('Not yet available from backend',
                            style: TextStyle(
                              fontSize: 10,
                              fontStyle: FontStyle.italic,
                              color: Colors.black45,
                            )),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _amenityChip(Icons.spa_outlined, 'Spa'),
                            _amenityChip(Icons.pool_outlined, 'Swimming Pool'),
                            _amenityChip(Icons.fitness_center_outlined, 'Fitness Centre'),
                            _amenityChip(Icons.wifi_outlined, 'Wifi'),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Transfer Details - static, transport records currently empty in API
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Transfer Details',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: darkNavy,
                            )),
                        const SizedBox(height: 4),
                        const Text('No transport data available yet',
                            style: TextStyle(
                              fontSize: 10,
                              fontStyle: FontStyle.italic,
                              color: Colors.black45,
                            )),
                        const SizedBox(height: 12),
                      ],
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

  Widget _amenityChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFDADADA)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: darkNavy),
          const SizedBox(width: 6),
          Text(label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: darkNavy,
              )),
        ],
      ),
    );
  }
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
      canvas.drawLine(Offset(startX, size.height / 2),
          Offset(startX + dashWidth, size.height / 2), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}