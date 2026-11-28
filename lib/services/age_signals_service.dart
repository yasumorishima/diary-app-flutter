import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Play Age Signals API の結果（android/.../AgeSignalsChannel.kt が返す Map）。
@immutable
class AgeSignals {
  /// このユーザーに年齢シグナルの共有義務がかかっているか
  /// （米カリフォルニア州 AB 1043・ブラジル Digital ECA など）。
  final bool mandatory;

  /// 年齢帯の下限・上限。共有されなかったときは両方 null、18 歳以上は上限が null。
  final int? ageLower;
  final int? ageUpper;

  const AgeSignals({this.mandatory = false, this.ageLower, this.ageUpper});

  static const none = AgeSignals();

  factory AgeSignals.fromMap(Map<Object?, Object?>? map) {
    if (map == null || map['error'] != null) return none;
    return AgeSignals(
      mandatory: map['mandatory'] == true,
      ageLower: map['ageLower'] as int?,
      ageUpper: map['ageUpper'] as int?,
    );
  }

  /// 18 歳未満と分かっている（上限が 17 以下）
  bool get isMinor => ageUpper != null && ageUpper! < 18;

  /// 13 歳未満と分かっている（上限が 12 以下）
  bool get isUnder13 => ageUpper != null && ageUpper! < 13;
}

/// 起動のたびに年齢シグナルを要求する（AB 1043 は起動時の要求を開発者に求めている）。
///
/// 共有義務がないユーザーには何も表示しない。失敗・タイムアウト・Android 以外は
/// [AgeSignals.none] になり、アプリは今までどおり動く。アプリには広告も年齢で変える機能も
/// 無いので、受け取った年齢帯は使わず、保存も送信もしない。
class AgeSignalsService {
  AgeSignalsService._();
  static final AgeSignalsService instance = AgeSignalsService._();

  static const _channel = MethodChannel('com.diary.daily/age_signals');

  /// Play のプロンプトにユーザーが答えるのを待つので長めに取る。
  static const _timeout = Duration(seconds: 30);

  Future<AgeSignals>? _result;

  /// 起動ごとに一度だけ問い合わせ、以降は同じ結果を返す。
  Future<AgeSignals> check() => _result ??= _check();

  Future<AgeSignals> _check() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return AgeSignals.none;
    }
    try {
      final map = await _channel
          .invokeMapMethod<Object?, Object?>('check')
          .timeout(_timeout);
      return AgeSignals.fromMap(map);
    } catch (e) {
      debugPrint('Age signals unavailable: $e');
      return AgeSignals.none;
    }
  }
}
