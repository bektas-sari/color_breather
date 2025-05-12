import 'package:flutter/material.dart';
import 'dart:async';

void main() {
  runApp(ColorBreatherApp());
}

class ColorBreatherApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Color Breather',
      debugShowCheckedModeBanner: false,
      home: BreathingScreen(),
    );
  }
}

class BreathingScreen extends StatefulWidget {
  @override
  _BreathingScreenState createState() => _BreathingScreenState();
}

class _BreathingScreenState extends State<BreathingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  final List<Color> _colorCycle = [
    Colors.blue,
    Colors.green,
    Colors.purple,
    Colors.pink,
    Colors.orange,
  ];

  int _colorIndex = 0;
  Color _backgroundColor = Colors.blue;
  String _currentPhase = "Ready?";

  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    _setupAnimation();
    _startBreathingCycle();
  }

  void _setupAnimation() {
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 8),
    );
    _scaleAnimation = Tween<double>(begin: 0.7, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  Future<void> _startBreathingCycle() async {
    if (_isRunning) return;
    _isRunning = true;

    while (mounted) {
      // Breathe In - 4 sn
      setState(() {
        _currentPhase = "Breathe In";
        _colorIndex = (_colorIndex + 1) % _colorCycle.length;
        _backgroundColor = _colorCycle[_colorIndex];
      });
      _controller.duration = Duration(seconds: 4);
      _controller.forward(from: 0);
      await Future.delayed(Duration(seconds: 4));

      // Hold - 4 sn
      setState(() {
        _currentPhase = "Hold";
      });
      await Future.delayed(Duration(seconds: 4));

      // Breathe Out - 8 sn
      setState(() {
        _currentPhase = "Breathe Out";
        _colorIndex = (_colorIndex + 1) % _colorCycle.length;
        _backgroundColor = _colorCycle[_colorIndex];
      });
      _controller.duration = Duration(seconds: 8);
      _controller.reverse(from: 1.0);
      await Future.delayed(Duration(seconds: 8));
    }
  }

  void _restart() {
    setState(() {
      _currentPhase = "Restarting...";
      _backgroundColor = Colors.blue;
    });
    _isRunning = false;
    _controller.reset();
    Future.delayed(Duration(milliseconds: 500), _startBreathingCycle);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TweenAnimationBuilder(
        tween: ColorTween(begin: _backgroundColor, end: _backgroundColor),
        duration: Duration(seconds: 2),
        builder: (context, Color? color, child) {
          return Container(
            color: color,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          _currentPhase,
                          style: TextStyle(
                            fontSize: 22,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 80),
                  ElevatedButton(
                    onPressed: _restart,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.4),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Padding(
                      padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      child: Text("Start Again"),
                    ),
                  ),
                ],
              ),
            ),

          );
        },
      ),
    );
  }
}
