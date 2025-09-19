import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../providers/addresses_provider.dart';

class AddressCard extends StatelessWidget {
  final AddressModel address;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onSetDefault;

  const AddressCard({
    super.key,
    required this.address,
    required this.onEdit,
    required this.onDelete,
    required this.onSetDefault,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AppTheme.glassMorphismContainer(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  address.name,
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isDark ? AppTheme.darkGlowingWhite : AppTheme.metallicGray,
                  ),
                ),
              ),
              if (address.isDefault)
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

          const SizedBox(height: 8),

          // Address
          Text(
            address.address,
            style: GoogleFonts.cairo(
              color: isDark ? AppTheme.darkGlowingWhite.withOpacity(0.6) : AppTheme.metallicGray,
            ),
          ),

          const SizedBox(height: 4),

          // City
          Text(
            address.city,
            style: GoogleFonts.cairo(
              color: isDark ? AppTheme.darkGlowingWhite.withOpacity(0.6) : AppTheme.metallicGray,
            ),
          ),

          const SizedBox(height: 4),

          // Phone
          Row(
            children: [
              Icon(
                Icons.phone,
                size: 16,
                color: AppTheme.neonBlue,
              ),
              const SizedBox(width: 4),
              Text(
                address.phone,
                style: GoogleFonts.cairo(
                  color: isDark ? AppTheme.darkGlowingWhite.withOpacity(0.6) : AppTheme.metallicGray,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Actions
          Row(
            children: [
              if (!address.isDefault)
                Expanded(
                  child: AppTheme.neonButton(
                    text: 'تعيين كافتراضي',
                    onPressed: onSetDefault,
                    color: AppTheme.neonBlue,
                    textStyle: GoogleFonts.cairo(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              if (!address.isDefault) const SizedBox(width: 8),
              Expanded(
                child: AppTheme.neonButton(
                  text: 'تعديل',
                  onPressed: onEdit,
                  color: AppTheme.neonBlue,
                  textStyle: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline, color: AppTheme.neonPink),
              ),
            ],
          ),
        ],
      ),
    );
  }
}