/// Formatiert eine Dauer als `m:ss` bzw. `h:mm:ss` ab einer Stunde.
///
/// Sekundenbruchteile werden abgeschnitten (nicht gerundet), damit der Timer
/// nie eine Sekunde zu früh springt.
String formatTimer(Duration d) {
  final total = d.isNegative ? 0 : d.inSeconds;
  final h = total ~/ 3600;
  final m = (total % 3600) ~/ 60;
  final s = total % 60;
  String two(int v) => v.toString().padLeft(2, '0');
  return h > 0 ? '$h:${two(m)}:${two(s)}' : '${two(m)}:${two(s)}';
}
