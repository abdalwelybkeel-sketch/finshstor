import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

import '../../../../core/models/order_model.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/orders_provider.dart';
import '../widgets/order_card.dart';
import '../../../home/presentation/widgets/futuristic_background.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _particleController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    // تأخير تحميل الطلبات حتى اكتمال مرحلة البناء
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadOrders();
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

  Future<void> _loadOrders() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final ordersProvider = Provider.of<OrdersProvider>(context, listen: false);

    if (authProvider.isAuthenticated) {
      print('Loading orders for userId: ${authProvider.currentUser!.id}');
      await ordersProvider.loadOrders(authProvider.currentUser!.id);
      print('Number of orders loaded: ${ordersProvider.orders.length}');
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
    final l10n = AppLocalizations.of(context)!;
    final isDark = theme.brightness == Brightness.dark;

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
                            l10n.orders,
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
                      child: Consumer<OrdersProvider>(
                        builder: (context, ordersProvider, child) {
                          if (ordersProvider.isLoading) {
                            return Center(
                              child: CircularProgressIndicator(
                                color: AppTheme.neonBlue,
                              ),
                            );
                          }

                          if (ordersProvider.orders.isEmpty) {
                            return AppTheme.glassMorphismContainer(
                              margin: const EdgeInsets.all(16),
                              padding: const EdgeInsets.all(40),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.receipt_long_outlined,
                                    size: 100,
                                    color: isDark ? AppTheme.darkNeonBlue : AppTheme.neonBlue,
                                  ),
                                  const SizedBox(height: 24),
                                  Text(
                                    'لا توجد طلبات',
                                    style: GoogleFonts.orbitron(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? AppTheme.darkGlowingWhite : AppTheme.metallicGray,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'ابدأ بطلب باقات الورود الجميلة',
                                    style: GoogleFonts.cairo(
                                      color: isDark ? AppTheme.darkGlowingWhite.withOpacity(0.6) : AppTheme.metallicGray,
                                    ),
                                  ),
                                  const SizedBox(height: 32),
                                  AppTheme.neonButton(
                                    text: 'تصفح المنتجات',
                                    onPressed: () {
                                      Navigator.pushNamedAndRemoveUntil(
                                        context,
                                        '/home',
                                            (route) => false,
                                      );
                                    },
                                    color: isDark ? AppTheme.darkNeonBlue : AppTheme.neonBlue,
                                    textStyle: GoogleFonts.cairo(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          return RefreshIndicator(
                            onRefresh: _loadOrders,
                            color: AppTheme.neonBlue,
                            child: ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              padding: const EdgeInsets.all(16),
                              itemCount: ordersProvider.orders.length,
                              itemBuilder: (context, index) {
                                final order = ordersProvider.orders[index];
                                return OrderCard(
                                  order: order,
                                  onTap: () {
                                    print('Navigating to order details with orderId: ${order.id}');
                                    Navigator.pushNamed(
                                      context,
                                      '/order-details',
                                      arguments: {'orderId': order.id},
                                    );
                                  },
                                  onCancel: order.status == OrderStatus.pending
                                      ? () async {
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
                                      await ordersProvider.cancelOrder(order.id);
                                      if (mounted) {
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
                                  }
                                      : null,
                                );
                              },
                            ),
                          );
                        },
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
}