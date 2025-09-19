import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../splash/presentation/widgets/animated_background.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_text_field.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  
  bool _isVendor = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.signUpWithEmail(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      fullName: _fullNameController.text.trim(),
      phoneNumber: _phoneController.text.trim().isEmpty 
          ? null 
          : _phoneController.text.trim(),
      isVendor: _isVendor,
    );

    if (success && mounted) {
      if (_isVendor) {
        Navigator.pushReplacementNamed(context, AppConfig.vendorDashboardRoute);
      } else {
        Navigator.pushReplacementNamed(context, AppConfig.homeRoute);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Stack(
        children: [
          const AnimatedBackground(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  
                  // Back Button
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Title
                  Text(
                    l10n.register,
                    style: theme.textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    'أنشئ حسابك الجديد وابدأ رحلتك معنا',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onBackground.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Register Form
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            AuthTextField(
                              controller: _fullNameController,
                              label: l10n.fullName,
                              prefixIcon: Icons.person_outline,
                              validator: (value) {
                                if (value?.isEmpty ?? true) {
                                  return 'يرجى إدخال الاسم الكامل';
                                }
                                return null;
                              },
                            ),
                            
                            const SizedBox(height: 16),
                            
                            AuthTextField(
                              controller: _emailController,
                              label: l10n.email,
                              keyboardType: TextInputType.emailAddress,
                              prefixIcon: Icons.email_outlined,
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
                            
                            const SizedBox(height: 16),
                            
                            AuthTextField(
                              controller: _phoneController,
                              label: l10n.phoneNumber,
                              keyboardType: TextInputType.phone,
                              prefixIcon: Icons.phone_outlined,
                            ),
                            
                            const SizedBox(height: 16),
                            
                            AuthTextField(
                              controller: _passwordController,
                              label: l10n.password,
                              isPassword: true,
                              prefixIcon: Icons.lock_outline,
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
                            
                            const SizedBox(height: 16),
                            
                            AuthTextField(
                              controller: _confirmPasswordController,
                              label: l10n.confirmPassword,
                              isPassword: true,
                              prefixIcon: Icons.lock_outline,
                              validator: (value) {
                                if (value?.isEmpty ?? true) {
                                  return 'يرجى تأكيد كلمة المرور';
                                }
                                if (value != _passwordController.text) {
                                  return 'كلمة المرور غير متطابقة';
                                }
                                return null;
                              },
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // Vendor Switch
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppTheme.neonPurple.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppTheme.neonPurple.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.store_outlined,
                                    color: AppTheme.neonBlue,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'هل أنت تاجر؟',
                                          style: theme.textTheme.bodyLarge?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          'سجل كتاجر لبيع منتجاتك',
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            color: theme.colorScheme.onBackground
                                                .withOpacity(0.6),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Switch(
                                    value: _isVendor,
                                    onChanged: (value) {
                                      setState(() {
                                        _isVendor = value;
                                      });
                                    },
                                    activeColor: AppTheme.neonBlue,
                                  ),
                                ],
                              ),
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // Register Button
                            Consumer<AuthProvider>(
                              builder: (context, authProvider, child) {
                                return SizedBox(
                                  width: double.infinity,
                                  height: 50,
                                  child: ElevatedButton(
                                    onPressed: authProvider.isLoading 
                                        ? null 
                                        : _handleRegister,
                                    child: authProvider.isLoading
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
                                        : Text(l10n.register),
                                  ),
                                );
                              },
                            ),
                            
                            // Error Message
                            Consumer<AuthProvider>(
                              builder: (context, authProvider, child) {
                                if (authProvider.errorMessage != null) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 16),
                                    child: Text(
                                      authProvider.errorMessage!,
                                      style: TextStyle(
                                        color: theme.colorScheme.error,
                                        fontSize: 14,
                                      ),
                                      textAlign: TextAlign.center,
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
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}