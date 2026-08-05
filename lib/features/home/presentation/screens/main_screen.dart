import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'home_screen.dart';
import '../../../upcoming/presentation/screens/upcoming_screen.dart';
import '../../../completed/presentation/screens/completed_screen.dart';
import '../../../settings/presentation/screens/settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const UpcomingScreen(),
    const CompletedScreen(),
    const SettingsScreen(),
  ];

  final List<String> _labels = ['Home', 'Upcoming', 'Completed', 'Settings'];
  final List<IconData> _activeIcons = [
    Icons.home_rounded,
    Icons.calendar_today_rounded,
    Icons.assignment_rounded,
    Icons.settings_rounded,
  ];
  final List<IconData> _inactiveIcons = [
    Icons.home_outlined,
    Icons.calendar_today_outlined,
    Icons.assignment_outlined,
    Icons.settings_outlined,
  ];

  static const Color darkNavy     = Color(0xFF072D62);
  static const Color inactiveGrey = Color(0xFF3D3D3D); // darker

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Color(0xFF072D62),
      statusBarIconBrightness: Brightness.light,
    ));
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F8),
      body: _screens[_currentIndex],
      bottomNavigationBar: _buildNavBar(context),
    );
  }

  Widget _buildNavBar(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    const barHeight = 78.0;
    const totalHeight = barHeight + 12;
    final itemWidth = w / 4;

    return SizedBox(
      height: totalHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: 20,
            left: 0,
            right: 0,
            bottom: 0,
            child: CustomPaint(
              size: Size(w, barHeight),
              painter: _NavBarPainter(
                activeIndex: _currentIndex,
                itemWidth: itemWidth,
              ),
            ),
          ),
          Row(
            children: List.generate(4, (i) {
              final bool isActive = _currentIndex == i;
              return SizedBox(
                width: itemWidth,
                height: totalHeight,
                child: GestureDetector(
                  onTap: () => setState(() => _currentIndex = i),
                  behavior: HitTestBehavior.opaque,
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.bottomCenter,
                    children: [
                      // Label
                      Positioned(
                        bottom: 18,
                        child: Text(
                          _labels[i],
                          style: TextStyle(
                            
                            fontSize: 12,
                            fontWeight: isActive
                                ? FontWeight.w800
                                : FontWeight.w700,
                            color: isActive ? darkNavy : inactiveGrey,
                          ),
                        ),
                      ),
                      // Icon
                      Positioned(
                        top: isActive ? -4 : 28,
                        child: isActive
                            ? Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Icon(_activeIcons[i],
                              color: darkNavy, size: 20),
                        )
                            : Icon(_inactiveIcons[i],
                            color: inactiveGrey, size: 20),
                      ),
                    ],
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

class _NavBarPainter extends CustomPainter {
  final int activeIndex;
  final double itemWidth;

  _NavBarPainter({required this.activeIndex, required this.itemWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    const cornerR = 30.0;

    final cx = itemWidth * activeIndex + itemWidth / 2;

    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    final fillPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, cornerR);
    path.quadraticBezierTo(0, 0, cornerR, 0);
    path.lineTo(cx - 49.566, 0);

    path.cubicTo(
      cx - 42.1494, 0.16908,
      cx - 34.3024, 9.5375,
      cx - 31.9737, 13.7952,
    );
    path.cubicTo(
      cx - 25.6946, 25.2771,
      cx - 14.0816, 33.6003,
      cx, 33.5465,
    );
    path.cubicTo(
      cx + 14.0861, 33.6003,
      cx + 25.6991, 25.2771,
      cx + 31.9785, 13.7952,
    );
    path.cubicTo(
      cx + 35.7365, 6.9168,
      cx + 40.3405, 0,
      cx + 60.1455, 0,
    );

    path.lineTo(w - cornerR, 0);
    path.quadraticBezierTo(w, 0, w, cornerR);
    path.lineTo(w, h);
    path.lineTo(0, h);
    path.close();

    canvas.save();
    canvas.translate(0, -1);
    canvas.drawPath(path, shadowPaint);
    canvas.restore();
    canvas.drawPath(path, fillPaint);
  }

  @override
  bool shouldRepaint(covariant _NavBarPainter oldDelegate) =>
      oldDelegate.activeIndex != activeIndex;
}