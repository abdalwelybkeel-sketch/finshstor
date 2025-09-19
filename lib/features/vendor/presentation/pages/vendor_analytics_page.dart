import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/vendor_provider.dart';
import '../widgets/dashboard_stats_card.dart';

class VendorAnalyticsPage extends StatefulWidget {
  const VendorAnalyticsPage({super.key});

  @override
  State<VendorAnalyticsPage> createState() => _VendorAnalyticsPageState();
}

class _VendorAnalyticsPageState extends State<VendorAnalyticsPage> {
  String _selectedPeriod = 'month';
  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
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
      appBar: AppBar(
        title: const Text('تحليلات المتجر'),
      ),
      body: Consumer<VendorProvider>(
        builder: (context, vendorProvider, child) {
          if (vendorProvider.isLoading) {
            return Center(
              child: CircularProgressIndicator(
                color: AppTheme.neonBlue,
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadAnalytics,
            color: AppTheme.neonBlue,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Overview Stats
                  Text(
                    'نظرة عامة',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  DashboardStatsCard(
                    title: 'إجمالي الإيرادات',
                    value: '${vendorProvider.totalRevenue.toInt()} ر.س',
                    icon: Icons.attach_money,
                    color: Colors.green,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Expanded(
                        child: DashboardStatsCard(
                          title: 'إجمالي الطلبات',
                          value: vendorProvider.totalOrders.toString(),
                          icon: Icons.receipt_long,
                          color: AppTheme.neonBlue,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DashboardStatsCard(
                          title: 'إجمالي المنتجات',
                          value: vendorProvider.totalProducts.toString(),
                          icon: Icons.inventory,
                          color: AppTheme.darkNeonPurple,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Monthly Revenue
                  Text(
                    'الإيرادات الشهرية',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  if (vendorProvider.monthlyRevenue.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(
                            Icons.analytics_outlined,
                            size: 64,
                            color: Colors.grey.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'لا توجد بيانات كافية',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ...vendorProvider.monthlyRevenue.entries.map((entry) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 5,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatMonthKey(entry.key),
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${entry.value.toInt()} ر.س',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.neonBlue,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
  String _formatMonthKey(String monthKey) {
    try {
      final parts = monthKey.split('-');
      if (parts.length == 2) {
        final year = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final date = DateTime(year, month);
        return DateFormat('MMMM yyyy', 'ar').format(date);
      }
      return monthKey;
    } catch (e) {
      return monthKey;
    }
  }