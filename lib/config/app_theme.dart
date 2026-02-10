import 'package:flutter/material.dart';

/// ไฟล์เก็บสีและ styling ที่ใช้ทั่วทั้งแอป
class AppTheme {
  // ============ สี ============
  static const Color primaryColor = Color(0xFF037D5B); // สีเขียวหลัก
  static const Color primaryLight = Color(0xFF05A040);
  static const Color primaryDark = Color(0xFF03754C);
  static const Color secondaryColor = Color(0xFF5A87D9);
  static const Color accentColor = Color(0xFFA480E1);
  
  static const Color backgroundColor = Color(0xFFF8FFF4); // สีพื้นหลัง
  static const Color surfaceColor = Colors.white;
  static const Color errorColor = Colors.red;
  static const Color successColor = Colors.green;
  static const Color warningColor = Colors.orange;
  
  static const Color textPrimaryColor = Colors.black87;
  static const Color textSecondaryColor = Colors.black54;
  static const Color textHintColor = Colors.black38;

  // ============ Padding/Spacing ============
  static const double paddingXS = 4;
  static const double paddingS = 8;
  static const double paddingM = 12;
  static const double paddingL = 16;
  static const double paddingXL = 24;
  static const double paddingXXL = 32;

  // ============ Border Radius ============
  static const double radiusSmall = 4;
  static const double radiusMedium = 8;
  static const double radiusLarge = 12;
  static const double radiusXL = 16;

  // ============ Text Styles ============
  static const TextStyle headingLarge = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: textPrimaryColor,
  );

  static const TextStyle headingMedium = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: textPrimaryColor,
  );

  static const TextStyle headingSmall = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: textPrimaryColor,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: textPrimaryColor,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: textPrimaryColor,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: textSecondaryColor,
  );

  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: textPrimaryColor,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: textPrimaryColor,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    color: textSecondaryColor,
  );

  // ============ Theme Data for MaterialApp ============
  static ThemeData getTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: secondaryColor,
        tertiary: accentColor,
        surface: surfaceColor,
        error: errorColor,
      ),
      scaffoldBackgroundColor: backgroundColor,
      
      // AppBar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),

      // Button Styles
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            horizontal: paddingXL,
            vertical: paddingM,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusLarge),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor, width: 2),
          padding: const EdgeInsets.symmetric(
            horizontal: paddingXL,
            vertical: paddingM,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusLarge),
          ),
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
        ),
        margin: const EdgeInsets.all(paddingM),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey[100],
        contentPadding: const EdgeInsets.symmetric(
          horizontal: paddingL,
          vertical: paddingM,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        labelStyle: const TextStyle(color: textPrimaryColor),
        hintStyle: const TextStyle(color: textHintColor),
      ),

      // Text Themes
      textTheme: const TextTheme(
        displayLarge: headingLarge,
        displayMedium: headingMedium,
        displaySmall: headingSmall,
        headlineMedium: headingMedium,
        headlineSmall: headingSmall,
        titleLarge: labelLarge,
        titleMedium: labelMedium,
        titleSmall: labelSmall,
        bodyLarge: bodyLarge,
        bodyMedium: bodyMedium,
        bodySmall: bodySmall,
        labelLarge: labelLarge,
        labelMedium: labelMedium,
        labelSmall: labelSmall,
      ),

      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
        ),
        elevation: 4,
      ),
    );
  }

  // ============ Custom Button Styles ============
  static ButtonStyle primaryButtonStyle() => ElevatedButton.styleFrom(
    backgroundColor: primaryColor,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(
      horizontal: paddingXL,
      vertical: paddingM,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusLarge),
    ),
  );

  static ButtonStyle secondaryButtonStyle() => ElevatedButton.styleFrom(
    backgroundColor: secondaryColor,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(
      horizontal: paddingXL,
      vertical: paddingM,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusLarge),
    ),
  );

  static ButtonStyle dangerButtonStyle() => ElevatedButton.styleFrom(
    backgroundColor: errorColor,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(
      horizontal: paddingXL,
      vertical: paddingM,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusLarge),
    ),
  );

  // ============ Custom Box Decoration ============
  static BoxDecoration get cardDecoration => BoxDecoration(
    color: surfaceColor,
    borderRadius: BorderRadius.circular(radiusLarge),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ],
  );

  static BoxDecoration get inputDecoration => BoxDecoration(
    color: Colors.grey[50],
    borderRadius: BorderRadius.circular(radiusMedium),
    border: Border.all(color: Colors.grey[300]!),
  );

  // ============ Status Colors ============
  static Color getStatusColor(int status) {
    switch (status) {
      case 1:
        return Colors.blue;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  static String getStatusText(int status) {
    switch (status) {
      case 1:
        return 'รอดำเนินการ';
      case 2:
        return 'กำลังดำเนินการ';
      case 3:
        return 'สำเร็จ';
      default:
        return 'ไม่ระบุ';
    }
  }
}
