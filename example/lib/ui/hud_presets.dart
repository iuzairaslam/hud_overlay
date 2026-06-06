import 'package:flutter/material.dart';
import 'package:hud_overlay/hud_overlay.dart';

import 'tokens.dart';

/// Shared HUD themes for the demos so the loader text stays readable on the
/// light demo backdrop. (In real apps you'd typically use [HudTheme.dark].)
abstract class Hud {
  /// White rounded card, soft shadow, dark text — the default demo look.
  static const light = HudTheme(
    barrierColor: Color(0x40000000),
    containerDecoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.all(Radius.circular(18)),
      boxShadow: [
        BoxShadow(color: Color(0x1F000000), blurRadius: 28, offset: Offset(0, 10)),
      ],
    ),
    containerPadding: EdgeInsets.symmetric(horizontal: 30, vertical: 26),
    messageStyle: T.hudDarkMessage,
    detailStyle: T.hudDarkDetail,
  );

  /// Light card without a scrim — used for non-blocking / interactive demos.
  static const lightNoScrim = HudTheme(
    barrierColor: Colors.transparent,
    interactive: true,
    containerDecoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.all(Radius.circular(18)),
      boxShadow: [
        BoxShadow(color: Color(0x29000000), blurRadius: 28, offset: Offset(0, 10)),
      ],
    ),
    containerPadding: EdgeInsets.symmetric(horizontal: 26, vertical: 22),
    messageStyle: T.hudDarkMessage,
    detailStyle: T.hudDarkDetail,
  );
}
