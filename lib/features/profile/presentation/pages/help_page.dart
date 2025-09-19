import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math' as math;

import '../../../../core/theme/app_theme.dart';
import '../../../home/presentation/widgets/futuristic_background.dart';


class HelpPage extends StatefulWidget {
  const HelpPage({super.key});

  @override
  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> with TickerProviderStateMixin {
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
                            'المساعدة',
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
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Support Team Info
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
                                          Icons.support_agent,
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
                                    'فريق الدعم',
                                    style: GoogleFonts.orbitron(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 24,
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
                                    'د/ مختار الشرعبي',
                                    style: GoogleFonts.cairo(
                                      color: AppTheme.neonBlue,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '772586514',
                                    style: GoogleFonts.cairo(
                                      color: AppTheme.neonBlue,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'نحن هنا لمساعدتك في أي وقت\nفريق الدعم متاح 24/7',
                                    style: GoogleFonts.cairo(
                                      color: isDark ? AppTheme.darkGlowingWhite.withOpacity(0.6) : AppTheme.metallicGray,
                                      height: 1.5,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Contact Options
                            Text(
                              'طرق التواصل',
                              style: GoogleFonts.orbitron(
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                                color: isDark ? AppTheme.darkGlowingWhite : AppTheme.metallicGray,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 16),

                            _buildContactCard(
                              icon: Icons.phone,
                              title: 'اتصال هاتفي',
                              subtitle: '772586514',
                              color: Colors.green,
                              onTap: () async {
                                final Uri phoneUri = Uri(scheme: 'tel', path: '772586514');
                                if (await canLaunchUrl(phoneUri)) {
                                  await launchUrl(phoneUri);
                                }
                              },
                            ),

                            const SizedBox(height: 12),

                            _buildContactCard(
                              icon: Icons.message,
                              title: 'واتساب',
                              subtitle: 'تواصل سريع',
                              color: Colors.green[600]!,
                              onTap: () async {
                                final Uri whatsappUri = Uri.parse(
                                  'https://wa.me/966772586514?text=مرحباً، أحتاج مساعدة في تطبيق متجر الورود',
                                );
                                if (await canLaunchUrl(whatsappUri)) {
                                  await launchUrl(whatsappUri);
                                }
                              },
                            ),

                            const SizedBox(height: 32),

                            // FAQ Section
                            Text(
                              'الأسئلة الشائعة',
                              style: GoogleFonts.orbitron(
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                                color: isDark ? AppTheme.darkGlowingWhite : AppTheme.metallicGray,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 16),

                            _buildFAQItem(
                              'كيف يمكنني تتبع طلبي؟',
                              'يمكنك تتبع طلبك من خلال صفحة "طلباتي" في الملف الشخصي، أو من خلال الرابط المرسل في رسالة التأكيد.',
                            ),
                            _buildFAQItem(
                              'ما هي مدة التوصيل؟',
                              'نقوم بتوصيل الطلبات خلال 24-48 ساعة داخل المدن الرئيسية، و3-5 أيام للمناطق الأخرى.',
                            ),
                            _buildFAQItem(
                              'هل يمكنني إلغاء طلبي؟',
                              'يمكنك إلغاء الطلب قبل تأكيده من التاجر. بعد التأكيد، يرجى التواصل مع فريق الدعم.',
                            ),
                            _buildFAQItem(
                              'كيف يمكنني استخدام كوبون الخصم؟',
                              'أدخل كود الكوبون في صفحة السلة قبل إتمام الشراء، وسيتم تطبيق الخصم تلقائياً.',
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

  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AnimatedBuilder(
      animation: _particleController,
      builder: (context, child) {
        return GestureDetector(
          onTap: onTap,
          child: AppTheme.glassMorphismContainer(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color, color.withOpacity(0.7)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.3 + 0.2 * math.sin(_particleController.value * 2 * math.pi)),
                        blurRadius: 10,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 32,
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
                        subtitle,
                        style: GoogleFonts.cairo(
                          color: isDark ? AppTheme.darkGlowingWhite.withOpacity(0.6) : AppTheme.metallicGray,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: color,
                  size: 16,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AppTheme.glassMorphismContainer(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        title: Text(
          question,
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.w600,
            color: isDark ? AppTheme.darkGlowingWhite : AppTheme.metallicGray,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              answer,
              style: GoogleFonts.cairo(
                color: isDark ? AppTheme.darkGlowingWhite.withOpacity(0.6) : AppTheme.metallicGray,
                height: 1.5,
              ),
            ),
          ),
        ],
        collapsedBackgroundColor: Colors.transparent,
        backgroundColor: Colors.transparent,
      ),
    );
  }
}