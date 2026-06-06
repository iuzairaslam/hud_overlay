import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/scheduler.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';

import 'hud_controller.dart';
import 'hud_overlay_widget.dart';
import 'hud_state.dart';
import 'hud_theme.dart';

/// Static, context-free service for controlling HUD overlays globally.
///
/// Requires [HudScope] somewhere in the widget tree to register its context.
/// Place [HudScope] inside [MaterialApp.builder] so the context has access to
/// the navigator overlay:
///
/// ```dart
/// MaterialApp(
///   builder: (context, child) => HudScope(child: child!),
///   home: MyHomePage(),
/// )
/// ```
///
/// Then call from anywhere:
/// ```dart
/// HudService.show(message: 'Saving…');
/// await save();
/// HudService.dismiss();
/// ```
class HudService {
  HudService._();

  /// The singleton instance — prefer the static helper methods.
  static final HudService instance = HudService._();

  BuildContext? _context;
  OverlayState? _overlay;
  HudTheme _defaultTheme = const HudTheme();
  bool _autoDismissOnNavigation = false;

  final Map<String, _OverlayRecord> _overlays = {};
  final List<String> _insertionOrder = [];

  static const String _unnamedKey = '__hud_unnamed__';

  /// A [NavigatorObserver] that dismisses all active overlays whenever a new
  /// route is pushed, provided [HudScope.autoDismissOnNavigation] is enabled.
  ///
  /// Register it on your app's navigator — a descendant [HudScope] cannot
  /// observe an ancestor [Navigator] by itself:
  ///
  /// ```dart
  /// MaterialApp(
  ///   navigatorObservers: [HudService.navigatorObserver],
  ///   home: HudScope(autoDismissOnNavigation: true, child: MyHome()),
  /// )
  /// ```
  static final NavigatorObserver navigatorObserver = _HudNavigatorObserver();

  // ── Internal registration surface (called by HudScope) ────────────────────
  // Non-private so HudScope (a separate Dart library) can call them.

  /// @nodoc
  void registerScope(
    OverlayState overlay,
    BuildContext announceContext,
    HudTheme? defaultTheme, {
    bool autoDismissOnNavigation = false,
  }) {
    _overlay = overlay;
    _context = announceContext;
    if (defaultTheme != null) _defaultTheme = defaultTheme;
    _autoDismissOnNavigation = autoDismissOnNavigation;
  }

  /// @nodoc
  void updateDefaultTheme(HudTheme? theme) {
    _defaultTheme = theme ?? const HudTheme();
  }

  /// @nodoc
  void setAutoDismissOnNavigation(bool value) {
    _autoDismissOnNavigation = value;
  }

  /// @nodoc
  void unregisterScope() {
    dismissAll();
    _context = null;
    _overlay = null;
    _autoDismissOnNavigation = false;
  }

  // ── Public static API ──────────────────────────────────────────────────────

  /// Shows a loading overlay.
  ///
  /// [key] identifies the overlay for stacking support.
  /// Omit [key] to control the single unnamed overlay.
  ///
  /// Provide [onCancel] to render a cancel button inside the card.
  static void show({
    double? progress,
    String? message,
    String? detail,
    HudTheme? theme,
    String semanticsLabel = 'Loading',
    String? key,
    VoidCallback? onCancel,
    String cancelLabel = 'Cancel',
  }) {
    instance._show(
      progress: progress,
      message: message,
      detail: detail,
      theme: theme,
      semanticsLabel: semanticsLabel,
      key: key ?? _unnamedKey,
      onCancel: onCancel,
      cancelLabel: cancelLabel,
    );
  }

  /// Transitions the active overlay to the success state and auto-dismisses.
  ///
  /// Requires an active overlay — call [show] first, or use [wrap].
  /// When [autoDismiss] is `null`, the duration is derived from the message
  /// length (floored at 1.5s).
  static void showSuccess({
    String? message,
    String? detail,
    Duration? autoDismiss,
    HudTheme? theme,
    String? key,
  }) {
    final record = instance._overlays[key ?? _unnamedKey];
    if (record == null) return;
    record.controller.showSuccess(
      message: message,
      detail: detail,
      autoDismiss: autoDismiss,
      theme: theme,
    );
    instance._announce(message ?? 'Success');
  }

  /// Transitions the active overlay to the error state and auto-dismisses.
  ///
  /// Requires an active overlay — call [show] first, or use [wrap].
  static void showError({
    String? message,
    String? detail,
    Duration? autoDismiss,
    HudTheme? theme,
    String? key,
  }) {
    final record = instance._overlays[key ?? _unnamedKey];
    if (record == null) return;
    record.controller.showError(
      message: message,
      detail: detail,
      autoDismiss: autoDismiss,
      theme: theme,
    );
    instance._announce(message ?? 'Error');
  }

  /// Shows an informational overlay that auto-dismisses.
  ///
  /// Unlike [showSuccess]/[showError], this creates an overlay if none is
  /// active for [key] — making it convenient for standalone info "toasts".
  static void showInfo({
    String? message,
    String? detail,
    Duration? autoDismiss,
    HudTheme? theme,
    String? key,
  }) {
    final resolvedKey = key ?? _unnamedKey;
    final record = instance._ensureRecord(
      resolvedKey,
      semanticsLabel: message ?? 'Info',
    );
    if (record == null) return;
    record.controller.showInfo(
      message: message,
      detail: detail,
      autoDismiss: autoDismiss,
      theme: theme ?? instance._defaultTheme,
    );
    instance._announce(message ?? 'Info');
  }

  /// Dismisses the overlay identified by [key].
  ///
  /// When [key] is omitted, dismisses the most recently shown overlay.
  static void dismiss({String? key}) {
    if (key != null) {
      instance._dismiss(key);
      return;
    }
    if (instance._insertionOrder.isNotEmpty) {
      instance._dismiss(instance._insertionOrder.last);
    }
  }

  /// Dismisses all active overlays.
  static void dismissAll() {
    for (final key in List<String>.from(instance._overlays.keys)) {
      instance._dismiss(key);
    }
  }

  /// Returns `true` if the overlay identified by [key] is currently visible.
  static bool isVisible({String? key}) {
    final record = instance._overlays[key ?? _unnamedKey];
    return record != null &&
        record.controller.status.state != HudState.hidden;
  }

  /// Shows an overlay for the lifetime of [future].
  ///
  /// Calls [showSuccess] when the future completes normally,
  /// [showError] when it throws. Always rethrows the error.
  static Future<T> wrap<T>(
    Future<T> future, {
    String? message,
    String? successMessage,
    String? errorMessage,
    HudTheme? theme,
    String? key,
  }) async {
    show(message: message, theme: theme, key: key);
    try {
      final result = await future;
      showSuccess(message: successMessage, theme: theme, key: key);
      return result;
    } catch (_) {
      showError(message: errorMessage, theme: theme, key: key);
      rethrow;
    }
  }

  /// Tracks a [Stream<double>] as deterministic progress.
  ///
  /// Values emitted by [progressStream] must be in [0.0, 1.0].
  /// When the stream closes, [onComplete] is called and the overlay is dismissed.
  static void trackStream(
    Stream<double> progressStream, {
    String? message,
    String? key,
    VoidCallback? onComplete,
  }) {
    show(message: message, key: key);
    final resolvedKey = key ?? _unnamedKey;
    StreamSubscription<double>? sub;
    sub = progressStream.listen(
      (value) {
        instance._overlays[resolvedKey]?.controller.updateProgress(value);
      },
      onDone: () {
        sub?.cancel();
        onComplete?.call();
        instance._dismiss(resolvedKey);
      },
      onError: (_) {
        sub?.cancel();
        showError(key: key);
      },
      cancelOnError: true,
    );
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  void _announce(String message) {
    final ctx = _context;
    if (ctx == null) return;
    unawaited(
      SemanticsService.sendAnnouncement(
        View.of(ctx),
        message,
        ui.TextDirection.ltr,
      ),
    );
  }

  /// Returns the record for [key], creating + inserting one if needed.
  ///
  /// Returns `null` only when no [HudScope] is registered.
  _OverlayRecord? _ensureRecord(
    String key, {
    required String semanticsLabel,
    VoidCallback? onCancel,
    String cancelLabel = 'Cancel',
  }) {
    final existing = _overlays[key];
    if (existing != null) {
      existing.semanticsLabel = semanticsLabel;
      existing.onCancel = onCancel;
      existing.cancelLabel = cancelLabel;
      existing.entry.markNeedsBuild();
      return existing;
    }

    final overlay = _overlay;
    if (overlay == null) return null;

    final controller = HudController(vsync: _SingleTickerVsync());
    final record = _OverlayRecord(
      controller: controller,
      semanticsLabel: semanticsLabel,
      onCancel: onCancel,
      cancelLabel: cancelLabel,
    );

    record.entry = OverlayEntry(
      builder: (_) => _ServiceOverlayWidget(
        record: record,
        onHidden: () => _removeRecord(key),
      ),
    );

    _overlays[key] = record;
    _insertionOrder.add(key);
    overlay.insert(record.entry);
    return record;
  }

  void _show({
    required String key,
    double? progress,
    String? message,
    String? detail,
    HudTheme? theme,
    String semanticsLabel = 'Loading',
    VoidCallback? onCancel,
    String cancelLabel = 'Cancel',
  }) {
    assert(
      _overlay != null,
      'HudService.show() called before HudScope was mounted. '
      'Place HudScope inside MaterialApp.builder or as a direct child of MaterialApp.',
    );
    final effectiveTheme = theme ?? _defaultTheme;

    final record = _ensureRecord(
      key,
      semanticsLabel: semanticsLabel,
      onCancel: onCancel,
      cancelLabel: cancelLabel,
    );
    if (record == null) return;

    record.controller.show(
      progress: progress,
      message: message,
      detail: detail,
      theme: effectiveTheme,
    );
    _announce(message ?? semanticsLabel);
  }

  void _dismiss(String key) {
    _overlays[key]?.controller.dismiss();
  }

  void _removeRecord(String key) {
    final record = _overlays.remove(key);
    _insertionOrder.remove(key);
    record?.entry.remove();
    record?.controller.dispose();
  }
}

// ── Internal types ─────────────────────────────────────────────────────────

/// Dismisses all overlays on route push when auto-dismiss is enabled.
class _HudNavigatorObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (HudService.instance._autoDismissOnNavigation) {
      HudService.dismissAll();
    }
  }
}

/// Mutable bookkeeping for one active service-path overlay.
class _OverlayRecord {
  _OverlayRecord({
    required this.controller,
    required this.semanticsLabel,
    this.onCancel,
    this.cancelLabel = 'Cancel',
  });

  final HudController controller;
  late final OverlayEntry entry;
  String semanticsLabel;
  VoidCallback? onCancel;
  String cancelLabel;
}

/// Minimal [TickerProvider] for controllers that live outside the widget tree.
class _SingleTickerVsync implements TickerProvider {
  @override
  Ticker createTicker(TickerCallback onTick) => Ticker(onTick);
}

/// Bridges [HudController] to [HudOverlayContent] for the service-path overlay.
class _ServiceOverlayWidget extends StatefulWidget {
  const _ServiceOverlayWidget({
    required this.record,
    required this.onHidden,
  });

  final _OverlayRecord record;
  final VoidCallback onHidden;

  @override
  State<_ServiceOverlayWidget> createState() => _ServiceOverlayWidgetState();
}

class _ServiceOverlayWidgetState extends State<_ServiceOverlayWidget> {
  HudController get _controller => widget.record.controller;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    if (!mounted) return;
    setState(() {});
    if (_controller.status.state == HudState.hidden) {
      WidgetsBinding.instance.addPostFrameCallback((_) => widget.onHidden());
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = _controller.status;
    return HudOverlayContent(
      animation: _controller.animation,
      state: status.state,
      progress: status.progress,
      message: status.message,
      detail: status.detail,
      theme: _controller.theme,
      semanticsLabel: widget.record.semanticsLabel,
      onCancel: widget.record.onCancel,
      cancelLabel: widget.record.cancelLabel,
    );
  }
}
