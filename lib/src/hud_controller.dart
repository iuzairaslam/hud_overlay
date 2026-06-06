import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'hud_state.dart';
import 'hud_theme.dart';

/// Internal controller that drives the overlay lifecycle for a single named key.
///
/// Each active overlay (identified by an optional key string) gets its own
/// [HudController]. The controller owns the [AnimationController] and the
/// [ValueNotifier] that the overlay widget subscribes to.
///
/// It also enforces the [HudTheme.gracePeriod] (delay before showing) and
/// [HudTheme.minShowDuration] (anti-flicker minimum) policies, and fires
/// haptic feedback on terminal states when [HudTheme.enableHaptics] is set.
class HudController with ChangeNotifier {
  /// Creates a [HudController] with the given [vsync] provider.
  HudController({required TickerProvider vsync})
      : _animationController = AnimationController(
          vsync: vsync,
          duration: const Duration(milliseconds: 200),
        );

  final AnimationController _animationController;
  Timer? _autoDismissTimer;
  Timer? _graceTimer;
  Timer? _minShowTimer;

  /// When the overlay last became visible — used to enforce [minShowDuration].
  DateTime? _shownAt;

  /// Whether the fade-in has been issued (and not yet reversed).
  bool _visible = false;

  HudStatus _status = const HudStatus(state: HudState.hidden);
  HudTheme _theme = const HudTheme();

  /// The current status snapshot.
  HudStatus get status => _status;

  /// The active theme.
  HudTheme get theme => _theme;

  /// The fade animation driven by [_animationController].
  Animation<double> get animation => _animationController;

  /// Shows the loading state with optional [progress], [message], [detail] and
  /// [theme].
  ///
  /// Honours [HudTheme.gracePeriod]: when set, the overlay does not fade in
  /// until the grace period elapses, and a [dismiss] before then cancels it
  /// without ever flashing on screen.
  void show({
    double? progress,
    String? message,
    String? detail,
    HudTheme? theme,
  }) {
    _cancelTimers();
    _theme = theme ?? const HudTheme();
    _animationController.duration = _theme.animationDuration;
    _status = HudStatus(
      state: HudState.loading,
      progress: progress,
      message: message,
      detail: detail,
    );
    notifyListeners();

    if (_theme.gracePeriod > Duration.zero && !_visible) {
      _graceTimer = Timer(_theme.gracePeriod, () {
        _graceTimer = null;
        _beginShow();
      });
    } else {
      _beginShow();
    }
  }

  /// Transitions the overlay to the success state, then auto-dismisses.
  ///
  /// When [autoDismiss] is `null`, the duration is derived from the message
  /// length (floored at 1.5s, capped at 5s).
  void showSuccess({
    String? message,
    String? detail,
    Duration? autoDismiss,
    HudTheme? theme,
  }) {
    _showTerminal(
      HudState.success,
      message: message,
      detail: detail,
      autoDismiss: autoDismiss,
      theme: theme,
      heavyHaptic: false,
    );
  }

  /// Transitions the overlay to the error state, then auto-dismisses.
  void showError({
    String? message,
    String? detail,
    Duration? autoDismiss,
    HudTheme? theme,
  }) {
    _showTerminal(
      HudState.error,
      message: message,
      detail: detail,
      autoDismiss: autoDismiss,
      theme: theme,
      heavyHaptic: true,
    );
  }

  /// Transitions the overlay to the informational state, then auto-dismisses.
  void showInfo({
    String? message,
    String? detail,
    Duration? autoDismiss,
    HudTheme? theme,
  }) {
    _showTerminal(
      HudState.info,
      message: message,
      detail: detail,
      autoDismiss: autoDismiss,
      theme: theme,
      heavyHaptic: false,
    );
  }

  void _showTerminal(
    HudState state, {
    String? message,
    String? detail,
    Duration? autoDismiss,
    HudTheme? theme,
    required bool heavyHaptic,
  }) {
    _cancelTimers();
    if (theme != null) _theme = theme;
    _animationController.duration = _theme.animationDuration;
    _status = HudStatus(state: state, message: message, detail: detail);
    notifyListeners();
    _beginShow();

    if (_theme.enableHaptics) {
      if (heavyHaptic) {
        HapticFeedback.heavyImpact();
      } else {
        HapticFeedback.lightImpact();
      }
    }

    _autoDismissTimer = Timer(_resolveAutoDismiss(autoDismiss, message), dismiss);
  }

  /// Updates the deterministic [progress] value (0.0–1.0) while loading.
  void updateProgress(double progress) {
    if (_status.state != HudState.loading) return;
    _status = HudStatus(
      state: HudState.loading,
      progress: progress.clamp(0.0, 1.0),
      message: _status.message,
      detail: _status.detail,
    );
    notifyListeners();
  }

  /// Fades the overlay out and transitions to [HudState.hidden].
  ///
  /// Respects [HudTheme.gracePeriod] (cancels a not-yet-shown overlay) and
  /// [HudTheme.minShowDuration] (defers dismissal until the minimum has
  /// elapsed).
  void dismiss() {
    _autoDismissTimer?.cancel();
    _autoDismissTimer = null;

    // Still inside the grace period — the overlay never became visible.
    if (_graceTimer != null) {
      _graceTimer!.cancel();
      _graceTimer = null;
      _setHidden();
      return;
    }

    // Enforce the minimum visible duration before fading out.
    final shownAt = _shownAt;
    if (shownAt != null && _theme.minShowDuration > Duration.zero) {
      final elapsed = DateTime.now().difference(shownAt);
      if (elapsed < _theme.minShowDuration) {
        _minShowTimer?.cancel();
        _minShowTimer = Timer(_theme.minShowDuration - elapsed, _reverseToHidden);
        return;
      }
    }

    _reverseToHidden();
  }

  void _beginShow() {
    _visible = true;
    _shownAt ??= DateTime.now();
    _animationController.forward();
  }

  void _reverseToHidden() {
    _minShowTimer?.cancel();
    _minShowTimer = null;
    _animationController.reverse().whenComplete(_setHidden);
  }

  void _setHidden() {
    _visible = false;
    _shownAt = null;
    _status = const HudStatus(state: HudState.hidden);
    notifyListeners();
  }

  /// Derives an auto-dismiss duration from the message length when not given,
  /// mirroring SVProgressHUD: ~0.06s per character, floored at 1.5s.
  Duration _resolveAutoDismiss(Duration? explicit, String? message) {
    if (explicit != null) return explicit;
    final length = message?.length ?? 0;
    final millis = (length * 60 + 500).clamp(1500, 5000);
    return Duration(milliseconds: millis);
  }

  void _cancelTimers() {
    _autoDismissTimer?.cancel();
    _autoDismissTimer = null;
    _graceTimer?.cancel();
    _graceTimer = null;
    _minShowTimer?.cancel();
    _minShowTimer = null;
  }

  @override
  void dispose() {
    _cancelTimers();
    _animationController.dispose();
    super.dispose();
  }
}
