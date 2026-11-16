import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// テーマモード管理プロバイダー
class ThemeProvider extends ChangeNotifier {
  static const String _themeModeKey = 'theme_mode';

  ThemeMode _themeMode = ThemeMode.light; // デフォルトはライトモード
  Brightness? _platformBrightness;

  ThemeMode get themeMode => _themeMode;

  /// 現在ダークモードかどうか（GAS版互換用）
  bool get isDarkMode {
    if (_themeMode == ThemeMode.dark) return true;
    if (_themeMode == ThemeMode.light) return false;
    // システム設定の場合はプラットフォームの明るさを使用
    // nullの場合は実際のシステム設定を取得（初期化完了前の対応）
    final brightness = _platformBrightness ??
        WidgetsBinding.instance.platformDispatcher.platformBrightness;
    return brightness == Brightness.dark;
  }

  /// プラットフォームの明るさを更新（システム設定時に使用）
  void updatePlatformBrightness(Brightness brightness) {
    if (_platformBrightness != brightness) {
      _platformBrightness = brightness;
      if (_themeMode == ThemeMode.system) {
        notifyListeners();
        _applySystemOverlay();
      }
    }
  }

  /// ステータスバーのアイコン色を現在のテーマに合わせる。
  /// ダーク時はヘッダーが暗色になるため light アイコン、ライト時は dark アイコン。
  void _applySystemOverlay() {
    final dark = isDarkMode;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: dark ? Brightness.light : Brightness.dark,
      statusBarBrightness: dark ? Brightness.dark : Brightness.light,
    ));
  }

  ThemeProvider() {
    _loadThemeMode();
  }

  /// 保存されたテーマモードを読み込み
  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final themeModeString = prefs.getString(_themeModeKey);

    if (themeModeString != null) {
      _themeMode = _parseThemeMode(themeModeString);
      notifyListeners();
    }
    _applySystemOverlay();
  }

  /// テーマモードを変更
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    _applySystemOverlay();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, _themeModeToString(mode));
  }

  /// ThemeModeを文字列に変換
  String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }

  /// 文字列をThemeModeに変換
  ThemeMode _parseThemeMode(String value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      default:
        return ThemeMode.system;
    }
  }

  /// テーマモード名を取得（UI表示用）
  /// 現在未使用 - SettingsScreenで_getThemeModeName()を使用（ローカライズ対応版）
  // String getThemeModeName() {
  //   switch (_themeMode) {
  //     case ThemeMode.light:
  //       return 'ライトモード';
  //     case ThemeMode.dark:
  //       return 'ダークモード';
  //     case ThemeMode.system:
  //       return 'システム設定';
  //   }
  // }

  /// ライト⇄ダーク切り替え（GAS版互換用）
  Future<void> toggleTheme() async {
    // 現在の表示状態に基づいて切り替え（system設定も考慮）
    if (isDarkMode) {
      await setThemeMode(ThemeMode.light);
    } else {
      await setThemeMode(ThemeMode.dark);
    }
  }
}
