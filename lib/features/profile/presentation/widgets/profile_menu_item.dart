import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

import '../../../../core/theme/app_theme.dart';

class ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final Color? textColor;

  const ProfileMenuItem({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: Listenable.merge([
        AnimationController(
          duration: const Duration(seconds: 10),
          vsync: Navigator.of(context),
        )..repeat(),
      ]),
      builder: (context, child) {
        final particleController = AnimationController(
          duration: const Duration(seconds: 10),
          vsync: Navigator.of(context),
        );
        return GestureDetector(
          onTap: onTap,
          child: AppTheme.glassMorphismContainer(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [(textColor ?? AppTheme.neonBlue), (textColor ?? AppTheme.neonBlue).withOpacity(0.7)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: (textColor ?? AppTheme.neonBlue).withOpacity(0.3 + 0.2 * math.sin(particleController.value * 2 * math.pi)),
                      blurRadius: 10,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              title: Text(
                title,
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.w600,
                  color: textColor ?? (isDark ? AppTheme.darkGlowingWhite : AppTheme.metallicGray),
                ),
              ),
              subtitle: subtitle != null
                  ? Text(
                subtitle!,
                style: GoogleFonts.cairo(
                  color: isDark ? AppTheme.darkGlowingWhite.withOpacity(0.6) : AppTheme.metallicGray,
                ),
              )
                  : null,
              trailing: Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: textColor ?? AppTheme.neonBlue,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        );
      },
    );
  }
}