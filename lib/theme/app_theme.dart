import 'package:flutter/material.dart';

/// Comprehensive Islamic-themed color scheme and design system
/// Provides purple background with cream/beige accents and gold highlights
class AppTheme {
  // Primary Islamic Purple Colors
  static const Color primaryPurple = Color(0xFF6B46C1);
  static const Color secondaryPurple = Color(0xFF8B5CF6);
  static const Color lightPurple = Color(0xFFA78BFA);
  static const Color darkPurple = Color(0xFF553C9A);
  
  // Cream and Beige Surface Colors
  static const Color creamSurface = Color(0xFFFEF7ED);
  static const Color creamBackground = Color(0xFFF9FAFB);
  static const Color warmBeige = Color(0xFFF3F4F6);
  static const Color lightCream = Color(0xFFFDF2F8);
  
  // Gold Accent Colors for Premium Features
  static const Color goldAccent = Color(0xFFF59E0B);
  static const Color lightGold = Color(0xFFFCD34D);
  static const Color darkGold = Color(0xFFD97706);
  
  // Islamic Text Colors
  static const Color islamicText = Color(0xFF1F2937);
  static const Color islamicTextLight = Color(0xFF6B7280);
  static const Color islamicTextDark = Color(0xFF111827);
  
  // Error and Success Colors
  static const Color errorRed = Color(0xFFDC2626);
  static const Color successGreen = Color(0xFF059669);
  static const Color warningOrange = Color(0xFFEA580C);
  
  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkPurpleAccent = Color(0xFF7C3AED);
  static const Color darkCreamAccent = Color(0xFFF1F5F9);

  /// Light theme configuration with Islamic aesthetic
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryPurple,
        brightness: Brightness.light,
      ).copyWith(
        primary: primaryPurple,
        secondary: secondaryPurple,
        surface: creamSurface,
        background: creamBackground,
        error: errorRed,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: islamicText,
        onBackground: islamicText,
        onError: Colors.white,
        outline: lightPurple,
        outlineVariant: warmBeige,
        shadow: primaryPurple.withOpacity(0.1),
        scrim: primaryPurple.withOpacity(0.5),
      ),
      
      // Custom text theme with Islamic typography
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: islamicTextDark,
          letterSpacing: -0.5,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: islamicTextDark,
          letterSpacing: -0.25,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: islamicTextDark,
        ),
        headlineLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: islamicTextDark,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: islamicTextDark,
        ),
        headlineSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: islamicTextDark,
        ),
        titleLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: islamicTextDark,
        ),
        titleMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: islamicTextDark,
        ),
        titleSmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: islamicTextDark,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: islamicText,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: islamicText,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: islamicTextLight,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: islamicText,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: islamicText,
        ),
        labelSmall: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: islamicTextLight,
        ),
      ),
      
      // App bar theme with Islamic styling
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        iconTheme: IconThemeData(color: Colors.white),
        actionsIconTheme: IconThemeData(color: Colors.white),
      ),
      
      // Card theme intentionally omitted for compatibility
      
      // Elevated button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryPurple,
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: primaryPurple.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      
      // Floating action button theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryPurple,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      
      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: creamBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: lightPurple.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: lightPurple.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryPurple, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: errorRed),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      
      // Bottom navigation bar theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: primaryPurple,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      
      // Dialog theme intentionally omitted for compatibility
      
      // Divider theme
      dividerTheme: DividerThemeData(
        color: lightPurple.withOpacity(0.2),
        thickness: 1,
        space: 1,
      ),
      
      // Icon theme
      iconTheme: const IconThemeData(
        color: islamicText,
        size: 24,
      ),
      
      // Switch theme
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return primaryPurple;
          }
          return islamicTextLight;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return primaryPurple.withOpacity(0.3);
          }
          return warmBeige;
        }),
      ),
      
      // Checkbox theme
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return primaryPurple;
          }
          return Colors.transparent;
        }),
        checkColor: MaterialStateProperty.all(Colors.white),
        side: BorderSide(color: lightPurple.withOpacity(0.5)),
      ),
      
      // Radio theme
      radioTheme: RadioThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return primaryPurple;
          }
          return islamicTextLight;
        }),
      ),
    );
  }

  /// Dark theme configuration with Islamic aesthetic
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: darkPurpleAccent,
        brightness: Brightness.dark,
      ).copyWith(
        primary: darkPurpleAccent,
        secondary: secondaryPurple,
        surface: darkSurface,
        background: darkBackground,
        error: errorRed,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: darkCreamAccent,
        onBackground: darkCreamAccent,
        onError: Colors.white,
        outline: secondaryPurple,
        outlineVariant: darkSurface,
        shadow: darkPurpleAccent.withOpacity(0.2),
        scrim: darkPurpleAccent.withOpacity(0.7),
      ),
      
      // Dark theme text styles
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: darkCreamAccent,
          letterSpacing: -0.5,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: darkCreamAccent,
          letterSpacing: -0.25,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: darkCreamAccent,
        ),
        headlineLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: darkCreamAccent,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: darkCreamAccent,
        ),
        headlineSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: darkCreamAccent,
        ),
        titleLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: darkCreamAccent,
        ),
        titleMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: darkCreamAccent,
        ),
        titleSmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: darkCreamAccent,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: darkCreamAccent,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: darkCreamAccent,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: Colors.white70,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: darkCreamAccent,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: darkCreamAccent,
        ),
        labelSmall: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: Colors.white70,
        ),
      ),
      
      // Dark app bar theme
      appBarTheme: const AppBarTheme(
        backgroundColor: darkBackground,
        foregroundColor: darkCreamAccent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: darkCreamAccent,
        ),
        iconTheme: IconThemeData(color: darkCreamAccent),
        actionsIconTheme: IconThemeData(color: darkCreamAccent),
      ),
      
      // Dark card theme intentionally omitted for compatibility
      
      // Dark elevated button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: darkPurpleAccent,
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: darkPurpleAccent.withOpacity(0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      
      // Dark floating action button theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: darkPurpleAccent,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      
      // Dark input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: secondaryPurple.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: secondaryPurple.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: darkPurpleAccent, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: errorRed),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      
      // Dark bottom navigation bar theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: darkBackground,
        selectedItemColor: darkPurpleAccent,
        unselectedItemColor: Colors.white70,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      
      // Dark dialog theme intentionally omitted for compatibility
      
      // Dark divider theme
      dividerTheme: DividerThemeData(
        color: secondaryPurple.withOpacity(0.3),
        thickness: 1,
        space: 1,
      ),
      
      // Dark icon theme
      iconTheme: const IconThemeData(
        color: darkCreamAccent,
        size: 24,
      ),
      
      // Dark switch theme
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return darkPurpleAccent;
          }
          return Colors.white70;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return darkPurpleAccent.withOpacity(0.5);
          }
          return darkSurface;
        }),
      ),
      
      // Dark checkbox theme
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return darkPurpleAccent;
          }
          return Colors.transparent;
        }),
        checkColor: MaterialStateProperty.all(Colors.white),
        side: BorderSide(color: secondaryPurple.withOpacity(0.5)),
      ),
      
      // Dark radio theme
      radioTheme: RadioThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return darkPurpleAccent;
          }
          return Colors.white70;
        }),
      ),
    );
  }

  /// Helper method to create Islamic-themed decorations
  static BoxDecoration createIslamicDecoration({
    Color? backgroundColor,
    Color? borderColor,
    double borderRadius = 12,
    List<BoxShadow>? boxShadow,
  }) {
    return BoxDecoration(
      color: backgroundColor ?? creamSurface,
      borderRadius: BorderRadius.circular(borderRadius),
      border: borderColor != null
          ? Border.all(color: borderColor, width: 1)
          : Border.all(color: lightPurple.withOpacity(0.2), width: 1),
      boxShadow: boxShadow ??
          [
            BoxShadow(
              color: primaryPurple.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
    );
  }

  /// Helper method to create Islamic gradient backgrounds
  static LinearGradient createIslamicGradient({
    AlignmentGeometry begin = Alignment.topLeft,
    AlignmentGeometry end = Alignment.bottomRight,
    List<Color>? colors,
  }) {
    return LinearGradient(
      begin: begin,
      end: end,
      colors: colors ??
          [
            primaryPurple.withOpacity(0.1),
            secondaryPurple.withOpacity(0.05),
            creamSurface,
          ],
    );
  }

  /// Helper method to create Islamic radial gradients
  static RadialGradient createIslamicRadialGradient({
    Alignment center = Alignment.center,
    double radius = 0.8,
    List<Color>? colors,
  }) {
    return RadialGradient(
      center: center,
      radius: radius,
      colors: colors ??
          [
            primaryPurple.withOpacity(0.15),
            secondaryPurple.withOpacity(0.08),
            Colors.transparent,
          ],
    );
  }

  /// Helper method to create Islamic-themed shadows
  static List<BoxShadow> createIslamicShadows({
    Color? color,
    double blurRadius = 4,
    Offset offset = const Offset(0, 2),
  }) {
    return [
      BoxShadow(
        color: color ?? primaryPurple.withOpacity(0.1),
        blurRadius: blurRadius,
        offset: offset,
      ),
    ];
  }

  /// Helper method to get Islamic-themed border radius
  static BorderRadius getIslamicBorderRadius({double radius = 12}) {
    return BorderRadius.circular(radius);
  }

  /// Helper method to create Islamic-themed text styles
  static TextStyle createIslamicTextStyle({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.normal,
    Color? color,
    double? letterSpacing,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color ?? islamicText,
      letterSpacing: letterSpacing,
    );
  }

  /// Helper method to create Islamic-themed button styles
  static ButtonStyle createIslamicButtonStyle({
    Color? backgroundColor,
    Color? foregroundColor,
    EdgeInsetsGeometry? padding,
    BorderRadius? borderRadius,
  }) {
    return ElevatedButton.styleFrom(
      backgroundColor: backgroundColor ?? primaryPurple,
      foregroundColor: foregroundColor ?? Colors.white,
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ?? BorderRadius.circular(8),
      ),
      elevation: 2,
      shadowColor: (backgroundColor ?? primaryPurple).withOpacity(0.3),
    );
  }
}
