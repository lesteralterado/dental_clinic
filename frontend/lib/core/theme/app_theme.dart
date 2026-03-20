import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Application theme configuration following Material Design 3
class AppTheme {
  AppTheme._();

  // ===========================================================================
  // DENTAL/MEDICAL COLOR PALETTE - Teal & Blue Grey
  // ===========================================================================

  // Light Theme Colors
  static const Color _lightPrimary = Color(0xFF008080); // Teal
  static const Color _lightOnPrimary = Color(0xFFFFFFFF);
  static const Color _lightPrimaryContainer = Color(0xFFB2DFDB); // Light Teal
  static const Color _lightOnPrimaryContainer = Color(0xFF004D40); // Dark Teal

  static const Color _lightSecondary = Color(0xFF607D8B); // Blue Grey
  static const Color _lightOnSecondary = Color(0xFFFFFFFF);
  static const Color _lightSecondaryContainer =
      Color(0xFFCFD8DC); // Light Blue Grey
  static const Color _lightOnSecondaryContainer = Color(0xFF37474F);

  static const Color _lightTertiary = Color(0xFFFFC107); // Amber
  static const Color _lightOnTertiary = Color(0xFF000000);
  static const Color _lightTertiaryContainer = Color(0xFFFFECB3);
  static const Color _lightOnTertiaryContainer = Color(0xFF5D4037);

  static const Color _lightError = Color(0xFFBA1A1A);
  static const Color _lightOnError = Color(0xFFFFFFFF);
  static const Color _lightErrorContainer = Color(0xFFFFDAD6);
  static const Color _lightOnErrorContainer = Color(0xFF410002);

  static const Color _lightBackground = Color(0xFFFAFDFC);
  static const Color _lightOnBackground = Color(0xFF191C1C);
  static const Color _lightSurface = Color(0xFFFAFDFC);
  static const Color _lightOnSurface = Color(0xFF191C1C);
  static const Color _lightSurfaceVariant = Color(0xFFDAE5E3);
  static const Color _lightOnSurfaceVariant = Color(0xFF3F4948);
  static const Color _lightOutline = Color(0xFF6F7978);
  static const Color _lightOutlineVariant = Color(0xFFBEC9C7);
  static const Color _lightSurfaceTint = _lightPrimary;
  static const Color _lightInverseSurface = Color(0xFF2D3131);
  static const Color _lightInverseOnSurface = Color(0xFFEFF1F0);
  static const Color _lightInversePrimary = Color(0xFF80CBC4);
  static const Color _lightSurfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color _lightSurfaceContainerLow = Color(0xFFF5F8F7);
  static const Color _lightSurfaceContainer = Color(0xFFEFF4F3);
  static const Color _lightSurfaceContainerHigh = Color(0xFFE9EFEE);
  static const Color _lightSurfaceContainerHighest = Color(0xFFE3E9E8);

  // Dark Theme Colors
  static const Color _darkPrimary = Color(0xFF4DB6AC); // Light Teal
  static const Color _darkOnPrimary = Color(0xFF00332E);
  static const Color _darkPrimaryContainer = Color(0xFF004D40); // Dark Teal
  static const Color _darkOnPrimaryContainer = Color(0xFFB2DFDB); // Light Teal

  static const Color _darkSecondary = Color(0xFF90A4AE); // Light Blue Grey
  static const Color _darkOnSecondary = Color(0xFF253238);
  static const Color _darkSecondaryContainer = Color(0xFF3B484F);
  static const Color _darkOnSecondaryContainer = Color(0xFFCFD8DC);

  static const Color _darkTertiary = Color(0xFFFFD54F); // Amber
  static const Color _darkOnTertiary = Color(0xFF3E2E00);
  static const Color _darkTertiaryContainer = Color(0xFF594400);
  static const Color _darkOnTertiaryContainer = Color(0xFFFFECB3);

  static const Color _darkError = Color(0xFFFFB4AB);
  static const Color _darkOnError = Color(0xFF690005);
  static const Color _darkErrorContainer = Color(0xFF93000A);
  static const Color _darkOnErrorContainer = Color(0xFFFFDAD6);

  static const Color _darkBackground = Color(0xFF191C1C);
  static const Color _darkOnBackground = Color(0xFFE1E3E2);
  static const Color _darkSurface = Color(0xFF191C1C);
  static const Color _darkOnSurface = Color(0xFFE1E3E2);
  static const Color _darkSurfaceVariant = Color(0xFF3F4948);
  static const Color _darkOnSurfaceVariant = Color(0xFFBEC9C7);
  static const Color _darkOutline = Color(0xFF899392);
  static const Color _darkOutlineVariant = Color(0xFF3F4948);
  static const Color _darkSurfaceTint = _darkPrimary;
  static const Color _darkInverseSurface = Color(0xFFE1E3E2);
  static const Color _darkInverseOnSurface = Color(0xFF2D3131);
  static const Color _darkInversePrimary = Color(0xFF00695C);
  static const Color _darkSurfaceContainerLowest = Color(0xFF0F1414);
  static const Color _darkSurfaceContainerLow = Color(0xFF171F1F);
  static const Color _darkSurfaceContainer = Color(0xFF1C2323);
  static const Color _darkSurfaceContainerHigh = Color(0xFF262D2D);
  static const Color _darkSurfaceContainerHighest = Color(0xFF313838);

  // ===========================================================================
  // LIGHT THEME
  // ===========================================================================

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: _lightPrimary,
        onPrimary: _lightOnPrimary,
        primaryContainer: _lightPrimaryContainer,
        onPrimaryContainer: _lightOnPrimaryContainer,
        secondary: _lightSecondary,
        onSecondary: _lightOnSecondary,
        secondaryContainer: _lightSecondaryContainer,
        onSecondaryContainer: _lightOnSecondaryContainer,
        tertiary: _lightTertiary,
        onTertiary: _lightOnTertiary,
        tertiaryContainer: _lightTertiaryContainer,
        onTertiaryContainer: _lightOnTertiaryContainer,
        error: _lightError,
        onError: _lightOnError,
        errorContainer: _lightErrorContainer,
        onErrorContainer: _lightOnErrorContainer,
        surface: _lightSurface,
        onSurface: _lightOnSurface,
        surfaceContainerHighest: _lightSurfaceContainerHighest,
        surfaceContainerHigh: _lightSurfaceContainerHigh,
        surfaceContainer: _lightSurfaceContainer,
        surfaceContainerLow: _lightSurfaceContainerLow,
        surfaceContainerLowest: _lightSurfaceContainerLowest,
        surfaceVariant: _lightSurfaceVariant,
        onSurfaceVariant: _lightOnSurfaceVariant,
        outline: _lightOutline,
        outlineVariant: _lightOutlineVariant,
        shadow: Colors.black,
        scrim: Colors.black,
        inverseSurface: _lightInverseSurface,
        onInverseSurface: _lightInverseOnSurface,
        inversePrimary: _lightInversePrimary,
        surfaceTint: _lightSurfaceTint,
      ),
      scaffoldBackgroundColor: _lightBackground,
      textTheme: _textTheme,

      // AppBar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: _lightSurface,
        foregroundColor: _lightOnSurface,
        elevation: 0,
        scrolledUnderElevation: 3,
        centerTitle: true,
        titleTextStyle: GoogleFonts.roboto(
          fontSize: 22,
          fontWeight: FontWeight.w500,
          color: _lightOnSurface,
        ),
        iconTheme: const IconThemeData(color: _lightOnSurface),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        elevation: 1,
        shadowColor: Colors.black45,
        surfaceTintColor: _lightSurfaceTint,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: _lightSurfaceContainer,
      ),

      // Filled Button Theme (M3 primary button)
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: _lightPrimary,
          foregroundColor: _lightOnPrimary,
          elevation: 1,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          textStyle: GoogleFonts.roboto(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _lightPrimary,
          side: const BorderSide(color: _lightOutline, width: 1),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          textStyle: GoogleFonts.roboto(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _lightPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          textStyle: GoogleFonts.roboto(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Input Decoration Theme (M3 style)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _lightSurfaceContainerHigh,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _lightPrimary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _lightError, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _lightError, width: 2),
        ),
        labelStyle: GoogleFonts.roboto(
          color: _lightOnSurfaceVariant,
        ),
        hintStyle: GoogleFonts.roboto(
          color: _lightOnSurfaceVariant.withOpacity(0.7),
        ),
        errorStyle: GoogleFonts.roboto(
          color: _lightError,
          fontSize: 12,
        ),
        prefixIconColor: _lightOnSurfaceVariant,
        suffixIconColor: _lightOnSurfaceVariant,
      ),

      // Navigation Bar Theme (M3)
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: _lightSurfaceContainer,
        indicatorColor: _lightPrimaryContainer,
        surfaceTintColor: Colors.transparent,
        elevation: 3,
        height: 80,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.roboto(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _lightOnSurface,
            );
          }
          return GoogleFonts.roboto(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: _lightOnSurfaceVariant,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(
              color: _lightOnPrimaryContainer,
              size: 24,
            );
          }
          return const IconThemeData(
            color: _lightOnSurfaceVariant,
            size: 24,
          );
        }),
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: _lightPrimaryContainer,
        foregroundColor: _lightOnPrimaryContainer,
        elevation: 3,
        highlightElevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: _lightSurfaceContainerHigh,
        selectedColor: _lightPrimaryContainer,
        labelStyle: GoogleFonts.roboto(
          fontSize: 14,
          color: _lightOnSurface,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        side: BorderSide.none,
      ),

      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: _lightSurfaceContainerHigh,
        surfaceTintColor: _lightSurfaceTint,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        titleTextStyle: GoogleFonts.roboto(
          fontSize: 24,
          fontWeight: FontWeight.w500,
          color: _lightOnSurface,
        ),
        contentTextStyle: GoogleFonts.roboto(
          fontSize: 14,
          color: _lightOnSurfaceVariant,
        ),
      ),

      // Snackbar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: _lightInverseSurface,
        contentTextStyle: GoogleFonts.roboto(
          color: _lightInverseOnSurface,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),

      // List Tile Theme
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        titleTextStyle: GoogleFonts.roboto(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: _lightOnSurface,
        ),
        subtitleTextStyle: GoogleFonts.roboto(
          fontSize: 14,
          color: _lightOnSurfaceVariant,
        ),
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: _lightOutlineVariant,
        thickness: 1,
        space: 1,
      ),

      // Tab Bar Theme
      tabBarTheme: TabBarThemeData(
        labelColor: _lightPrimary,
        unselectedLabelColor: _lightOnSurfaceVariant,
        indicatorColor: _lightPrimary,
        labelStyle: GoogleFonts.roboto(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.roboto(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // ===========================================================================
  // DARK THEME
  // ===========================================================================

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: _darkPrimary,
        onPrimary: _darkOnPrimary,
        primaryContainer: _darkPrimaryContainer,
        onPrimaryContainer: _darkOnPrimaryContainer,
        secondary: _darkSecondary,
        onSecondary: _darkOnSecondary,
        secondaryContainer: _darkSecondaryContainer,
        onSecondaryContainer: _darkOnSecondaryContainer,
        tertiary: _darkTertiary,
        onTertiary: _darkOnTertiary,
        tertiaryContainer: _darkTertiaryContainer,
        onTertiaryContainer: _darkOnTertiaryContainer,
        error: _darkError,
        onError: _darkOnError,
        errorContainer: _darkErrorContainer,
        onErrorContainer: _darkOnErrorContainer,
        surface: _darkSurface,
        onSurface: _darkOnSurface,
        surfaceContainerHighest: _darkSurfaceContainerHighest,
        surfaceContainerHigh: _darkSurfaceContainerHigh,
        surfaceContainer: _darkSurfaceContainer,
        surfaceContainerLow: _darkSurfaceContainerLow,
        surfaceContainerLowest: _darkSurfaceContainerLowest,
        surfaceVariant: _darkSurfaceVariant,
        onSurfaceVariant: _darkOnSurfaceVariant,
        outline: _darkOutline,
        outlineVariant: _darkOutlineVariant,
        shadow: Colors.black,
        scrim: Colors.black,
        inverseSurface: _darkInverseSurface,
        onInverseSurface: _darkInverseOnSurface,
        inversePrimary: _darkInversePrimary,
        surfaceTint: _darkSurfaceTint,
      ),
      scaffoldBackgroundColor: _darkBackground,
      textTheme: _textTheme.apply(
        bodyColor: _darkOnBackground,
        displayColor: _darkOnBackground,
      ),

      // AppBar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: _darkSurface,
        foregroundColor: _darkOnSurface,
        elevation: 0,
        scrolledUnderElevation: 3,
        centerTitle: true,
        titleTextStyle: GoogleFonts.roboto(
          fontSize: 22,
          fontWeight: FontWeight.w500,
          color: _darkOnSurface,
        ),
        iconTheme: const IconThemeData(color: _darkOnSurface),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        elevation: 1,
        shadowColor: Colors.black54,
        surfaceTintColor: _darkSurfaceTint,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: _darkSurfaceContainer,
      ),

      // Filled Button Theme
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: _darkPrimary,
          foregroundColor: _darkOnPrimary,
          elevation: 1,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          textStyle: GoogleFonts.roboto(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _darkPrimary,
          side: const BorderSide(color: _darkOutline, width: 1),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          textStyle: GoogleFonts.roboto(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _darkPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          textStyle: GoogleFonts.roboto(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _darkSurfaceContainerHigh,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _darkPrimary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _darkError, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _darkError, width: 2),
        ),
        labelStyle: GoogleFonts.roboto(
          color: _darkOnSurfaceVariant,
        ),
        hintStyle: GoogleFonts.roboto(
          color: _darkOnSurfaceVariant.withOpacity(0.7),
        ),
        errorStyle: GoogleFonts.roboto(
          color: _darkError,
          fontSize: 12,
        ),
        prefixIconColor: _darkOnSurfaceVariant,
        suffixIconColor: _darkOnSurfaceVariant,
      ),

      // Navigation Bar Theme
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: _darkSurfaceContainer,
        indicatorColor: _darkPrimaryContainer,
        surfaceTintColor: Colors.transparent,
        elevation: 3,
        height: 80,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.roboto(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _darkOnSurface,
            );
          }
          return GoogleFonts.roboto(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: _darkOnSurfaceVariant,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(
              color: _darkOnPrimaryContainer,
              size: 24,
            );
          }
          return const IconThemeData(
            color: _darkOnSurfaceVariant,
            size: 24,
          );
        }),
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: _darkPrimaryContainer,
        foregroundColor: _darkOnPrimaryContainer,
        elevation: 3,
        highlightElevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: _darkSurfaceContainerHigh,
        selectedColor: _darkPrimaryContainer,
        labelStyle: GoogleFonts.roboto(
          fontSize: 14,
          color: _darkOnSurface,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        side: BorderSide.none,
      ),

      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: _darkSurfaceContainerHigh,
        surfaceTintColor: _darkSurfaceTint,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        titleTextStyle: GoogleFonts.roboto(
          fontSize: 24,
          fontWeight: FontWeight.w500,
          color: _darkOnSurface,
        ),
        contentTextStyle: GoogleFonts.roboto(
          fontSize: 14,
          color: _darkOnSurfaceVariant,
        ),
      ),

      // Snackbar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: _darkInverseSurface,
        contentTextStyle: GoogleFonts.roboto(
          color: _darkInverseOnSurface,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),

      // List Tile Theme
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        titleTextStyle: GoogleFonts.roboto(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: _darkOnSurface,
        ),
        subtitleTextStyle: GoogleFonts.roboto(
          fontSize: 14,
          color: _darkOnSurfaceVariant,
        ),
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: _darkOutlineVariant,
        thickness: 1,
        space: 1,
      ),

      // Tab Bar Theme
      tabBarTheme: TabBarThemeData(
        labelColor: _darkPrimary,
        unselectedLabelColor: _darkOnSurfaceVariant,
        indicatorColor: _darkPrimary,
        labelStyle: GoogleFonts.roboto(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.roboto(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // ===========================================================================
  // TEXT THEME - Material 3 Type Scale
  // ===========================================================================

  static TextTheme get _textTheme {
    return TextTheme(
      // Display - Large display text
      displayLarge: GoogleFonts.roboto(
        fontSize: 57,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.25,
      ),
      displayMedium: GoogleFonts.roboto(
        fontSize: 45,
        fontWeight: FontWeight.w400,
      ),
      displaySmall: GoogleFonts.roboto(
        fontSize: 36,
        fontWeight: FontWeight.w400,
      ),

      // Headline - Section headings
      headlineLarge: GoogleFonts.roboto(
        fontSize: 32,
        fontWeight: FontWeight.w400,
      ),
      headlineMedium: GoogleFonts.roboto(
        fontSize: 28,
        fontWeight: FontWeight.w400,
      ),
      headlineSmall: GoogleFonts.roboto(
        fontSize: 24,
        fontWeight: FontWeight.w400,
      ),

      // Title - Card/tile titles
      titleLarge: GoogleFonts.roboto(
        fontSize: 22,
        fontWeight: FontWeight.w500,
      ),
      titleMedium: GoogleFonts.roboto(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.15,
      ),
      titleSmall: GoogleFonts.roboto(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
      ),

      // Body - Main content
      bodyLarge: GoogleFonts.roboto(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
      ),
      bodyMedium: GoogleFonts.roboto(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
      ),
      bodySmall: GoogleFonts.roboto(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
      ),

      // Label - Buttons, captions
      labelLarge: GoogleFonts.roboto(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
      ),
      labelMedium: GoogleFonts.roboto(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
      ),
      labelSmall: GoogleFonts.roboto(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
      ),
    );
  }

  // ===========================================================================
  // CUSTOM APP COLORS
  // ===========================================================================

  // Status colors for appointments/patients
  static const Color successColor = Color(0xFF4CAF50);
  static const Color warningColor = Color(0xFFFFC107);
  static const Color infoColor = Color(0xFF2196F3);
  static const Color pendingColor = Color(0xFFFF9800);
  static const Color completedColor = Color(0xFF8BC34A);
  static const Color cancelledColor = Color(0xFFF44336);

  // Additional semantic colors
  static const Color medicalTeal = Color(0xFF008080);
  static const Color dentalBlue = Color(0xFF1976D2);
  static const Color cleanWhite = Color(0xFFFAFAFA);
}
