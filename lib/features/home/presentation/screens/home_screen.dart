import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/booking_repository.dart';
import '../../data/hotel_repository.dart';
import '../../data/transport_repository.dart';
import '../../../settings/data/profile_repository.dart';
import 'feedback_screen.dart';
import '../../../notifications/presentation/screens/notification_history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedFilter = 'ALL';
  bool _showCheckInOtp = false;
  bool _showCheckOutOtp = false;

  static const String _checkInOtpValue = 'N/A';
  static const String _checkOutOtpValue = 'N/A';

  final List<String> _hotelImages = [
    'https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=300',
    'https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=300',
    'https://images.unsplash.com/photo-1578683010236-d716f9a3f461?w=300',
    'https://images.unsplash.com/photo-1584132967334-10e028bd69f7?w=300',
  ];

  static const String _hotelAddress = 'Address not available';

  static const Color navy           = Color(0xFF072D62);
  static const Color dullNavy       = Color(0xFF6B7A99);
  static const Color textDarkGrey   = Color(0xFF0A0A0A);
  static const Color otpBlue        = Color(0xFF0093E9);
  static const Color feedbackYellow = Color(0xFFE2B741);
  static const Color chipGrey       = Color(0xFFD9D9D9);
  static const Color chipGreen      = Color(0xFF14AE5C);

  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0;

  final _profileRepository = ProfileRepository();
  final _bookingRepository = BookingRepository();
  final _hotelRepository = HotelRepository();
  final _transportRepository = TransportRepository();

  bool _isLoading = true;
  String? _errorMessage;

  String _crewName = '';
  String _crewId = '';
  Booking? _latestBooking;
  HotelInfo? _hotelInfo;
  List<TransportInfo> _transports = [];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      setState(() {
        _scrollOffset = _scrollController.offset;
      });
    });
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final profileResult = await _profileRepository.getMyProfile();
    final bookingsResult = await _bookingRepository.getMyBookings();

    if (!mounted) return;

    if (!profileResult.success || !bookingsResult.success) {
      setState(() {
        _errorMessage = profileResult.errorMessage ?? bookingsResult.errorMessage;
        _isLoading = false;
      });
      return;
    }

    final latestBooking =
    bookingsResult.bookings.isNotEmpty ? bookingsResult.bookings.first : null;

    HotelInfo? hotelInfo;
    List<TransportInfo> transports = [];

    if (latestBooking != null) {
      if (latestBooking.hotelId.isNotEmpty) {
        final hotelResult = await _hotelRepository.getHotelById(latestBooking.hotelId);
        if (hotelResult.success) {
          hotelInfo = hotelResult.hotel;
        }
      }

      final transportResult = await _transportRepository.getTransportsForBooking(latestBooking.id);
      if (transportResult.success) {
        transports = transportResult.transports;
      }
    }

    if (!mounted) return;

    setState(() {
      _crewName = profileResult.profile?.fullName ?? '';
      _crewId = profileResult.profile?.crewId ?? '';
      _latestBooking = latestBooking;
      _hotelInfo = hotelInfo;
      _transports = transports;
      _isLoading = false;
    });
  }

  String _formatDateTime(DateTime dt) {
    return DateFormat('MMM dd, yyyy - HH:mm').format(dt.toLocal());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _openInGoogleMaps(String address) async {
    final Uri mapsUri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address)}',
    );
    if (!await launchUrl(mapsUri, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch Google Maps for: $address');
    }
  }

  void _openImageViewer(BuildContext context, List<String> images, int initialIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _FullScreenImageViewer(
          images: images,
          initialIndex: initialIndex,
        ),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    final double expandedHeight = 120.0;
    final double collapsedHeight = 72.0;
    final double collapseProgress = (_scrollOffset / expandedHeight).clamp(0.0, 1.0);

    final double headerHeight = topPad +
        expandedHeight * (1 - collapseProgress) +
        collapsedHeight * collapseProgress;

    final double welcomeOpacity = (1.0 - collapseProgress * 2).clamp(0.0, 1.0);
    final double nameFontSize = 24 - (6 * collapseProgress);
    final double namePadTop = topPad + 14 - (14 * collapseProgress * 0.5);

    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFFAFAFA),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: const Color(0xFFFAFAFA),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_errorMessage!,
                    style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
                const SizedBox(height: 12),
                ElevatedButton(onPressed: _loadData, child: const Text('Retry')),
              ],
            ),
          ),
        ),
      );
    }

    final checkInText =
    _latestBooking != null ? _formatDateTime(_latestBooking!.checkInUtc) : '--';
    final checkOutText =
    _latestBooking != null ? _formatDateTime(_latestBooking!.checkOutUtc) : '--';
    final hotelNameText = _hotelInfo?.name ?? 'Hotel details unavailable';

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                SizedBox(height: topPad + expandedHeight),
                Padding(
                  padding: const EdgeInsets.fromLTRB(13.5, 14, 13.5, 20),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 14),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 13),
                          child: _buildFilterPill(),
                        ),
                        const SizedBox(height: 14),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                hotelNameText.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: navy,
                                  letterSpacing: 0.64,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 4),
                              GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () => _openInGoogleMaps(_hotelAddress),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(Icons.location_on_outlined, size: 12, color: otpBlue),
                                    const SizedBox(width: 3),
                                    Expanded(
                                      child: Text(
                                        _hotelAddress,
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: otpBlue,
                                          letterSpacing: 0.4,
                                          height: 1.4,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                height: 62,
                                child: Row(
                                  children: _hotelImages.asMap().entries.map((e) {
                                    return Expanded(
                                      child: Padding(
                                        padding: EdgeInsets.only(right: e.key < 3 ? 4 : 0),
                                        child: GestureDetector(
                                          onTap: () => _openImageViewer(context, _hotelImages, e.key),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(10),
                                            child: Image.network(
                                              e.value,
                                              height: 62,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) => Container(
                                                height: 62,
                                                color: const Color(0xFFD9D9D9),
                                                child: const Icon(Icons.image_outlined,
                                                    color: Color(0xFF9CA3AF)),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFAFAFA),
                                  borderRadius: BorderRadius.circular(7),
                                  border: Border.all(color: const Color(0xFFDADADA), width: 0.5),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
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
                                          padding: const EdgeInsets.fromLTRB(14, 8, 10, 8),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text('Check-In',
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w800,
                                                      color: navy,
                                                      letterSpacing: 0.56)),
                                              const SizedBox(height: 2),
                                              Text(checkInText,
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w700,
                                                      color: textDarkGrey)),
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  Flexible(
                                                    child: Text('OTP @ check in ',
                                                        overflow: TextOverflow.ellipsis,
                                                        style: TextStyle(
                                                            fontSize: 11,
                                                            fontStyle: FontStyle.italic,
                                                            fontWeight: FontWeight.w700,
                                                            color: textDarkGrey)),
                                                  ),
                                                  Text(
                                                      _showCheckInOtp ? _checkInOtpValue : '****',
                                                      style: const TextStyle(
                                                          fontSize: 11,
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
                                                      size: 13,
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
                                          padding: const EdgeInsets.fromLTRB(10, 8, 14, 8),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text('Check-Out',
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w800,
                                                      color: navy,
                                                      letterSpacing: 0.56)),
                                              const SizedBox(height: 2),
                                              Text(checkOutText,
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w700,
                                                      color: textDarkGrey)),
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  Flexible(
                                                    child: Text('OTP @ check out ',
                                                        overflow: TextOverflow.ellipsis,
                                                        style: TextStyle(
                                                            fontSize: 11,
                                                            fontStyle: FontStyle.italic,
                                                            fontWeight: FontWeight.w700,
                                                            color: textDarkGrey)),
                                                  ),
                                                  Text(
                                                      _showCheckOutOtp ? _checkOutOtpValue : '****',
                                                      style: const TextStyle(
                                                          fontSize: 11,
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
                                                      size: 13,
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
                              Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  '*Share the OTPs during Check-in and Check-out',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    fontStyle: FontStyle.italic,
                                    color: otpBlue,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                            ],
                          ),
                        ),
                        _amenitiesRow(),
                        const SizedBox(height: 8),
                        _transportRow(),
                        const SizedBox(height: 8),
                        _pickupRow(),
                        const SizedBox(height: 14),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(14, 0, 14, 16),
                          child: Row(
                            children: [
                              Expanded(
                                child: _actionBtn('Feedback', feedbackYellow,
                                    onTap: () => Navigator.push(context,
                                        MaterialPageRoute(builder: (_) => FeedbackScreen(
                                          hotelName: hotelNameText,
                                          bookingId: _latestBooking?.id,
                                          hotelId: _latestBooking?.hotelId,
                                          crewId: _crewId,
                                        )))),
                              ),
                              const SizedBox(width: 8),
                              Expanded(child: _actionBtn('Call Us', navy, onTap: () {})),
                              const SizedBox(width: 8),
                              Expanded(child: _actionBtn('Chat Us', navy, onTap: () {})),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: headerHeight,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.3159, 1.0],
                  colors: [Color(0xFF072D62), Color(0xFF114995)],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30 * (1 - collapseProgress * 0.5)),
                  bottomRight: Radius.circular(30 * (1 - collapseProgress * 0.5)),
                ),
              ),
              padding: EdgeInsets.fromLTRB(27, namePadTop, 20, 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (welcomeOpacity > 0)
                          Opacity(
                            opacity: welcomeOpacity,
                            child: const Text(
                              'Welcome Back,',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.28,
                              ),
                            ),
                          ),
                        const SizedBox(height: 2),
                        Text(
                          _crewName.isNotEmpty ? _crewName : '--',
                          style: TextStyle(
                            fontSize: nameFontSize,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.48,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const NotificationHistoryScreen()),
                      ),
                      child: const Icon(Icons.notifications_outlined,
                          color: Colors.white, size: 22),
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

  Widget _buildFilterPill() {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFFDADADA)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 2,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(_latestBooking?.stationIata ?? '--',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.52,
                  color: navy)),
          _chip('ALL'),
          _chip('HOTEL'),
          _chip('TRANSPORT'),
        ],
      ),
    );
  }

  Widget _chip(String label) {
    final bool selected = _selectedFilter == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: EdgeInsets.symmetric(horizontal: selected ? 12 : 8, vertical: 5),
        decoration: BoxDecoration(
          color: selected ? chipGreen : chipGrey,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.44,
                color: selected ? Colors.white : navy)),
      ),
    );
  }

  Widget _amenitiesRow() {
    return _expandableCard(
      icon: Icons.spa_outlined,
      title: 'Amenities & Policies',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Not yet available from backend',
              style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic, color: Colors.black45)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['Spa', 'Swimming Pool', 'Wifi', 'Fitness Centre']
                .map((label) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFDADADA)),
              ),
              child: Text(label,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: navy)),
            ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _transportRow() {
    return _expandableCard(
      icon: Icons.directions_car_outlined,
      title: 'Transport Details',
      child: _transports.isEmpty
          ? const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Text(
          'No transport arranged for this booking yet.',
          style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.black45),
        ),
      )
          : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _transports
            .asMap()
            .entries
            .map((e) => Padding(
          padding: EdgeInsets.only(bottom: e.key < _transports.length - 1 ? 12 : 0),
          child: _transportCard(e.value),
        ))
            .toList(),
      ),
    );
  }

  Widget _transportCard(TransportInfo t) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(t.type.isNotEmpty ? t.type : 'Transport',
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: otpBlue)),
        const SizedBox(height: 8),
        _transportInfoRow(Icons.directions_car_outlined,
            t.vehicleRegistration.isNotEmpty ? t.vehicleRegistration : '--'),
        const SizedBox(height: 8),
        _transportInfoRow(Icons.call_outlined,
            t.driverPhone.isNotEmpty ? t.driverPhone : '--'),
        const SizedBox(height: 8),
        _transportInfoRow(Icons.person_outline,
            t.driverName.isNotEmpty ? t.driverName : '--'),
        const SizedBox(height: 8),
        _transportInfoRow(Icons.info_outline,
            t.status.isNotEmpty ? t.status : '--'),
        const SizedBox(height: 10),
        if ((t.status).isNotEmpty)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: feedbackYellow,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
              child: Text('Track Location',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: navy)),
            ),
          ),
      ],
    );
  }

  Widget _transportInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
              shape: BoxShape.circle, border: Border.all(color: const Color(0xFFDADADA))),
          child: Icon(icon, size: 14, color: navy),
        ),
        const SizedBox(width: 8),
        Text(text,
            style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w800, color: navy)),
      ],
    );
  }

  Widget _pickupRow() {
    return _expandableCard(
      icon: Icons.store_mall_directory_outlined,
      title: 'Pick-up & Drop-off Zone',
      child: const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Text(
          'No pick-up/drop-off zone data available yet.',
          style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.black45),
        ),
      ),
    );
  }

  Widget _expandableCard({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF2F2F2),
          borderRadius: BorderRadius.circular(21.5),
          border: Border.all(color: const Color(0xFFDADADA), width: 0.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            dense: true,
            leading: Icon(icon, color: AppColors.primary, size: 18),
            title: Text(title,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: navy,
                    letterSpacing: 0.56)),
            iconColor: const Color(0xFF6B7280),
            collapsedIconColor: const Color(0xFF6B7280),
            tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(21.5)),
            collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(21.5)),
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFF2F2F2),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(21.5),
                    bottomRight: Radius.circular(21.5),
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                child: child,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _actionBtn(String label, Color color, {required VoidCallback onTap}) {
    return SizedBox(
      height: 38,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(19)),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
        ),
        child: Text(label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Colors.white)),
      ),
    );
  }
}

class _FullScreenImageViewer extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const _FullScreenImageViewer({required this.images, required this.initialIndex});

  @override
  State<_FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<_FullScreenImageViewer> {
  late final PageController _controller = PageController(initialPage: widget.initialIndex);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: PageView.builder(
        controller: _controller,
        itemCount: widget.images.length,
        itemBuilder: (context, index) {
          return InteractiveViewer(
            minScale: 1,
            maxScale: 4,
            child: Center(
              child: Image.network(
                widget.images[index],
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) =>
                const Icon(Icons.broken_image_outlined, color: Colors.white54, size: 48),
              ),
            ),
          );
        },
      ),
    );
  }
}