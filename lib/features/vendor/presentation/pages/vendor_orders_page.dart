import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/models/order_model.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/vendor_provider.dart';
import '../../../orders/presentation/widgets/order_card.dart';

class VendorOrdersPage extends StatefulWidget {
  const VendorOrdersPage({super.key});

  @override
  State<VendorOrdersPage> createState() => _VendorOrdersPageState();
}

class _VendorOrdersPageState extends State<VendorOrdersPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadOrders();
    });
  }

  Future<void> _loadOrders() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final vendorProvider = Provider.of<VendorProvider>(context, listen: false);

    if (authProvider.isAuthenticated && authProvider.currentUser!.isVendor) {
      if (kDebugMode) {
        print('VendorOrdersPage: Loading orders for vendorId: ${authProvider.currentUser!.id}');
      }
      await vendorProvider.loadVendorData(authProvider.currentUser!.id);
      if (vendorProvider.errorMessage != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(vendorProvider.errorMessage!)),
        );
      }
    } else {
      if (kDebugMode) {
        print('VendorOrdersPage: User is not authenticated or not a vendor');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('طلبات المتجر'),
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

          if (vendorProvider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: theme.colorScheme.onBackground.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    vendorProvider.errorMessage!,
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadOrders,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.neonBlue,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: const Text(
                      'إعادة المحاولة',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          }

          if (vendorProvider.vendorOrders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 100,
                    color: theme.colorScheme.onBackground.withOpacity(0.3),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'لا توجد طلبات',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: theme.colorScheme.onBackground.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'ستظهر هنا جميع الطلبات على منتجاتك',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onBackground.withOpacity(0.5),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadOrders,
            color: AppTheme.neonBlue,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: vendorProvider.vendorOrders.length,
              itemBuilder: (context, index) {
                final order = vendorProvider.vendorOrders[index];
                return OrderCard(
                  order: order,
                  onTap: () {
                    if (kDebugMode) {
                      print('VendorOrdersPage: Navigating to order details with orderId: ${order.id}');
                    }
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
                        title: const Text('رفض الطلب'),
                        content: const Text('هل أنت متأكد من رفض هذا الطلب؟'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('لا'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text(
                              'نعم، رفض',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );

                    if (confirmed == true && mounted) {
                      final vendorProvider = Provider.of<VendorProvider>(
                        context,
                        listen: false,
                      );
                      await vendorProvider.updateOrderStatus(
                        order.id,
                        OrderStatus.cancelled,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('تم رفض الطلب'),
                        ),
                      );
                    }
                  }
                      : null,
                  onAccept: order.status == OrderStatus.pending
                      ? () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('قبول الطلب'),
                        content: const Text('هل أنت متأكد من قبول هذا الطلب؟'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('لا'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text(
                              'نعم، قبول',
                              style: TextStyle(color: Colors.green),
                            ),
                          ),
                        ],
                      ),
                    );

                    if (confirmed == true && mounted) {
                      final vendorProvider = Provider.of<VendorProvider>(
                        context,
                        listen: false,
                      );
                      await vendorProvider.updateOrderStatus(
                        order.id,
                        OrderStatus.confirmed,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('تم قبول الطلب'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  }
                      : null,
                );
              },
            ),
          );
        },
      ),
    );
  }
}