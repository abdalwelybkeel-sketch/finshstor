import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

import '../../../../core/theme/app_theme.dart';

class SearchBarWidget extends StatefulWidget {
  final Function(String) onSearch;

  const SearchBarWidget({
    super.key,
    required this.onSearch,
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget>
    with TickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

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
            borderRadius: BorderRadius.circular(30),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(isDark ? 0.1 : 0.8),
                Colors.white.withOpacity(isDark ? 0.05 : 0.6),
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
                      .withOpacity(0.5 * _glowAnimation.value),
                  blurRadius: 30,
                  spreadRadius: 0,
                  offset: const Offset(0, 10),
                ),
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
                blurRadius: 20,
                spreadRadius: 0,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
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
              child: TextField(
                focusNode: _focusNode,
                onSubmitted: widget.onSearch,
                style: GoogleFonts.cairo(
                  color: isDark 
                      ? AppTheme.darkGlowingWhite 
                      : AppTheme.metallicGray,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: 'ابحث في عالم الورود المستقبلي...',
                  hintStyle: GoogleFonts.cairo(
                    color: (isDark 
                        ? AppTheme.darkGlowingWhite 
                        : AppTheme.metallicGray).withOpacity(0.6),
                    fontSize: 16,
                  ),
                  prefixIcon: Container(
                    padding: const EdgeInsets.all(12),
                    child: Icon(
                      Icons.search_rounded,
                      color: _isFocused
                          ? (isDark ? AppTheme.darkNeonBlue : AppTheme.neonBlue)
                          : (isDark 
                              ? AppTheme.darkGlowingWhite 
                              : AppTheme.metallicGray).withOpacity(0.6),
                      size: 24,
                    ),
                  ),
                  suffixIcon: _isFocused
                      ? Container(
                          padding: const EdgeInsets.all(8),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: isDark
                                    ? [AppTheme.darkNeonBlue, AppTheme.darkNeonPurple]
                                    : [AppTheme.neonBlue, AppTheme.neonPurple],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: (isDark ? AppTheme.darkNeonBlue : AppTheme.neonBlue)
                                      .withOpacity(0.5),
                                  blurRadius: 10,
                                  spreadRadius: 0,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 18,
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