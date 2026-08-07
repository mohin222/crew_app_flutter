import 'package:flutter/material.dart';
import '../../data/duties_repository.dart';

class UpcomingScreen extends StatefulWidget {
  const UpcomingScreen({super.key});

  @override
  State<UpcomingScreen> createState() => _UpcomingScreenState();
}

class _UpcomingScreenState extends State<UpcomingScreen> {
  String _selectedStatus = 'Current';
  DateTime _currentMonth = DateTime.now();

  final _dutiesRepository = DutiesRepository();
  bool _isLoading = true;
  String? _errorMessage;
  List<DutyCard> _allDutyCards = [];
  final ScrollController _scrollController = ScrollController();

  String _monthName(int m) => [
    '',
    'January', 'February', 'March', 'April',
    'May', 'June', 'July', 'August', 'September',
    'October', 'November', 'December'
  ][m];

  Future<void> _pickMonthYear() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _currentMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDatePickerMode: DatePickerMode.year,
      helpText: 'SELECT MONTH',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: darkNavy,
              onPrimary: Colors.white,
              onSurface: darkNavy,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: darkNavy),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _currentMonth = DateTime(picked.year, picked.month);
      });
    }
  }

  static const Color darkNavy   = Color(0xFF04193E);
  static const Color badgeColor = Color(0xFFE2B741);
  static const Color cardBorder = Color(0xFFDADADA);
  static const Color redCode    = Color(0xFFC62828);

  @override
  void initState() {
    super.initState();
    _loadDuties();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.offset > 40) {
      final now = DateTime.now();
      if (_currentMonth.year != now.year || _currentMonth.month != now.month) {
        setState(() {
          _currentMonth = DateTime(now.year, now.month);
        });
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadDuties() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _dutiesRepository.getAllDuties();

    if (!mounted) return;

    if (result.success) {
      setState(() {
        _allDutyCards = result.duties;
        _isLoading = false;
        if (result.duties.isNotEmpty) {
          final firstDate = result.duties.first.checkIn;
          _currentMonth = DateTime(firstDate.year, firstDate.month);
        }
      });
    } else {
      setState(() {
        _errorMessage = result.errorMessage;
        _isLoading = false;
      });
    }
  }

  Map<int, String> _computeDutyDaysForCurrentMonth() {
    final Map<int, String> days = {};
    final now = DateTime.now();

    for (final duty in _allDutyCards) {
      for (final date in [duty.checkIn, duty.checkOut]) {
        if (date.year == _currentMonth.year && date.month == _currentMonth.month) {
          final isToday = date.year == now.year &&
              date.month == now.month &&
              date.day == now.day;
          final isPast = date.isBefore(DateTime(now.year, now.month, now.day));
          days[date.day] = isToday ? 'today' : (isPast ? 'past' : 'upcoming');
        }
      }
    }
    return days;
  }

  Map<int, String> _dutyStationForCurrentMonth() {
    final Map<int, String> stations = {};
    for (final duty in _allDutyCards) {
      for (final date in [duty.checkIn, duty.checkOut]) {
        if (date.year == _currentMonth.year && date.month == _currentMonth.month) {
          stations[date.day] = duty.code;
        }
      }
    }
    return stations;
  }

  List<Map<String, String>> _dutiesForTab(String tab) {
    const currentStatuses = ['CHECKED_IN'];
    const upcomingStatuses = [
      'HOTEL_APPROVED',
      'PUBLISHED_TO_CREW',
      'PUBLISHED_TO_HOTEL',
      'DRAFT',
    ];

    final statuses = tab == 'Current' ? currentStatuses : upcomingStatuses;

    return _allDutyCards
        .where((d) => statuses.contains(d.status))
        .map((d) => d.toMap())
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final duties = _dutiesForTab(_selectedStatus);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Stack(
        children: [
          Positioned(
            top: 0, left: 0, right: 0,
            child: Container(
              height: topPad + 205,
              color: const Color(0xFFFAFAFA),
            ),
          ),
          Positioned(
            top: 0, left: 0, right: 0,
            child: Container(
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
                children: [
                  const Icon(Icons.arrow_back_ios,
                      color: Colors.white, size: 18),
                  const SizedBox(width: 4),
                  const Text('Upcoming',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.white)),
                ],
              ),
            ),
          ),
          Column(
            children: [
              SizedBox(height: topPad + 121),
              Container(
                color: const Color(0xFFFAFAFA),
                padding: const EdgeInsets.fromLTRB(22, 16, 22, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('Status:',
                            style: TextStyle(
                                fontSize: 14,
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.14,
                                color: Color(0xFF333333))),
                        const SizedBox(width: 14),
                        _tab('Current'),
                        const SizedBox(width: 20),
                        _tab('Upcoming'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(height: 1, color: const Color(0xFFE5E7EB)),
                  ],
                ),
              ),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _errorMessage != null
                    ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_errorMessage!,
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center),
                        const SizedBox(height: 12),
                        ElevatedButton(
                            onPressed: _loadDuties,
                            child: const Text('Retry')),
                      ],
                    ),
                  ),
                )
                    : SingleChildScrollView(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_selectedStatus == 'Current') ...[
                        _buildCalendar(),
                        const SizedBox(height: 14),
                      ],
                      if (duties.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 40),
                            child: Text(
                              'No ${_selectedStatus.toLowerCase()} duties',
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF6B7280)),
                            ),
                          ),
                        ),
                      ...duties.map((d) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildDutyCard(d),
                      )),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tab(String label) {
    final bool sel = _selectedStatus == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedStatus = label),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: sel ? darkNavy : const Color(0xFF333333))),
          const SizedBox(height: 4),
          Container(
            height: 2,
            width: sel ? 48 : 0,
            decoration: BoxDecoration(
              color: badgeColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: _pickMonthYear,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: cardBorder),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${_monthName(_currentMonth.month)} ${_currentMonth.year}',
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: darkNavy),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.keyboard_arrow_down,
                          size: 16, color: Color(0xFF6B7280)),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: cardBorder),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () => setState(() => _currentMonth = DateTime(
                          _currentMonth.year, _currentMonth.month - 1)),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                        child: Icon(Icons.chevron_left,
                            size: 18, color: Color(0xFF6B7280)),
                      ),
                    ),
                    Container(width: 1, height: 24, color: cardBorder),
                    GestureDetector(
                      onTap: () => setState(() => _currentMonth = DateTime(
                          _currentMonth.year, _currentMonth.month + 1)),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                        child: Icon(Icons.chevron_right,
                            size: 18, color: Color(0xFF6B7280)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT']
                .map((d) => SizedBox(
              width: 38,
              child: Text(d,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF333333))),
            ))
                .toList(),
          ),
          const SizedBox(height: 10),
          _buildGrid(),
        ],
      ),
    );
  }

  Widget _buildGrid() {
    final firstWeekday =
        DateTime(_currentMonth.year, _currentMonth.month, 1).weekday % 7;
    final daysInMonth =
        DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
    final daysInPrev =
        DateTime(_currentMonth.year, _currentMonth.month, 0).day;

    final dutyDays = _computeDutyDaysForCurrentMonth();
    final dutyStations = _dutyStationForCurrentMonth();

    final cells = <Widget>[];
    for (int i = firstWeekday - 1; i >= 0; i--) {
      cells.add(_cell(daysInPrev - i, isOther: true));
    }
    for (int d = 1; d <= daysInMonth; d++) {
      cells.add(_cell(d, dutyType: dutyDays[d], stationCode: dutyStations[d]));
    }
    int n = 1;
    while (cells.length % 7 != 0) {
      cells.add(_cell(n++, isOther: true));
    }

    final rows = <Widget>[];
    for (int i = 0; i < cells.length; i += 7) {
      rows.add(Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: cells.sublist(i, i + 7),
      ));
      rows.add(const SizedBox(height: 4));
    }
    return Column(children: rows);
  }

  Widget _cell(int day, {bool isOther = false, String? dutyType, String? stationCode}) {
    Color bg = Colors.transparent;
    Color numColor = isOther ? const Color(0xFFCCCCCC) : darkNavy;
    Color codeColor = Colors.transparent;
    String? code;

    if (!isOther && dutyType != null) {
      code = stationCode ?? '';
      if (dutyType == 'past') {
        bg = const Color(0xFF4A4E6B);
        numColor = Colors.white;
        codeColor = Colors.white;
      } else if (dutyType == 'today') {
        bg = const Color(0xFFBDD4F4);
        numColor = darkNavy;
        codeColor = darkNavy;
      } else if (dutyType == 'upcoming') {
        bg = const Color(0xFFFEF3C7);
        numColor = const Color(0xFF92400E);
        codeColor = const Color(0xFFD97706);
      }
    }

    return SizedBox(
      width: 38,
      height: 46,
      child: Container(
        margin: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('$day',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: numColor)),
            if (code != null && code.isNotEmpty && !isOther)
              Text(code,
                  style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                      color: codeColor)),
          ],
        ),
      ),
    );
  }

  Widget _buildDutyCard(Map<String, String> d) {
    return ClipPath(
      clipper: TicketClipper(),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 4,
              spreadRadius: 0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Expanded(
                child: Text(d['hotel']!,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.32,
                        color: darkNavy)),
              ),
              const SizedBox(width: 4),
              Text('(${d['code']!})',
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.32,
                      color: redCode)),
            ]),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(d['from']!,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.64,
                        color: darkNavy)),
                const SizedBox(width: 6),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: LayoutBuilder(
                          builder: (ctx, constraints) => CustomPaint(
                            size: Size(constraints.maxWidth, 1),
                            painter: DashedLinePainter(),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Transform.rotate(
                          angle: 1.5708,
                          child: const Icon(Icons.flight,
                              size: 16, color: darkNavy),
                        ),
                      ),
                      Expanded(
                        child: LayoutBuilder(
                          builder: (ctx, constraints) => CustomPaint(
                            size: Size(constraints.maxWidth, 1),
                            painter: DashedLinePainter(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Text(d['to']!,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.64,
                        color: darkNavy)),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(d['fromDate']!,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.28,
                        color: darkNavy)),
                Text(d['toDate']!,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.28,
                        color: darkNavy)),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(d['duration']!,
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Colors.white)),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F7F7),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text('Status: ${d['status']!}',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: darkNavy)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class TicketClipper extends CustomClipper<Path> {
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

class DashedLinePainter extends CustomPainter {
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