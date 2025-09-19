import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../../../../core/theme/app_theme.dart';

class FuturisticBackground extends StatefulWidget {
  const FuturisticBackground({super.key});

  @override
  State<FuturisticBackground> createState() => _FuturisticBackgroundState();
}

class _FuturisticBackgroundState extends State<FuturisticBackground>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _particleController;
  late List<Particle> _particles;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
    
    _particleController = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    )..repeat();
    
    _particles = List.generate(30, (index) => Particle());
  }

  @override
  void dispose() {
    _controller.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  AppTheme.ultraDarkSpace,
                  AppTheme.darkMetallicGray.withOpacity(0.8),
                  AppTheme.ultraDarkSpace,
                ]
              : [
                  const Color(0xFFF8FAFC),
                  const Color(0xFFE2E8F0),
                  const Color(0xFFF1F5F9),
                ],
        ),
      ),
      child: Stack(
        children: [
          // Animated Gradient Overlay
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment(
                      math.cos(_controller.value * 2 * math.pi) * 0.5,
                      math.sin(_controller.value * 2 * math.pi) * 0.5,
                    ),
                    end: Alignment(
                      -math.cos(_controller.value * 2 * math.pi) * 0.5,
                      -math.sin(_controller.value * 2 * math.pi) * 0.5,
                    ),
                    colors: isDark
                        ? [
                            AppTheme.darkNeonBlue.withOpacity(0.1),
                            AppTheme.darkNeonPurple.withOpacity(0.1),
                            AppTheme.darkNeonPink.withOpacity(0.1),
                            Colors.transparent,
                          ]
                        : [
                            AppTheme.neonBlue.withOpacity(0.05),
                            AppTheme.neonPurple.withOpacity(0.05),
                            AppTheme.neonPink.withOpacity(0.05),
                            Colors.transparent,
                          ],
                  ),
                ),
              );
            },
          ),
          
          // Floating Particles
          AnimatedBuilder(
            animation: _particleController,
            builder: (context, child) {
              return CustomPaint(
                painter: ParticlesPainter(
                  _particles, 
                  _particleController.value,
                  isDark,
                ),
                size: Size.infinite,
              );
            },
          ),
        ],
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
  late double opacity;

  Particle() {
    x = math.Random().nextDouble();
    y = math.Random().nextDouble();
    size = math.Random().nextDouble() * 6 + 2;
    speed = math.Random().nextDouble() * 0.3 + 0.1;
    direction = math.Random().nextDouble() * 2 * math.pi;
    opacity = math.Random().nextDouble() * 0.5 + 0.2;
    
    final colors = [
      AppTheme.neonBlue,
      AppTheme.neonPurple,
      AppTheme.neonPink,
      AppTheme.holographicGreen,
    ];
    color = colors[math.Random().nextInt(colors.length)];
  }

  void update(double time) {
    x += math.cos(direction + time * 2) * speed * 0.01;
    y += math.sin(direction + time * 2) * speed * 0.01;
    
    if (x < 0) x = 1;
    if (x > 1) x = 0;
    if (y < 0) y = 1;
    if (y > 1) y = 0;
  }
}

class ParticlesPainter extends CustomPainter {
  final List<Particle> particles;
  final double time;
  final bool isDark;

  ParticlesPainter(this.particles, this.time, this.isDark);

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      particle.update(time);
      
      final paint = Paint()
        ..color = particle.color.withOpacity(
          particle.opacity * (isDark ? 0.8 : 0.4),
        )
        ..style = PaintingStyle.fill;
      
      // Draw glowing effect
      final glowPaint = Paint()
        ..color = particle.color.withOpacity(
          particle.opacity * 0.2 * (isDark ? 1.0 : 0.5),
        )
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
      
      final center = Offset(
        particle.x * size.width,
        particle.y * size.height,
      );
      
      // Draw glow
      canvas.drawCircle(center, particle.size * 3, glowPaint);
      
      // Draw particle
      canvas.drawCircle(center, particle.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}