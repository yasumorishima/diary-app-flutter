import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// 押せるものに「名前」が付いているかを機械で掃く。
///
/// TalkBack / VoiceOver は名前の無いボタンを「ボタン」としか読まない。
/// v1.0.39 は気分ボタンやお祝いだけを直していて、戻る・ダークライト切替・
/// 月送り・消す・書きかえる といった毎日押すボタンは 42 個中 22 個が
/// 名前を持っていなかった。同じ穴が空いたら、ここで落とす。
///
/// 実機の読み上げは自動では確かめられないので、
/// 「名前を渡していない押せるもの」がゼロであることだけを固定する。
void main() {
  const widgets = <String>[
    'IconButton',
    'InkWell',
    'GestureDetector',
    'FloatingActionButton',
  ];

  /// [open] の位置の '(' に対応する ')' の位置を返す。
  int matchParen(String src, int open) {
    var depth = 0;
    for (var i = open; i < src.length; i++) {
      final c = src[i];
      if (c == '(') depth++;
      if (c == ')') {
        depth--;
        if (depth == 0) return i;
      }
    }
    return src.length - 1;
  }

  test('押せるものに 読み上げ用の名前 が付いている', () {
    final files = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))
        .where((f) => !f.path.replaceAll('\\', '/').contains('/l10n/'))
        .toList()
      ..sort((a, b) => a.path.compareTo(b.path));

    var scanned = 0;
    final unnamed = <String>[];

    for (final file in files) {
      final src = file.readAsStringSync();
      for (final name in widgets) {
        for (final m in RegExp('\\b$name\\(').allMatches(src)) {
          final open = m.end - 1;
          final body = src.substring(open, matchParen(src, open) + 1);

          final hasTap =
              (body.contains('onPressed:') && !body.contains('onPressed: null')) ||
                  (body.contains('onTap:') && !body.contains('onTap: null'));
          if (!hasTap) continue;
          scanned++;

          // ExcludeSemantics は名前を「消す」側なので数えない
          String semanticsOnly(String s) => s.replaceAll('ExcludeSemantics(', '');

          final named = body.contains('tooltip:') ||
              body.contains('semanticLabel') ||
              body.contains('semanticsLabel') ||
              semanticsOnly(body).contains('Semantics(') ||
              body.contains('Text(');
          // 外側が Semantics で包んでいる場合も名前が付いている
          final before = src.substring(
              m.start - 400 < 0 ? 0 : m.start - 400, m.start);
          if (named || semanticsOnly(before).contains('Semantics(')) continue;

          final line = '\n'.allMatches(src.substring(0, m.start)).length + 1;
          unnamed.add('${file.path}:$line  $name');
        }
      }
    }

    // 掃く対象が消えてしまった（＝検査が空回りしている）ことを防ぐ
    expect(scanned, greaterThanOrEqualTo(40),
        reason: '押せるものが $scanned 個しか見つからない。検査の側が壊れていないか確かめること');
    expect(unnamed, isEmpty,
        reason: '読み上げに名前を渡していない押せるものがある:\n${unnamed.join('\n')}');
  });
}
