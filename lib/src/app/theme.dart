import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// ProHome brend ranglari (web `index.css` bilan mos).
class AppColors {
  AppColors._();

  // Chuqurroq, "issiq" emerald — ko'zga yoqimli, ilovaga tortadigan.
  static const Color primary = Color(0xFF0BA678); // emerald
  static const Color primaryHover = Color(0xFF08926A);
  static const Color primaryDeep = Color(0xFF067A58);
  static const Color primaryBright = Color(0xFF12D89A);
  static const Color primaryLight = Color(0xFFE4F7F0);
  static const Color accent = Color(0xFFFF8A3D); // issiq to'q sariq

  // Light
  static const Color lightBg = Color(0xFFF4F6F8);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightText = Color(0xFF0F1729);
  static const Color lightMuted = Color(0xFF7A8699);
  static const Color lightBorder = Color(0xFFEDEFF3);

  // Dark
  static const Color darkBg = Color(0xFF0B0F17);
  static const Color darkSurface = Color(0xFF151B26);
  static const Color darkSurfaceAlt = Color(0xFF1E2733);
  static const Color darkText = Color(0xFFEAF1F7);
  static const Color darkMuted = Color(0xFF8494A3);
  static const Color darkBorder = Color(0xFF232D3A);

  static const Color danger = Color(0xFFF0454B);
  static const Color success = Color(0xFF0BA678);

  /// Bosh sahifa banner / tugmalar uchun gradient.
  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryBright, primary, primaryDeep],
  );
}

class AppTheme {
  AppTheme._();

  static const double radius = 22;

  /// iOS uslubidagi yumshoq soya.
  static List<BoxShadow> softShadow(Brightness b) => b == Brightness.dark
      ? const [
          BoxShadow(color: Color(0x33000000), blurRadius: 18, offset: Offset(0, 8)),
        ]
      : const [
          BoxShadow(color: Color(0x0F1B2A4A), blurRadius: 24, offset: Offset(0, 10)),
          BoxShadow(color: Color(0x08000000), blurRadius: 4, offset: Offset(0, 1)),
        ];

  static ThemeData light() => _base(
        brightness: Brightness.light,
        scheme: const ColorScheme.light(
          primary: AppColors.primary,
          onPrimary: Colors.white,
          secondary: AppColors.accent,
          onSecondary: Colors.white,
          surface: AppColors.lightSurface,
          onSurface: AppColors.lightText,
          error: AppColors.danger,
          outlineVariant: AppColors.lightBorder,
        ),
        scaffoldBg: AppColors.lightBg,
        muted: AppColors.lightMuted,
        border: AppColors.lightBorder,
      );

  static ThemeData dark() => _base(
        brightness: Brightness.dark,
        scheme: const ColorScheme.dark(
          primary: AppColors.primary,
          onPrimary: Colors.white,
          secondary: AppColors.accent,
          onSecondary: Colors.black,
          surface: AppColors.darkSurface,
          onSurface: AppColors.darkText,
          error: AppColors.danger,
          outlineVariant: AppColors.darkBorder,
        ),
        scaffoldBg: AppColors.darkBg,
        muted: AppColors.darkMuted,
        border: AppColors.darkBorder,
      );

  static ThemeData _base({
    required Brightness brightness,
    required ColorScheme scheme,
    required Color scaffoldBg,
    required Color muted,
    required Color border,
  }) {
    final textTheme = GoogleFonts.interTextTheme(
      brightness == Brightness.dark
          ? ThemeData.dark().textTheme
          : ThemeData.light().textTheme,
    ).apply(bodyColor: scheme.onSurface, displayColor: scheme.onSurface);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: scaffoldBg,
      textTheme: textTheme.copyWith(
        headlineSmall: GoogleFonts.plusJakartaSans(
          textStyle: textTheme.headlineSmall,
          fontWeight: FontWeight.w700,
        ),
        titleLarge: GoogleFonts.plusJakartaSans(
          textStyle: textTheme.titleLarge,
          fontWeight: FontWeight.w700,
        ),
        titleMedium: GoogleFonts.plusJakartaSans(
          textStyle: textTheme.titleMedium,
          fontWeight: FontWeight.w600,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: scaffoldBg,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: false,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 19,
          fontWeight: FontWeight.w700,
          color: scheme.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
          side: BorderSide(color: border),
        ),
      ),
      dividerTheme: DividerThemeData(color: border, thickness: 1, space: 1),
      chipTheme: ChipThemeData(
        backgroundColor: scheme.surface,
        side: BorderSide(color: border),
        labelStyle: TextStyle(color: scheme.onSurface, fontSize: 12.5),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: brightness == Brightness.dark
            ? AppColors.darkSurfaceAlt
            : const Color(0xFFF1F3F6),
        hintStyle: TextStyle(color: muted),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.6),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size.fromHeight(52),
          textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.onSurface,
          minimumSize: const Size.fromHeight(52),
          side: BorderSide(color: border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: brightness == Brightness.dark
            ? AppColors.primary.withValues(alpha: 0.20)
            : AppColors.primaryLight,
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        elevation: 0,
        height: 64,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: states.contains(WidgetState.selected)
                ? AppColors.primary
                : muted,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? AppColors.primary
                : muted,
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      extensions: [AppSemanticColors(muted: muted, border: border)],
    );
  }
}

/// `Theme.of(context).extension<AppSemanticColors>()!` orqali olinadi.
class AppSemanticColors extends ThemeExtension<AppSemanticColors> {
  const AppSemanticColors({required this.muted, required this.border});
  final Color muted;
  final Color border;

  @override
  AppSemanticColors copyWith({Color? muted, Color? border}) =>
      AppSemanticColors(muted: muted ?? this.muted, border: border ?? this.border);

  @override
  AppSemanticColors lerp(AppSemanticColors? other, double t) {
    if (other == null) return this;
    return AppSemanticColors(
      muted: Color.lerp(muted, other.muted, t)!,
      border: Color.lerp(border, other.border, t)!,
    );
  }
}

extension ThemeX on BuildContext {
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get texts => Theme.of(this).textTheme;
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
  Color get muted =>
      Theme.of(this).extension<AppSemanticColors>()?.muted ?? Colors.grey;
  Color get border =>
      Theme.of(this).extension<AppSemanticColors>()?.border ??
      Colors.grey.shade300;
  List<BoxShadow> get softShadow => AppTheme.softShadow(Theme.of(this).brightness);
}
