import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/payment_provider.dart';
import '../widgets/payment_method_card.dart';
import 'add_payment_method_page.dart';
import '../../../home/presentation/widgets/futuristic_background.dart';

class PaymentMethodsPage extends StatefulWidget {
  const PaymentMethodsPage({super.key});

  @override
  State<PaymentMethodsPage> createState() => _PaymentMethodsPageState();
}

class _PaymentMethodsPageState extends State<PaymentMethodsPage> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _particleController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadPaymentMethods();
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

  Future<void> _loadPaymentMethods() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final paymentProvider = Provider.of<PaymentProvider>(context, listen: false);

    if (authProvider.isAuthenticated) {
      await paymentProvider.loadPaymentMethods(authProvider.currentUser!.id);
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
                            'طرق الدفع',
                            style: GoogleFonts.orbitron(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppTheme.darkGlowingWhite : AppTheme.metallicGray,
                            ),
                          ),
                        ),
                      ),
                      actions: [
                        IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AddPaymentMethodPage(),
                              ),
                            ).then((_) => _loadPaymentMethods());
                          },
                          icon: const Icon(Icons.add),
                        ),
                      ],
                    ),
                    SliverToBoxAdapter(
                      child: Consumer<PaymentProvider>(
                        builder: (context, paymentProvider, child) {
                          if (paymentProvider.isLoading) {
                            return Center(
                              child: CircularProgressIndicator(
                                color: AppTheme.neonBlue,
                              ),
                            );
                          }

                          return Column(
                            children: [
                              // Default Payment Methods
                              AppTheme.glassMorphismContainer(
                                margin: const EdgeInsets.all(16),
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'طرق الدفع المتاحة',
                                      style: GoogleFonts.orbitron(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 24,
                                        color: isDark ? AppTheme.darkGlowingWhite : AppTheme.metallicGray,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                    const SizedBox(height: 16),

                                    // Cash on Delivery
                                    PaymentMethodCard(
                                      icon: Icons.money,
                                      title: 'الدفع عند الاستلام',
                                      subtitle: 'ادفع نقداً عند وصول الطلب',
                                      isDefault: true,
                                      onTap: () {
                                        // Already selected by default
                                      },
                                    ),

                                    const SizedBox(height: 12),

                                    // Stripe Payment
                                    PaymentMethodCard(
                                      icon: Icons.credit_card,
                                      title: 'بطاقة ائتمان/خصم',
                                      subtitle: 'ادفع بأمان باستخدام بطاقتك',
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => const AddPaymentMethodPage(),
                                          ),
                                        ).then((_) => _loadPaymentMethods());
                                      },
                                    ),
                                  ],
                                ),
                              ),

                              // Saved Payment Methods
                              if (paymentProvider.paymentMethods.isNotEmpty) ...[
                                AppTheme.glassMorphismContainer(
                                  margin: const EdgeInsets.symmetric(horizontal: 16),
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'البطاقات المحفوظة',
                                        style: GoogleFonts.orbitron(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 24,
                                          color: isDark ? AppTheme.darkGlowingWhite : AppTheme.metallicGray,
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                    ],
                                  ),
                                ),

                                SliverList(
                                  delegate: SliverChildBuilderDelegate(
                                        (context, index) {
                                      final paymentMethod = paymentProvider.paymentMethods[index];
                                      return PaymentMethodCard(
                                        icon: _getCardIcon(paymentMethod.cardType),
                                        title: '**** **** **** ${paymentMethod.last4}',
                                        subtitle: '${paymentMethod.cardType} • ${paymentMethod.expiryMonth}/${paymentMethod.expiryYear}',
                                        isDefault: paymentMethod.isDefault,
                                        onTap: () async {
                                          final authProvider = Provider.of<AuthProvider>(
                                            context,
                                            listen: false,
                                          );
                                          await paymentProvider.setDefaultPaymentMethod(
                                            authProvider.currentUser!.id,
                                            paymentMethod.id,
                                          );
                                        },
                                        onDelete: () async {
                                          final confirmed = await showDialog<bool>(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              backgroundColor: Colors.transparent,
                                              content: AppTheme.glassMorphismContainer(
                                                child: Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Text(
                                                      'حذف البطاقة',
                                                      style: GoogleFonts.orbitron(
                                                        fontSize: 20,
                                                        fontWeight: FontWeight.bold,
                                                        color: isDark ? AppTheme.darkGlowingWhite : AppTheme.metallicGray,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 16),
                                                    Text(
                                                      'هل أنت متأكد من حذف هذه البطاقة؟',
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
                                                          text: 'حذف',
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
                                            final authProvider = Provider.of<AuthProvider>(
                                              context,
                                              listen: false,
                                            );
                                            await paymentProvider.deletePaymentMethod(
                                              authProvider.currentUser!.id,
                                              paymentMethod.id,
                                            );
                                          }
                                        },
                                      );
                                    },
                                    childCount: paymentProvider.paymentMethods.length,
                                  ),
                                ),
                              ] else ...[
                                AppTheme.glassMorphismContainer(
                                  margin: const EdgeInsets.all(16),
                                  padding: const EdgeInsets.all(40),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.credit_card_off,
                                        size: 100,
                                        color: isDark ? AppTheme.darkNeonBlue : AppTheme.neonBlue,
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'لا توجد بطاقات محفوظة',
                                        style: GoogleFonts.orbitron(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: isDark ? AppTheme.darkGlowingWhite : AppTheme.metallicGray,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'أضف بطاقة ائتمان لتسهيل عملية الدفع',
                                        style: GoogleFonts.cairo(
                                          color: isDark ? AppTheme.darkGlowingWhite.withOpacity(0.6) : AppTheme.metallicGray,

                                        ),
                                      ),
                                      const SizedBox(height: 32),
                                      AppTheme.neonButton(
                                        text: 'إضافة بطاقة جديدة',
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => const AddPaymentMethodPage(),
                                            ),
                                          ).then((_) => _loadPaymentMethods());
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
                              ],

                              // Floating Action Button as part of content
                              Container(
                                margin: const EdgeInsets.all(20),
                                child: Center(
                                  child: AnimatedBuilder(
                                    animation: _particleController,
                                    builder: (context, child) {
                                      return Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(30),
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: isDark
                                                ? [AppTheme.darkNeonBlue, AppTheme.darkNeonPurple]
                                                : [AppTheme.neonBlue, AppTheme.neonPurple],
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: (isDark ? AppTheme.darkNeonBlue : AppTheme.neonBlue)
                                                  .withOpacity(0.5),
                                              blurRadius: 20,
                                              spreadRadius: 0,
                                              offset: const Offset(0, 10),
                                            ),
                                            BoxShadow(
                                              color: (isDark ? AppTheme.darkNeonBlue : AppTheme.neonBlue)
                                                  .withOpacity(0.3 + 0.2 * math.sin(_particleController.value * 2 * math.pi)),
                                              blurRadius: 40,
                                              spreadRadius: 0,
                                              offset: const Offset(0, 20),
                                            ),
                                          ],
                                        ),
                                        child: FloatingActionButton.extended(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => const AddPaymentMethodPage(),
                                              ),
                                            ).then((_) => _loadPaymentMethods());
                                          },
                                          backgroundColor: Colors.transparent,
                                          elevation: 0,
                                          icon: const Icon(
                                            Icons.add,
                                            color: Colors.white,
                                          ),
                                          label: Text(
                                            'إضافة بطاقة جديدة',
                                            style: GoogleFonts.cairo(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),

                              const SizedBox(height: 120),
                            ],
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

  IconData _getCardIcon(String cardType) {
    switch (cardType.toLowerCase()) {
      case 'visa':
        return Icons.credit_card;
      case 'mastercard':
        return Icons.credit_card;
      case 'amex':
        return Icons.credit_card;
      default:
        return Icons.credit_card;
    }
  }
}