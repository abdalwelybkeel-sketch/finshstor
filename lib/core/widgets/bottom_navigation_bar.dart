import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

import '../theme/app_theme.dart';
import '../providers/navigation_provider.dart';

class CustomBottomNavigationBar extends StatefulWidget {
  const CustomBottomNavigationBar({super.key});

  @override
  State<CustomBottomNavigationBar> createState() => _CustomBottomNavigationBarState();
}

class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _glowController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

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
    _animationController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Consumer<NavigationProvider>(
      builder: (context, navigationProvider, child) {
        return Container(
          height: 90,
          margin: const EdgeInsets.all(16),
          child: Stack(
            children: [
              // Glassmorphism Background
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [
                            const Color(0x40FFFFFF),
                            const Color(0x20FFFFFF),
                            const Color(0x10FFFFFF),
                          ]
                        : [
                            const Color(0x60FFFFFF),
                            const Color(0x40FFFFFF),
                            const Color(0x20FFFFFF),
                          ],
                  ),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isDark 
                          ? AppTheme.darkNeonBlue.withOpacity(0.2)
                          : AppTheme.neonBlue.withOpacity(0.2),
                      blurRadius: 30,
                      spreadRadius: 0,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: isDark
                            ? [
                                AppTheme.darkMetallicGray.withOpacity(0.8),
                                AppTheme.ultraDarkSpace.withOpacity(0.9),
                              ]
                            : [
                                Colors.white.withOpacity(0.8),
                                Colors.white.withOpacity(0.6),
                              ],
                      ),
                    ),
                  ),
                ),
              ),

              // Navigation Items
              Positioned.fill(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildNavItem(
                      context,
                      icon: Icons.home_rounded,
                      label: 'الرئيسية',
                      index: 0,
                      isActive: navigationProvider.currentIndex == 0,
                      onTap: () => navigationProvider.setIndex(0),
                      isDark: isDark,
                    ),
                    _buildNavItem(
                      context,
                      icon: Icons.shopping_cart_rounded,
                      label: 'السلة',
                      index: 1,
                      isActive: navigationProvider.currentIndex == 1,
                      onTap: () => navigationProvider.setIndex(1),
                      badge: navigationProvider.cartItemCount > 0 
                          ? navigationProvider.cartItemCount.toString() 
                          : null,
                      isDark: isDark,
                    ),
                    _buildNavItem(
                      context,
                      icon: Icons.search_rounded,
                      label: 'البحث',
                      index: 2,
                      isActive: navigationProvider.currentIndex == 2,
                      onTap: () => navigationProvider.setIndex(2),
                      isDark: isDark,
                    ),
                    _buildNavItem(
                      context,
                      icon: Icons.person_rounded,
                      label: 'الملف الشخصي',
                      index: 3,
                      isActive: navigationProvider.currentIndex == 3,
                      onTap: () => navigationProvider.setIndex(3),
                      isDark: isDark,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required int index,
    required bool isActive,
    required VoidCallback onTap,
    required bool isDark,
    String? badge,
  }) {
    return GestureDetector(
      onTap: () {
        onTap();
        if (isActive) {
          _animationController.forward().then((_) {
            _animationController.reverse();
          });
        }
      },
      child: AnimatedBuilder(
        animation: _glowAnimation,
        builder: (context, child) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  children: [
                    // Glow Effect for Active Item
                    if (isActive)
                      AnimatedBuilder(
                        animation: _scaleAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _scaleAnimation.value,
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    (isDark ? AppTheme.darkNeonBlue : AppTheme.neonBlue)
                                        .withOpacity(0.3 * _glowAnimation.value),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),

                    // Icon Container
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: isActive
                            ? LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: isDark
                                    ? [
                                        AppTheme.darkNeonBlue,
                                        AppTheme.darkNeonPurple,
                                      ]
                                    : [
                                        AppTheme.neonBlue,
                                        AppTheme.neonPurple,
                                      ],
                              )
                            : null,
                        border: isActive
                            ? null
                            : Border.all(
                                color: Colors.white.withOpacity(0.1),
                                width: 1,
                              ),
                        boxShadow: isActive
                            ? [
                                BoxShadow(
                                  color: (isDark ? AppTheme.darkNeonBlue : AppTheme.neonBlue)
                                      .withOpacity(0.5),
                                  blurRadius: 20,
                                  spreadRadius: 0,
                                  offset: const Offset(0, 8),
                                ),
                              ]
                            : null,
                      ),
                      child: Icon(
                        icon,
                        color: isActive 
                            ? Colors.white
                            : (isDark 
                                ? AppTheme.darkGlowingWhite.withOpacity(0.6)
                                : AppTheme.metallicGray.withOpacity(0.6)),
                        size: isActive ? 26 : 24,
                      ),
                    ),

                    // Badge
                    if (badge != null)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppTheme.neonPink, Color(0xFFFF4757)],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.neonPink.withOpacity(0.5),
                                blurRadius: 10,
                                spreadRadius: 0,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 20,
                            minHeight: 20,
                          ),
                          child: Text(
                            badge,
                            style: GoogleFonts.orbitron(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 6),

                // Label
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 300),
                  style: GoogleFonts.cairo(
                    fontSize: isActive ? 12 : 10,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                    color: isActive 
                        ? (isDark ? AppTheme.darkNeonBlue : AppTheme.neonBlue)
                        : (isDark 
                            ? AppTheme.darkGlowingWhite.withOpacity(0.6)
                            : AppTheme.metallicGray.withOpacity(0.6)),
                    letterSpacing: 0.5,
                  ),
                  child: Text(label),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}