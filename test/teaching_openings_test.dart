import 'package:flutter_test/flutter_test.dart';

import 'package:satranc_2d/features/coach/teaching_openings.dart';

void main() {
  test('Vezir gambiti tam satır', () {
    final m = TeachingOpenings.bestMatch(['d2d4', 'd7d5', 'c2c4']);
    expect(m?.name, 'Vezir gambiti');
  });

  test('İtalyan beş hamle', () {
    final m = TeachingOpenings.bestMatch([
      'e2e4',
      'e7e5',
      'g1f3',
      'b8c6',
      'f1c4',
    ]);
    expect(m?.name, 'İtalyan oyunu');
  });

  test('İngiliz c2c4', () {
    final m = TeachingOpenings.bestMatch(['c2c4']);
    expect(m?.name, 'İngiliz başlangıcı');
  });
}
