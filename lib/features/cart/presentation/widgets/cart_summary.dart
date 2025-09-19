import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

import '../../../../core/theme/app_theme.dart';

class CartSummary extends StatefulWidget {
  final double subtotal;
  final double tax;
  final double shipping;
  final double total;
  final VoidCallback onCheckout;

  const CartSummary({
    super.key,
    required this.subtotal,
    required this.tax,
    required this.shipping,
    required this.total,
    required this.onCheckout,
  });

  @override
  State<CartSummary> createState() => _CartSummaryState();
}

class _CartSummaryState extends State<CartSummary>
    with TickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(
      begin: 0.5,
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

    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(32),
            ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(isDark ? 0.15 : 0.9),
                Colors.white.withOpacity(isDark ? 0.05 : 0.7),
              ],
            ),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: (isDark ? AppTheme.darkNeonBlue : AppTheme.neonBlue)
                    .withOpacity(0.2 * _glowAnimation.value),
                blurRadius: 30,
                spreadRadius: 0,
                offset: const Offset(0, -10),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.5 : 0.1),
                blurRadius: 20,
                spreadRadius: 0,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(32),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: isDark
                      ? [
                          AppTheme.darkMetallicGray.withOpacity(0.9),
                          AppTheme.ultraDarkSpace.withOpacity(0.95),
                        ]
                      : [
                          Colors.white.withOpacity(0.95),
                          Colors.white.withOpacity(0.8),
                        ],
                ),
              ),
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle
                  Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? [AppTheme.darkNeonBlue, AppTheme.darkNeonPurple]
                            : [AppTheme.neonBlue, AppTheme.neonPurple],
                      ),
                      borderRadius: BorderRadius.circular(3),
                      boxShadow: [
                        BoxShadow(
                          color: (isDark ? AppTheme.darkNeonBlue : AppTheme.neonBlue)
                              .withOpacity(0.5),
                          blurRadius: 10,
                          spreadRadius: 0,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Summary Details
                  _buildSummaryRow('المجموع الفرعي', widget.subtotal, theme, isDark),
                  const SizedBox(height: 12),
                  _buildSummaryRow('الضريبة (15%)', widget.tax, theme, isDark),
                  const SizedBox(height: 12),
                  _buildSummaryRow(
                    widget.shipping == 0 ? 'الشحن (مجاني)' : 'الشحن', 
                    widget.shipping, 
                    theme,
                    isDark,
                    isShipping: true,
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Divider
                  Container(
                    height: 2,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? [
                                AppTheme.darkNeonBlue.withOpacity(0.3),
                                AppTheme.darkNeonPurple.withOpacity(0.3),
                                AppTheme.darkNeonPink.withOpacity(0.3),
                              ]
                            : [
                                AppTheme.neonBlue.withOpacity(0.3),
                                AppTheme.neonPurple.withOpacity(0.3),
                                AppTheme.neonPink.withOpacity(0.3),
                              ],
                      ),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Total
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'الإجمالي',
                        style: GoogleFonts.orbitron(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDark 
                              ? AppTheme.darkGlowingWhite 
                              : AppTheme.metallicGray,
                          letterSpacing: 1.0,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isDark
                                ? [AppTheme.darkNeonBlue, AppTheme.darkNeonPurple]
                                : [AppTheme.neonBlue, AppTheme.neonPurple],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: (isDark ? AppTheme.darkNeonBlue : AppTheme.neonBlue)
                                  .withOpacity(0.5),
                              blurRadius: 15,
                              spreadRadius: 0,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Text(
                          '${widget.total.toInt()} ر.س',
                          style: GoogleFonts.orbitron(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Checkout Button
                  SizedBox(
                    width: double.infinity,
                    child: AppTheme.neonButton(
                      text: 'إتمام الطلب',
                      onPressed: widget.onCheckout,
                      color: isDark ? AppTheme.darkNeonPink : AppTheme.neonPink,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      textStyle: GoogleFonts.orbitron(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  
                  // Free Shipping Notice
                  if (widget.subtotal < 200)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.holographicGreen.withOpacity(0.1),
                              AppTheme.holographicGreen.withOpacity(0.05),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.holographicGreen.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          'أضف ${(200 - widget.subtotal).toInt()} ر.س للحصول على شحن مجاني',
                          style: GoogleFonts.cairo(
                            color: AppTheme.holographicGreen,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummaryRow(
    String label, 
    double amount, 
    ThemeData theme, 
    bool isDark, {
    bool isShipping = false
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 16,
            color: isDark 
                ? AppTheme.darkGlowingWhite 
                : AppTheme.metallicGray,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          isShipping && amount == 0 
              ? 'مجاني'
              : '${amount.toInt()} ر.س',
          style: GoogleFonts.orbitron(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isShipping && amount == 0 
                ? AppTheme.holographicGreen
                : (isDark ? AppTheme.darkGlowingWhite : AppTheme.metallicGray),
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}