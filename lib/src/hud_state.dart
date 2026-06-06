/// The possible visual states of a HUD overlay.
enum HudState {
  /// The overlay is not visible.
  hidden,

  /// A loading spinner / progress indicator is shown.
  loading,

  /// A success icon is shown (auto-dismisses after `autoDismiss`).
  success,

  /// An error icon is shown (auto-dismisses after `autoDismiss`).
  error,

  /// An informational icon is shown (auto-dismisses after `autoDismiss`).
  info,
}

/// A snapshot of the current HUD state, carried through the widget tree.
class HudStatus {
  /// Creates a [HudStatus].
  const HudStatus({
    required this.state,
    this.progress,
    this.message,
    this.detail,
  });

  /// The current visual state.
  final HudState state;

  /// Deterministic progress in the range [0.0, 1.0].
  ///
  /// `null` means indeterminate (spinning indicator).
  final double? progress;

  /// Optional primary text displayed below the indicator.
  final String? message;

  /// Optional secondary text displayed below [message].
  final String? detail;

  /// Returns `true` when the overlay should be visible.
  bool get isVisible => state != HudState.hidden;

  @override
  String toString() => 'HudStatus(state: $state, progress: $progress, '
      'message: $message, detail: $detail)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HudStatus &&
        other.state == state &&
        other.progress == progress &&
        other.message == message &&
        other.detail == detail;
  }

  @override
  int get hashCode => Object.hash(state, progress, message, detail);
}
