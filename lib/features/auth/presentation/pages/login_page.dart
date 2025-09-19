import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

import '../../../../core/config/app_config.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../home/presentation/widgets/futuristic_background.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/social_login_button.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  late AnimationController _animationController;
  late AnimationController _logoController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _logoRotation;

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

    _logoController = AnimationController(
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

    _logoRotation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.linear,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _logoController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.signInWithEmail(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (success && mounted) {
      if (authProvider.currentUser?.isVendor == true) {
        Navigator.pushReplacementNamed(context, AppConfig.vendorDashboardRoute);
      } else {
        Navigator.pushReplacementNamed(context, AppConfig.homeRoute);
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.signInWithGoogle();

    if (success && mounted) {
      if (authProvider.currentUser?.isVendor == true) {
        Navigator.pushReplacementNamed(context, AppConfig.vendorDashboardRoute);
      } else {
        Navigator.pushReplacementNamed(context, AppConfig.homeRoute);
      }
    }
  }

  Future<void> _handleAppleSignIn() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.signInWithApple();

    if (success && mounted) {
      if (authProvider.currentUser?.isVendor == true) {
        Navigator.pushReplacementNamed(context, AppConfig.vendorDashboardRoute);
      } else {
        Navigator.pushReplacementNamed(context, AppConfig.homeRoute);
      }
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 60),
                      
                      // Futuristic Logo
                      Hero(
                        tag: 'app_logo',
                        child: AnimatedBuilder(
                          animation: _logoRotation,
                          builder: (context, child) {
                            return Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: isDark
                                      ? [
                                          AppTheme.darkNeonBlue,
                                          AppTheme.darkNeonPurple,
                                          AppTheme.darkNeonPink,
                                        ]
                                      : [
                                          AppTheme.neonBlue,
                                          AppTheme.neonPurple,
                                          AppTheme.neonPink,
                                        ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: (isDark ? AppTheme.darkNeonBlue : AppTheme.neonBlue)
                                        .withOpacity(0.5),
                                    blurRadius: 30,
                                    spreadRadius: 0,
                                    offset: const Offset(0, 15),
                                  ),
                                  BoxShadow(
                                    color: (isDark ? AppTheme.darkNeonPurple : AppTheme.neonPurple)
                                        .withOpacity(0.3),
                                    blurRadius: 60,
                                    spreadRadius: 0,
                                    offset: const Offset(0, 30),
                                  ),
                                ],
                              ),
                              child: Transform.rotate(
                                angle: _logoRotation.value * 0.1,
                                child: const Icon(
                                  Icons.local_florist_rounded,
                                  size: 60,
                                  color: Colors.white,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // Welcome Text
                      Text(
                        'مرحباً بك في المستقبل',
                        style: GoogleFonts.orbitron(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: isDark 
                              ? AppTheme.darkGlowingWhite 
                              : AppTheme.metallicGray,
                          letterSpacing: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: 12),
                      
                      Text(
                        'ادخل إلى عالم الورود الرقمي',
                        style: GoogleFonts.cairo(
                          fontSize: 18,
                          color: (isDark 
                              ? AppTheme.darkGlowingWhite 
                              : AppTheme.metallicGray).withOpacity(0.8),
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: 50),
                      
                      // Login Form
                      AppTheme.glassMorphismContainer(
                        padding: const EdgeInsets.all(32),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              AuthTextField(
                                controller: _emailController,
                                label: 'البريد الإلكتروني',
                                keyboardType: TextInputType.emailAddress,
                                prefixIcon: Icons.email_rounded,
                                validator: (value) {
                                  if (value?.isEmpty ?? true) {
                                    return 'يرجى إدخال البريد الإلكتروني';
                                  }
                                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                      .hasMatch(value!)) {
                                    return 'البريد الإلكتروني غير صحيح';
                                  }
                                  return null;
                                },
                              ),
                              
                              const SizedBox(height: 20),
                              
                              AuthTextField(
                                controller: _passwordController,
                                label: 'كلمة المرور',
                                isPassword: true,
                                prefixIcon: Icons.lock_rounded,
                                validator: (value) {
                                  if (value?.isEmpty ?? true) {
                                    return 'يرجى إدخال كلمة المرور';
                                  }
                                  if (value!.length < 6) {
                                    return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
                                  }
                                  return null;
                                },
                              ),
                              
                              const SizedBox(height: 32),
                              
                              // Login Button
                              Consumer<AuthProvider>(
                                builder: (context, authProvider, child) {
                                  return SizedBox(
                                    width: double.infinity,
                                    child: AppTheme.neonButton(
                                      text: 'دخول إلى المستقبل',
                                      onPressed: authProvider.isLoading 
                                          ? () {} 
                                          : _handleLogin,
                                      isLoading: authProvider.isLoading,
                                      color: isDark ? AppTheme.darkNeonBlue : AppTheme.neonBlue,
                                      padding: const EdgeInsets.symmetric(vertical: 18),
                                    ),
                                  );
                                },
                              ),
                              
                              // Error Message
                              Consumer<AuthProvider>(
                                builder: (context, authProvider, child) {
                                  if (authProvider.errorMessage != null) {
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 20),
                                      child: Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              const Color(0xFFFF4757).withOpacity(0.1),
                                              const Color(0xFFFF4757).withOpacity(0.05),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: const Color(0xFFFF4757).withOpacity(0.3),
                                            width: 1,
                                          ),
                                        ),
                                        child: Text(
                                          authProvider.errorMessage!,
                                          style: GoogleFonts.cairo(
                                            color: const Color(0xFFFF4757),
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    );
                                  }
                                  return const SizedBox.shrink();
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Social Login
                      Text(
                        'أو ادخل باستخدام',
                        style: GoogleFonts.cairo(
                          fontSize: 16,
                          color: (isDark 
                              ? AppTheme.darkGlowingWhite 
                              : AppTheme.metallicGray).withOpacity(0.7),
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: 20),
                      
                      Row(
                        children: [
                          Expanded(
                            child: SocialLoginButton(
                              icon: Icons.g_mobiledata_rounded,
                              label: 'Google',
                              onPressed: _handleGoogleSignIn,
                              backgroundColor: Colors.white,
                              textColor: AppTheme.metallicGray,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: SocialLoginButton(
                              icon: Icons.apple_rounded,
                              label: 'Apple',
                              onPressed: _handleAppleSignIn,
                              backgroundColor: AppTheme.metallicGray,
                              textColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // Register Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'مستخدم جديد؟ ',
                            style: GoogleFonts.cairo(
                              fontSize: 16,
                              color: isDark 
                                  ? AppTheme.darkGlowingWhite 
                                  : AppTheme.metallicGray,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (context, animation, secondaryAnimation) => 
                                      const RegisterPage(),
                                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                    return SlideTransition(
                                      position: Tween<Offset>(
                                        begin: const Offset(1.0, 0.0),
                                        end: Offset.zero,
                                      ).animate(CurvedAnimation(
                                        parent: animation,
                                        curve: Curves.easeInOutCubic,
                                      )),
                                      child: child,
                                    );
                                  },
                                  transitionDuration: const Duration(milliseconds: 400),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: isDark
                                      ? [
                                          AppTheme.darkNeonPurple.withOpacity(0.2),
                                          AppTheme.darkNeonPink.withOpacity(0.2),
                                        ]
                                      : [
                                          AppTheme.neonPurple.withOpacity(0.2),
                                          AppTheme.neonPink.withOpacity(0.2),
                                        ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: (isDark ? AppTheme.darkNeonPurple : AppTheme.neonPurple)
                                      .withOpacity(0.5),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                'انضم إلينا',
                                style: GoogleFonts.orbitron(
                                  color: isDark ? AppTheme.darkNeonPurple : AppTheme.neonPurple,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}