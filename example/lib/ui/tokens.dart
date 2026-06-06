import 'package:flutter/material.dart';

/// Shared design tokens so every demo screen looks consistent and
/// presentation-ready for README / pub.dev screenshots.
abstract class T {
  // Surfaces
  static const bg = Color(0xFFF2F2F7);
  static const card = Colors.white;
  static const stage = Color(0xFFFFFFFF);

  // Text
  static const ink = Color(0xFF1C1C1E);
  static const sub = Color(0xFF8E8E93);
  static const faint = Color(0xFFC7C7CC);

  // Accents (iOS system palette)
  static const blue = Color(0xFF007AFF);
  static const green = Color(0xFF34C759);
  static const red = Color(0xFFFF3B30);
  static const orange = Color(0xFFFF9500);
  static const purple = Color(0xFF5856D6);
  static const pink = Color(0xFFFF2D55);
  static const teal = Color(0xFF30B0C7);

  static const radius = 18.0;

  static const title = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w700,
    color: ink,
  );

  static const body = TextStyle(
    fontSize: 14,
    height: 1.4,
    color: sub,
  );

  static const code = TextStyle(
    fontSize: 12,
    fontFamily: 'monospace',
    letterSpacing: 0.2,
    color: Color(0xFF3A3A3C),
  );

  static List<BoxShadow> get shadow => const [
        BoxShadow(
          color: Color(0x14000000),
          blurRadius: 18,
          offset: Offset(0, 6),
        ),
      ];

  /// Dark loader text used on light HUD cards in the demos.
  static const hudDarkMessage = TextStyle(
    color: ink,
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );
  static const hudDarkDetail = TextStyle(
    color: sub,
    fontSize: 12.5,
  );
}
