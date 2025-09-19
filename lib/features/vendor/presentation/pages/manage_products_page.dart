import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/vendor_provider.dart';
import '../widgets/vendor_product_card.dart';

class ManageProductsPage extends StatefulWidget {
  const ManageProductsPage({super.key});

  @override
  State<ManageProductsPage> createState() => _ManageProductsPageState();
}

class _ManageProductsPageState extends State<ManageProductsPage> {
  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
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
        title: const Text('إدارة المنتجات'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/add-product').then((_) {
                _loadProducts();
              });
            },
            icon: const Icon(Icons.add),
          ),
        ],
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

          if (vendorProvider.vendorProducts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inventory_outlined,
                    size: 100,
                    color: Colors.grey.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'لا توجد منتجات',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'ابدأ بإضافة منتجاتك الأولى',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/add-product').then((_) {
                        _loadProducts();
                      });
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('إضافة منتج جديد'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadProducts,
            color: AppTheme.neonBlue,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: vendorProvider.vendorProducts.length,
              itemBuilder: (context, index) {
                final product = vendorProvider.vendorProducts[index];
                return VendorProductCard(
                  product: product,
                  onEdit: () {
                    // TODO: Navigate to edit product page
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('ميزة تعديل المنتج ستكون متاحة قريباً'),
                      ),
                    );
                  },
                  onDelete: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('حذف المنتج'),
                        content: Text('هل أنت متأكد من حذف "${product.name}"؟'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('إلغاء'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text(
                              'حذف',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );

                    if (confirmed == true) {
                      final success = await vendorProvider.deleteProduct(product.id);
                      if (success && mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('تم حذف المنتج بنجاح'),
                          ),
                        );
                      }
                    }
                  },
                  onToggleActive: () async {
                    final updatedProduct = product.copyWith(
                      isActive: !product.isActive,
                    );
                    await vendorProvider.updateProduct(updatedProduct);
                  },
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/add-product').then((_) {
            _loadProducts();
          });
        },
        backgroundColor: AppTheme.neonBlue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}