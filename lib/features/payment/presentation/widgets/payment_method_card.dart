import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';

class PaymentMethodCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isDefault;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const PaymentMethodCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.isDefault = false,
    required this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AppTheme.glassMorphismContainer(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.neonBlue, AppTheme.darkNeonBlue],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppTheme.darkGlowingWhite : AppTheme.metallicGray,
                ),
              ),
            ),
            if (isDefault)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.neonBlue, AppTheme.darkNeonBlue],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'افتراضي',
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.cairo(
            color: isDark ? AppTheme.darkGlowingWhite.withOpacity(0.6) : AppTheme.metallicGray,
          ),
        ),
        trailing: onDelete != null
            ? IconButton(
          onPressed: onDelete,
          icon: const Icon(Icons.delete_outline, color: AppTheme.neonPink),
        )
            : Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: AppTheme.neonBlue,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}