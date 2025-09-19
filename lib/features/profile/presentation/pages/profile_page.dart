import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

import '../../../../core/config/app_config.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../home/presentation/widgets/futuristic_background.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_menu_item.dart';


class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with TickerProviderStateMixin {
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
    _animationController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
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
                            l10n.profile,
                            style: GoogleFonts.orbitron(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppTheme.darkGlowingWhite : AppTheme.metallicGray,
                            ),
                          ),
                        ),
                      ),
                      actions: [
                        Consumer<ThemeProvider>(
                          builder: (context, themeProvider, child) {
                            return AnimatedBuilder(
                              animation: _particleController,
                              builder: (context, child) {
                                return Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: isDark
                                          ? [AppTheme.darkNeonBlue, AppTheme.darkNeonPurple]
                                          : [AppTheme.neonBlue, AppTheme.neonPurple],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppTheme.neonBlue.withOpacity(0.3 + 0.2 * math.sin(_particleController.value * 2 * math.pi)),
                                        blurRadius: 20,
                                        spreadRadius: 0,
                                      ),
                                    ],
                                  ),
                                  child: IconButton(
                                    onPressed: themeProvider.toggleTheme,
                                    icon: Icon(
                                      themeProvider.isDarkMode
                                          ? Icons.light_mode
                                          : Icons.dark_mode,
                                      color: Colors.white,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),

                    // Main Content
                    SliverToBoxAdapter(
                      child: Consumer<AuthProvider>(
                        builder: (context, authProvider, child) {
                          if (!authProvider.isAuthenticated) {
                            return AppTheme.glassMorphismContainer(
                              margin: const EdgeInsets.all(20),
                              padding: const EdgeInsets.all(40),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.person_outline,
                                    size: 100,
                                    color: isDark ? AppTheme.darkNeonBlue : AppTheme.neonBlue,
                                  ),
                                  const SizedBox(height: 24),
                                  Text(
                                    'يرجى تسجيل الدخول',
                                    style: GoogleFonts.orbitron(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? AppTheme.darkGlowingWhite : AppTheme.metallicGray,
                                    ),
                                  ),
                                  const SizedBox(height: 32),
                                  AppTheme.neonButton(
                                    text: 'تسجيل الدخول',
                                    onPressed: () {
                                      Navigator.pushReplacementNamed(context, AppConfig.loginRoute);
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

                          return Column(
                            children: [
                              // Profile Header
                              ProfileHeader(user: authProvider.currentUser!),

                              const SizedBox(height: 24),

                              // Menu Items
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Column(
                                  children: [
                                    // Account Section
                                    _buildSectionTitle('الحساب', theme),
                                    ProfileMenuItem(
                                      icon: Icons.person_outline,
                                      title: 'تعديل الملف الشخصي',
                                      onTap: () {
                                        Navigator.pushNamed(context, '/edit-profile');
                                      },
                                    ),
                                    ProfileMenuItem(
                                      icon: Icons.location_on_outlined,
                                      title: l10n.addresses,
                                      onTap: () {
                                        Navigator.pushNamed(context, '/addresses');
                                      },
                                    ),
                                    ProfileMenuItem(
                                      icon: Icons.payment_outlined,
                                      title: l10n.paymentMethods,
                                      onTap: () {
                                        Navigator.pushNamed(context, '/payment-methods');
                                      },
                                    ),

                                    const SizedBox(height: 24),

                                    // Orders Section
                                    _buildSectionTitle('الطلبات', theme),
                                    ProfileMenuItem(
                                      icon: Icons.receipt_long_outlined,
                                      title: l10n.orders,
                                      onTap: () {
                                        Navigator.pushNamed(context, AppConfig.ordersRoute);
                                      },
                                    ),
                                    ProfileMenuItem(
                                      icon: Icons.favorite_outline,
                                      title: 'المفضلة',
                                      onTap: () {
                                        Navigator.pushNamed(context, '/favorites');
                                      },
                                    ),

                                    const SizedBox(height: 24),

                                    // Settings Section
                                    _buildSectionTitle(l10n.settings, theme),
                                    ProfileMenuItem(
                                      icon: Icons.notifications_outlined,
                                      title: l10n.notifications,
                                      onTap: () {
                                        Navigator.pushNamed(context, AppConfig.notificationSettingsRoute);
                                      },
                                    ),
                                    Consumer<LocaleProvider>(
                                      builder: (context, localeProvider, child) {
                                        return ProfileMenuItem(
                                          icon: Icons.language_outlined,
                                          title: l10n.language,
                                          subtitle: localeProvider.isArabic ? 'العربية' : 'English',
                                          onTap: () {
                                            localeProvider.toggleLocale();
                                          },
                                        );
                                      },
                                    ),
                                    ProfileMenuItem(
                                      icon: Icons.help_outline,
                                      title: 'المساعدة والدعم',
                                      onTap: () {
                                        Navigator.pushNamed(context, AppConfig.helpRoute);
                                      },
                                    ),
                                    ProfileMenuItem(
                                      icon: Icons.info_outline,
                                      title: 'حول التطبيق',
                                      onTap: () {
                                        Navigator.pushNamed(context, AppConfig.aboutRoute);
                                      },
                                    ),

                                    const SizedBox(height: 24),

                                    // Vendor Section (if applicable)
                                    if (authProvider.currentUser?.isVendor == true) ...[
                                      _buildSectionTitle('البائع', theme),
                                      ProfileMenuItem(
                                        icon: Icons.dashboard_outlined,
                                        title: l10n.vendorDashboard,
                                        onTap: () {
                                          Navigator.pushNamed(context, AppConfig.vendorDashboardRoute);
                                        },
                                      ),
                                      const SizedBox(height: 24),
                                    ],

                                    // Logout
                                    ProfileMenuItem(
                                      icon: Icons.logout,
                                      title: l10n.logout,
                                      textColor: AppTheme.neonPink,
                                      onTap: () async {
                                        final confirmed = await showDialog<bool>(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            backgroundColor: Colors.transparent,
                                            content: AppTheme.glassMorphismContainer(
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    l10n.logout,
                                                    style: GoogleFonts.orbitron(
                                                      fontSize: 20,
                                                      fontWeight: FontWeight.bold,
                                                      color: isDark ? AppTheme.darkGlowingWhite : AppTheme.metallicGray,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 16),
                                                  Text(
                                                    'هل أنت متأكد من تسجيل الخروج؟',
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
                                                        text: l10n.cancel,
                                                        onPressed: () => Navigator.pop(context, false),
                                                        color: AppTheme.neonBlue,
                                                        textStyle: GoogleFonts.cairo(
                                                          fontSize: 14,
                                                          fontWeight: FontWeight.bold,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                      AppTheme.neonButton(
                                                        text: l10n.logout,
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
                                          await authProvider.signOut();
                                          Navigator.pushNamedAndRemoveUntil(
                                            context,
                                            AppConfig.loginRoute,
                                                (route) => false,
                                          );
                                        }
                                      },
                                    ),

                                    const SizedBox(height: 120),
                                  ],
                                ),
                              ),
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

  Widget _buildSectionTitle(String title, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, right: 16),
      child: Text(
        title,
        style: GoogleFonts.orbitron(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: isDark ? AppTheme.darkGlowingWhite : AppTheme.metallicGray,
          letterSpacing: 1.2,
          shadows: [
            Shadow(
              color: AppTheme.neonBlue.withOpacity(0.5),
              blurRadius: 10,
            ),
          ],
        ),
      ),
    );
  }
}