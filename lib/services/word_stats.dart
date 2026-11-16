import '../models/diary_entry.dart';

/// 頻出語の軽量抽出（完全オンデバイス、採点や感情分析は行わない）。
///
/// 形態素解析なしで、漢字の連続(2字以上)・カタカナの連続(2字以上)・
/// 英単語(3字以上)を語の候補として数える。楽しい「よく使った言葉」表示用。
class WordStats {
  WordStats._();

  static final RegExp _kanjiRun = RegExp(r'[一-鿿々]{2,}');
  static final RegExp _katakanaRun = RegExp(r'[ァ-ヴー]{2,}');
  static final RegExp _latinWord = RegExp(r'[a-z]{3,}');
  static final RegExp _onlyChoon = RegExp(r'^ー+$');

  static const Set<String> _stopWordsJa = {
    '今日', '昨日', '明日', '明後日', '一日', '毎日', '今週', '先週',
    '来週', '今月', '先月', '来月', '今年', '去年', '来年', '時間',
    '時期', '今回', '前回', '次回', '最近', '本当', '感じ', '気分',
    '気持', '日記', '自分', '場合', '結局', '結構', '全然', '途中',
    '普通', '予定', '状態', '最初', '最後',
  };

  static const Set<String> _stopWordsEn = {
    'the', 'and', 'was', 'were', 'that', 'this', 'with', 'have', 'has',
    'had', 'for', 'but', 'not', 'you', 'are', 'they', 'day', 'today',
    'about', 'just', 'what', 'when', 'will', 'would', 'could', 'than',
    'then', 'them', 'from', 'there', 'here', 'very', 'really', 'much',
    'more', 'some', 'went', 'get', 'got', 'did', 'because',
  };

  /// 頻出語を出現回数の多い順に返す。
  static List<MapEntry<String, int>> topWords(
    Iterable<DiaryEntry> entries, {
    int limit = 5,
  }) {
    final counts = <String, int>{};
    for (final entry in entries) {
      for (final regex in [_kanjiRun, _katakanaRun]) {
        for (final match in regex.allMatches(entry.content)) {
          final word = match.group(0)!;
          if (word.length > 10) continue;
          if (_onlyChoon.hasMatch(word)) continue;
          if (_stopWordsJa.contains(word)) continue;
          counts[word] = (counts[word] ?? 0) + 1;
        }
      }
      for (final match in _latinWord.allMatches(entry.content.toLowerCase())) {
        final word = match.group(0)!;
        if (_stopWordsEn.contains(word)) continue;
        counts[word] = (counts[word] ?? 0) + 1;
      }
    }
    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(limit).toList();
  }
}
