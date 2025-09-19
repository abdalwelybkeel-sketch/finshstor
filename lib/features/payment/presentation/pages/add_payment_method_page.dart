import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/payment_provider.dart';
import '../../../home/presentation/widgets/futuristic_background.dart';

class AddPaymentMethodPage extends StatefulWidget {
  const AddPaymentMethodPage({super.key});

  @override
  State<AddPaymentMethodPage> createState() => _AddPaymentMethodPageState();
}

class _AddPaymentMethodPageState extends State<AddPaymentMethodPage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _holderNameController = TextEditingController();
  bool _isDefault = false;

  late AnimationController _animationController;
  late AnimationController _particleController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
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

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _holderNameController.dispose();
    _animationController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  String _getCardType(String cardNumber) {
    if (cardNumber.startsWith('4')) return 'Visa';
    if (cardNumber.startsWith('5')) return 'Mastercard';
    if (cardNumber.startsWith('3')) return 'Amex';
    return 'Unknown';
  }

  Future<void> _savePaymentMethod() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final paymentProvider = Provider.of<PaymentProvider>(context, listen: false);

    if (!authProvider.isAuthenticated) return;

    final cardNumber = _cardNumberController.text.replaceAll(' ', '');
    final expiry = _expiryController.text.split('/');

    final success = await paymentProvider.addPaymentMethod(
      userId: authProvider.currentUser!.id,
      cardType: _getCardType(cardNumber),
      last4: cardNumber.substring(cardNumber.length - 4),
      expiryMonth: expiry[0],
      expiryYear: expiry[1],
      holderName: _holderNameController.text.trim(),
      isDefault: _isDefault,
    );

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تم إضافة طريقة الدفع بنجاح',
            style: GoogleFonts.cairo(color: Colors.white),
          ),
          backgroundColor: AppTheme.neonBlue,
        ),
      );
    }
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
                            'إضافة بطاقة جديدة',
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
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              // Card Preview
                              AnimatedBuilder(
                                animation: _particleController,
                                builder: (context, child) {
                                  return AppTheme.glassMorphismContainer(
                                    padding: const EdgeInsets.all(24),
                                    margin: const EdgeInsets.only(bottom: 32),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'متجر الورود',
                                              style: GoogleFonts.cairo(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Icon(
                                              _getCardType(_cardNumberController.text) == 'Visa'
                                                  ? Icons.credit_card
                                                  : Icons.credit_card,
                                              color: Colors.white,
                                              size: 32,
                                            ),
                                          ],
                                        ),
                                        const Spacer(),
                                        Text(
                                          _cardNumberController.text.isEmpty
                                              ? '**** **** **** ****'
                                              : _formatCardNumber(_cardNumberController.text),
                                          style: GoogleFonts.orbitron(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 2,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              _holderNameController.text.isEmpty
                                                  ? 'اسم حامل البطاقة'
                                                  : _holderNameController.text.toUpperCase(),
                                              style: GoogleFonts.cairo(
                                                color: Colors.white,
                                                fontSize: 14,
                                              ),
                                            ),
                                            Text(
                                              _expiryController.text.isEmpty
                                                  ? 'MM/YY'
                                                  : _expiryController.text,
                                              style: GoogleFonts.cairo(
                                                color: Colors.white,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),

                              // Card Number Field
                              AppTheme.glassMorphismContainer(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                child: TextFormField(
                                  controller: _cardNumberController,
                                  decoration: InputDecoration(
                                    labelText: 'رقم البطاقة',
                                    hintText: '1234 5678 9012 3456',
                                    prefixIcon: Icon(Icons.credit_card, color: AppTheme.neonBlue),
                                    labelStyle: GoogleFonts.cairo(
                                      color: isDark ? AppTheme.darkGlowingWhite : AppTheme.metallicGray,
                                    ),
                                    border: InputBorder.none,
                                  ),
                                  keyboardType: TextInputType.number,
                                  onChanged: (value) {
                                    setState(() {});
                                  },
                                  validator: (value) {
                                    if (value?.isEmpty ?? true) {
                                      return 'يرجى إدخال رقم البطاقة';
                                    }
                                    final cleanValue = value!.replaceAll(' ', '');
                                    if (cleanValue.length < 16) {
                                      return 'رقم البطاقة غير صحيح';
                                    }
                                    return null;
                                  },
                                ),
                              ),

                              const SizedBox(height: 16),

                              // Expiry and CVV Row
                              Row(
                                children: [
                                  Expanded(
                                    child: AppTheme.glassMorphismContainer(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      child: TextFormField(
                                        controller: _expiryController,
                                        decoration: InputDecoration(
                                          labelText: 'تاريخ الانتهاء',
                                          hintText: 'MM/YY',
                                          prefixIcon: Icon(Icons.calendar_today, color: AppTheme.neonBlue),
                                          labelStyle: GoogleFonts.cairo(
                                            color: isDark ? AppTheme.darkGlowingWhite : AppTheme.metallicGray,
                                          ),
                                          border: InputBorder.none,
                                        ),
                                        keyboardType: TextInputType.number,
                                        onChanged: (value) {
                                          setState(() {});
                                        },
                                        validator: (value) {
                                          if (value?.isEmpty ?? true) {
                                            return 'يرجى إدخال تاريخ الانتهاء';
                                          }
                                          if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(value!)) {
                                            return 'تنسيق غير صحيح';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: AppTheme.glassMorphismContainer(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      child: TextFormField(
                                        controller: _cvvController,
                                        decoration: InputDecoration(
                                          labelText: 'CVV',
                                          hintText: '123',
                                          prefixIcon: Icon(Icons.security, color: AppTheme.neonBlue),
                                          labelStyle: GoogleFonts.cairo(
                                            color: isDark ? AppTheme.darkGlowingWhite : AppTheme.metallicGray,
                                          ),
                                          border: InputBorder.none,
                                        ),
                                        keyboardType: TextInputType.number,
                                        obscureText: true,
                                        validator: (value) {
                                          if (value?.isEmpty ?? true) {
                                            return 'يرجى إدخال CVV';
                                          }
                                          if (value!.length < 3) {
                                            return 'CVV غير صحيح';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 16),

                              // Holder Name Field
                              AppTheme.glassMorphismContainer(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                child: TextFormField(
                                  controller: _holderNameController,
                                  decoration: InputDecoration(
                                    labelText: 'اسم حامل البطاقة',
                                    prefixIcon: Icon(Icons.person_outline, color: AppTheme.neonBlue),
                                    labelStyle: GoogleFonts.cairo(
                                      color: isDark ? AppTheme.darkGlowingWhite : AppTheme.metallicGray,
                                    ),
                                    border: InputBorder.none,
                                  ),
                                  onChanged: (value) {
                                    setState(() {});
                                  },
                                  validator: (value) {
                                    if (value?.isEmpty ?? true) {
                                      return 'يرجى إدخال اسم حامل البطاقة';
                                    }
                                    return null;
                                  },
                                ),
                              ),

                              const SizedBox(height: 24),

                              // Default Payment Method Switch
                              AppTheme.glassMorphismContainer(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.payment,
                                      color: AppTheme.neonBlue,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'طريقة الدفع الافتراضية',
                                            style: GoogleFonts.cairo(
                                              fontWeight: FontWeight.w600,
                                              color: isDark ? AppTheme.darkGlowingWhite : AppTheme.metallicGray,
                                            ),
                                          ),
                                          Text(
                                            'سيتم استخدام هذه البطاقة افتراضياً في الطلبات',
                                            style: GoogleFonts.cairo(
                                              color: isDark
                                                  ? AppTheme.darkGlowingWhite.withOpacity(0.6)
                                                  : AppTheme.metallicGray.withOpacity(0.6),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Switch(
                                      value: _isDefault,
                                      onChanged: (value) {
                                        setState(() {
                                          _isDefault = value;
                                        });
                                      },
                                      activeColor: AppTheme.neonBlue,
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 32),

                              // Save Button
                              Consumer<PaymentProvider>(
                                builder: (context, paymentProvider, child) {
                                  return SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: paymentProvider.isLoading ? null : _savePaymentMethod,
                                      child: paymentProvider.isLoading
                                          ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            Colors.white,
                                          ),
                                        ),
                                      )
                                          : const Text('إضافة البطاقة'),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 120),
                            ],
                          ),
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

  String _formatCardNumber(String cardNumber) {
    final cleanNumber = cardNumber.replaceAll(' ', '');
    final buffer = StringBuffer();
    for (int i = 0; i < cleanNumber.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(cleanNumber[i]);
    }
    return buffer.toString();
  }
}