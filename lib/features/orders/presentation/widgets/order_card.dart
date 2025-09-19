import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/models/order_model.dart';
import '../../../../core/theme/app_theme.dart';

class OrderCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback onTap;
  final VoidCallback? onCancel;
  final VoidCallback? onAccept;

  const OrderCard({
    super.key,
    required this.order,
    required this.onTap,
    this.onCancel,
    this.onAccept,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AppTheme.glassMorphismContainer(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'طلب #${order.id.substring(0, 8)}',
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppTheme.darkGlowingWhite : AppTheme.metallicGray,
                  ),
                ),
                _buildStatusChip(order.status, theme),
              ],
            ),

            const SizedBox(height: 8),

            // Order Date
            Text(
              DateFormat('dd/MM/yyyy - hh:mm a', 'ar').format(order.createdAt),
              style: GoogleFonts.cairo(
                color: isDark ? AppTheme.darkGlowingWhite.withOpacity(0.6) : AppTheme.metallicGray,
              ),
            ),

            const SizedBox(height: 12),

            // Order Items Preview
            Text(
              '${order.items.length} منتج',
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.w600,
                color: isDark ? AppTheme.darkGlowingWhite : AppTheme.metallicGray,
              ),
            ),

            const SizedBox(height: 4),

            // First few items
            Text(
              order.items.take(2).map((item) => item.productName).join(', ') +
                  (order.items.length > 2 ? '...' : ''),
              style: GoogleFonts.cairo(
                color: isDark ? AppTheme.darkGlowingWhite.withOpacity(0.7) : AppTheme.metallicGray,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 12),

            // Order Total and Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${order.total.toInt()} ر.س',
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.neonBlue,
                  ),
                ),

                Row(
                  children: [
                    if (order.status == OrderStatus.pending && onAccept != null)
                      AppTheme.neonButton(
                        text: 'قبول',
                        onPressed: () async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              backgroundColor: Colors.transparent,
                              content: AppTheme.glassMorphismContainer(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'قبول الطلب',
                                      style: GoogleFonts.orbitron(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: isDark ? AppTheme.darkGlowingWhite : AppTheme.metallicGray,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'هل أنت متأكد من قبول هذا الطلب؟',
                                      style: GoogleFonts.cairo(
                                        color: isDark ? AppTheme.darkGlowingWhite : AppTheme.metallicGray,
                                        height: 1.5,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 24),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        AppTheme.neonButton(
                                          text: 'لا',
                                          onPressed: () => Navigator.pop(context, false),
                                          color: AppTheme.neonBlue,
                                          textStyle: GoogleFonts.cairo(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        AppTheme.neonButton(
                                          text: 'نعم، قبول',
                                          onPressed: () => Navigator.pop(context, true),
                                          color: Colors.green,
                                          textStyle: GoogleFonts.cairo(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );

                          if (confirmed == true) {
                            onAccept!();
                          }
                        },
                        color: Colors.green,
                        textStyle: GoogleFonts.cairo(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    if (order.status == OrderStatus.pending && onCancel != null)
                      AppTheme.neonButton(
                        text: 'إلغاء',
                        onPressed: () async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              backgroundColor: Colors.transparent,
                              content: AppTheme.glassMorphismContainer(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'إلغاء الطلب',
                                      style: GoogleFonts.orbitron(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: isDark ? AppTheme.darkGlowingWhite : AppTheme.metallicGray,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'هل أنت متأكد من إلغاء هذا الطلب؟',
                                      style: GoogleFonts.cairo(
                                        color: isDark ? AppTheme.darkGlowingWhite : AppTheme.metallicGray,
                                        height: 1.5,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 24),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        AppTheme.neonButton(
                                          text: 'لا',
                                          onPressed: () => Navigator.pop(context, false),
                                          color: AppTheme.neonBlue,
                                          textStyle: GoogleFonts.cairo(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        AppTheme.neonButton(
                                          text: 'نعم، إلغاء',
                                          onPressed: () => Navigator.pop(context, true),
                                          color: AppTheme.neonPink,
                                          textStyle: GoogleFonts.cairo(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );

                          if (confirmed == true) {
                            onCancel!();
                          }
                        },
                        color: AppTheme.neonPink,
                        textStyle: GoogleFonts.cairo(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    AppTheme.neonButton(
                      text: 'التفاصيل',
                      onPressed: onTap,
                      color: AppTheme.neonBlue,
                      textStyle: GoogleFonts.cairo(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(OrderStatus status, ThemeData theme) {
    Color backgroundColor;
    Color textColor;
    String text = order.statusText;

    switch (status) {
      case OrderStatus.pending:
        backgroundColor = Colors.orange.withOpacity(0.1);
        textColor = Colors.orange;
        break;
      case OrderStatus.confirmed:
        backgroundColor = Colors.blue.withOpacity(0.1);
        textColor = Colors.blue;
        break;
      case OrderStatus.preparing:
        backgroundColor = AppTheme.darkNeonPurple.withOpacity(0.1);
        textColor = AppTheme.darkNeonPurple;
        break;
      case OrderStatus.shipped:
        backgroundColor = Colors.indigo.withOpacity(0.1);
        textColor = Colors.indigo;
        break;
      case OrderStatus.delivered:
        backgroundColor = Colors.green.withOpacity(0.1);
        textColor = Colors.green;
        break;
      case OrderStatus.cancelled:
        backgroundColor = Colors.red.withOpacity(0.1);
        textColor = Colors.red;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: GoogleFonts.cairo(
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}