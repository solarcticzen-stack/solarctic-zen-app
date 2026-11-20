import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:solarctic_zen/core/design_system/app_theme.dart';
import 'package:solarctic_zen/core/design_system/charts.dart';

Widget host(Widget chart) => MaterialApp(
  theme: SzTheme.dark(),
  home: Scaffold(
    body: Padding(padding: const EdgeInsets.all(20), child: chart),
  ),
);

final data = [
  for (var i = 0; i < 6; i++)
    ChartDatum(
      value: i.toDouble(),
      axisLabel: 'W$i',
      tooltip: 'Woche $i: $i Eisbäder',
    ),
];

void main() {
  test('Rasterwerte sind «schön» und decken den Bereich ab', () {
    expect(niceTicks(0, 5), [0, 2, 4, 6]);
    expect(niceTicks(0, 3.4), [0, 1, 2, 3, 4]);
    final t = niceTicks(2, 14);
    expect(t.first, lessThanOrEqualTo(2));
    expect(t.last, greaterThanOrEqualTo(14));
  });

  testWidgets(
    'Balken: Antippen zeigt den genauen Wert, erneutes Antippen blendet aus',
    (tester) async {
      await tester.pumpWidget(
        host(SzBarChart(data: data, semanticsLabel: 'Eisbäder pro Woche')),
      );
      expect(find.byKey(const Key('chart-tooltip')), findsNothing);

      final box = tester.getRect(find.byType(SzBarChart));
      // Letzter Balken liegt am rechten Rand.
      final lastBar = Offset(box.right - 5, box.center.dy);
      await tester.tapAt(lastBar);
      await tester.pump();
      expect(find.text('Woche 5: 5 Eisbäder'), findsOneWidget);

      await tester.tapAt(lastBar);
      await tester.pump();
      expect(find.byKey(const Key('chart-tooltip')), findsNothing);
    },
  );

  testWidgets('Linie: Wischen wählt den Punkt unter dem Finger', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(SzLineChart(data: data, semanticsLabel: 'Dauer je Session')),
    );
    final box = tester.getRect(find.byType(SzLineChart));
    final gesture = await tester.startGesture(
      Offset(box.right - 5, box.center.dy),
    );
    await gesture.moveBy(const Offset(-20, 0));
    await tester.pump();
    expect(find.byKey(const Key('chart-tooltip')), findsOneWidget);
    await gesture.up();
  });

  testWidgets('Screenreader erhält die Zusammenfassung', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      host(
        SzBarChart(data: data, semanticsLabel: 'Eisbäder pro Woche: zuletzt 5'),
      ),
    );
    expect(
      find.bySemanticsLabel('Eisbäder pro Woche: zuletzt 5'),
      findsOneWidget,
    );
    handle.dispose();
  });

  testWidgets('Ohne Daten: Hinweis statt leerem Diagramm', (tester) async {
    await tester.pumpWidget(
      host(const SzLineChart(data: [], semanticsLabel: 'x')),
    );
    expect(find.text('Noch keine Daten'), findsOneWidget);
  });

  testWidgets('Ein einzelner Wert und lauter Nullen funktionieren', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        const SzLineChart(
          data: [ChartDatum(value: 4, axisLabel: 'A', tooltip: 'A')],
          semanticsLabel: 'x',
        ),
      ),
    );
    await tester.pumpWidget(
      host(
        SzBarChart(
          data: [
            for (var i = 0; i < 12; i++)
              ChartDatum(value: 0, axisLabel: '$i', tooltip: '$i'),
          ],
          semanticsLabel: 'x',
        ),
      ),
    );
    expect(tester.takeException(), isNull);
  });
}
