import 'package:flutter/material.dart';

import 'hud_service.dart';
import 'hud_theme.dart';

/// App-level widget that registers the [HudService] with the widget tree.
///
/// [HudScope] hosts its own [Overlay], so it works no matter where you place
/// it. The recommended placement is [MaterialApp.builder] so the HUD renders
/// above every route:
///
/// ```dart
/// MaterialApp(
///   builder: (context, child) => HudScope(child: child!),
///   home: MyHomePage(),
/// )
/// ```
///
/// It also works as the direct child of [MaterialApp]:
/// ```dart
/// MaterialApp(home: HudScope(child: MyHomePage()))
/// ```
class HudScope extends StatefulWidget {
  /// Creates a [HudScope].
  const HudScope({
    super.key,
    required this.child,
    this.defaultTheme,
    this.autoDismissOnNavigation = false,
  });

  /// The widget subtree that gains access to [HudService].
  final Widget child;

  /// App-wide default theme applied when no per-call theme is provided.
  final HudTheme? defaultTheme;

  /// When `true`, [HudService] auto-dismisses all active overlays whenever a
  /// new route is pushed.
  ///
  /// This requires [HudService.navigatorObserver] to be registered on your
  /// app's navigator, since a descendant widget cannot observe an ancestor
  /// [Navigator] on its own:
  ///
  /// ```dart
  /// MaterialApp(
  ///   navigatorObservers: [HudService.navigatorObserver],
  ///   home: HudScope(autoDismissOnNavigation: true, child: MyHome()),
  /// )
  /// ```
  final bool autoDismissOnNavigation;

  @override
  State<HudScope> createState() => _HudScopeState();
}

class _HudScopeState extends State<HudScope> {
  // HudScope owns this Overlay so HUD entries have a guaranteed host,
  // independent of where the scope is placed in the tree.
  final GlobalKey<OverlayState> _overlayKey = GlobalKey<OverlayState>();

  @override
  void initState() {
    super.initState();
    // Defer until the Overlay we build below has been created.
    WidgetsBinding.instance.addPostFrameCallback((_) => _register());
  }

  void _register() {
    if (!mounted) return;
    final overlay = _overlayKey.currentState;
    if (overlay == null) return;
    HudService.instance.registerScope(
      overlay,
      context,
      widget.defaultTheme,
      autoDismissOnNavigation: widget.autoDismissOnNavigation,
    );
  }

  @override
  void didUpdateWidget(HudScope oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.defaultTheme != widget.defaultTheme) {
      HudService.instance.updateDefaultTheme(widget.defaultTheme);
    }
    if (oldWidget.autoDismissOnNavigation != widget.autoDismissOnNavigation) {
      HudService.instance.setAutoDismissOnNavigation(
        widget.autoDismissOnNavigation,
      );
    }
  }

  @override
  void dispose() {
    HudService.instance.unregisterScope();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Overlay(
      key: _overlayKey,
      initialEntries: [
        OverlayEntry(
          opaque: true,
          maintainState: true,
          builder: (_) => widget.child,
        ),
      ],
    );
  }
}
