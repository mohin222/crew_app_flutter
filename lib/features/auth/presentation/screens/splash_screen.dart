import 'dart:math';
import 'package:flutter/material.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  static const double _trackWidth = 184;
  static const double _trackHeight = 52;
  static const double _thumbSize = 40;
  static const double _horizontalPadding = 6;

  late final double _maxDrag =
      _trackWidth - _thumbSize - (_horizontalPadding * 2);

  double _dragX = 0;
  bool _navigated = false;
  bool _isAutoSliding = false;

  late final AnimationController _controller;
  Animation<double>? _snapAnimation;

  // Cloud puffs spawned behind the thumb while it moves (drag or auto-slide).
  final List<_CloudPuff> _clouds = [];
  final Random _rng = Random();
  double _lastSpawnX = -999;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    )..addListener(() {
      if (_snapAnimation != null) {
        setState(() => _dragX = _snapAnimation!.value);
        _maybeSpawnCloud();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (_isAutoSliding) return;
    setState(() {
      _dragX = (_dragX + details.delta.dx).clamp(0.0, _maxDrag);
    });
    _maybeSpawnCloud();
  }

  void _onDragEnd(DragEndDetails details) {
    if (_isAutoSliding) return;
    final reachedEnd = _dragX >= _maxDrag * 0.85;

    if (reachedEnd) {
      _snapTo(_maxDrag, thenNavigate: true);
    } else {
      _snapTo(0, thenNavigate: false);
    }
  }

  // Tap on the thumb: auto-slide smoothly from current position to the end,
  // spawning clouds along the way, then navigate.
  void _onThumbTap() {
    if (_isAutoSliding) return;
    _isAutoSliding = true;
    _snapTo(_maxDrag, thenNavigate: true, autoDuration: true);
  }

  void _snapTo(double target,
      {required bool thenNavigate, bool autoDuration = false}) {
    _controller.duration = Duration(
      milliseconds: autoDuration ? 650 : 220,
    );
    _snapAnimation = Tween<double>(begin: _dragX, end: target).animate(
      CurvedAnimation(
        parent: _controller,
        curve: autoDuration ? Curves.easeInOut : Curves.easeOut,
      ),
    );
    _controller.forward(from: 0).whenComplete(() {
      _isAutoSliding = false;
      if (thenNavigate) _goToLogin();
    });
  }

  void _maybeSpawnCloud() {
    // Spawn a new puff roughly every 10px of travel.
    if ((_dragX - _lastSpawnX).abs() < 10) return;
    _lastSpawnX = _dragX;
    final puff = _CloudPuff(
      x: _dragX + _thumbSize / 2,
      y: _trackHeight / 2 + (_rng.nextDouble() - 0.5) * 14,
      size: 10 + _rng.nextDouble() * 8,
    );
    setState(() => _clouds.add(puff));

    // Fade out & remove after a short life.
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() => _clouds.remove(puff));
      }
    });
  }

  void _goToLogin() {
    if (_navigated) return;
    _navigated = true;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Thumb fades/scales slightly as it nears the end, matching common
    // slide-to-unlock feedback. Purely cosmetic ? safe to remove.
    final dragProgress = _maxDrag == 0 ? 0.0 : (_dragX / _maxDrag);

    return Scaffold(
      backgroundColor: const Color(0xFF072D62),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/splash_bg.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              color: const Color(0xFF114995).withOpacity(0.3),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 81,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'CREW\nSCHEDULE',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 12),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Stay Updated with your upcoming and past activities, and easily view accommodations all in one place',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                // --- Slide-to-start control ---
                Container(
                  width: _trackWidth,
                  height: _trackHeight,
                  padding:
                  const EdgeInsets.symmetric(horizontal: _horizontalPadding),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(26),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Stack(
                      alignment: Alignment.centerLeft,
                      clipBehavior: Clip.none,
                      children: [
                        // Label fades out as the thumb covers it
                        Positioned.fill(
                          child: Center(
                            child: Opacity(
                              opacity:
                              (1 - dragProgress * 1.6).clamp(0.0, 1.0),
                              child: const Padding(
                                padding: EdgeInsets.only(left: 24),
                                child: Text(
                                  'Get Started',
                                  style: TextStyle(
                                    
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF04193E),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Cloud puffs trailing behind the thumb
                        ..._clouds.map((c) => Positioned(
                          left: c.x - c.size / 2,
                          top: c.y - c.size / 2,
                          child: IgnorePointer(
                            child: Icon(
                              Icons.cloud,
                              size: c.size,
                              color: const Color(0xFF114995)
                                  .withOpacity(0.35),
                            ),
                          ),
                        )),

                        // Draggable / tappable thumb
                        Positioned(
                          left: _dragX,
                          child: GestureDetector(
                            onHorizontalDragUpdate: _onDragUpdate,
                            onHorizontalDragEnd: _onDragEnd,
                            onTap: _onThumbTap,
                            child: Container(
                              width: _thumbSize,
                              height: _thumbSize,
                              decoration: const BoxDecoration(
                                color: Color(0xFF114995),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                // TODO: replace with the exact plane asset
                                // exported from Figma dev mode, e.g.:
                                // Image.asset('assets/icons/plane_icon.png',
                                //     width: 18, height: 18),
                                child: Transform.rotate(
                                  angle: 1.59, // rotates icon to point rightward
                                  child: const Icon(
                                    Icons.flight_rounded,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ),
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
            bottom: 18,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 139,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFFDADADA),
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CloudPuff {
  final double x;
  final double y;
  final double size;
  _CloudPuff({required this.x, required this.y, required this.size});
}