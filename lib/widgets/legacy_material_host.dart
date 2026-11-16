// table_calendar（使っている 3.2.0・最新の 3.3.0 とも）は見出しの左右ボタンと表示切替ボタンを
// package:flutter/material.dart（旧 material ライブラリ）の InkWell と Theme で描く。
// 今のカレンダー画面は見出しを隠している（headerVisible: false）ので、それらは作られない。
// それでも包んでおくのは、見出しを出した日に、押した瞬間に落ちる形を残さないため。
// 旧ライブラリの InkWell は旧ライブラリの Material を祖先に要求し、無いと押した時点で落ちる。
// 色は旧ライブラリの Theme から読む。アプリは package:material_ui へ移ったので、
// その画面の中にはどちらも無い。そこで、旧ライブラリのウィジェットを使う所だけをこれで包む。
//
// MaterialUiCompatibilityBridge（material_ui が用意した移行用の包み）が旧 Theme と旧
// Localizations を渡し、透明な旧 Material が InkWell の土台になる。どちらも移行用で
// deprecated なので、このファイルの中だけ警告を止める。table_calendar が material_ui へ
// 移ったら、このファイルごと消す。
// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart' as legacy;
import 'package:material_ui/material_ui.dart';

/// 旧 material ライブラリのウィジェットを material_ui の画面の中で動かすための包み。
class LegacyMaterialHost extends StatelessWidget {
  const LegacyMaterialHost({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MaterialUiCompatibilityBridge(
      child: legacy.Material(
        type: legacy.MaterialType.transparency,
        child: child,
      ),
    );
  }
}
