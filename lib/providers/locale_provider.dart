import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 言語設定を管理するProvider
class LocaleProvider with ChangeNotifier {
  Locale? _locale;

  Locale? get locale => _locale;

  /// 対応言語リスト
  static const List<Locale> supportedLocales = [
    Locale('ja'), // 日本語
    Locale('en'), // 英語
    Locale('zh'), // 中国語（簡体字）
    Locale('ko'), // 韓国語
    Locale('es'), // スペイン語
    Locale('pt'), // ポルトガル語
    Locale('hi'), // ヒンディー語
    Locale('id'), // インドネシア語
    Locale('fr'), // フランス語
    Locale('de'), // ドイツ語
  ];

  /// 言語名マップ
  static const Map<String, String> localeNames = {
    'ja': '日本語',
    'en': 'English',
    'zh': '中文（简体）',
    'ko': '한국어',
    'es': 'Español',
    'pt': 'Português',
    'hi': 'हिन्दी',
    'id': 'Bahasa Indonesia',
    'fr': 'Français',
    'de': 'Deutsch',
  };

  /// 初期化（SharedPreferencesから言語設定を読み込み）
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final localeCode = prefs.getString('locale');
    if (localeCode != null) {
      _locale = Locale(localeCode);
      notifyListeners();
    }
  }

  /// 言語を変更
  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;

    _locale = locale;
    notifyListeners();

    // SharedPreferencesに保存
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('locale', locale.languageCode);
  }

  /// 言語をクリア（システム言語に戻す）
  Future<void> clearLocale() async {
    _locale = null;
    notifyListeners();

    // SharedPreferencesから削除
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('locale');
  }

  /// 指定した言語コードが対応言語かチェック
  bool isSupported(String languageCode) {
    return supportedLocales.any((locale) => locale.languageCode == languageCode);
  }

  /// 現在の言語名を取得
  String getCurrentLocaleName() {
    if (_locale == null) return 'システム設定';
    return localeNames[_locale!.languageCode] ?? _locale!.languageCode;
  }
}
