import 'package:flutter/material.dart';

/// Nexpill's look: the SuperDaveLab family palette.
///
/// Every app in the family — GridDock, LedgerSprout, Ebb, Nexpill — shares
/// one look, so these colours are the family's design tokens (navy ink on
/// warm paper, a cyan-teal accent, amber and red for attention), copied
/// from GridDock's `web/app.css`. Change them there first, then here; don't
/// give Nexpill colours of its own.
///
/// Legibility comes first: Nexpill is read by tired people, often at night,
/// sometimes in a hurry. Figtree for text, Fraunces for titles and the
/// numbers that matter, as in Ebb.
///
/// Fonts are bundled (assets/fonts, SIL OFL). Never fetch them at runtime:
/// Nexpill has no network, by design.
class NexpillPalette {
  const NexpillPalette({
    required this.primary,
    required this.onPrimary,
    required this.background,
    required this.card,
    required this.ink,
    required this.muted,
    required this.line,
    required this.soon,
    required this.late,
    required this.ok,
  });

  final Color primary;
  final Color onPrimary;
  final Color background;
  final Color card;
  final Color ink;
  final Color muted;
  final Color line;

  /// Due soon, or running low.
  final Color soon;

  /// Overdue, missed, out of stock — and errors.
  final Color late;

  /// Can be given now.
  final Color ok;

  // Family tokens: --accent, --paper, --surface, --ink, --muted, --line,
  // --warn, --danger, --ok.
  static const light = NexpillPalette(
    primary: Color(0xFF0E7490),
    onPrimary: Color(0xFFFFFFFF),
    background: Color(0xFFF5F1E8),
    card: Color(0xFFFFFFFF),
    ink: Color(0xFF112031),
    muted: Color(0xFF5B6B7A),
    line: Color(0xFFD9E2EC),
    soon: Color(0xFFB45309),
    late: Color(0xFFB91C1C),
    ok: Color(0xFF166534),
  );

  static const dark = NexpillPalette(
    primary: Color(0xFF22D3EE),
    onPrimary: Color(0xFF0F1620),
    background: Color(0xFF0F1620),
    card: Color(0xFF1E2939),
    ink: Color(0xFFE2E8F0),
    muted: Color(0xFF94A3B8),
    line: Color(0x29E2E8F0), // ink at 16%
    soon: Color(0xFFFBBF24),
    late: Color(0xFFF87171),
    ok: Color(0xFF4ADE80),
  );
}

/// Status colours for widgets that need more than [ColorScheme].
class StatusColors extends ThemeExtension<StatusColors> {
  const StatusColors({required this.soon, required this.late, required this.ok});

  final Color soon;
  final Color late;
  final Color ok;

  static StatusColors of(BuildContext context) =>
      Theme.of(context).extension<StatusColors>()!;

  @override
  StatusColors copyWith({Color? soon, Color? late, Color? ok}) => StatusColors(
      soon: soon ?? this.soon, late: late ?? this.late, ok: ok ?? this.ok);

  @override
  StatusColors lerp(StatusColors? other, double t) => other == null
      ? this
      : StatusColors(
          soon: Color.lerp(soon, other.soon, t)!,
          late: Color.lerp(late, other.late, t)!,
          ok: Color.lerp(ok, other.ok, t)!,
        );
}

class NexpillTheme {
  static ThemeData light() => _build(NexpillPalette.light, Brightness.light);
  static ThemeData dark() => _build(NexpillPalette.dark, Brightness.dark);

  static const serif = 'Fraunces';
  static const sans = 'Figtree';

  /// The bundled fonts are variable: Flutter needs the weight axis set
  /// explicitly, not just [FontWeight].
  static TextStyle font(
    String family,
    double size,
    double weight, {
    double? height,
    double? spacing,
    Color? color,
  }) =>
      TextStyle(
        fontFamily: family,
        fontSize: size,
        fontWeight: FontWeight.values[((weight / 100).round() - 1).clamp(0, 8)],
        fontVariations: [
          FontVariation('wght', weight),
          if (family == serif) const FontVariation('SOFT', 50),
          if (family == serif) FontVariation('opsz', size.clamp(9, 144)),
        ],
        height: height,
        letterSpacing: spacing,
        color: color,
      );

  static ThemeData _build(NexpillPalette p, Brightness brightness) {
    final scheme = ColorScheme(
      brightness: brightness,
      primary: p.primary,
      onPrimary: p.onPrimary,
      primaryContainer:
          Color.alphaBlend(p.primary.withValues(alpha: 0.14), p.card),
      onPrimaryContainer: p.primary,
      secondary: p.primary,
      onSecondary: p.onPrimary,
      secondaryContainer:
          Color.alphaBlend(p.primary.withValues(alpha: 0.10), p.card),
      onSecondaryContainer: p.primary,
      error: p.late,
      onError: brightness == Brightness.light ? Colors.white : Colors.black,
      surface: p.background,
      onSurface: p.ink,
      onSurfaceVariant: p.muted,
      surfaceContainerLowest: p.card,
      surfaceContainerLow: p.card,
      surfaceContainer: p.card,
      surfaceContainerHigh: p.card,
      surfaceContainerHighest: p.line,
      outline: p.muted,
      outlineVariant: p.line,
    );

    final text = TextTheme(
      displaySmall: font(serif, 34, 560, height: 1.1, color: p.ink),
      headlineMedium: font(serif, 28, 540, height: 1.15, color: p.ink),
      headlineSmall: font(serif, 24, 540, height: 1.2, color: p.ink),
      titleLarge: font(serif, 21, 580, height: 1.25, color: p.ink),
      titleMedium: font(sans, 16.5, 640, height: 1.3, color: p.ink),
      titleSmall: font(sans, 14, 650, height: 1.3, spacing: 0.2, color: p.ink),
      bodyLarge: font(sans, 16.5, 430, height: 1.45, color: p.ink),
      bodyMedium: font(sans, 15, 430, height: 1.45, color: p.ink),
      bodySmall: font(sans, 13, 450, height: 1.4, color: p.muted),
      labelLarge: font(sans, 15.5, 620, spacing: 0.1),
      labelMedium: font(sans, 13, 600, spacing: 0.2, color: p.muted),
      labelSmall: font(sans, 11.5, 650, spacing: 0.6, color: p.muted),
    );

    final rounded =
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16));

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      textTheme: text,
      fontFamily: sans,
      scaffoldBackgroundColor: p.background,
      extensions: [StatusColors(soon: p.soon, late: p.late, ok: p.ok)],
      appBarTheme: AppBarTheme(
        backgroundColor: p.background,
        foregroundColor: p.ink,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        elevation: 0,
        titleTextStyle: font(serif, 23, 580, color: p.ink),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: p.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: p.line),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 50),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: text.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 50),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: text.labelLarge,
          side: BorderSide(color: p.line),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
            foregroundColor: p.primary, textStyle: text.labelLarge),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: p.card,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: p.line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: p.line),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: p.card,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        titleTextStyle: text.titleLarge,
        contentTextStyle: text.bodyMedium,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: p.card,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: p.ink,
        contentTextStyle: font(sans, 14.5, 500, color: p.background),
        shape: rounded,
      ),
      dividerTheme: DividerThemeData(color: p.line, thickness: 1, space: 1),
      listTileTheme: ListTileThemeData(
        iconColor: p.muted,
        titleTextStyle: text.bodyLarge,
        subtitleTextStyle: text.bodySmall,
      ),
      switchTheme: const SwitchThemeData(
        trackOutlineColor: WidgetStatePropertyAll(Colors.transparent),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: p.primary,
        foregroundColor: p.onPrimary,
        elevation: 1,
        shape: rounded,
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          selectedBackgroundColor:
              Color.alphaBlend(p.primary.withValues(alpha: 0.16), p.card),
          selectedForegroundColor: p.primary,
          side: BorderSide(color: p.line),
        ),
      ),
    );
  }
}
