// PedsFlow - Proprietary Software
// Copyright (c) 2026 Ahmed Saleh. All rights reserved.
// See LICENSE in the repository root.
// Third-party materials remain subject to their respective licenses.
class SearchNormalizer {
  static const Map<String, String> aliases = <String, String>{
    'vomitting': 'vomiting',
    'emesis': 'vomiting',
    'gravol': 'dimenhydrinate',
    'zofran': 'ondansetron',
    'hypok': 'hypokalemia',
    'hypophos': 'hypophosphatemia',
    'bronch': 'bronchiolitis',
    'pna': 'pneumonia',
    'icp': 'raised intracranial pressure',
    'chs': 'cannabis hyperemesis syndrome',
    'tylenol': 'acetaminophen',
    'paracetamol': 'acetaminophen',
    'motrin': 'ibuprofen',
    'advil': 'ibuprofen',
    'dilaudid': 'hydromorphone',
    'epi': 'epinephrine',
    'status asthma': 'status asthmaticus',
    'rsi': 'rapid sequence intubation',
    'dka cerebral edema': 'cerebral edema in dka',
  };

  static String normalize(String value) {
    final String raw = value.trim().toLowerCase().replaceAll(
          RegExp(r'\s+'),
          ' ',
        );
    if (raw.isEmpty) {
      return '';
    }

    final String? phraseAlias = aliases[raw];
    if (phraseAlias != null) {
      return phraseAlias;
    }

    return raw
        .split(' ')
        .map((String token) => aliases[token] ?? token)
        .join(' ');
  }

  static bool matches(String searchableText, String normalizedQuery) {
    if (normalizedQuery.isEmpty) {
      return false;
    }
    final String haystack = searchableText.toLowerCase();
    return normalizedQuery
        .split(' ')
        .every((String token) => haystack.contains(token));
  }

  static int rank(String title, String normalizedQuery) {
    final String normalizedTitle = title.toLowerCase();
    if (normalizedTitle == normalizedQuery) {
      return 0;
    }
    if (normalizedTitle.startsWith(normalizedQuery)) {
      return 1;
    }
    if (normalizedTitle.split(' ').contains(normalizedQuery)) {
      return 2;
    }
    return 3;
  }
}

