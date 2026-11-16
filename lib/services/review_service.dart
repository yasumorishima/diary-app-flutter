import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// アプリ内レビュー依頼（In-App Review API）。
/// 一定回数 日記を保存した満足ユーザーに、一度だけ控えめに評価を依頼する。
class ReviewService {
  static const String _kSaveCount = 'review_save_count';
  static const String _kRequested = 'review_requested';
  static const int _threshold = 3;

  /// 日記保存のたびに呼ぶ。閾値到達かつ未依頼なら In-App Review を要求する。
  static Future<void> onEntrySaved() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_kRequested) ?? false) {
      return;
    }
    final count = (prefs.getInt(_kSaveCount) ?? 0) + 1;
    await prefs.setInt(_kSaveCount, count);
    if (count < _threshold) {
      return;
    }
    final inAppReview = InAppReview.instance;
    if (await inAppReview.isAvailable()) {
      await inAppReview.requestReview();
      await prefs.setBool(_kRequested, true);
    }
  }
}
