import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

import '../../../../core/models/order_model.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/orders_provider.dart';
import '../../../home/presentation/widgets/futuristic_background.dart';

class OrderDetailsPage extends StatefulWidget {
  final String orderId;

  const OrderDetailsPage({
    super.key,
    required this.orderId,
  });

  @override
  State<OrderDetailsPage> createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> with TickerProviderStateMixin {
  OrderModel? _order;
  bool _isLoading = true;
  String? _errorMessage;

  late AnimationController _animationController;
  late AnimationController _particleController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadOrder();
    });
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

  Future<void> _loadOrder() async {
    if (kDebugMode) {
      print('OrderDetailsPage: Loading order with ID: ${widget.orderId}');
    }
    final ordersProvider = Provider.of<OrdersProvider>(context, listen: false);
    try {
      final order = await ordersProvider.getOrder(widget.orderId);
      setState(() {
        _order = order;
        _isLoading = false;
        _errorMessage = order == null ? 'الطلب غير موجود' : null;
      });
      if (order == null && kDebugMode) {
        print('OrderDetailsPage: Order not found for ID: ${widget.orderId}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('OrderDetailsPage: Error loading order: $e');
      }
      setState(() {
        _isLoading = false;
        _errorMessage = 'فشل تحميل الطلب: $e';
      });
    }
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

    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: AppTheme.neonBlue,
          ),
        ),
      );
    }

    if (_errorMessage != null || _order == null) {
      return Scaffold(
        body: Stack(
          children: [
            const FuturisticBackground(),
            SafeArea(
              child: Center(
                child: AppTheme.glassMorphismContainer(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: isDark ? AppTheme.darkNeonPink : AppTheme.neonPink,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage ?? 'الطلب غير موجود',
                        style: GoogleFonts.orbitron(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppTheme.darkGlowingWhite : AppTheme.metallicGray,
                        ),
                      ),
                      const SizedBox(height: 16),
                      AppTheme.neonButton(
                        text: 'إعادة المحاولة',
                        onPressed: () => _loadOrder(),
                        color: isDark ? AppTheme.darkNeonBlue : AppTheme.neonBlue,
                        textStyle: GoogleFonts.cairo(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          const FuturisticBackground(),
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      pinned: true,
                      backgroundColor: Colors.transparent,
                      flexibleSpace: Container(
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
                        child: Center(
                          child: Text(
                            'طلب #${_order!.id.substring(0, 8)}',
                            style: GoogleFonts.orbitron(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppTheme.darkGlowingWhite : AppTheme.metallicGray,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Order Status
                            AppTheme.glassMorphismContainer(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  Icon(
                                    _getStatusIcon(_order!.status),
                                    size: 48,
                                    color: _getStatusColor(_order!.status),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    _order!.statusText,
                                    style: GoogleFonts.orbitron(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: _getStatusColor(_order!.status),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'تاريخ الطلب: ${DateFormat('dd/MM/yyyy - hh:mm a', 'ar').format(_order!.createdAt)}',
                                    style: GoogleFonts.cairo(
                                      color: isDark ? AppTheme.darkGlowingWhite.withOpacity(0.6) : AppTheme.metallicGray,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Order Items
                            Text(
                              'المنتجات',
                              style: GoogleFonts.orbitron(
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                                color: isDark ? AppTheme.darkGlowingWhite : AppTheme.metallicGray,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ..._order!.items.map((item) => AppTheme.glassMorphismContainer(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Icon(Icons.shopping_bag, color: AppTheme.neonBlue),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.productName,
                                          style: GoogleFonts.cairo(
                                            fontWeight: FontWeight.bold,
                                            color: isDark ? AppTheme.darkGlowingWhite : AppTheme.metallicGray,
                                          ),
                                        ),
                                        Text(
                                          '${item.quantity} x ${item.price} ر.س',
                                          style: GoogleFonts.cairo(
                                            color: isDark ? AppTheme.darkGlowingWhite.withOpacity(0.6) : AppTheme.metallicGray,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '${(item.price * item.quantity).toInt()} ر.س',
                                    style: GoogleFonts.cairo(
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.neonBlue,
                                    ),
                                  ),
                                ],
                              ),
                            )),

                            const SizedBox(height: 24),

                            // Shipping Address
                            Text(
                              'عنوان التوصيل',
                              style: GoogleFonts.orbitron(
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                                color: isDark ? AppTheme.darkGlowingWhite : AppTheme.metallicGray,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 16),
                            AppTheme.glassMorphismContainer(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'الاسم: ${_order!.shippingAddress['name']}',
                                    style: GoogleFonts.cairo(
                                      color: isDark ? AppTheme.darkGlowingWhite : AppTheme.metallicGray,
                                    ),
                                  ),
                                  Text(
                                    'العنوان: ${_order!.shippingAddress['address']}',
                                    style: GoogleFonts.cairo(
                                      color: isDark ? AppTheme.darkGlowingWhite : AppTheme.metallicGray,
                                    ),
                                  ),
                                  Text(
                                    'المدينة: ${_order!.shippingAddress['city']}',
                                    style: GoogleFonts.cairo(
                                      color: isDark ? AppTheme.darkGlowingWhite : AppTheme.metallicGray,
                                    ),
                                  ),
                                  Text(
                                    'الهاتف: ${_order!.shippingAddress['phone']}',
                                    style: GoogleFonts.cairo(
                                      color: isDark ? AppTheme.darkGlowingWhite : AppTheme.metallicGray,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Payment Method
                            Text(
                              'طريقة الدفع',
                              style: GoogleFonts.orbitron(
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                                color: isDark ? AppTheme.darkGlowingWhite : AppTheme.metallicGray,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 16),
                            AppTheme.glassMorphismContainer(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Icon(Icons.payment, color: AppTheme.neonBlue),
                                  const SizedBox(width: 12),
                                  Text(
                                    _order!.paymentMethod == PaymentMethod.cashOnDelivery
                                        ? 'الدفع عند الاستلام'
                                        : 'بطاقة ائتمان',
                                    style: GoogleFonts.cairo(
                                      color: isDark ? AppTheme.darkGlowingWhite : AppTheme.metallicGray,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Order Summary
                            Text(
                              'ملخص الطلب',
                              style: GoogleFonts.orbitron(
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                                color: isDark ? AppTheme.darkGlowingWhite : AppTheme.metallicGray,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 16),
                            AppTheme.glassMorphismContainer(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  _buildSummaryRow('المجموع الفرعي', _order!.subtotal, theme),
                                  const SizedBox(height: 8),
                                  _buildSummaryRow('الضريبة', _order!.tax, theme),
                                  const SizedBox(height: 8),
                                  _buildSummaryRow('الشحن', _order!.shipping, theme),
                                  const Divider(height: 24),
                                  _buildSummaryRow('الإجمالي', _order!.total, theme),
                                ],
                              ),
                            ),

                            const SizedBox(height: 32),

                            // Cancel Button if pending
                            if (_order!.status == OrderStatus.pending)
                              AppTheme.neonButton(
                                text: 'إلغاء الطلب',
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

                                  if (confirmed == true && mounted) {
                                    final ordersProvider = Provider.of<OrdersProvider>(
                                      context,
                                      listen: false,
                                    );
                                    await ordersProvider.cancelOrder(_order!.id);
                                    if (mounted) {
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'تم إلغاء الطلب بنجاح',
                                            style: GoogleFonts.cairo(color: Colors.white),
                                          ),
                                          backgroundColor: AppTheme.neonBlue,
                                        ),
                                      );
                                    }
                                  }
                                },
                                color: AppTheme.neonPink,
                                textStyle: GoogleFonts.cairo(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),

                            const SizedBox(height: 120),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.cairo(
            color: isDark ? AppTheme.darkGlowingWhite : AppTheme.metallicGray,
          ),
        ),
        Text(
          '${amount.toInt()} ر.س',
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.w600,
            color: isDark ? AppTheme.darkGlowingWhite : AppTheme.metallicGray,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.confirmed:
        return Colors.blue;
      case OrderStatus.preparing:
        return AppTheme.darkNeonPurple;
      case OrderStatus.shipped:
        return Colors.indigo;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }

  IconData _getStatusIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Icons.access_time;
      case OrderStatus.confirmed:
        return Icons.check_circle_outline;
      case OrderStatus.preparing:
        return Icons.inventory;
      case OrderStatus.shipped:
        return Icons.local_shipping;
      case OrderStatus.delivered:
        return Icons.done_all;
      case OrderStatus.cancelled:
        return Icons.cancel;
    }
  }
}