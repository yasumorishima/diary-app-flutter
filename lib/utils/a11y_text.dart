/// 読み上げに渡す文字。
///
/// 画面の文字には飾りの絵文字が混ざる。そのまま渡すと読み上げが
/// 「本 連用日記」「〜ですか 手をあげる」のように飾りまで読む
/// （2026-09-01 に実機のノードツリーで確認）。
/// 見た目は変えずに、読み上げへ渡す方だけ落とす。
library;

final RegExp _decoration = RegExp(
  r'[\u{1F000}-\u{1FAFF}\u{2600}-\u{27BF}\u{FE0F}\u{2190}-\u{21FF}'
  r'\u{2B00}-\u{2BFF}\u{1F1E6}-\u{1F1FF}]',
  unicode: true,
);

/// 飾りの絵文字を落とし、余った空白を詰める。
/// 絵文字しか無い文字列のときは、消してしまうと名前が無くなるので元のまま返す。
String spokenText(String text) {
  final stripped = text.replaceAll(_decoration, ' ').replaceAll(RegExp(r'\s+'), ' ').trim();
  return stripped.isEmpty ? text : stripped;
}
