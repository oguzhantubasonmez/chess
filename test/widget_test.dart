import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:satranc_2d/app.dart';

void main() {
  testWidgets('Menüden yerel oyuna girince tahta ve beyaz sırası görünür', (WidgetTester tester) async {
    await tester.pumpWidget(const SatrancApp());
    expect(find.text('Satranç 2D'), findsWidgets);
    await tester.ensureVisible(
      find.byKey(const ValueKey<String>('menu_local_2p')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey<String>('menu_local_2p')));
    // Oyun ekranında AmbientParticlesLayer sürekli animasyon; pumpAndSettle bitmez.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 320));
    expect(find.textContaining('Beyaz'), findsOneWidget);
    expect(find.textContaining('koç şeridi'), findsOneWidget);
  });
}
