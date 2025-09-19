import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

import '../../../../core/config/app_config.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/vendor_provider.dart';
import '../widgets/dashboard_stats_card.dart';
import '../widgets/recent_orders_list.dart';
import '../widgets/vendor_app_bar.dart';
import '../../../home/presentation/widgets/futuristic_background.dart';

class VendorDashboardPage extends StatefulWidget {
  const VendorDashboardPage({super.key});

  @override
  State<VendorDashboardPage> createState() => _VendorDashboardPageState();
}

class _VendorDashboardPageState extends State<VendorDashboardPage> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _particleController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadVendorData();
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

  Future<void> _loadVendorData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final vendorProvider = Provider.of<VendorProvider>(context, listen: false);

    if (authProvider.isAuthenticated && authProvider.currentUser!.isVendor) {
      await vendorProvider.loadVendorData(authProvider.currentUser!.id);
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

    return Scaffold(
      body: Stack(
        children: [
          const FuturisticBackground(),
          Consumer2<AuthProvider, VendorProvider>(
        builder: (context, authProvider, vendorProvider, child) {
          if (!authProvider.isAuthenticated || !authProvider.currentUser!.isVendor) {
            return SafeArea(
              child: Center(
                child: AppTheme.glassMorphismContainer(
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.store_outlined,
                        size: 100,
                        color: isDark ? AppTheme.darkNeonBlue : AppTheme.neonBlue,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'غير مصرح لك بالوصول',
                        style: GoogleFonts.orbitron(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppTheme.darkGlowingWhite : AppTheme.metallicGray,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          if (vendorProvider.isLoading) {
            return SafeArea(
              child: Center(
                child: AppTheme.glassMorphismContainer(
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 60,
                        height: 60,
                        child: CircularProgressIndicator(
                          strokeWidth: 4,
                          valueColor: AlwaysStoppedAnimation(
                            isDark ? AppTheme.darkNeonBlue : AppTheme.neonBlue,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'جاري تحميل بيانات المتجر...',
                        style: GoogleFonts.cairo(
                          color: isDark ? AppTheme.darkGlowingWhite : AppTheme.metallicGray,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          return SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: RefreshIndicator(
            onRefresh: _loadVendorData,
            color: AppTheme.neonBlue,
            child: CustomScrollView(
              slivers: [
                // App Bar
                VendorAppBar(user: authProvider.currentUser!),

                // Dashboard Stats
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppTheme.glassMorphismContainer(
                          padding: const EdgeInsets.all(20),
                          child: Text(
                            'إحصائيات المتجر',
                            style: GoogleFonts.orbitron(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppTheme.darkGlowingWhite : AppTheme.metallicGray,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: DashboardStatsCard(
                                title: 'إجمالي الإيرادات',
                                value: '${vendorProvider.totalRevenue.toInt()} ر.س',
                                icon: Icons.attach_money,
                                color: Colors.green,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: DashboardStatsCard(
                                title: 'إجمالي الطلبات',
                                value: vendorProvider.totalOrders.toString(),
                                icon: Icons.receipt_long,
                                color: AppTheme.neonBlue,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        DashboardStatsCard(
                          title: 'إجمالي المنتجات',
                          value: vendorProvider.totalProducts.toString(),
                          icon: Icons.inventory,
                          color: AppTheme.darkNeonPurple,
                        ),
                      ],
                    ),
                  ),
                ),

                // Quick Actions
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppTheme.glassMorphismContainer(
                          padding: const EdgeInsets.all(20),
                          child: Text(
                            'إجراءات سريعة',
                            style: GoogleFonts.orbitron(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppTheme.darkGlowingWhite : AppTheme.metallicGray,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildQuickActionCard(
                                context,
                                'إضافة منتج',
                                Icons.add_box_outlined,
                                AppTheme.neonBlue,
                                () {
                                  Navigator.pushNamed(context, AppConfig.addProductRoute);
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildQuickActionCard(
                                context,
                                'إدارة المنتجات',
                                Icons.inventory_outlined,
                                AppTheme.darkNeonPurple,
                                () {
                                  Navigator.pushNamed(context, AppConfig.manageProductsRoute);
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildQuickActionCard(
                                context,
                                'الطلبات',
                                Icons.list_alt_outlined,
                                Colors.blue,
                                () {
                                  Navigator.pushNamed(context, AppConfig.vendorOrdersRoute);
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildQuickActionCard(
                                context,
                                'التقارير',
                                Icons.analytics_outlined,
                                Colors.orange,
                                () {
                                  Navigator.pushNamed(context, AppConfig.vendorAnalyticsRoute);
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Recent Orders
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppTheme.glassMorphismContainer(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'الطلبات الأخيرة',
                                style: GoogleFonts.orbitron(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? AppTheme.darkGlowingWhite : AppTheme.metallicGray,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              AppTheme.neonButton(
                                text: 'عرض الكل',
                                onPressed: () {
                                  Navigator.pushNamed(context, AppConfig.vendorOrdersRoute);
                                },
                                color: isDark ? AppTheme.darkNeonPurple : AppTheme.neonPurple,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                textStyle: GoogleFonts.cairo(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        RecentOrdersList(
                          orders: vendorProvider.vendorOrders.take(5).toList(),
                          onOrderTap: (order) {
                            Navigator.pushNamed(
                              context,
                              AppConfig.orderDetailsRoute,
                              arguments: {'orderId': order.id},
                            );
                          },
                          onStatusUpdate: (orderId, status) async {
                            await vendorProvider.updateOrderStatus(orderId, status);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'تم تحديث حالة الطلب',
                                    style: GoogleFonts.cairo(color: Colors.white),
                                  ),
                                  backgroundColor: AppTheme.neonBlue,
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                // Bottom Spacing
                const SliverToBoxAdapter(
                  child: SizedBox(height: 100),
                ),
              ],
            ),
                ),
              ),
            ),
          );
        },
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _particleController,
      builder: (context, child) {
        return GestureDetector(
      onTap: onTap,
          child: AppTheme.glassMorphismContainer(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color, color.withOpacity(0.8)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.3 + 0.2 * math.sin(_particleController.value * 2 * math.pi)),
                        blurRadius: 20,
                        spreadRadius: 0,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppTheme.darkGlowingWhite : AppTheme.metallicGray,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

              ),
              child: Icon(
                icon,
                color: color,
                size: 32,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}