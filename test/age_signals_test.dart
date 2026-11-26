import 'package:diary_app/services/age_signals_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

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

  group('adConfigFor', () {
    test('unknown age or adult → leave AdMob defaults', () {
      expect(adConfigFor(AgeSignals.none), isNull);
      expect(adConfigFor(const AgeSignals(mandatory: true)), isNull);
      expect(
          adConfigFor(const AgeSignals(mandatory: true, ageLower: 18)), isNull);
    });

    test('13-17 → under age of consent, PG', () {
      for (final range in [(13, 15), (16, 17)]) {
        final c = adConfigFor(
            AgeSignals(mandatory: true, ageLower: range.$1, ageUpper: range.$2))!;
        expect(c.tagForUnderAgeOfConsent, TagForUnderAgeOfConsent.yes);
        expect(c.tagForChildDirectedTreatment,
            TagForChildDirectedTreatment.unspecified);
        expect(c.maxAdContentRating, MaxAdContentRating.pg);
      }
    });

    test('0-12 → child-directed, G', () {
      final c = adConfigFor(
          const AgeSignals(mandatory: true, ageLower: 0, ageUpper: 12))!;
      expect(c.tagForChildDirectedTreatment, TagForChildDirectedTreatment.yes);
      expect(c.tagForUnderAgeOfConsent, TagForUnderAgeOfConsent.yes);
      expect(c.maxAdContentRating, MaxAdContentRating.g);
    });
  });
}
