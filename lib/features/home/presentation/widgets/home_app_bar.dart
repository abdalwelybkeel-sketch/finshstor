import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

import '../../../../core/config/app_config.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class HomeAppBar extends StatefulWidget {
  const HomeAppBar({super.key});

  @override
  State<HomeAppBar> createState() => _HomeAppBarState();
}

class _HomeAppBarState extends State<HomeAppBar>
    with TickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      child: AppTheme.glassMorphismContainer(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // Futuristic Logo
            AnimatedBuilder(
              animation: _glowAnimation,
              builder: (context, child) {
                return Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDark
                          ? [AppTheme.darkNeonBlue, AppTheme.darkNeonPurple]
                          : [AppTheme.neonBlue, AppTheme.neonPurple],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (isDark ? AppTheme.darkNeonBlue : AppTheme.neonBlue)
                            .withOpacity(0.5 * _glowAnimation.value),
                        blurRadius: 20,
                        spreadRadius: 0,
                        offset: const Offset(0, 8),
                      ),
                      BoxShadow(
                        color: (isDark ? AppTheme.darkNeonPurple : AppTheme.neonPurple)
                            .withOpacity(0.3 * _glowAnimation.value),
                        blurRadius: 40,
                        spreadRadius: 0,
                        offset: const Offset(0, 16),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.local_florist_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                );
              },
            ),
            
            const SizedBox(width: 16),
            
            // Welcome Text
            Expanded(
              child: Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'مرحباً بك في المستقبل',
                        style: GoogleFonts.cairo(
                          fontSize: 14,
                          color: (isDark 
                              ? AppTheme.darkGlowingWhite 
                              : AppTheme.metallicGray).withOpacity(0.8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        authProvider.currentUser?.fullName ?? 'مستكشف الورود',
                        style: GoogleFonts.orbitron(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark 
                              ? AppTheme.darkGlowingWhite 
                              : AppTheme.metallicGray,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            
            // Holographic Notifications
            AnimatedBuilder(
              animation: _glowAnimation,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        (isDark ? AppTheme.darkNeonPink : AppTheme.neonPink)
                            .withOpacity(0.2 * _glowAnimation.value),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: IconButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/notifications');
                    },
                    icon: Stack(
                      children: [
                        Icon(
                          Icons.notifications_rounded,
                          color: isDark 
                              ? AppTheme.darkGlowingWhite 
                              : AppTheme.metallicGray,
                          size: 28,
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: isDark
                                    ? [AppTheme.darkNeonPink, Color(0xFFFF4757)]
                                    : [AppTheme.neonPink, Color(0xFFFF4757)],
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: (isDark ? AppTheme.darkNeonPink : AppTheme.neonPink)
                                      .withOpacity(0.8),
                                  blurRadius: 8,
                                  spreadRadius: 0,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            
            const SizedBox(width: 8),
            
            // Futuristic Profile Avatar
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, AppConfig.profileRoute);
              },
              child: Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  return AnimatedBuilder(
                    animation: _glowAnimation,
                    builder: (context, child) {
                      return Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: isDark
                                ? [
                                    AppTheme.darkNeonBlue.withOpacity(0.3),
                                    AppTheme.darkNeonPurple.withOpacity(0.3),
                                  ]
                                : [
                                    AppTheme.neonBlue.withOpacity(0.3),
                                    AppTheme.neonPurple.withOpacity(0.3),
                                  ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: (isDark ? AppTheme.darkNeonBlue : AppTheme.neonBlue)
                                  .withOpacity(0.3 * _glowAnimation.value),
                              blurRadius: 15,
                              spreadRadius: 0,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(3),
                        child: CircleAvatar(
                          radius: 22,
                          backgroundColor: isDark 
                              ? AppTheme.darkMetallicGray 
                              : AppTheme.glowingWhite,
                          backgroundImage: authProvider.currentUser?.profileImage != null
                              ? NetworkImage(authProvider.currentUser!.profileImage!)
                              : null,
                          child: authProvider.currentUser?.profileImage == null
                              ? Icon(
                                  Icons.person_rounded,
                                  color: isDark 
                                      ? AppTheme.darkNeonBlue 
                                      : AppTheme.neonBlue,
                                  size: 24,
                                )
                              : null,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}