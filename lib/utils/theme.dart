import 'package:material_ui/material_ui.dart';
import 'constants.dart';

/// アプリのテーマ設定（ゆるのり ポップ版）
///
/// 明るい・楽しい・ポップ・チャンキー。紫グラデ(#667eea→#764ba2)は廃止。
class AppTheme {
  // ---- ポップ配色パレット ----
  static const Color popPink = Color(0xFFFF8FD0);
  static const Color popPink2 = Color(0xFFFF6FB5);
  static const Color popPinkText = Color(0xFFFF5A9E);
  static const Color popYellow = Color(0xFFFFD166);
  static const Color popYellow2 = Color(0xFFFFD93D);
  static const Color popSky = Color(0xFF4D96FF);
  static const Color popSky2 = Color(0xFF5C9BFF);
  static const Color popMint = Color(0xFF43D19E);
  static const Color popMint2 = Color(0xFF6BCB77);
  static const Color popGrape = Color(0xFF8A5CFF);
  static const Color popGrapeShadow = Color(0xFF6A3FE0);
  static const Color popOrange = Color(0xFFFFB03B);

  // ライト
  static const Color lightBg = Color(0xFFFFF7FB);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightText = Color(0xFF2B2B3A);
  static const Color lightSubText = Color(0xFF8A8AA0);

  // ダーク（暗すぎない、グレープ寄りのポップ暗色）
  static const Color darkBg = Color(0xFF241F2B);
  static const Color darkCard = Color(0xFF2E2836);
  static const Color darkText = Color(0xFFF2ECF7);
  static const Color darkSubText = Color(0xFFB9AECB);

  /// ホームのヘッダーグラデ（ピンク→サニー黄）
  static const List<Color> headerGradient = [popPink, popYellow];

  /// 「書く」系ヘッダー/ボタンのグラデ（グレープ→スカイ）
  static const List<Color> writeGradient = [popGrape, popSky2];

  /// 画面背景のグラデ（ほんのりポップ）
  static List<Color> pageGradient(bool isDark) => isDark
      ? const [Color(0xFF2A2333), Color(0xFF241F2B)]
      : const [Color(0xFFFFF0F8), Color(0xFFFFF7FB)];

  static Color cardColor(bool isDark) => isDark ? darkCard : lightCard;
  static Color textColor(bool isDark) => isDark ? darkText : lightText;
  static Color subTextColor(bool isDark) => isDark ? darkSubText : lightSubText;

  /// アクセントグラデをダーク時だけ暗く落とす（ヘッダーの眩しさ対策）。
  /// 各色を darkBg 方向へ寄せ、色味だけ残した暗色バンドにする。
  static List<Color> dimForDark(List<Color> colors, bool isDark) {
    if (!isDark) return colors;
    return [for (final c in colors) Color.lerp(c, darkBg, 0.80)!];
  }

  /// ライトテーマ
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: popGrape,
        secondary: popPink2,
        surface: lightCard,
        onPrimary: Colors.white,
        onSurface: lightText,
      ),
      scaffoldBackgroundColor: lightBg,
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: lightCard,
        foregroundColor: lightText,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: lightCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFFAF8FF),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.all(AppConstants.paddingMedium),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: popGrape,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingLarge,
            vertical: AppConstants.paddingMedium,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: popPink2,
        foregroundColor: Colors.white,
      ),
    );
  }

  /// ダークテーマ
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: popPink,
        secondary: popSky,
        surface: darkCard,
        onPrimary: Color(0xFF2B2137),
        onSurface: darkText,
      ),
      scaffoldBackgroundColor: darkBg,
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: darkCard,
        foregroundColor: darkText,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF352E40),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.all(AppConstants.paddingMedium),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: popPink2,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.paddingLarge,
            vertical: AppConstants.paddingMedium,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: popPink2,
        foregroundColor: Colors.white,
      ),
    );
  }
}
