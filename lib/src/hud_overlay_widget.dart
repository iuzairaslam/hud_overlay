import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

import 'hud_state.dart';
import 'hud_theme.dart';

/// A widget that displays a loading overlay on top of [child].
///
/// The overlay is inserted into the nearest [Overlay] ancestor and fades in/out
/// based on [isLoading]. All pointer events and focus traversal are blocked
/// while the overlay is visible (unless [dismissible] is `true` or the theme is
/// [HudTheme.interactive]).
///
/// ### Basic usage
/// ```dart
/// HudOverlay(
///   isLoading: _isLoading,
///   child: MyForm(),
/// )
/// ```
class HudOverlay extends StatefulWidget {
  /// Creates a [HudOverlay].
  const HudOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.progress,
    this.message,
    this.detail,
    this.theme,
    this.semanticsLabel = 'Loading',
    this.dismissible = false,
    this.onDismiss,
    this.onCancel,
    this.cancelLabel = 'Cancel',
    this.overlayKey,
    this.externalAnimation,
    this.currentState,
  });

  /// Whether the overlay is visible.
  final bool isLoading;

  /// The widget rendered beneath the overlay.
  final Widget child;

  /// Deterministic progress in the range [0.0, 1.0].
  ///
  /// `null` renders an indeterminate spinner.
  final double? progress;

  /// Optional primary text displayed below the indicator.
  final String? message;

  /// Optional secondary text displayed below [message].
  final String? detail;

  /// Visual configuration. Falls back to [HudTheme] defaults when `null`.
  final HudTheme? theme;

  /// Accessibility label announced when the overlay appears.
  final String semanticsLabel;

  /// When `true`, tapping outside the indicator card dismisses the overlay.
  final bool dismissible;

  /// Called when the user taps outside and [dismissible] is `true`.
  final VoidCallback? onDismiss;

  /// When non-null, a cancel button is shown inside the card.
  final VoidCallback? onCancel;

  /// Label for the cancel button (shown only when [onCancel] is provided).
  final String cancelLabel;

  /// Named key for stacking support when embedding the widget directly.
  final String? overlayKey;

  /// Pre-built animation from an external [AnimationController].
  @visibleForTesting
  final Animation<double>? externalAnimation;

  /// Overrides the resolved [HudState] (used by the service bridge).
  @visibleForTesting
  final HudState? currentState;

  @override
  State<HudOverlay> createState() => _HudOverlayState();
}

class _HudOverlayState extends State<HudOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  OverlayEntry? _entry;

  Timer? _graceTimer;
  Timer? _minShowTimer;
  DateTime? _shownAt;

  HudTheme get _theme => widget.theme ?? const HudTheme();

  Duration get _animDuration {
    final disable = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    return disable ? Duration.zero : _theme.animationDuration;
  }

  Animation<double> get _animation => widget.externalAnimation ?? _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: _theme.animationDuration,
    );
    if (widget.isLoading) {
      _requestShow();
    }
  }

  @override
  void didUpdateWidget(HudOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    _controller.duration = _animDuration;

    final wasLoading = oldWidget.isLoading;
    final isLoading = widget.isLoading;

    if (!wasLoading && isLoading) {
      _requestShow();
    } else if (wasLoading && !isLoading) {
      _requestHide();
    } else if (_entry != null) {
      // Props changed while the overlay is already visible.
      // Defer so OverlayEntry.markNeedsBuild() (which calls setState on
      // OverlayState) is never issued mid-build, avoiding the cascade of
      // SliverList key-order and duplicate-GlobalKey failures.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _entry?.markNeedsBuild();
      });
    }
  }

  @override
  void dispose() {
    _graceTimer?.cancel();
    _minShowTimer?.cancel();
    _entry?.remove();
    _entry = null;
    _controller.dispose();
    super.dispose();
  }

  /// Schedules a show, honouring [HudTheme.gracePeriod].
  void _requestShow() {
    void doShow() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && widget.isLoading) _show();
      });
    }

    final grace = _theme.gracePeriod;
    if (grace > Duration.zero && _entry == null) {
      _graceTimer?.cancel();
      _graceTimer = Timer(grace, () {
        _graceTimer = null;
        doShow();
      });
    } else {
      doShow();
    }
  }

  /// Schedules a hide, honouring grace cancellation and [minShowDuration].
  void _requestHide() {
    // Still inside the grace period — the overlay never became visible.
    if (_graceTimer != null) {
      _graceTimer!.cancel();
      _graceTimer = null;
      return;
    }

    final shownAt = _shownAt;
    final minShow = _theme.minShowDuration;
    if (shownAt != null && minShow > Duration.zero) {
      final elapsed = DateTime.now().difference(shownAt);
      if (elapsed < minShow) {
        _minShowTimer?.cancel();
        _minShowTimer = Timer(minShow - elapsed, () {
          _minShowTimer = null;
          if (mounted) _hide();
        });
        return;
      }
    }

    _hide();
  }

  void _show() {
    if (_entry != null) {
      _entry!.markNeedsBuild();
      return;
    }
    _controller.duration = _animDuration;
    _shownAt = DateTime.now();
    _entry = OverlayEntry(builder: _buildOverlay);
    Overlay.of(context).insert(_entry!);
    _controller.forward(from: 0.0);
    unawaited(
      SemanticsService.sendAnnouncement(
        View.of(context),
        widget.message ?? widget.semanticsLabel,
        ui.TextDirection.ltr,
      ),
    );
  }

  void _hide() {
    if (_entry == null) return;
    _controller.reverse().whenComplete(() {
      _entry?.remove();
      _entry = null;
      _shownAt = null;
    });
  }

  Widget _buildOverlay(BuildContext context) {
    final state = widget.currentState ??
        (widget.isLoading ? HudState.loading : HudState.hidden);
    return HudOverlayContent(
      animation: _animation,
      state: state,
      progress: widget.progress,
      message: widget.message,
      detail: widget.detail,
      theme: _theme,
      semanticsLabel: widget.semanticsLabel,
      dismissible: widget.dismissible,
      onCancel: widget.onCancel,
      cancelLabel: widget.cancelLabel,
      onDismiss: widget.dismissible
          ? () {
              widget.onDismiss?.call();
              _hide();
            }
          : null,
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

// ── Shared overlay visual content ──────────────────────────────────────────

/// The visual content of a HUD overlay — barrier, optional blur, and indicator card.
///
/// Used by both [HudOverlay] (widget path) and the [HudService] bridge.
/// You can use this widget directly if you need fine-grained control over
/// the overlay entry lifecycle.
class HudOverlayContent extends StatelessWidget {
  /// Creates a [HudOverlayContent].
  const HudOverlayContent({
    super.key,
    required this.animation,
    required this.state,
    required this.theme,
    required this.semanticsLabel,
    this.progress,
    this.message,
    this.detail,
    this.dismissible = false,
    this.onDismiss,
    this.onCancel,
    this.cancelLabel = 'Cancel',
  });

  /// Drives the fade-in / fade-out opacity.
  final Animation<double> animation;

  /// Current [HudState] — determines which indicator is rendered.
  final HudState state;

  /// Visual configuration.
  final HudTheme theme;

  /// Accessibility label.
  final String semanticsLabel;

  /// Deterministic progress value (0.0–1.0) or `null` for indeterminate.
  final double? progress;

  /// Optional primary message text rendered below the indicator.
  final String? message;

  /// Optional secondary detail text rendered below [message].
  final String? detail;

  /// Whether tapping outside dismisses the overlay.
  final bool dismissible;

  /// Called when the user taps outside (only when [dismissible] is `true`).
  final VoidCallback? onDismiss;

  /// When non-null, a cancel button is rendered inside the card.
  final VoidCallback? onCancel;

  /// Label for the cancel button.
  final String cancelLabel;

  @override
  Widget build(BuildContext context) {
    final content = AnimatedBuilder(
      animation: animation,
      builder: (_, __) => Opacity(
        opacity: theme.animationCurve.transform(
          animation.value.clamp(0.0, 1.0),
        ),
        child: Stack(
          children: [
            // Only the barrier participates in input blocking / dismissal —
            // the card (and any cancel button) stays interactive in all modes.
            Positioned.fill(child: _buildBarrier()),
            _buildPositioned(_buildCard()),
          ],
        ),
      ),
    );

    // OverlayEntry has no Material ancestor, so without this wrapper Flutter
    // renders Text with the "missing material" fallback — yellow + underline.
    return Material(type: MaterialType.transparency, child: content);
  }

  Widget _buildBarrier() {
    Widget barrier;
    if (theme.blur > 0) {
      barrier = ClipRect(
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: theme.blur, sigmaY: theme.blur),
          child: ColoredBox(color: theme.barrierColor),
        ),
      );
    } else {
      barrier = ColoredBox(color: theme.barrierColor);
    }

    if (theme.interactive) {
      // Let touches pass through to the UI beneath the overlay.
      return IgnorePointer(child: barrier);
    }
    if (dismissible) {
      // Tapping the scrim dismisses the overlay.
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onDismiss,
        child: barrier,
      );
    }
    // Default: block all background input by absorbing pointers on the scrim.
    return AbsorbPointer(child: barrier);
  }

  Widget _buildCard() {
    Widget indicator;
    switch (state) {
      case HudState.success:
        indicator = theme.successWidget ??
            const Icon(Icons.check_circle_outline,
                color: Colors.greenAccent, size: 48);
      case HudState.error:
        indicator = theme.errorWidget ??
            const Icon(Icons.error_outline,
                color: Colors.redAccent, size: 48);
      case HudState.info:
        indicator = theme.infoWidget ??
            const Icon(Icons.info_outline,
                color: Colors.lightBlueAccent, size: 48);
      case HudState.loading:
      case HudState.hidden:
        indicator = theme.indicator ??
            CircularProgressIndicator.adaptive(value: progress);
    }

    final showProgress = progress != null && state == HudState.loading;

    // Semantic wrapper: label + live-region + progressBar role when
    // deterministic. Indicator's own semantics are excluded to avoid duplicates.
    final semanticIndicator = Semantics(
      label: semanticsLabel,
      liveRegion: true,
      value: showProgress ? '${((progress ?? 0) * 100).round()}%' : null,
      minValue: showProgress ? '0' : null,
      maxValue: showProgress ? '100' : null,
      role: showProgress ? SemanticsRole.progressBar : null,
      child: ExcludeSemantics(child: indicator),
    );

    final column = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        semanticIndicator,
        if (message != null) ...[
          const SizedBox(height: 10),
          Text(
            message!,
            style: theme.messageStyle ??
                const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
            textAlign: TextAlign.center,
          ),
        ],
        if (detail != null) ...[
          const SizedBox(height: 4),
          Text(
            detail!,
            style: theme.detailStyle ??
                const TextStyle(
                  color: Colors.white70,
                  fontSize: 12.5,
                ),
            textAlign: TextAlign.center,
          ),
        ],
        if (onCancel != null) ...[
          const SizedBox(height: 12),
          TextButton(
            onPressed: onCancel,
            style: theme.cancelButtonStyle,
            child: Text(cancelLabel),
          ),
        ],
      ],
    );

    // When containerDecoration is null the indicator floats directly over the
    // barrier with no card — giving users full control over the visual chrome.
    // Provide a decoration to opt in to a card background.
    final Widget card = theme.containerDecoration != null
        ? Container(
            decoration: theme.containerDecoration,
            padding: theme.containerPadding ??
                const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: column,
          )
        : Padding(
            padding: theme.containerPadding ?? EdgeInsets.zero,
            child: column,
          );

    // Only in dismissible mode does the card need to swallow taps so they
    // don't fall through to the barrier's dismiss handler. Adding it
    // unconditionally would leak a spurious `tap` semantics action.
    if (dismissible) {
      return GestureDetector(onTap: () {}, child: card);
    }
    return card;
  }

  Widget _buildPositioned(Widget card) {
    switch (theme.position) {
      case HudPosition.top:
        return Positioned(
          top: 80,
          left: 0,
          right: 0,
          child: Center(child: card),
        );
      case HudPosition.bottom:
        return Positioned(
          bottom: 80,
          left: 0,
          right: 0,
          child: Center(child: card),
        );
      case HudPosition.center:
        return Center(child: card);
    }
  }
}
