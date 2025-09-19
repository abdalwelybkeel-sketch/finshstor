import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Futuristic Colors - Light Mode
  static const Color neonBlue = Color(0xFFE91E63);
  static const Color neonPurple = Color(0xFFF8BBD9);
  static const Color neonPink = Color(0xFFAD1457);
  static const Color holographicGreen = Color(0xFF00FF88);
  static const Color glowingWhite = Color(0xFFE1BEE7);
  static const Color metallicGray = Color(0xFF1A1A2E);
  static const Color darkSpace = Color(0xFF0F0F23);
  static const Color glassMorphism = Color(0x1AFFFFFF);

  // Futuristic Colors - Dark Mode
  static const Color darkNeonBlue = Color(0xFF0099CC);
  static const Color darkNeonPurple = Color(0xFF6D28D9);
  static const Color darkNeonPink = Color(0xFFE91E63);
  static const Color darkHolographicGreen = Color(0xFF10B981);
  static const Color darkGlowingWhite = Color(0xFFE5E7EB);
  static const Color darkMetallicGray = Color(0xFF374151);
  static const Color ultraDarkSpace = Color(0xFF111827);

  // Gradients
  static const LinearGradient neonGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [neonBlue, neonPurple, neonPink],
  );

  static const LinearGradient darkNeonGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [darkNeonBlue, darkNeonPurple, darkNeonPink],
  );

  static const LinearGradient glassGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x40FFFFFF),
      Color(0x20FFFFFF),
      Color(0x10FFFFFF),
    ],
  );

  // Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // Color Scheme
      colorScheme: const ColorScheme.light(
        primary: neonBlue,
        secondary: neonPurple,
        tertiary: neonPink,
        surface: glowingWhite,
        background: Color(0xFFF8FAFC),
        onPrimary: darkSpace,
        onSecondary: glowingWhite,
        onSurface: metallicGray,
        onBackground: metallicGray,
        error: Color(0xFFFF4757),
        onError: glowingWhite,
      ),

      // Scaffold Background
      scaffoldBackgroundColor: const Color(0xFFF8FAFC),

      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.orbitron(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: metallicGray,
          letterSpacing: 1.2,
        ),
        iconTheme: const IconThemeData(color: metallicGray),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
      ),

      // Text Theme
      textTheme: GoogleFonts.cairoTextTheme().copyWith(
        displayLarge: GoogleFonts.orbitron(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: metallicGray,
          letterSpacing: 1.5,
        ),
        displayMedium: GoogleFonts.orbitron(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: metallicGray,
          letterSpacing: 1.2,
        ),
        headlineLarge: GoogleFonts.orbitron(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: metallicGray,
          letterSpacing: 1.0,
        ),
        headlineMedium: GoogleFonts.cairo(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: metallicGray,
        ),
        bodyLarge: GoogleFonts.cairo(
          fontSize: 16,
          color: metallicGray,
          height: 1.6,
        ),
        bodyMedium: GoogleFonts.cairo(
          fontSize: 14,
          color: metallicGray,
          height: 1.5,
        ),
      ),

      // Card Theme
      cardTheme: CardTheme(
        elevation: 0,
        color: Colors.transparent,
        shadowColor: neonBlue.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: glowingWhite,
          elevation: 0,
          shadowColor: neonBlue.withOpacity(0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          textStyle: GoogleFonts.orbitron(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: glassMorphism,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(
            color: neonBlue.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(
            color: neonBlue.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(
            color: neonBlue,
            width: 2.5,
          ),
        ),
        labelStyle: GoogleFonts.cairo(
          color: metallicGray,
          fontWeight: FontWeight.w500,
        ),
        hintStyle: GoogleFonts.cairo(
          color: metallicGray.withOpacity(0.6),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 20,
        ),
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: neonBlue,
        unselectedItemColor: metallicGray,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  // Dark Theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // Color Scheme
      colorScheme: const ColorScheme.dark(
        primary: darkNeonBlue,
        secondary: darkNeonPurple,
        tertiary: darkNeonPink,
        surface: darkMetallicGray,
        background: ultraDarkSpace,
        onPrimary: darkGlowingWhite,
        onSecondary: darkGlowingWhite,
        onSurface: darkGlowingWhite,
        onBackground: darkGlowingWhite,
        error: Color(0xFFFF6B6B),
        onError: darkGlowingWhite,
      ),

      // Scaffold Background
      scaffoldBackgroundColor: ultraDarkSpace,

      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.orbitron(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: darkGlowingWhite,
          letterSpacing: 1.2,
        ),
        iconTheme: const IconThemeData(color: darkGlowingWhite),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
      ),

      // Text Theme
      textTheme: GoogleFonts.cairoTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.orbitron(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: darkGlowingWhite,
          letterSpacing: 1.5,
        ),
        displayMedium: GoogleFonts.orbitron(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: darkGlowingWhite,
          letterSpacing: 1.2,
        ),
        headlineLarge: GoogleFonts.orbitron(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: darkGlowingWhite,
          letterSpacing: 1.0,
        ),
        headlineMedium: GoogleFonts.cairo(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: darkGlowingWhite,
        ),
        bodyLarge: GoogleFonts.cairo(
          fontSize: 16,
          color: darkGlowingWhite,
          height: 1.6,
        ),
        bodyMedium: GoogleFonts.cairo(
          fontSize: 14,
          color: darkGlowingWhite,
          height: 1.5,
        ),
      ),

      // Card Theme
      cardTheme: CardTheme(
        elevation: 0,
        color: Colors.transparent,
        shadowColor: darkNeonBlue.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: darkGlowingWhite,
          elevation: 0,
          shadowColor: darkNeonBlue.withOpacity(0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          textStyle: GoogleFonts.orbitron(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0x20FFFFFF),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(
            color: darkNeonBlue.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(
            color: darkNeonBlue.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(
            color: darkNeonBlue,
            width: 2.5,
          ),
        ),
        labelStyle: GoogleFonts.cairo(
          color: darkGlowingWhite,
          fontWeight: FontWeight.w500,
        ),
        hintStyle: GoogleFonts.cairo(
          color: darkGlowingWhite.withOpacity(0.6),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 20,
        ),
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: darkNeonBlue,
        unselectedItemColor: darkGlowingWhite,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  // Glassmorphism Container
  static Widget glassMorphismContainer({
    required Widget child,
    double borderRadius = 24,
    double blur = 20,
    Color? color,
    EdgeInsets? padding,
    EdgeInsets? margin,
    Border? border,
    List<BoxShadow>? boxShadow,
  }) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        border: border ?? Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: boxShadow ?? [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: blur,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.1),
            blurRadius: blur / 2,
            spreadRadius: -5,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Container(
          decoration: BoxDecoration(
            gradient: color != null 
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      color.withOpacity(0.3),
                      color.withOpacity(0.1),
                    ],
                  )
                : glassGradient,
          ),
          padding: padding,
          child: child,
        ),
      ),
    );
  }

  // Neon Button
  static Widget neonButton({
    required String text,
    required VoidCallback onPressed,
    Color? color,
    double borderRadius = 20,
    EdgeInsets? padding,
    TextStyle? textStyle,
    bool isLoading = false,
  }) {
    final buttonColor = color ?? neonBlue;
    
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            buttonColor,
            buttonColor.withOpacity(0.8),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: buttonColor.withOpacity(0.5),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: buttonColor.withOpacity(0.3),
            blurRadius: 40,
            spreadRadius: 0,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding: padding ?? const EdgeInsets.symmetric(
            horizontal: 32,
            vertical: 16,
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                text,
                style: textStyle ?? GoogleFonts.orbitron(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
      ),
    );
  }

  // Holographic Card
  static Widget holographicCard({
    required Widget child,
    double borderRadius = 24,
    EdgeInsets? padding,
    EdgeInsets? margin,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: margin,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0x30FFFFFF),
                  Color(0x10FFFFFF),
                  Color(0x05FFFFFF),
                ],
              ),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: neonBlue.withOpacity(0.1),
                  blurRadius: 20,
                  spreadRadius: 0,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: neonPurple.withOpacity(0.1),
                  blurRadius: 40,
                  spreadRadius: 0,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            padding: padding ?? const EdgeInsets.all(20),
            child: child,
          ),
        ),
      ),
    );
  }

  // Animated Gradient Background
  static Widget animatedGradientBackground({
    required Widget child,
    List<Color>? colors,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors ?? [
            const Color(0xFFF8FAFC),
            const Color(0xFFE2E8F0),
            const Color(0xFFF1F5F9),
          ],
        ),
      ),
      child: child,
    );
  }
}

// Theme Provider
class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }
}

// Locale Provider
class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('ar', 'SA');

  Locale get locale => _locale;
  bool get isArabic => _locale.languageCode == 'ar';

  void setLocale(Locale locale) {
    _locale = locale;
    notifyListeners();
  }

  void toggleLocale() {
    _locale = _locale.languageCode == 'ar'
        ? const Locale('en', 'US')
        : const Locale('ar', 'SA');
    notifyListeners();
  }
}