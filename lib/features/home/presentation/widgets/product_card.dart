import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

import '../../../../core/models/product_model.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class ProductCard extends StatefulWidget {
  final ProductModel product;
  final VoidCallback onTap;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard>
    with TickerProviderStateMixin {
  late AnimationController _hoverController;
  late AnimationController _glowController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;
  late Animation<double> _glowAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _glowController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.03,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeInOut,
    ));

    _elevationAnimation = Tween<double>(
      begin: 0.0,
      end: 20.0,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeInOut,
    ));

    _glowAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _hoverController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) {
        setState(() => _isHovered = true);
        _hoverController.forward();
      },
      onTapUp: (_) {
        setState(() => _isHovered = false);
        _hoverController.reverse();
      },
      onTapCancel: () {
        setState(() => _isHovered = false);
        _hoverController.reverse();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: AnimatedBuilder(
              animation: _glowAnimation,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withOpacity(isDark ? 0.15 : 0.6),
                        Colors.white.withOpacity(isDark ? 0.05 : 0.3),
                      ],
                    ),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (isDark ? AppTheme.darkNeonBlue : AppTheme.neonBlue)
                            .withOpacity(0.2 * _glowAnimation.value),
                        blurRadius: 20 + _elevationAnimation.value,
                        spreadRadius: 0,
                        offset: Offset(0, 8 + _elevationAnimation.value / 2),
                      ),
                      BoxShadow(
                        color: (isDark ? AppTheme.darkNeonPurple : AppTheme.neonPurple)
                            .withOpacity(0.1 * _glowAnimation.value),
                        blurRadius: 40 + _elevationAnimation.value,
                        spreadRadius: 0,
                        offset: Offset(0, 16 + _elevationAnimation.value),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: isDark
                              ? [
                                  AppTheme.darkMetallicGray.withOpacity(0.8),
                                  AppTheme.ultraDarkSpace.withOpacity(0.9),
                                ]
                              : [
                                  Colors.white.withOpacity(0.9),
                                  Colors.white.withOpacity(0.7),
                                ],
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Product Image
                          Expanded(
                            flex: 3,
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(24),
                                  ),
                                  child: Hero(
                                    tag: 'product_${widget.product.id}',
                                    child: CachedNetworkImage(
                                      imageUrl: widget.product.images.isNotEmpty 
                                          ? widget.product.images.first 
                                          : 'https://images.pexels.com/photos/1070850/pexels-photo-1070850.jpeg',
                                      width: double.infinity,
                                      height: double.infinity,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              AppTheme.neonBlue.withOpacity(0.3),
                                              AppTheme.neonBlue.withOpacity(0.1),
                                            ],
                                          ),
                                        ),
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            color: AppTheme.neonBlue,
                                            strokeWidth: 2,
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
                                              AppTheme.neonBlue.withOpacity(0.1),
                                            ],
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.local_florist_rounded,
                                          color: AppTheme.neonBlue,
                                          size: 40,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                
                                // Holographic Overlay
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(24),
                                    ),
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        AppTheme.neonBlue.withOpacity(0.2),
                                        Colors.transparent,
                                        AppTheme.neonBlue.withOpacity(0.1),
                                      ],
                                    ),
                                  ),
                                ),
                                
                                // Discount Badge
                                if (widget.product.hasDiscount)
                                  Positioned(
                                    top: 12,
                                    right: 12,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [Color(0xFFFF4757), Color(0xFFFF3742)],
                                        ),
                                        borderRadius: BorderRadius.circular(15),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFFFF4757).withOpacity(0.5),
                                            blurRadius: 10,
                                            spreadRadius: 0,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Text(
                                        '${widget.product.discount!.toInt()}%',
                                        style: GoogleFonts.orbitron(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                  ),
                                
                                // Favorite Button
                                Positioned(
                                  top: 12,
                                  left: 12,
                                  child: Container(
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
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 10,
                                          spreadRadius: 0,
                                          offset: const Offset(0, 4),
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
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // Product Info
                          Expanded(
                            flex: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Product Name
                                  Text(
                                    widget.product.name,
                                    style: GoogleFonts.cairo(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: isDark 
                                          ? AppTheme.darkGlowingWhite 
                                          : AppTheme.metallicGray,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  
                                  const SizedBox(height: 8),
                                  
                                  // Rating
                                  Row(
                                    children: [
                                      ...List.generate(5, (index) {
                                        return Icon(
                                          index < widget.product.rating.floor()
                                              ? Icons.star_rounded
                                              : Icons.star_border_rounded,
                                          color: AppTheme.holographicGreen,
                                          size: 16,
                                        );
                                      }),
                                      const SizedBox(width: 6),
                                      Text(
                                        '(${widget.product.reviewCount})',
                                        style: GoogleFonts.cairo(
                                          fontSize: 12,
                                          color: (isDark 
                                              ? AppTheme.darkGlowingWhite 
                                              : AppTheme.metallicGray).withOpacity(0.6),
                                        ),
                                      ),
                                    ],
                                  ),
                                  
                                  const Spacer(),
                                  
                                  // Price and Add to Cart
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          if (widget.product.hasDiscount)
                                            Text(
                                              '${widget.product.price.toInt()} ر.س',
                                              style: GoogleFonts.cairo(
                                                fontSize: 12,
                                                decoration: TextDecoration.lineThrough,
                                                color: (isDark 
                                                    ? AppTheme.darkGlowingWhite 
                                                    : AppTheme.metallicGray).withOpacity(0.5),
                                              ),
                                            ),
                                          Text(
                                            '${widget.product.finalPrice.toInt()} ر.س',
                                            style: GoogleFonts.orbitron(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: isDark ? AppTheme.darkNeonBlue : AppTheme.neonBlue,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                      
                                      Consumer2<CartProvider, AuthProvider>(
                                        builder: (context, cartProvider, authProvider, child) {
                                          return GestureDetector(
                                            onTap: () async {
                                              if (!authProvider.isAuthenticated) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: const Text('يرجى تسجيل الدخول أولاً'),
                                                    backgroundColor: isDark 
                                                        ? AppTheme.darkNeonPink 
                                                        : AppTheme.neonPink,
                                                  ),
                                                );
                                                return;
                                              }
                                              
                                              await cartProvider.addToCart(
                                                userId: authProvider.currentUser!.id,
                                                productId: widget.product.id,
                                                productName: widget.product.name,
                                                productImage: widget.product.images.isNotEmpty 
                                                    ? widget.product.images.first 
                                                    : '',
                                                price: widget.product.finalPrice,
                                                quantity: 1,
                                              );
                                              
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text('تم إضافة ${widget.product.name} للسلة'),
                                                  backgroundColor: isDark 
                                                      ? AppTheme.darkNeonBlue 
                                                      : AppTheme.neonBlue,
                                                ),
                                              );
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                  colors: isDark
                                                      ? [AppTheme.darkNeonBlue, AppTheme.darkNeonPurple]
                                                      : [AppTheme.neonBlue, AppTheme.neonPurple],
                                                ),
                                                borderRadius: BorderRadius.circular(12),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: (isDark ? AppTheme.darkNeonBlue : AppTheme.neonBlue)
                                                        .withOpacity(0.5),
                                                    blurRadius: 15,
                                                    spreadRadius: 0,
                                                    offset: const Offset(0, 6),
                                                  ),
                                                ],
                                              ),
                                              child: const Icon(
                                                Icons.add_shopping_cart_rounded,
                                                color: Colors.white,
                                                size: 20,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}