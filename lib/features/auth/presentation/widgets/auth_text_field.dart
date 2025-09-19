import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';

class AuthTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final bool isPassword;
  final TextInputType keyboardType;
  final IconData? prefixIcon;
  final String? Function(String?)? validator;

  const AuthTextField({
    super.key,
    required this.controller,
    required this.label,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.validator,
  });

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField>
    with TickerProviderStateMixin {
  bool _obscureText = true;
  bool _isFocused = false;
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));

    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _glowController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(isDark ? 0.1 : 0.6),
                Colors.white.withOpacity(isDark ? 0.05 : 0.3),
              ],
            ),
            border: Border.all(
              color: _isFocused
                  ? (isDark ? AppTheme.darkNeonBlue : AppTheme.neonBlue)
                  : Colors.white.withOpacity(0.3),
              width: _isFocused ? 2 : 1.5,
            ),
            boxShadow: [
              if (_isFocused)
                BoxShadow(
                  color: (isDark ? AppTheme.darkNeonBlue : AppTheme.neonBlue)
                      .withOpacity(0.3 * _glowAnimation.value),
                  blurRadius: 25,
                  spreadRadius: 0,
                  offset: const Offset(0, 8),
                ),
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
                blurRadius: 15,
                spreadRadius: 0,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
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
              child: TextFormField(
                controller: widget.controller,
                focusNode: _focusNode,
                keyboardType: widget.keyboardType,
                obscureText: widget.isPassword ? _obscureText : false,
                validator: widget.validator,
                style: GoogleFonts.cairo(
                  color: isDark 
                      ? AppTheme.darkGlowingWhite 
                      : AppTheme.metallicGray,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  labelText: widget.label,
                  labelStyle: GoogleFonts.cairo(
                    color: _isFocused
                        ? (isDark ? AppTheme.darkNeonBlue : AppTheme.neonBlue)
                        : (isDark 
                            ? AppTheme.darkGlowingWhite 
                            : AppTheme.metallicGray).withOpacity(0.7),
                    fontWeight: FontWeight.w500,
                  ),
                  prefixIcon: widget.prefixIcon != null 
                      ? Container(
                          padding: const EdgeInsets.all(12),
                          child: Icon(
                            widget.prefixIcon,
                            color: _isFocused
                                ? (isDark ? AppTheme.darkNeonBlue : AppTheme.neonBlue)
                                : (isDark 
                                    ? AppTheme.darkGlowingWhite 
                                    : AppTheme.metallicGray).withOpacity(0.6),
                            size: 24,
                          ),
                        )
                      : null,
                  suffixIcon: widget.isPassword
                      ? Container(
                          padding: const EdgeInsets.all(8),
                          child: IconButton(
                            icon: Icon(
                              _obscureText 
                                  ? Icons.visibility_rounded 
                                  : Icons.visibility_off_rounded,
                              color: _isFocused
                                  ? (isDark ? AppTheme.darkNeonBlue : AppTheme.neonBlue)
                                  : (isDark 
                                      ? AppTheme.darkGlowingWhite 
                                      : AppTheme.metallicGray).withOpacity(0.6),
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureText = !_obscureText;
                              });
                            },
                          ),
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 20,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}