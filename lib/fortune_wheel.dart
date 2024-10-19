import 'dart:math';
import 'package:flutter/material.dart';

enum SpinResult { win, lose, draw }

class FortuneWheel extends StatefulWidget {
  final SpinResult desiredResult;

  const FortuneWheel({Key? key, required this.desiredResult}) : super(key: key);

  @override
  _FortuneWheelState createState() => _FortuneWheelState();
}

class _FortuneWheelState extends State<FortuneWheel> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    print("initState spinner");
    print('desiredResult: ${widget.desiredResult}');
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAnimation();
    });
  }

@override
void didUpdateWidget(FortuneWheel oldWidget) {
  print("didUpdateWidget spinner");
  super.didUpdateWidget(oldWidget);
  if (oldWidget.desiredResult != widget.desiredResult) {
    // Reset and restart the animation when desiredResult changes
    _controller.reset();
    _startAnimation();
  }
}

  void _startAnimation() {
    
    //final Random random = Random();
    final double targetAngle = _getTargetAngle();
    const double randomOffset = (2 * pi)/4;
    final double totalRotation = (5 * 2 * pi) + targetAngle + randomOffset;

    _animation = Tween<double>(
      begin: 0,
      end: totalRotation,
    ).animate(_controller);

    _controller.forward();
  }

  double _getTargetAngle() {
    switch (widget.desiredResult) {
      case SpinResult.win:
      print('win');
        return 0;
      case SpinResult.lose:
      print('lose');
        return 2 * pi / 3;
      case SpinResult.draw:
      print('draw');
        return 4 * pi / 3;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.arrow_downward, size: 50, color: Colors.white),
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Transform.rotate(
                angle: _animation.value,
                child: CustomPaint(
                  size: const Size(300, 300),
                  painter: WheelPainter(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class WheelPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..style = PaintingStyle.fill;
    final double radius = size.width / 2;
    final Offset center = Offset(radius, radius);

    paint.color = Colors.red;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius),
        0, 2 * pi / 3, true, paint);

    paint.color = Colors.green;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius),
        2 * pi / 3, 2 * pi / 3, true, paint);

    paint.color = Colors.yellow;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius),
        4 * pi / 3, 2 * pi / 3, true, paint);

    // Draw section labels
    final TextPainter textPainter = TextPainter(textDirection: TextDirection.ltr);
    final TextStyle textStyle = TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold);

    void drawText(String text, double angle) {
      textPainter.text = TextSpan(text: text, style: textStyle);
      textPainter.layout();
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(angle);
      textPainter.paint(canvas, Offset(-textPainter.width / 2, -radius * 0.75));
      canvas.restore();
    }

    drawText('Neutral', 0);
    drawText('Failure', pi);
    drawText('Success', 5 * pi / 3);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}