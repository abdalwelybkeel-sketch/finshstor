import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/vendor_provider.dart';
import '../widgets/dashboard_stats_card.dart';
import '../widgets/recent_orders_list.dart';
import '../widgets/vendor_app_bar.dart';

class VendorDashboardPage extends StatefulWidget {
  const VendorDashboardPage({super.key});

  @override
  State<VendorDashboardPage> createState() => _VendorDashboardPageState();
}

class _VendorDashboardPageState extends State<VendorDashboardPage> {
  @override
  void initState() {
    super.initState();
    _loadVendorData();
  }

  Future<void> _loadVendorData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final vendorProvider = Provider.of<VendorProvider>(context, listen: false);

    if (authProvider.isAuthenticated && authProvider.currentUser!.isVendor) {
      await vendorProvider.loadVendorData(authProvider.currentUser!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Consumer2<AuthProvider, VendorProvider>(
        builder: (context, authProvider, vendorProvider, child) {
          if (!authProvider.isAuthenticated || !authProvider.currentUser!.isVendor) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.store_outlined,
                    size: 100,
                    color: theme.colorScheme.onBackground.withOpacity(0.3),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'غير مصرح لك بالوصول',
                    style: theme.textTheme.headlineSmall,
                  ),
                ],
              ),
            );
          }

          if (vendorProvider.isLoading) {
            return Center(
              child: CircularProgressIndicator(
                color: AppTheme.neonBlue,
              ),
            );
          }

          return RefreshIndicator(
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
                        Text(
                          'إحصائيات المتجر',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
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
                        Text(
                          'إجراءات سريعة',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
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
                                  Navigator.pushNamed(context, '/add-product');
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
                                  Navigator.pushNamed(context, '/manage-products');
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'الطلبات الأخيرة',
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pushNamed(context, AppConfig.vendorOrdersRoute);
                              },
                              child: Text(
                                'عرض الكل',
                                style: TextStyle(
                                  color: AppTheme.neonBlue,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        RecentOrdersList(
                          orders: vendorProvider.vendorOrders.take(5).toList(),
                          onOrderTap: (order) {
                            Navigator.pushNamed(
                              context,
                              '/order-details',
                              arguments: {'orderId': order.id},
                            );
                          },
                          onStatusUpdate: (orderId, status) async {
                            await vendorProvider.updateOrderStatus(orderId, status);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('تم تحديث حالة الطلب'),
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
          );
        },
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

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
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