import 'package:flutter_test/flutter_test.dart';
import 'package:diary_app/models/diary_entry.dart';

void main() {
  group('DiaryEntry.generateId', () {
    test('zero-pads month and day', () {
      expect(DiaryEntry.generateId(DateTime(2026, 1, 5)), '2026-01-05');
      expect(DiaryEntry.generateId(DateTime(2026, 12, 31)), '2026-12-31');
    });
  });

  group('DiaryEntry.tagList', () {
    DiaryEntry entryWithTags(String tags) => DiaryEntry(
          id: '2026-01-01',
          date: DateTime(2026, 1, 1),
          content: 'content',
          tags: tags,
        );

    test('empty tags returns empty list', () {
      expect(entryWithTags('').tagList, isEmpty);
    });

    test('splits on half-width comma', () {
      expect(entryWithTags('a,b').tagList, ['a', 'b']);
    });

    test('splits on Japanese touten and full-width comma', () {
      expect(entryWithTags('仕事、家族，旅行').tagList,
          ['仕事', '家族', '旅行']);
    });

    test('trims whitespace and drops empty segments', () {
      expect(entryWithTags(' a , , b ').tagList, ['a', 'b']);
    });
  });

  group('DiaryEntry date helpers', () {
    test('monthDay zero-pads and year extracts', () {
      final e = DiaryEntry(
        id: '2026-03-07',
        date: DateTime(2026, 3, 7),
        content: 'x',
      );
      expect(e.monthDay, '03/07');
      expect(e.year, 2026);
    });
  });
}
