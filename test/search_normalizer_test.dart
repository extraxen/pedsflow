import 'package:flutter_test/flutter_test.dart';
import 'package:pediatric_night_companion/services/search_normalizer.dart';

void main() {
  group('SearchNormalizer', () {
    test('normalizes common misspellings and brand names', () {
      expect(SearchNormalizer.normalize('vomitting'), 'vomiting');
      expect(SearchNormalizer.normalize('Gravol'), 'dimenhydrinate');
      expect(SearchNormalizer.normalize('Zofran'), 'ondansetron');
      expect(SearchNormalizer.normalize('PNA'), 'pneumonia');
      expect(SearchNormalizer.normalize('status asthma'), 'status asthmaticus');
    });

    test('normalizes aliases inside multi-word queries', () {
      expect(
        SearchNormalizer.normalize('severe pna'),
        'severe pneumonia',
      );
    });

    test('requires every query token to match', () {
      expect(
        SearchNormalizer.matches(
          'pediatric severe pneumonia respiratory support',
          'severe pneumonia',
        ),
        isTrue,
      );
      expect(
        SearchNormalizer.matches(
          'pediatric pneumonia',
          'severe pneumonia',
        ),
        isFalse,
      );
    });

    test('ranks exact and prefix matches first', () {
      expect(SearchNormalizer.rank('DKA', 'dka'), 0);
      expect(SearchNormalizer.rank('DKA cerebral injury', 'dka'), 1);
      expect(SearchNormalizer.rank('Pediatric DKA', 'dka'), 2);
    });
  });
}
