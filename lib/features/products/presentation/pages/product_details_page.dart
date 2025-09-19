import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

import '../../../../core/models/product_model.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../providers/products_provider.dart';
import '../widgets/product_options_sheet.dart';
import '../../../home/presentation/widgets/futuristic_background.dart';

class ProductDetailsPage extends StatefulWidget {
  final String productId;

  const ProductDetailsPage({
    super.key,
    required this.productId,
  });

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage>
    with TickerProviderStateMixin {
  ProductModel? _product;
  bool _isLoading = true;
  int _currentImageIndex = 0;

  late AnimationController _animationController;
  late AnimationController _glowController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProduct();
    });
  }

  void _initAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _glowController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _glowAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  Future<void> _loadProduct() async {
    final productsProvider = Provider.of<ProductsProvider>(context, listen: false);
    final product = await productsProvider.getProduct(widget.productId);

    if (mounted) {
      setState(() {
        _product = product;
        _isLoading = false;
      });
    }
  }

  void _showOptionsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ProductOptionsSheet(
        product: _product!,
        onAddToCart: (options) async {
          final authProvider = Provider.of<AuthProvider>(context, listen: false);
          final cartProvider = Provider.of<CartProvider>(context, listen: false);

          if (!authProvider.isAuthenticated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'يرجى تسجيل الدخول أولاً',
                  style: GoogleFonts.cairo(color: Colors.white),
                ),
                backgroundColor: AppTheme.neonPink,
              ),
            );
            return;
          }

          await cartProvider.addToCart(
            userId: authProvider.currentUser!.id,
            productId: _product!.id,
            productName: _product!.name,
            productImage: _product!.images.isNotEmpty ? _product!.images.first : '',
            price: _product!.finalPrice,
            quantity: options['quantity'] ?? 1,
            selectedSize: options['size'],
            selectedColor: options['color'],
            giftWrap: options['giftWrap'],
            greetingCard: options['greetingCard'],
            vendorId: _product!.vendorId,
          );
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'تم إضافة ${_product!.name} للسلة',
                style: GoogleFonts.cairo(color: Colors.white),
              ),
              backgroundColor: AppTheme.neonBlue,
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_isLoading) {
      return Scaffold(
        body: Stack(
          children: [
            const FuturisticBackground(),
            SafeArea(
              child: Center(
                child: AppTheme.glassMorphismContainer(
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
                        'جاري تحميل المنتج...',
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
            ),
          ],
        ),
      );
    }

    if (_product == null) {
      return Scaffold(
        body: Stack(
          children: [
            const FuturisticBackground(),
            SafeArea(
              child: Center(
                child: AppTheme.glassMorphismContainer(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        size: 80,
                        color: isDark ? AppTheme.darkNeonPink : AppTheme.neonPink,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'المنتج غير موجود',
                        style: GoogleFonts.orbitron(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppTheme.darkGlowingWhite : AppTheme.metallicGray,
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
                    // Futuristic App Bar with Image
                    SliverAppBar(
                      expandedHeight: 450,
                      pinned: true,
                      backgroundColor: Colors.transparent,
                      flexibleSpace: FlexibleSpaceBar(
                        background: Stack(
                          fit: StackFit.expand,
                          children: [
                            if (_product!.images.isNotEmpty)
                              CarouselSlider(
                                options: CarouselOptions(
                                  height: double.infinity,
                                  viewportFraction: 1.0,
                                  onPageChanged: (index, reason) {
                                    if (mounted) {
                                      setState(() {
                                        _currentImageIndex = index;
                                      });
                                    }
                                  },
                                ),
                                items: _product!.images.map((image) {
                                  return Hero(
                                    tag: 'product_${_product!.id}',
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        CachedNetworkImage(
                                          imageUrl: image,
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          placeholder: (context, url) => Container(
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                                colors: [
                                                  AppTheme.neonBlue.withOpacity(0.3),
                                                  AppTheme.neonPurple.withOpacity(0.3),
                                                ],
                                              ),
                                            ),
                                            child: Center(
                                              child: CircularProgressIndicator(
                                                color: isDark ? AppTheme.darkNeonBlue : AppTheme.neonBlue,
                                              ),
                                            ),
                                          ),
                                          errorWidget: (context, url, error) => Container(
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                                colors: [
                                                  AppTheme.neonBlue.withOpacity(0.3),
                                                  AppTheme.neonPurple.withOpacity(0.3),
                                                ],
                                              ),
                                            ),
                                            child: Icon(
                                              Icons.local_florist_rounded,
                                              color: isDark ? AppTheme.darkNeonBlue : AppTheme.neonBlue,
                                              size: 80,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                              colors: [
                                                Colors.transparent,
                                                Colors.black.withOpacity(0.3),
                                                Colors.black.withOpacity(0.7),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            if (_product!.images.length > 1)
                              Positioned(
                                bottom: 100,
                                left: 0,
                                right: 0,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: _product!.images.asMap().entries.map((entry) {
                                    return AnimatedContainer(
                                      duration: const Duration(milliseconds: 300),
                                      width: _currentImageIndex == entry.key ? 30 : 10,
                                      height: 10,
                                      margin: const EdgeInsets.symmetric(horizontal: 4),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        gradient: _currentImageIndex == entry.key
                                            ? LinearGradient(
                                          colors: isDark
                                              ? [AppTheme.darkNeonBlue, AppTheme.darkNeonPurple]
                                              : [AppTheme.neonBlue, AppTheme.neonPurple],
                                        )
                                            : null,
                                        color: _currentImageIndex == entry.key
                                            ? null
                                            : Colors.white.withOpacity(0.5),
                                        boxShadow: _currentImageIndex == entry.key
                                            ? [
                                          BoxShadow(
                                            color: (isDark ? AppTheme.darkNeonBlue : AppTheme.neonBlue)
                                                .withOpacity(0.5),
                                            blurRadius: 10,
                                            spreadRadius: 0,
                                            offset: const Offset(0, 4),
                                          ),
                                        ]
                                            : null,
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            if (_product!.hasDiscount)
                              Positioned(
                                top: 120,
                                right: 20,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [AppTheme.neonPink, Color(0xFFFF3742)],
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppTheme.neonPink.withOpacity(0.5),
                                        blurRadius: 15,
                                        spreadRadius: 0,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    'خصم ${_product!.discount!.toInt()}%',
                                    style: GoogleFonts.orbitron(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      actions: [
                        AnimatedBuilder(
                          animation: _glowAnimation,
                          builder: (context, child) {
                            return Container(
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.white.withOpacity(0.3),
                                    Colors.white.withOpacity(0.1),
                                  ],
                                ),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: (isDark ? AppTheme.darkNeonPink : AppTheme.neonPink)
                                        .withOpacity(0.3 * _glowAnimation.value),
                                    blurRadius: 15,
                                    spreadRadius: 0,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: IconButton(
                                onPressed: () {
                                  // TODO: Add to favorites
                                },
                                icon: Icon(
                                  Icons.favorite_border_rounded,
                                  color: isDark ? AppTheme.darkNeonPink : AppTheme.neonPink,
                                  size: 24,
                                ),
                              ),
                            );
                          },
                        ),
                        Container(
                          margin: const EdgeInsets.only(right: 16),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withOpacity(0.3),
                                Colors.white.withOpacity(0.1),
                              ],
                            ),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: IconButton(
                            onPressed: () {
                              // TODO: Share product
                            },
                            icon: const Icon(
                              Icons.share_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SliverToBoxAdapter(
                      child: AppTheme.glassMorphismContainer(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Product Name and Rating
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    _product!.name,
                                    style: GoogleFonts.orbitron(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? AppTheme.darkGlowingWhite : AppTheme.metallicGray,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                AppTheme.glassMorphismContainer(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.star_rounded,
                                            color: AppTheme.holographicGreen,
                                            size: 24,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            _product!.rating.toStringAsFixed(1),
                                            style: GoogleFonts.orbitron(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: AppTheme.holographicGreen,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${_product!.reviewCount} تقييم',
                                        style: GoogleFonts.cairo(
                                          fontSize: 12,
                                          color: AppTheme.holographicGreen,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            // Price
                            AnimatedBuilder(
                              animation: _glowAnimation,
                              builder: (context, child) {
                                return AppTheme.glassMorphismContainer(
                                  padding: const EdgeInsets.all(20),
                                  child: Row(
                                    children: [
                                      if (_product!.hasDiscount) ...[
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'السعر الأصلي',
                                              style: GoogleFonts.cairo(
                                                fontSize: 12,
                                                color: (isDark ? AppTheme.darkGlowingWhite : AppTheme.metallicGray)
                                                    .withOpacity(0.6),
                                              ),
                                            ),
                                            Text(
                                              '${_product!.price.toInt()} ر.س',
                                              style: GoogleFonts.orbitron(
                                                fontSize: 16,
                                                decoration: TextDecoration.lineThrough,
                                                color: (isDark ? AppTheme.darkGlowingWhite : AppTheme.metallicGray)
                                                    .withOpacity(0.5),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(width: 20),
                                      ],
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              _product!.hasDiscount ? 'السعر بعد الخصم' : 'السعر',
                                              style: GoogleFonts.cairo(
                                                fontSize: 14,
                                                color: isDark ? AppTheme.darkNeonBlue : AppTheme.neonBlue,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            Text(
                                              '${_product!.finalPrice.toInt()} ر.س',
                                              style: GoogleFonts.orbitron(
                                                fontSize: 32,
                                                fontWeight: FontWeight.bold,
                                                color: isDark ? AppTheme.darkNeonBlue : AppTheme.neonBlue,
                                                letterSpacing: 1.5,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 24),
                            // Stock Status
                            AppTheme.glassMorphismContainer(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _product!.isInStock ? Icons.check_circle_rounded : Icons.cancel_rounded,
                                    color: _product!.isInStock ? AppTheme.holographicGreen : AppTheme.neonPink,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _product!.isInStock
                                        ? 'متوفر (${_product!.stock} قطعة)'
                                        : 'غير متوفر',
                                    style: GoogleFonts.orbitron(
                                      color: _product!.isInStock ? AppTheme.holographicGreen : AppTheme.neonPink,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 32),
                            // Description
                            Text(
                              'الوصف',
                              style: GoogleFonts.orbitron(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppTheme.darkGlowingWhite : AppTheme.metallicGray,
                                letterSpacing: 1.0,
                              ),
                            ),
                            const SizedBox(height: 16),
                            AppTheme.glassMorphismContainer(
                              padding: const EdgeInsets.all(20),
                              child: Text(
                                _product!.description,
                                style: GoogleFonts.cairo(
                                  fontSize: 16,
                                  height: 1.8,
                                  color: isDark ? AppTheme.darkGlowingWhite : AppTheme.metallicGray,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Sizes (if available)
                            if (_product!.sizes.isNotEmpty) ...[
                              Text(
                                'الأحجام المتاحة',
                                style: GoogleFonts.orbitron(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? AppTheme.darkGlowingWhite : AppTheme.metallicGray,
                                  letterSpacing: 0.8,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 12,
                                runSpacing: 8,
                                children: _product!.sizes.map((size) {
                                  return AppTheme.glassMorphismContainer(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    child: Text(
                                      size,
                                      style: GoogleFonts.cairo(
                                        color: isDark ? AppTheme.darkNeonPurple : AppTheme.neonPurple,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 24),
                            ],
                            // Colors (if available)
                            if (_product!.colors.isNotEmpty) ...[
                              Text(
                                'الألوان المتاحة',
                                style: GoogleFonts.orbitron(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? AppTheme.darkGlowingWhite : AppTheme.metallicGray,
                                  letterSpacing: 0.8,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 12,
                                runSpacing: 8,
                                children: _product!.colors.map((color) {
                                  return AppTheme.glassMorphismContainer(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    child: Text(
                                      color,
                                      style: GoogleFonts.cairo(
                                        color: isDark ? AppTheme.darkNeonPink : AppTheme.neonPink,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 24),
                            ],
                            // Vendor Info
                            AppTheme.glassMorphismContainer(
                              padding: const EdgeInsets.all(20),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: isDark
                                            ? [AppTheme.darkNeonPurple, AppTheme.darkNeonPink]
                                            : [AppTheme.neonPurple, AppTheme.neonPink],
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: (isDark ? AppTheme.darkNeonPurple : AppTheme.neonPurple)
                                              .withOpacity(0.5),
                                          blurRadius: 15,
                                          spreadRadius: 0,
                                          offset: const Offset(0, 6),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.store_rounded,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'البائع',
                                          style: GoogleFonts.cairo(
                                            fontSize: 12,
                                            color: (isDark ? AppTheme.darkGlowingWhite : AppTheme.metallicGray)
                                                .withOpacity(0.7),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _product!.vendorName,
                                          style: GoogleFonts.orbitron(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: isDark ? AppTheme.darkGlowingWhite : AppTheme.metallicGray,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  AppTheme.neonButton(
                                    text: 'عرض المتجر',
                                    onPressed: () {
                                      // TODO: View vendor profile
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
                            const SizedBox(height: 120),
                          ],
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
      bottomNavigationBar: AppTheme.glassMorphismContainer(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(isDark ? 0.1 : 0.6),
                      Colors.white.withOpacity(isDark ? 0.05 : 0.3),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: (isDark ? AppTheme.darkNeonBlue : AppTheme.neonBlue)
                        .withOpacity(0.5),
                    width: 1.5,
                  ),
                ),
                child: ElevatedButton(
                  onPressed: _product!.isInStock ? _showOptionsSheet : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'إضافة للسلة',
                    style: GoogleFonts.orbitron(
                      color: isDark ? AppTheme.darkNeonBlue : AppTheme.neonBlue,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: AppTheme.neonButton(
                text: 'اشتري الآن',
                onPressed: _product!.isInStock ? () {
                  // TODO: Buy now
                } : () {},
                color: isDark ? AppTheme.darkNeonPink : AppTheme.neonPink,
                padding: const EdgeInsets.symmetric(vertical: 18),
                textStyle: GoogleFonts.orbitron(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}