import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/addresses_provider.dart';
import '../widgets/address_card.dart';
import 'add_address_page.dart';
import '../../../home/presentation/widgets/futuristic_background.dart';

class AddressesPage extends StatefulWidget {
  const AddressesPage({super.key});

  @override
  State<AddressesPage> createState() => _AddressesPageState();
}

class _AddressesPageState extends State<AddressesPage> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _particleController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    // تأخير تحميل العناوين حتى اكتمال مرحلة البناء
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAddresses();
    });
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

  Future<void> _loadAddresses() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final addressesProvider = Provider.of<AddressesProvider>(context, listen: false);

    if (authProvider.isAuthenticated) {
      await addressesProvider.loadAddresses(authProvider.currentUser!.id);
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
                            'عناوين التوصيل',
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
                                builder: (context) => const AddAddressPage(),
                              ),
                            ).then((_) => _loadAddresses());
                          },
                          icon: Icon(Icons.add, color: AppTheme.neonBlue),
                        ),
                      ],
                    ),
                    SliverToBoxAdapter(
                      child: Consumer<AddressesProvider>(
                        builder: (context, addressesProvider, child) {
                          if (addressesProvider.isLoading) {
                            return Center(
                              child: CircularProgressIndicator(
                                color: AppTheme.neonBlue,
                              ),
                            );
                          }

                          if (addressesProvider.addresses.isEmpty) {
                            return AppTheme.glassMorphismContainer(
                              margin: const EdgeInsets.all(16),
                              padding: const EdgeInsets.all(40),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.location_on_outlined,
                                    size: 100,
                                    color: isDark ? AppTheme.darkNeonBlue : AppTheme.neonBlue,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'لا توجد عناوين محفوظة',
                                    style: GoogleFonts.orbitron(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? AppTheme.darkGlowingWhite : AppTheme.metallicGray,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'أضف عنوان جديد لتسهيل عملية التوصيل',
                                    style: GoogleFonts.cairo(
                                      color: isDark ? AppTheme.darkGlowingWhite.withOpacity(0.6) : AppTheme.metallicGray,

                                    ),
                                  ),
                                  const SizedBox(height: 32),
                                  AppTheme.neonButton(
                                    text: 'إضافة عنوان جديد',
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const AddAddressPage(),
                                        ),
                                      ).then((_) => _loadAddresses());
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
                            );
                          }

                          return RefreshIndicator(
                            onRefresh: _loadAddresses,
                            color: AppTheme.neonBlue,
                            child: ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              padding: const EdgeInsets.all(16),
                              itemCount: addressesProvider.addresses.length,
                              itemBuilder: (context, index) {
                                final address = addressesProvider.addresses[index];
                                return AddressCard(
                                  address: address,
                                  onEdit: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => AddAddressPage(address: address),
                                      ),
                                    ).then((_) => _loadAddresses());
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
                                                'حذف العنوان',
                                                style: GoogleFonts.orbitron(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                  color: isDark ? AppTheme.darkGlowingWhite : AppTheme.metallicGray,
                                                ),
                                              ),
                                              const SizedBox(height: 16),
                                              Text(
                                                'هل أنت متأكد من حذف هذا العنوان؟',
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
                                      await addressesProvider.deleteAddress(
                                        authProvider.currentUser!.id,
                                        address.id,
                                      );
                                    }
                                  },
                                  onSetDefault: () async {
                                    final authProvider = Provider.of<AuthProvider>(
                                      context,
                                      listen: false,
                                    );
                                    await addressesProvider.setDefaultAddress(
                                      authProvider.currentUser!.id,
                                      address.id,
                                    );
                                  },
                                );
                              },
                            ),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddAddressPage(),
            ),
          ).then((_) => _loadAddresses());
        },
        backgroundColor: AppTheme.neonBlue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}