import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../../../../core/theme/app_theme.dart';

class AnimatedBackground extends StatefulWidget {
  const AnimatedBackground({super.key});

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late List<Particle> _particles;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
    
    _particles = List.generate(50, (index) => Particle());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.neonPurple.withOpacity(0.1),
            AppTheme.darkGlowingWhite.withOpacity(0.1),
            AppTheme.darkMetallicGray.withOpacity(0.1),
          ],
        ),
      ),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: ParticlesPainter(_particles, _controller.value),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

class Particle {
  late double x;
  late double y;
  late double size;
  late Color color;
  late double speed;
  late double direction;

  Particle() {
    x = math.Random().nextDouble();
    y = math.Random().nextDouble();
    size = math.Random().nextDouble() * 4 + 2;
    speed = math.Random().nextDouble() * 0.5 + 0.1;
    direction = math.Random().nextDouble() * 2 * math.pi;
    
    final colors = [
      AppTheme.neonBlue.withOpacity(0.3),
      AppTheme.darkNeonPurple.withOpacity(0.3),
      AppTheme.neonPurple.withOpacity(0.4),
      AppTheme.darkMetallicGray.withOpacity(0.3),
    ];
    color = colors[math.Random().nextInt(colors.length)];
  }

  void update(double time) {
    x += math.cos(direction) * speed * 0.01;
    y += math.sin(direction) * speed * 0.01;
    
    if (x < 0) x = 1;
    if (x > 1) x = 0;
    if (y < 0) y = 1;
    if (y > 1) y = 0;
  }
}

class ParticlesPainter extends CustomPainter {
  final List<Particle> particles;
  final double time;

  ParticlesPainter(this.particles, this.time);

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      particle.update(time);
      
      final paint = Paint()
        ..color = particle.color
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(
        Offset(
          particle.x * size.width,
          particle.y * size.height,
        ),
        particle.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}