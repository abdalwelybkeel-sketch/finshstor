import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

import '../../../../core/models/user_model.dart';
import '../../../../core/theme/app_theme.dart';


class ProfileHeader extends StatefulWidget {
  final UserModel user;

  const ProfileHeader({
    super.key,
    required this.user,
  });

  @override
  State<ProfileHeader> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends State<ProfileHeader> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _particleController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _particleController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.neonBlue.withOpacity(0.2),
            AppTheme.neonPurple.withOpacity(0.2),
          ],
        ),
      ),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: AppTheme.glassMorphismContainer(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Profile Image
                AnimatedBuilder(
                  animation: _particleController,
                  builder: (context, child) {
                    return Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: AppTheme.neonPurple,
                          backgroundImage: widget.user.profileImage != null
                              ? NetworkImage(widget.user.profileImage!)
                              : null,
                          child: widget.user.profileImage == null
                              ? Icon(
                            Icons.person,
                            size: 50,
                            color: AppTheme.neonBlue,
                          )
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [AppTheme.neonBlue, AppTheme.darkNeonBlue],
                              ),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.neonBlue.withOpacity(0.3 + 0.2 * math.sin(_particleController.value * 2 * math.pi)),
                                  blurRadius: 20,
                                  spreadRadius: 0,
                                ),
                              ],
                            ),
                            child: IconButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/edit-profile');
                              },
                              icon: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 20,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 36,
                                minHeight: 36,
                              ),
                              padding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 16),

                // User Name
                Text(
                  widget.user.fullName,
                  style: GoogleFonts.orbitron(
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                    color: isDark ? AppTheme.darkGlowingWhite : AppTheme.metallicGray,
                    shadows: [
                      Shadow(
                        color: AppTheme.neonBlue.withOpacity(0.5),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 4),

                // User Email
                Text(
                  widget.user.email,
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    color: isDark ? AppTheme.darkGlowingWhite.withOpacity(0.7) : AppTheme.metallicGray,
                  ),
                ),

                const SizedBox(height: 8),

                // User Type Badge
                AnimatedBuilder(
                  animation: _particleController,
                  builder: (context, child) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: widget.user.isVendor
                              ? [AppTheme.darkNeonPurple, AppTheme.neonPurple]
                              : [AppTheme.neonBlue, AppTheme.darkNeonBlue],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: (widget.user.isVendor ? AppTheme.darkNeonPurple : AppTheme.neonBlue)
                                .withOpacity(0.3 + 0.2 * math.sin(_particleController.value * 2 * math.pi)),
                            blurRadius: 10,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: Text(
                        widget.user.isVendor ? 'بائع' : 'مستخدم',
                        style: GoogleFonts.cairo(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}