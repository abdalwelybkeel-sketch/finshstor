import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'dart:math' as math;

import '../../../../core/config/app_config.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../products/presentation/providers/products_provider.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../widgets/category_card.dart';
import '../widgets/product_card.dart';
import '../widgets/home_app_bar.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/futuristic_background.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _particleController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final List<String> _bannerImages = [
    'https://images.pexels.com/photos/1070850/pexels-photo-1070850.jpeg',
    'https://images.pexels.com/photos/1022385/pexels-photo-1022385.jpeg',
    'https://images.pexels.com/photos/1181534/pexels-photo-1181534.jpeg',
  ];

  final List<Map<String, dynamic>> _categories = [
    {
      'name': 'باقات الحب',
      'icon': Icons.favorite_rounded,
      'color': AppTheme.neonPink,
      'image': 'https://images.pexels.com/photos/1070850/pexels-photo-1070850.jpeg',
    },
    {
      'name': 'باقات الزفاف',
      'icon': Icons.celebration_rounded,
      'color': AppTheme.neonPurple,
      'image': 'https://images.pexels.com/photos/1022385/pexels-photo-1022385.jpeg',
    },
    {
      'name': 'باقات التخرج',
      'icon': Icons.school_rounded,
      'color': AppTheme.holographicGreen,
      'image': 'https://images.pexels.com/photos/1181534/pexels-photo-1181534.jpeg',
    },
    {
      'name': 'باقات المناسبات',
      'icon': Icons.cake_rounded,
      'color': AppTheme.neonBlue,
      'image': 'https://images.pexels.com/photos/1070850/pexels-photo-1070850.jpeg',
    },
  ];

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadData();
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

  Future<void> _loadData() async {
    final productsProvider = Provider.of<ProductsProvider>(context, listen: false);
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await productsProvider.loadProducts();
    });
    
    if (authProvider.isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await cartProvider.loadCart(authProvider.currentUser!.id);
      });
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
          // Futuristic Animated Background
          const FuturisticBackground(),
          
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: CustomScrollView(
                  slivers: [
                    // App Bar
                    SliverToBoxAdapter(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              (isDark ? AppTheme.darkNeonBlue : AppTheme.neonBlue).withOpacity(0.1),
                              (isDark ? AppTheme.darkNeonPurple : AppTheme.neonPurple).withOpacity(0.1),
                            ],
                          ),
                        ),
                        child: const HomeAppBar(),
                      ),
                    ),

                    // Search Bar
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                        child: SearchBarWidget(
                          onSearch: (query) {
                            Navigator.pushNamed(
                              context,
                              AppConfig.searchRoute,
                              arguments: {'search': query},
                            );
                          },
                        ),
                      ),
                    ),

                    // Holographic Banner Carousel
                    SliverToBoxAdapter(
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                        child: CarouselSlider(
                          options: CarouselOptions(
                            height: 220,
                            autoPlay: true,
                            enlargeCenterPage: true,
                            viewportFraction: 0.9,
                            autoPlayInterval: const Duration(seconds: 4),
                            autoPlayCurve: Curves.easeInOutCubic,
                          ),
                          items: _bannerImages.asMap().entries.map((entry) {
                            final index = entry.key;
                            final image = entry.value;
                            
                            return AnimatedBuilder(
                              animation: _particleController,
                              builder: (context, child) {
                                return Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 8),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(24),
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Colors.white.withOpacity(0.2),
                                        Colors.white.withOpacity(0.1),
                                      ],
                                    ),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.3),
                                      width: 1.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: (isDark ? AppTheme.darkNeonBlue : AppTheme.neonBlue)
                                            .withOpacity(0.3),
                                        blurRadius: 30,
                                        spreadRadius: 0,
                                        offset: const Offset(0, 15),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(24),
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        // Background Image
                                        Image.network(
                                          image,
                                          fit: BoxFit.cover,
                                        ),
                                        
                                        // Holographic Overlay
                                        Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: [
                                                (isDark ? AppTheme.darkNeonBlue : AppTheme.neonBlue)
                                                    .withOpacity(0.3),
                                                (isDark ? AppTheme.darkNeonPurple : AppTheme.neonPurple)
                                                    .withOpacity(0.2),
                                                Colors.transparent,
                                              ],
                                            ),
                                          ),
                                        ),
                                        
                                        // Content
                                        Positioned(
                                          bottom: 30,
                                          right: 30,
                                          left: 30,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'عروض خاصة',
                                                style: GoogleFonts.orbitron(
                                                  color: Colors.white,
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.bold,
                                                  letterSpacing: 1.5,
                                                  shadows: [
                                                    Shadow(
                                                      color: (isDark ? AppTheme.darkNeonBlue : AppTheme.neonBlue)
                                                          .withOpacity(0.8),
                                                      blurRadius: 10,
                                                      offset: const Offset(0, 2),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                'على باقات الورود المميزة',
                                                style: GoogleFonts.cairo(
                                                  color: Colors.white.withOpacity(0.9),
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          }).toList(),
                        ),
                      ),
                    ),

                    // Categories Section
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'الفئات',
                              style: GoogleFonts.orbitron(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppTheme.darkGlowingWhite : AppTheme.metallicGray,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              height: 140,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                padding: EdgeInsets.zero,
                                itemCount: _categories.length,
                                itemBuilder: (context, index) {
                                  final category = _categories[index];
                                  return CategoryCard(
                                    name: category['name'],
                                    icon: category['icon'],
                                    color: category['color'],
                                    image: category['image'],
                                    onTap: () {
                                      Navigator.pushNamed(
                                        context,
                                        AppConfig.productsListRoute,
                                        arguments: {'category': category['name']},
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Featured Products
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'المنتجات المميزة',
                              style: GoogleFonts.orbitron(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppTheme.darkGlowingWhite : AppTheme.metallicGray,
                                letterSpacing: 1.2,
                              ),
                            ),
                            AppTheme.neonButton(
                              text: 'عرض الكل',
                              onPressed: () {
                                Navigator.pushNamed(context, AppConfig.productsListRoute);
                              },
                              color: isDark ? AppTheme.darkNeonPurple : AppTheme.neonPurple,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                              textStyle: GoogleFonts.cairo(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Products Grid
                    Consumer<ProductsProvider>(
                      builder: (context, productsProvider, child) {
                        if (productsProvider.isLoading) {
                          return SliverToBoxAdapter(
                            child: Container(
                              height: 200,
                              margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                              child: AppTheme.glassMorphismContainer(
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 50,
                                        height: 50,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 3,
                                          valueColor: AlwaysStoppedAnimation(
                                            isDark ? AppTheme.darkNeonBlue : AppTheme.neonBlue,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'جاري تحميل المنتجات...',
                                        style: GoogleFonts.cairo(
                                          color: isDark 
                                              ? AppTheme.darkGlowingWhite 
                                              : AppTheme.metallicGray,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }

                        final featuredProducts = productsProvider.products
                            .where((product) => product.isFeatured)
                            .take(6)
                            .toList();

                        if (featuredProducts.isEmpty) {
                          return SliverToBoxAdapter(
                            child: Container(
                              margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                              child: AppTheme.glassMorphismContainer(
                                padding: const EdgeInsets.all(40),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.local_florist_rounded,
                                      size: 80,
                                      color: (isDark ? AppTheme.darkNeonBlue : AppTheme.neonBlue)
                                          .withOpacity(0.5),
                                    ),
                                    const SizedBox(height: 20),
                                    Text(
                                      'لا توجد منتجات مميزة حالياً',
                                      style: GoogleFonts.cairo(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: isDark 
                                            ? AppTheme.darkGlowingWhite 
                                            : AppTheme.metallicGray,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }

                        return SliverPadding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                          sliver: SliverGrid(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.75,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final product = featuredProducts[index];
                                return ProductCard(
                                  product: product,
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      AppConfig.productDetailsRoute,
                                      arguments: {'productId': product.id},
                                    );
                                  },
                                );
                              },
                              childCount: featuredProducts.length,
                            ),
                          ),
                        );
                      },
                    ),

                    // Bottom Spacing
                    const SliverToBoxAdapter(
                      child: SizedBox(height: 120),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      
      // Futuristic Floating Action Button
      floatingActionButton: Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          if (cartProvider.itemCount == 0) return const SizedBox.shrink();
          
          return AnimatedBuilder(
            animation: _particleController,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [AppTheme.darkNeonPink, AppTheme.darkNeonPurple]
                        : [AppTheme.neonPink, AppTheme.neonPurple],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (isDark ? AppTheme.darkNeonPink : AppTheme.neonPink)
                          .withOpacity(0.5),
                      blurRadius: 20,
                      spreadRadius: 0,
                      offset: const Offset(0, 10),
                    ),
                    BoxShadow(
                      color: (isDark ? AppTheme.darkNeonPink : AppTheme.neonPink)
                          .withOpacity(0.3 + 0.2 * math.sin(_particleController.value * 2 * math.pi)),
                      blurRadius: 40,
                      spreadRadius: 0,
                      offset: const Offset(0, 20),
                    ),
                  ],
                ),
                child: FloatingActionButton.extended(
                  onPressed: () {
                    // Switch to cart tab instead of navigating
                    final navigationProvider = Provider.of<NavigationProvider>(context, listen: false);
                    navigationProvider.setIndex(1);
                  },
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  icon: const Icon(
                    Icons.shopping_cart_rounded,
                    color: Colors.white,
                  ),
                  label: Text(
                    '${cartProvider.itemCount}',
                    style: GoogleFonts.orbitron(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}