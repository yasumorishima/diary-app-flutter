import 'package:diary_app/services/age_signals_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AgeSignals.fromMap', () {
    test('null / error → none', () {
      expect(AgeSignals.fromMap(null).mandatory, isFalse);
      final e = AgeSignals.fromMap({'error': -3});
      expect(e.mandatory, isFalse);
      expect(e.ageUpper, isNull);
    });

    test('not mandatory', () {
      final s = AgeSignals.fromMap({'mandatory': false});
      expect(s.mandatory, isFalse);
      expect(s.isMinor, isFalse);
    });

    test('shared range', () {
      final s = AgeSignals.fromMap(
          {'mandatory': true, 'status': 1, 'ageLower': 13, 'ageUpper': 15});
      expect(s.mandatory, isTrue);
      expect(s.ageLower, 13);
      expect(s.ageUpper, 15);
      expect(s.isMinor, isTrue);
      expect(s.isUnder13, isFalse);
    });
  });
}
