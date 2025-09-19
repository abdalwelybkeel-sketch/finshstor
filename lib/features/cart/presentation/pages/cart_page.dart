import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../widgets/cart_item_card.dart';
import '../widgets/cart_summary.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  Future<void> _loadCart() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    if (authProvider.isAuthenticated) {
      await cartProvider.loadCart(authProvider.currentUser!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.cart),
        actions: [
          Consumer<CartProvider>(
            builder: (context, cartProvider, child) {
              if (cartProvider.items.isEmpty) return const SizedBox.shrink();
              
              return TextButton(
                onPressed: () async {
                  final authProvider = Provider.of<AuthProvider>(context, listen: false);
                  if (authProvider.isAuthenticated) {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('مسح السلة'),
                        content: const Text('هل أنت متأكد من مسح جميع المنتجات من السلة؟'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('إلغاء'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: Text(
                              'مسح',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );

                    if (confirmed == true) {
                      await cartProvider.clearCart(authProvider.currentUser!.id);
                    }
                  }
                },
                child: Text(
                  'مسح الكل',
                  style: TextStyle(color: Colors.red),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          if (cartProvider.isLoading) {
            return Center(
              child: CircularProgressIndicator(
                color: AppTheme.neonBlue,
              ),
            );
          }

          if (cartProvider.items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 100,
                    color: theme.colorScheme.onBackground.withOpacity(0.3),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    l10n.cartEmpty,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: theme.colorScheme.onBackground.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'ابدأ بإضافة منتجات جميلة لسلتك',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onBackground.withOpacity(0.5),
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, AppConfig.homeRoute);
                    },
                    child: const Text('تصفح المنتجات'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Cart Items
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: cartProvider.items.length,
                  itemBuilder: (context, index) {
                    final item = cartProvider.items[index];
                    return CartItemCard(
                      item: item,
                      onQuantityChanged: (newQuantity) async {
                        final authProvider = Provider.of<AuthProvider>(context, listen: false);
                        if (authProvider.isAuthenticated) {
                          await cartProvider.updateQuantity(
                            authProvider.currentUser!.id,
                            item.id,
                            newQuantity,
                          );
                        }
                      },
                      onRemove: () async {
                        final authProvider = Provider.of<AuthProvider>(context, listen: false);
                        if (authProvider.isAuthenticated) {
                          await cartProvider.removeFromCart(
                            authProvider.currentUser!.id,
                            item.id,
                          );
                        }
                      },
                    );
                  },
                ),
              ),

              // Cart Summary
              CartSummary(
                subtotal: cartProvider.subtotal,
                tax: cartProvider.tax,
                shipping: cartProvider.shipping,
                total: cartProvider.total,
                onCheckout: () {
                  Navigator.pushNamed(context, '/checkout');
                },
              ),
            ],
          );
        },
      ),
    );
  }
}