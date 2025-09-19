import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../widgets/cart_item_card.dart';
import '../widgets/cart_summary.dart';
import '../../../home/presentation/widgets/futuristic_background.dart';

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
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          const FuturisticBackground(),
          SafeArea(
            child: Column(
              children: [
                // Custom App Bar
                Container(
                  padding: const EdgeInsets.all(20),
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
                  child: AppTheme.glassMorphismContainer(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Row(
                      children: [
                        Icon(
                          Icons.shopping_cart_rounded,
                          color: isDark ? AppTheme.darkNeonBlue : AppTheme.neonBlue,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            l10n.cart,
                            style: GoogleFonts.orbitron(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppTheme.darkGlowingWhite : AppTheme.metallicGray,
                            ),
                          ),
                        ),
                        Consumer<CartProvider>(
                          builder: (context, cartProvider, child) {
                            if (cartProvider.items.isEmpty) return const SizedBox.shrink();
                            
                            return AppTheme.neonButton(
                              text: 'مسح الكل',
                              onPressed: () async {
                                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                                if (authProvider.isAuthenticated) {
                                  final confirmed = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      backgroundColor: Colors.transparent,
                                      content: AppTheme.glassMorphismContainer(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              'مسح السلة',
                                              style: GoogleFonts.orbitron(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: isDark ? AppTheme.darkGlowingWhite : AppTheme.metallicGray,
                                              ),
                                            ),
                                            const SizedBox(height: 16),
                                            Text(
                                              'هل أنت متأكد من مسح جميع المنتجات من السلة؟',
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
                                                  text: 'إلغاء',
                                                  onPressed: () => Navigator.pop(context, false),
                                                  color: AppTheme.neonBlue,
                                                  textStyle: GoogleFonts.cairo(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                AppTheme.neonButton(
                                                  text: 'مسح',
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
                                    await cartProvider.clearCart(authProvider.currentUser!.id);
                                  }
                                }
                              },
                              color: AppTheme.neonPink,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              textStyle: GoogleFonts.cairo(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Cart Content
                Expanded(
                  child: Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          if (cartProvider.isLoading) {
            return AppTheme.glassMorphismContainer(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(40),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
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
                      'جاري تحميل السلة...',
                      style: GoogleFonts.cairo(
                        color: isDark ? AppTheme.darkGlowingWhite : AppTheme.metallicGray,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          if (cartProvider.items.isEmpty) {
            return AppTheme.glassMorphismContainer(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(40),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_cart_outlined,
                      size: 100,
                      color: isDark ? AppTheme.darkNeonBlue : AppTheme.neonBlue,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      l10n.cartEmpty,
                      style: GoogleFonts.orbitron(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppTheme.darkGlowingWhite : AppTheme.metallicGray,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'ابدأ بإضافة منتجات جميلة لسلتك',
                      style: GoogleFonts.cairo(
                        color: isDark ? AppTheme.darkGlowingWhite.withOpacity(0.6) : AppTheme.metallicGray,
                      ),
                    ),
                    const SizedBox(height: 32),
                    AppTheme.neonButton(
                      text: 'تصفح المنتجات',
                      onPressed: () {
                        // Switch to home tab instead of navigating
                        final navigationProvider = Provider.of<NavigationProvider>(context, listen: false);
                        navigationProvider.setIndex(0);
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
                  Navigator.pushNamed(context, AppConfig.checkoutRoute);
                },
              ),
            ],
          );
        },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}