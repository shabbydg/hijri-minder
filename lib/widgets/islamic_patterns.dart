import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Collection of reusable mandala and Islamic geometric pattern widgets
/// Uses CustomPainter for optimal performance and customizable Islamic aesthetics

/// Custom painter for drawing intricate mandala patterns
class MandalaPainter extends CustomPainter {
  final Color color;
  final double opacity;
  final int complexity;
  final double size;

  MandalaPainter({
    required this.color,
    this.opacity = 0.1,
    this.complexity = 8,
    this.size = 100.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;

    // Draw concentric circles
    for (int i = 1; i <= complexity; i++) {
      final circleRadius = (radius * i) / complexity;
      canvas.drawCircle(center, circleRadius, paint);
    }

    // Draw radial lines
    for (int i = 0; i < complexity * 2; i++) {
      final angle = (2 * math.pi * i) / (complexity * 2);
      final endPoint = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      canvas.drawLine(center, endPoint, paint);
    }

    // Draw Islamic geometric patterns
    _drawGeometricPatterns(canvas, center, radius, paint);
  }

  void _drawGeometricPatterns(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    
    // Draw eight-pointed star pattern
    for (int i = 0; i < 8; i++) {
      final angle1 = (2 * math.pi * i) / 8;
      final angle2 = (2 * math.pi * (i + 2)) / 8;
      
      final point1 = Offset(
        center.dx + radius * 0.6 * math.cos(angle1),
        center.dy + radius * 0.6 * math.sin(angle1),
      );
      
      final point2 = Offset(
        center.dx + radius * 0.3 * math.cos(angle2),
        center.dy + radius * 0.3 * math.sin(angle2),
      );
      
      path.moveTo(point1.dx, point1.dy);
      path.lineTo(point2.dx, point2.dy);
    }
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant MandalaPainter oldDelegate) {
    return color != oldDelegate.color ||
           opacity != oldDelegate.opacity ||
           complexity != oldDelegate.complexity ||
           size != oldDelegate.size;
  }
}

/// Widget for displaying mandala patterns
class MandalaPattern extends StatelessWidget {
  final double size;
  final Color color;
  final double opacity;
  final int complexity;
  final Widget? child;

  const MandalaPattern({
    super.key,
    this.size = 100.0,
    this.color = const Color(0xFF6B46C1),
    this.opacity = 0.1,
    this.complexity = 8,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: MandalaPainter(
          color: color,
          opacity: opacity,
          complexity: complexity,
          size: size,
        ),
        child: child,
      ),
    );
  }
}

/// Custom painter for Islamic border patterns
class IslamicBorderPainter extends CustomPainter {
  final Color color;
  final double opacity;
  final double strokeWidth;

  IslamicBorderPainter({
    required this.color,
    this.opacity = 0.3,
    this.strokeWidth = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final path = Path();
    
    // Draw Islamic geometric border pattern
    final segments = 16;
    for (int i = 0; i < segments; i++) {
      final t1 = i / segments;
      final t2 = (i + 1) / segments;
      
      final x1 = size.width * t1;
      final y1 = size.height * (0.5 + 0.3 * math.sin(t1 * 4 * math.pi));
      
      final x2 = size.width * t2;
      final y2 = size.height * (0.5 + 0.3 * math.sin(t2 * 4 * math.pi));
      
      if (i == 0) {
        path.moveTo(x1, y1);
      }
      path.lineTo(x2, y2);
    }
    
    canvas.drawPath(path, paint);
    
    // Add corner decorations
    _drawCornerDecorations(canvas, size, paint);
  }

  void _drawCornerDecorations(Canvas canvas, Size size, Paint paint) {
    final cornerSize = math.min(size.width, size.height) * 0.1;
    
    // Top-left corner
    canvas.drawCircle(Offset(cornerSize, cornerSize), cornerSize * 0.3, paint);
    
    // Top-right corner
    canvas.drawCircle(Offset(size.width - cornerSize, cornerSize), cornerSize * 0.3, paint);
    
    // Bottom-left corner
    canvas.drawCircle(Offset(cornerSize, size.height - cornerSize), cornerSize * 0.3, paint);
    
    // Bottom-right corner
    canvas.drawCircle(Offset(size.width - cornerSize, size.height - cornerSize), cornerSize * 0.3, paint);
  }

  @override
  bool shouldRepaint(covariant IslamicBorderPainter oldDelegate) {
    return color != oldDelegate.color ||
           opacity != oldDelegate.opacity ||
           strokeWidth != oldDelegate.strokeWidth;
  }
}

/// Widget for Islamic decorative borders
class IslamicBorder extends StatelessWidget {
  final Widget child;
  final Color color;
  final double opacity;
  final double strokeWidth;
  final EdgeInsets padding;

  const IslamicBorder({
    super.key,
    required this.child,
    this.color = const Color(0xFF6B46C1),
    this.opacity = 0.3,
    this.strokeWidth = 1.0,
    this.padding = const EdgeInsets.all(8.0),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      child: CustomPaint(
        painter: IslamicBorderPainter(
          color: color,
          opacity: opacity,
          strokeWidth: strokeWidth,
        ),
        child: child,
      ),
    );
  }
}

/// Custom painter for geometric background patterns
class GeometricBackgroundPainter extends CustomPainter {
  final Color color;
  final double opacity;
  final double patternSize;

  GeometricBackgroundPainter({
    required this.color,
    this.opacity = 0.05,
    this.patternSize = 50.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(opacity)
      ..style = PaintingStyle.fill;

    // Draw repeating geometric pattern
    for (double x = 0; x < size.width; x += patternSize) {
      for (double y = 0; y < size.height; y += patternSize) {
        _drawGeometricTile(canvas, Offset(x, y), patternSize, paint);
      }
    }
  }

  void _drawGeometricTile(Canvas canvas, Offset offset, double tileSize, Paint paint) {
    final path = Path();
    
    // Draw Islamic geometric tile pattern
    final center = Offset(offset.dx + tileSize / 2, offset.dy + tileSize / 2);
    final radius = tileSize * 0.3;
    
    // Draw eight-pointed star
    for (int i = 0; i < 8; i++) {
      final angle = (2 * math.pi * i) / 8;
      final point = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant GeometricBackgroundPainter oldDelegate) {
    return color != oldDelegate.color ||
           opacity != oldDelegate.opacity ||
           patternSize != oldDelegate.patternSize;
  }
}

/// Widget for geometric background patterns
class GeometricBackground extends StatelessWidget {
  final Widget child;
  final Color color;
  final double opacity;
  final double patternSize;

  const GeometricBackground({
    super.key,
    required this.child,
    this.color = const Color(0xFF6B46C1),
    this.opacity = 0.05,
    this.patternSize = 50.0,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        RepaintBoundary(
          child: Positioned.fill(
            child: CustomPaint(
              painter: GeometricBackgroundPainter(
                color: color,
                opacity: opacity,
                patternSize: patternSize,
              ),
              isComplex: true,
              willChange: false,
            ),
          ),
        ),
        child,
      ],
    );
  }
}

/// Custom painter for decorative corner elements
class DecorativeCornerPainter extends CustomPainter {
  final Color color;
  final double opacity;
  final CornerPosition position;

  DecorativeCornerPainter({
    required this.color,
    this.opacity = 0.2,
    required this.position,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(opacity)
      ..style = PaintingStyle.fill;

    final path = Path();
    final cornerSize = math.min(size.width, size.height) * 0.8;
    
    switch (position) {
      case CornerPosition.topLeft:
        path.moveTo(0, cornerSize);
        path.lineTo(cornerSize, 0);
        path.lineTo(0, 0);
        path.close();
        break;
      case CornerPosition.topRight:
        path.moveTo(size.width - cornerSize, 0);
        path.lineTo(size.width, cornerSize);
        path.lineTo(size.width, 0);
        path.close();
        break;
      case CornerPosition.bottomLeft:
        path.moveTo(0, size.height - cornerSize);
        path.lineTo(0, size.height);
        path.lineTo(cornerSize, size.height);
        path.close();
        break;
      case CornerPosition.bottomRight:
        path.moveTo(size.width - cornerSize, size.height);
        path.lineTo(size.width, size.height);
        path.lineTo(size.width, size.height - cornerSize);
        path.close();
        break;
    }
    
    canvas.drawPath(path, paint);
    
    // Add decorative elements
    _drawDecorativeElements(canvas, size, paint);
  }

  void _drawDecorativeElements(Canvas canvas, Size size, Paint paint) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) * 0.2;
    
    // Draw small circles
    for (int i = 0; i < 3; i++) {
      final angle = (2 * math.pi * i) / 3;
      final circleCenter = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      canvas.drawCircle(circleCenter, radius * 0.3, paint);
    }
  }

  @override
  bool shouldRepaint(covariant DecorativeCornerPainter oldDelegate) {
    return color != oldDelegate.color ||
           opacity != oldDelegate.opacity ||
           position != oldDelegate.position;
  }
}

/// Enum for corner positions
enum CornerPosition { topLeft, topRight, bottomLeft, bottomRight }

/// Widget for decorative corner elements
class DecorativeCorner extends StatelessWidget {
  final Widget child;
  final Color color;
  final double opacity;
  final CornerPosition position;

  const DecorativeCorner({
    super.key,
    required this.child,
    this.color = const Color(0xFF6B46C1),
    this.opacity = 0.2,
    required this.position,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Positioned(
          top: position == CornerPosition.topLeft || position == CornerPosition.topRight ? 0 : null,
          bottom: position == CornerPosition.bottomLeft || position == CornerPosition.bottomRight ? 0 : null,
          left: position == CornerPosition.topLeft || position == CornerPosition.bottomLeft ? 0 : null,
          right: position == CornerPosition.topRight || position == CornerPosition.bottomRight ? 0 : null,
          child: CustomPaint(
            painter: DecorativeCornerPainter(
              color: color,
              opacity: opacity,
              position: position,
            ),
            size: const Size(40, 40),
          ),
        ),
      ],
    );
  }
}

/// Custom painter for star patterns
class StarPatternPainter extends CustomPainter {
  final Color color;
  final double opacity;
  final int points;

  StarPatternPainter({
    required this.color,
    this.opacity = 0.3,
    this.points = 8,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(opacity)
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = math.min(size.width, size.height) / 2;
    final innerRadius = outerRadius * 0.4;

    final path = Path();
    
    for (int i = 0; i < points * 2; i++) {
      final angle = (2 * math.pi * i) / (points * 2);
      final radius = i % 2 == 0 ? outerRadius : innerRadius;
      
      final point = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant StarPatternPainter oldDelegate) {
    return color != oldDelegate.color ||
           opacity != oldDelegate.opacity ||
           points != oldDelegate.points;
  }
}

/// Widget for star patterns
class StarPattern extends StatelessWidget {
  final double size;
  final Color color;
  final double opacity;
  final int points;

  const StarPattern({
    super.key,
    this.size = 30.0,
    this.color = const Color(0xFF6B46C1),
    this.opacity = 0.3,
    this.points = 8,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: StarPatternPainter(
          color: color,
          opacity: opacity,
          points: points,
        ),
      ),
    );
  }
}

/// Custom painter for crescent patterns
class CrescentPatternPainter extends CustomPainter {
  final Color color;
  final double opacity;

  CrescentPatternPainter({
    required this.color,
    this.opacity = 0.3,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(opacity)
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;

    // Draw crescent shape
    final outerPath = Path();
    outerPath.addOval(Rect.fromCircle(center: center, radius: radius));
    
    final innerPath = Path();
    innerPath.addOval(Rect.fromCircle(
      center: Offset(center.dx + radius * 0.3, center.dy),
      radius: radius * 0.7,
    ));
    
    final crescentPath = Path.combine(PathOperation.difference, outerPath, innerPath);
    canvas.drawPath(crescentPath, paint);
  }

  @override
  bool shouldRepaint(covariant CrescentPatternPainter oldDelegate) {
    return color != oldDelegate.color ||
           opacity != oldDelegate.opacity;
  }
}

/// Widget for crescent patterns
class CrescentPattern extends StatelessWidget {
  final double size;
  final Color color;
  final double opacity;

  const CrescentPattern({
    super.key,
    this.size = 30.0,
    this.color = const Color(0xFF6B46C1),
    this.opacity = 0.3,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: CrescentPatternPainter(
          color: color,
          opacity: opacity,
        ),
      ),
    );
  }
}

/// Animated mandala pattern with subtle rotation
class AnimatedMandalaPattern extends StatefulWidget {
  final double size;
  final Color color;
  final double opacity;
  final int complexity;
  final Duration duration;
  final Widget? child;

  const AnimatedMandalaPattern({
    super.key,
    this.size = 100.0,
    this.color = const Color(0xFF6B46C1),
    this.opacity = 0.1,
    this.complexity = 8,
    this.duration = const Duration(seconds: 20),
    this.child,
  });

  @override
  State<AnimatedMandalaPattern> createState() => _AnimatedMandalaPatternState();
}

class _AnimatedMandalaPatternState extends State<AnimatedMandalaPattern>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    ));
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.rotate(
          angle: _animation.value,
          child: MandalaPattern(
            size: widget.size,
            color: widget.color,
            opacity: widget.opacity,
            complexity: widget.complexity,
            child: widget.child,
          ),
        );
      },
    );
  }
}
