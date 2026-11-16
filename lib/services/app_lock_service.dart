import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

/// アプリロック状態の保持と FLAG_SECURE 制御
///
/// ロック有効状態をメモリにキャッシュし、lifecycle コールバックから
/// 同期的に参照できるようにする（pause 時の再ロックを遅延させない）。
class AppLockService {
  static final AppLockService instance = AppLockService._init();
  AppLockService._init();

  static const MethodChannel _channel =
      MethodChannel('com.diary.daily/secure');

  /// ロック有効フラグ（起動時に load() でキャッシュ）
  bool enabled = false;

  Future<void> load() async {
    if (kIsWeb) return;
    final prefs = await SharedPreferences.getInstance();
    enabled = prefs.getBool(AppConstants.prefAppLockEnabled) ?? false;
    await _applySecureFlag();
  }

  Future<void> setEnabled(bool value) async {
    enabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.prefAppLockEnabled, value);
    await _applySecureFlag();
  }

  /// ロック有効中は FLAG_SECURE を常時 ON にして、リセント（タスク切替）の
  /// サムネイルとスクリーンショットの両方から日記本文を守る。
  /// （pause 後にロック画面を描画する方式ではスナップショット取得に
  /// 間に合わないことがあるため、フラグの常時 ON で防ぐ）
  Future<void> _applySecureFlag() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
    try {
      await _channel.invokeMethod(enabled ? 'enableSecure' : 'disableSecure');
    } on PlatformException {
      // ネイティブ側未実装等は無視（ロック自体は機能する）
    } on MissingPluginException {
      // ユニットテスト環境等
    }
  }
}
