import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math' as math;

import '../../../../core/theme/app_theme.dart';
import '../../../home/presentation/widgets/futuristic_background.dart';


class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> with TickerProviderStateMixin {
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
                            'حول التطبيق',
                            style: GoogleFonts.orbitron(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppTheme.darkGlowingWhite : AppTheme.metallicGray,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Main Content
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            // App Logo
                            AnimatedBuilder(
                              animation: _particleController,
                              builder: (context, child) {
                                return AppTheme.glassMorphismContainer(

                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        colors: [
                                          AppTheme.neonBlue,
                                          AppTheme.darkNeonPurple,
                                        ],
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppTheme.neonBlue.withOpacity(0.3 + 0.2 * math.sin(_particleController.value * 2 * math.pi)),
                                          blurRadius: 20,
                                          spreadRadius: 5,
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.local_florist,
                                      size: 60,
                                      color: Colors.white,
                                    ),
                                  ),
                                );
                              },
                            ),

                            const SizedBox(height: 24),

                            // App Name
                            Text(
                              'متجر الورود',
                              style: GoogleFonts.orbitron(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppTheme.darkGlowingWhite : AppTheme.metallicGray,
                                shadows: [
                                  Shadow(
                                    color: AppTheme.neonBlue.withOpacity(0.5),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 8),

                            Text(
                              'الإصدار 1.0.0',
                              style: GoogleFonts.cairo(
                                color: isDark ? AppTheme.darkGlowingWhite.withOpacity(0.6) : AppTheme.metallicGray,
                                fontSize: 16,
                              ),
                            ),

                            const SizedBox(height: 32),

                            // Description
                            AppTheme.glassMorphismContainer(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.local_florist,
                                    color: AppTheme.neonBlue,
                                    size: 40,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'متجر الورود هو تطبيق متخصص في بيع أجمل باقات الورود لجميع المناسبات. نحن نقدم تشكيلة واسعة من الورود الطازجة والباقات المصممة بعناية لتناسب جميع الأذواق والمناسبات.',
                                    style: GoogleFonts.cairo(
                                      fontSize: 16,
                                      height: 1.6,
                                      color: isDark ? AppTheme.darkGlowingWhite : AppTheme.metallicGray,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 32),

                            // Developer Info
                            AppTheme.glassMorphismContainer(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                children: [
                                  AnimatedBuilder(
                                    animation: _particleController,
                                    builder: (context, child) {
                                      return CircleAvatar(
                                        radius: 40,
                                        backgroundColor: AppTheme.neonBlue,
                                        child: Icon(
                                          Icons.person,
                                          color: Colors.white,
                                          size: 40,
                                          shadows: [
                                            Shadow(
                                              color: AppTheme.neonBlue.withOpacity(0.3 + 0.2 * math.sin(_particleController.value * 2 * math.pi)),
                                              blurRadius: 20,
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'طُور من قِبل',
                                    style: GoogleFonts.cairo(
                                      color: isDark ? AppTheme.darkGlowingWhite.withOpacity(0.6) : AppTheme.metallicGray,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'د/ مختار الشرعبي',
                                    style: GoogleFonts.orbitron(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 24,
                                      color: AppTheme.neonBlue,
                                      shadows: [
                                        Shadow(
                                          color: AppTheme.neonBlue.withOpacity(0.5),
                                          blurRadius: 10,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.phone,
                                        color: AppTheme.neonBlue,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '772586514',
                                        style: GoogleFonts.cairo(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 18,
                                          color: isDark ? AppTheme.darkGlowingWhite : AppTheme.metallicGray,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 32),

                            // Features
                            Text(
                              'مميزات التطبيق',
                              style: GoogleFonts.orbitron(
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                                color: isDark ? AppTheme.darkGlowingWhite : AppTheme.metallicGray,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 16),

                            _buildFeatureItem(
                              Icons.local_florist,
                              'تشكيلة واسعة من الورود',
                              'باقات متنوعة لجميع المناسبات',
                            ),
                            _buildFeatureItem(
                              Icons.delivery_dining,
                              'توصيل سريع',
                              'توصيل خلال 24-48 ساعة',
                            ),
                            _buildFeatureItem(
                              Icons.payment,
                              'دفع آمن',
                              'طرق دفع متعددة وآمنة',
                            ),
                            _buildFeatureItem(
                              Icons.support_agent,
                              'دعم فني 24/7',
                              'فريق دعم متاح في أي وقت',
                            ),

                            const SizedBox(height: 32),

                            // Contact Info
                            Text(
                              'تواصل معنا',
                              style: GoogleFonts.orbitron(
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                                color: isDark ? AppTheme.darkGlowingWhite : AppTheme.metallicGray,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 16),

                            _buildContactItem(
                              Icons.phone,
                              'الهاتف',
                              '772586514',
                                  () async {
                                final Uri phoneUri = Uri(scheme: 'tel', path: '772586514');
                                if (await canLaunchUrl(phoneUri)) {
                                  await launchUrl(phoneUri);
                                }
                              },
                            ),
                            _buildContactItem(
                              Icons.email,
                              'البريد الإلكتروني',
                              'support@roses.com',
                                  () async {
                                final Uri emailUri = Uri(
                                  scheme: 'mailto',
                                  path: 'support@roses.com',
                                );
                                if (await canLaunchUrl(emailUri)) {
                                  await launchUrl(emailUri);
                                }
                              },
                            ),

                            const SizedBox(height: 32),

                            // Copyright
                            Text(
                              '© 2025 متجر الورود. جميع الحقوق محفوظة.',
                              style: GoogleFonts.cairo(
                                fontSize: 14,
                                color: isDark ? AppTheme.darkGlowingWhite.withOpacity(0.5) : AppTheme.metallicGray,
                              ),
                              textAlign: TextAlign.center,
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
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AppTheme.glassMorphismContainer(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.neonBlue, AppTheme.darkNeonBlue],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
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
                  title,
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isDark ? AppTheme.darkGlowingWhite : AppTheme.metallicGray,
                  ),
                ),
                Text(
                  description,
                  style: GoogleFonts.cairo(
                    color: isDark ? AppTheme.darkGlowingWhite.withOpacity(0.6) : AppTheme.metallicGray,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(
      IconData icon,
      String title,
      String value,
      VoidCallback onTap,
      ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AnimatedBuilder(
      animation: _particleController,
      builder: (context, child) {
        return AppTheme.glassMorphismContainer(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            onTap: onTap,
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.neonBlue, AppTheme.darkNeonBlue],
                ),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.neonBlue.withOpacity(0.3 + 0.2 * math.sin(_particleController.value * 2 * math.pi)),
                    blurRadius: 10,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 20,
              ),
            ),
            title: Text(
              title,
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.w600,
                color: isDark ? AppTheme.darkGlowingWhite : AppTheme.metallicGray,
              ),
            ),
            subtitle: Text(
              value,
              style: GoogleFonts.cairo(
                color: isDark ? AppTheme.darkGlowingWhite.withOpacity(0.6) : AppTheme.metallicGray,
              ),
            ),
            trailing: Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppTheme.neonBlue,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      },
    );
  }
}