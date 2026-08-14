// Regression tests for the responsive Taboo card: it must render every word
// without overflowing, at both a tiny (squeezed) and a large card size.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tabiu/data/models/card_model.dart';
import 'package:tabiu/widgets/tabiu_card.dart';

const _front = TabooCard(
  id: 'a',
  main: 'TOTEM',
  forbidden: ['Batıl', 'Şans', 'İnanç', 'Survivor', 'Uğur'],
);
const _back = TabooCard(
  id: 'b',
  main: 'TERMOMETRE',
  forbidden: ['Ateş', 'Derece', 'Ölçmek', 'Cıva', 'Hasta'],
);

Future<void> _pumpCard(WidgetTester tester, Size size) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: size.width,
            height: size.height,
            child: const TabiuCard(
              front: _front,
              back: _back,
              showingBack: false,
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 100));
}

void main() {
  testWidgets('card fits and shows all words when squeezed (285x300)',
      (tester) async {
    await _pumpCard(tester, const Size(285, 300));
    expect(tester.takeException(), isNull); // no overflow
    expect(find.text('TOTEM'), findsOneWidget);
    for (final w in _front.forbidden) {
      expect(find.text(w), findsOneWidget);
    }
  });

  testWidgets('card fits and shows all words at a large size (360x640)',
      (tester) async {
    await _pumpCard(tester, const Size(360, 640));
    expect(tester.takeException(), isNull);
    expect(find.text('TOTEM'), findsOneWidget);
    for (final w in _front.forbidden) {
      expect(find.text(w), findsOneWidget);
    }
  });
}
