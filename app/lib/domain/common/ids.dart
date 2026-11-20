import 'dart:math';

final Random _random = Random.secure();

/// Erzeugt eine UUIDv7 (RFC 9562): zeitlich sortierbar, offline eindeutig.
///
/// Aufbau: 48 Bit Unix-Zeit in ms · Version 7 · 74 Bit Zufall.
String newId({DateTime? now}) {
  final ms = (now ?? DateTime.now()).millisecondsSinceEpoch;
  final bytes = List<int>.generate(16, (_) => _random.nextInt(256));
  for (var i = 0; i < 6; i++) {
    bytes[i] = (ms >> (8 * (5 - i))) & 0xff;
  }
  bytes[6] = (bytes[6] & 0x0f) | 0x70; // Version 7
  bytes[8] = (bytes[8] & 0x3f) | 0x80; // Variante RFC 9562
  final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
      '${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
}
