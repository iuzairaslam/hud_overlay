import 'package:flutter/material.dart';

/// Defines where the HUD indicator card is positioned on screen.
enum HudPosition {
  /// Centered on screen (default).
  center,

  /// Anchored to the top third of the screen.
  top,

  /// Anchored to the bottom third of the screen.
  bottom,
}

/// Immutable visual configuration for a [HudOverlay].
///
/// Pass a [HudTheme] to [HudOverlay.theme], [HudScope.defaultTheme], or
/// any [HudService] call to customise the appearance of the overlay.
///
/// Two ready-made presets are available — [HudTheme.light] and
/// [HudTheme.dark] — which you can further tweak with [copyWith].
@immutable
class HudTheme {
  /// Creates a [HudTheme].
  ///
  /// All parameters are optional; each has a sensible default.
  const HudTheme({
    this.barrierColor = Colors.black54,
    this.blur = 0.0,
    this.indicator,
    this.successWidget,
    this.errorWidget,
    this.infoWidget,
    this.messageStyle,
    this.detailStyle,
    this.animationDuration = const Duration(milliseconds: 200),
    this.animationCurve = Curves.easeInOut,
    this.position = HudPosition.center,
    this.containerDecoration,
    this.containerPadding,
    this.enableHaptics = false,
    this.gracePeriod = Duration.zero,
    this.minShowDuration = Duration.zero,
    this.interactive = false,
    this.cancelButtonStyle,
  });

  /// A light preset: white rounded card on a faint scrim with dark text.
  ///
  /// Combine with [copyWith] to fine-tune:
  /// ```dart
  /// HudTheme.light().copyWith(blur: 8);
  /// ```
  factory HudTheme.light() => HudTheme(
        barrierColor: const Color(0x33000000),
        containerDecoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1F000000),
              blurRadius: 24,
              offset: Offset(0, 8),
            ),
          ],
        ),
        messageStyle: const TextStyle(
          color: Color(0xFF1C1C1E),
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        detailStyle: const TextStyle(
          color: Color(0xFF8E8E93),
          fontSize: 12.5,
        ),
      );

  /// A dark preset: charcoal rounded card on a dim scrim with white text.
  factory HudTheme.dark() => HudTheme(
        barrierColor: const Color(0x66000000),
        containerDecoration: BoxDecoration(
          color: const Color(0xE5202024),
          borderRadius: BorderRadius.circular(14),
        ),
        messageStyle: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        detailStyle: const TextStyle(
          color: Color(0xB3FFFFFF),
          fontSize: 12.5,
        ),
      );

  /// The colour drawn behind the indicator card.
  ///
  /// Set to [Colors.transparent] to show only the card with no scrim.
  final Color barrierColor;

  /// Backdrop blur radius in logical pixels.
  ///
  /// Set to a value > 0 to enable a [BackdropFilter] blur behind the overlay.
  /// A value of 6.0 produces a pleasant frosted-glass effect.
  final double blur;

  /// The loading indicator widget.
  ///
  /// Defaults to [CircularProgressIndicator.adaptive] so it renders as a
  /// Cupertino activity indicator on iOS and a Material spinner on Android.
  final Widget? indicator;

  /// Widget shown during [HudState.success].
  ///
  /// Defaults to a green [Icons.check_circle_outline] icon.
  final Widget? successWidget;

  /// Widget shown during [HudState.error].
  ///
  /// Defaults to a red [Icons.error_outline] icon.
  final Widget? errorWidget;

  /// Widget shown during [HudState.info].
  ///
  /// Defaults to a blue [Icons.info_outline] icon.
  final Widget? infoWidget;

  /// Text style applied to the primary message.
  final TextStyle? messageStyle;

  /// Text style applied to the secondary detail line.
  final TextStyle? detailStyle;

  /// Duration of the fade-in / fade-out animation.
  final Duration animationDuration;

  /// Curve used for the fade animation.
  final Curve animationCurve;

  /// Where the indicator card is anchored on screen.
  final HudPosition position;

  /// Decoration applied to the indicator card container.
  ///
  /// When `null` (default) no card is rendered — the indicator floats
  /// directly over the barrier. Pass a [BoxDecoration] to opt in to a card:
  ///
  /// ```dart
  /// containerDecoration: BoxDecoration(
  ///   color: Colors.white,
  ///   borderRadius: BorderRadius.circular(16),
  /// )
  /// ```
  final BoxDecoration? containerDecoration;

  /// Padding inside the indicator card container.
  final EdgeInsets? containerPadding;

  /// Whether to fire platform haptic feedback when the overlay transitions to
  /// the success, error, or info state.
  ///
  /// Defaults to `false`. Success/info use a light impact, error uses a
  /// heavy impact.
  final bool enableHaptics;

  /// Delay before the overlay actually fades in.
  ///
  /// If the overlay is dismissed before this period elapses, it never becomes
  /// visible. Use this to avoid a distracting flash for very fast operations.
  ///
  /// Defaults to [Duration.zero] (show immediately).
  final Duration gracePeriod;

  /// Minimum time the overlay stays visible once shown.
  ///
  /// A dismiss requested before this period elapses is deferred until it does,
  /// preventing a jarring flicker when an operation finishes almost instantly.
  ///
  /// Defaults to [Duration.zero] (dismiss immediately when asked).
  final Duration minShowDuration;

  /// When `true`, the barrier does not block touches — the UI beneath the
  /// overlay stays interactive (like SVProgressHUD's `maskType: none`).
  ///
  /// Defaults to `false` (the overlay blocks all input while visible).
  final bool interactive;

  /// Style for the optional cancel button shown when `onCancel` is provided.
  final ButtonStyle? cancelButtonStyle;

  /// Returns a copy of this theme with the given fields replaced.
  HudTheme copyWith({
    Color? barrierColor,
    double? blur,
    Widget? indicator,
    Widget? successWidget,
    Widget? errorWidget,
    Widget? infoWidget,
    TextStyle? messageStyle,
    TextStyle? detailStyle,
    Duration? animationDuration,
    Curve? animationCurve,
    HudPosition? position,
    BoxDecoration? containerDecoration,
    EdgeInsets? containerPadding,
    bool? enableHaptics,
    Duration? gracePeriod,
    Duration? minShowDuration,
    bool? interactive,
    ButtonStyle? cancelButtonStyle,
  }) {
    return HudTheme(
      barrierColor: barrierColor ?? this.barrierColor,
      blur: blur ?? this.blur,
      indicator: indicator ?? this.indicator,
      successWidget: successWidget ?? this.successWidget,
      errorWidget: errorWidget ?? this.errorWidget,
      infoWidget: infoWidget ?? this.infoWidget,
      messageStyle: messageStyle ?? this.messageStyle,
      detailStyle: detailStyle ?? this.detailStyle,
      animationDuration: animationDuration ?? this.animationDuration,
      animationCurve: animationCurve ?? this.animationCurve,
      position: position ?? this.position,
      containerDecoration: containerDecoration ?? this.containerDecoration,
      containerPadding: containerPadding ?? this.containerPadding,
      enableHaptics: enableHaptics ?? this.enableHaptics,
      gracePeriod: gracePeriod ?? this.gracePeriod,
      minShowDuration: minShowDuration ?? this.minShowDuration,
      interactive: interactive ?? this.interactive,
      cancelButtonStyle: cancelButtonStyle ?? this.cancelButtonStyle,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HudTheme &&
        other.barrierColor == barrierColor &&
        other.blur == blur &&
        other.indicator == indicator &&
        other.successWidget == successWidget &&
        other.errorWidget == errorWidget &&
        other.infoWidget == infoWidget &&
        other.messageStyle == messageStyle &&
        other.detailStyle == detailStyle &&
        other.animationDuration == animationDuration &&
        other.animationCurve == animationCurve &&
        other.position == position &&
        other.containerDecoration == containerDecoration &&
        other.containerPadding == containerPadding &&
        other.enableHaptics == enableHaptics &&
        other.gracePeriod == gracePeriod &&
        other.minShowDuration == minShowDuration &&
        other.interactive == interactive &&
        other.cancelButtonStyle == cancelButtonStyle;
  }

  @override
  int get hashCode => Object.hashAll([
        barrierColor,
        blur,
        indicator,
        successWidget,
        errorWidget,
        infoWidget,
        messageStyle,
        detailStyle,
        animationDuration,
        animationCurve,
        position,
        containerDecoration,
        containerPadding,
        enableHaptics,
        gracePeriod,
        minShowDuration,
        interactive,
        cancelButtonStyle,
      ]);
}
