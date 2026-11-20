import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import 'app_theme.dart';
import 'tokens.dart';

// Diagramm-Bausteine (DESIGN_SYSTEM.md §6, Diagramm-Richtlinie):
// - je Diagramm genau eine Reihe → keine Legende, der Titel benennt sie
// - dünne Marken: Balken mit 4 px gerundetem Ende auf der Grundlinie, 2 px Linien,
//   Markierungen ≥ 8 px, zurückhaltendes Raster, eine Achse
// - Werte nur selektiv beschriftet; genauer Wert per Antippen/Wischen (Tooltip)
// - Screenreader erhalten eine Textzusammenfassung

/// Ein Wert mit kurzer Achsenbeschriftung und Tooltip-Text.
@immutable
class ChartDatum {
  const ChartDatum({
    required this.value,
    required this.axisLabel,
    required this.tooltip,
  });

  final double value;
  final String axisLabel;
  final String tooltip;
}

/// «Schöne» Rasterwerte zwischen [min] und [max] (ca. [count] Stufen).
List<double> niceTicks(double min, double max, {int count = 4}) {
  if (max <= min) max = min + 1;
  final raw = (max - min) / count;
  final mag = math.pow(10, (math.log(raw) / math.ln10).floor()).toDouble();
  final norm = raw / mag;
  final step =
      (norm <= 1
          ? 1
          : norm <= 2
          ? 2
          : norm <= 2.5
          ? 2.5
          : norm <= 5
          ? 5
          : 10) *
      mag;
  final start = (min / step).floor() * step;
  final ticks = <double>[];
  for (var v = start; v <= max + step * 0.001; v += step) {
    ticks.add(double.parse(v.toStringAsFixed(6)));
  }
  if (ticks.last < max) ticks.add(ticks.last + step);
  return ticks;
}

String _fmtTick(double v) =>
    v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);

enum _Kind { bar, line }

abstract class _SzChart extends StatefulWidget {
  const _SzChart({
    required this.data,
    required this.semanticsLabel,
    required this.kind,
    this.color,
    this.height = 160,
    this.minY,
    super.key,
  });

  final List<ChartDatum> data;
  final String semanticsLabel;
  final _Kind kind;

  /// Standard: Primärfarbe des Themas.
  final Color? color;
  final double height;

  /// Untergrenze der Achse; Standard 0 bei Balken, sonst aus den Daten.
  final double? minY;
}

/// Balkendiagramm (eine Reihe), z. B. Eisbäder pro Woche.
class SzBarChart extends _SzChart {
  const SzBarChart({
    required super.data,
    required super.semanticsLabel,
    super.color,
    super.height,
    super.key,
  }) : super(kind: _Kind.bar, minY: 0);

  @override
  State<SzBarChart> createState() => _ChartState<SzBarChart>();
}

/// Liniendiagramm (eine Reihe), z. B. Dauer oder Temperatur je Session.
class SzLineChart extends _SzChart {
  const SzLineChart({
    required super.data,
    required super.semanticsLabel,
    super.color,
    super.height,
    super.minY,
    super.key,
  }) : super(kind: _Kind.line);

  @override
  State<SzLineChart> createState() => _ChartState<SzLineChart>();
}

class _ChartState<T extends _SzChart> extends State<T> {
  int? _selected;

  static const _leftAxis = 30.0;
  static const _bottomAxis = 20.0;
  static const _top = 8.0;

  int _indexAt(double dx, double width) {
    final plot = width - _leftAxis;
    final n = widget.data.length;
    final i = ((dx - _leftAxis) / plot * n).floor();
    return i.clamp(0, n - 1);
  }

  @override
  void didUpdateWidget(T old) {
    super.didUpdateWidget(old);
    if (_selected != null && _selected! >= widget.data.length) _selected = null;
  }

  @override
  Widget build(BuildContext context) {
    final p = context.sz;
    final color = widget.color ?? p.accentPrimary;
    if (widget.data.isEmpty) {
      return SizedBox(
        height: widget.height,
        child: Center(
          child: Text(
            'Noch keine Daten',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      );
    }
    return Semantics(
      label: widget.semanticsLabel,
      excludeSemantics: true,
      child: LayoutBuilder(
        builder: (context, c) {
          final width = c.maxWidth;
          void select(Offset pos) =>
              setState(() => _selected = _indexAt(pos.dx, width));
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (d) {
              final i = _indexAt(d.localPosition.dx, width);
              setState(() => _selected = _selected == i ? null : i);
            },
            onHorizontalDragStart: (d) => select(d.localPosition),
            onHorizontalDragUpdate: (d) => select(d.localPosition),
            child: SizedBox(
              height: widget.height,
              width: width,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _ChartPainter(
                        kind: widget.kind,
                        values: [for (final d in widget.data) d.value],
                        labels: [for (final d in widget.data) d.axisLabel],
                        minY: widget.minY,
                        selected: _selected,
                        color: color,
                        surface: p.bgSurface,
                        grid: p.borderSubtle,
                        text: p.textSecondary,
                        insets: const EdgeInsets.fromLTRB(
                          _leftAxis,
                          _top,
                          0,
                          _bottomAxis,
                        ),
                      ),
                    ),
                  ),
                  if (_selected != null) _tooltip(context, width),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _tooltip(BuildContext context, double width) {
    final p = context.sz;
    final n = widget.data.length;
    final slot = (width - _leftAxis) / n;
    final x = _leftAxis + slot * (_selected! + 0.5);
    const w = 150.0;
    final left = (x - w / 2).clamp(0.0, math.max(0.0, width - w)).toDouble();
    return Positioned(
      left: left,
      top: -6,
      width: w,
      child: IgnorePointer(
        child: Container(
          key: const Key('chart-tooltip'),
          padding: const EdgeInsets.symmetric(
            horizontal: SzSpacing.s,
            vertical: SzSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: p.bgElevated,
            borderRadius: BorderRadius.circular(SzRadius.s),
            border: Border.all(color: p.borderSubtle),
          ),
          child: Text(
            widget.data[_selected!].tooltip,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: p.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _ChartPainter extends CustomPainter {
  _ChartPainter({
    required this.kind,
    required this.values,
    required this.labels,
    required this.minY,
    required this.selected,
    required this.color,
    required this.surface,
    required this.grid,
    required this.text,
    required this.insets,
  });

  final _Kind kind;
  final List<double> values;
  final List<String> labels;
  final double? minY;
  final int? selected;
  final Color color;
  final Color surface;
  final Color grid;
  final Color text;
  final EdgeInsets insets;

  @override
  void paint(Canvas canvas, Size size) {
    final plot = insets.deflateRect(Offset.zero & size);
    final dataMin = values.reduce(math.min);
    final dataMax = values.reduce(math.max);
    final lo = minY ?? (dataMin - (dataMax - dataMin) * 0.15).floorToDouble();
    final ticks = niceTicks(lo, math.max(dataMax, lo + 1));
    final yMin = ticks.first, yMax = ticks.last;
    double y(double v) =>
        plot.bottom - (v - yMin) / (yMax - yMin) * plot.height;

    // Raster (zurückhaltend) + Achsenwerte
    final gridPaint = Paint()
      ..color = grid
      ..strokeWidth = 1;
    for (final t in ticks) {
      final yy = y(t);
      canvas.drawLine(Offset(plot.left, yy), Offset(plot.right, yy), gridPaint);
      _label(
        canvas,
        _fmtTick(t),
        Offset(plot.left - 6, yy),
        align: Alignment.centerRight,
      );
    }

    final n = values.length;
    final slot = plot.width / n;
    final dim = selected == null ? 1.0 : 0.4;

    if (kind == _Kind.bar) {
      final barW = math.min(18.0, math.max(4.0, slot - 2)); // ≥ 2 px Abstand
      for (var i = 0; i < n; i++) {
        final cx = plot.left + slot * (i + 0.5);
        final top = y(values[i]);
        final h = plot.bottom - top;
        final paint = Paint()
          ..color = color.withValues(alpha: i == selected ? 1 : dim);
        if (h <= 0) {
          // 0-Wert: kurze Marke auf der Grundlinie, damit die Woche sichtbar bleibt.
          canvas.drawLine(
            Offset(cx - barW / 2, plot.bottom),
            Offset(cx + barW / 2, plot.bottom),
            Paint()
              ..color = grid
              ..strokeWidth = 2,
          );
          continue;
        }
        final r = math.min(4.0, barW / 2);
        canvas.drawRRect(
          RRect.fromRectAndCorners(
            Rect.fromLTRB(cx - barW / 2, top, cx + barW / 2, plot.bottom),
            topLeft: Radius.circular(r),
            topRight: Radius.circular(r),
          ),
          paint,
        );
      }
    } else {
      final pts = [
        for (var i = 0; i < n; i++)
          Offset(plot.left + slot * (i + 0.5), y(values[i])),
      ];
      final path = Path()..moveTo(pts.first.dx, pts.first.dy);
      for (final pt in pts.skip(1)) {
        path.lineTo(pt.dx, pt.dy);
      }
      canvas.drawPath(
        path,
        Paint()
          ..color = color.withValues(alpha: selected == null ? 1 : 0.6)
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke
          ..strokeJoin = StrokeJoin.round
          ..strokeCap = StrokeCap.round,
      );
      // Markierung nur am letzten bzw. ausgewählten Punkt (mit Ring in Flächenfarbe).
      final mark = selected ?? n - 1;
      if (selected != null) {
        canvas.drawLine(
          Offset(pts[mark].dx, plot.top),
          Offset(pts[mark].dx, plot.bottom),
          Paint()
            ..color = text.withValues(alpha: 0.5)
            ..strokeWidth = 1,
        );
      }
      canvas.drawCircle(pts[mark], 6, Paint()..color = surface);
      canvas.drawCircle(pts[mark], 4.5, Paint()..color = color);
    }

    // Achsenbeschriftung unten: nur erste, mittlere und letzte (keine Überlappung).
    final show = <int>{0, n - 1, if (n > 4) (n - 1) ~/ 2};
    for (final i in show) {
      final cx = plot.left + slot * (i + 0.5);
      final align = i == 0 && n > 1
          ? Alignment.topLeft
          : i == n - 1 && n > 1
          ? Alignment.topRight
          : Alignment.topCenter;
      _label(
        canvas,
        labels[i],
        Offset(
          i == 0 && n > 1
              ? cx - slot / 2
              : i == n - 1 && n > 1
              ? cx + slot / 2
              : cx,
          plot.bottom + 4,
        ),
        align: align,
      );
    }
  }

  void _label(
    Canvas canvas,
    String s,
    Offset anchor, {
    required Alignment align,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: s,
        style: TextStyle(
          color: text,
          fontSize: 10,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final dx = switch (align.x) {
      -1 => 0.0,
      1 => -tp.width,
      _ => -tp.width / 2,
    };
    final dy = switch (align.y) {
      -1 => 0.0,
      _ => -tp.height / 2,
    };
    tp.paint(canvas, anchor + Offset(dx, dy));
  }

  @override
  bool shouldRepaint(_ChartPainter old) =>
      old.values != values ||
      old.selected != selected ||
      old.color != color ||
      old.labels != labels;
}
