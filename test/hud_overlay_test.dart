import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hud_overlay/hud_overlay.dart';

// ── Helpers ────────────────────────────────────────────────────────────────

Widget _wrap(Widget body, {HudTheme? theme}) {
  return MaterialApp(
    home: HudScope(
      defaultTheme: theme,
      child: Scaffold(body: body),
    ),
  );
}

/// Mounts a [HudController] backed by a real in-tree [TickerProvider] so its
/// animations are driven correctly by [WidgetTester.pump], and disposes it on
/// teardown. Exposes the controller through [onReady].
class _ControllerHarness extends StatefulWidget {
  const _ControllerHarness(this.onReady);
  final void Function(HudController) onReady;

  @override
  State<_ControllerHarness> createState() => _ControllerHarnessState();
}

class _ControllerHarnessState extends State<_ControllerHarness>
    with SingleTickerProviderStateMixin {
  late final HudController controller = HudController(vsync: this);

  @override
  void initState() {
    super.initState();
    widget.onReady(controller);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => const SizedBox();
}

/// Pumps a [_ControllerHarness] and returns the created [HudController].
Future<HudController> _mountController(WidgetTester tester) async {
  late HudController c;
  await tester.pumpWidget(MaterialApp(home: _ControllerHarness((x) => c = x)));
  return c;
}

/// Hosts overlay content inside a [Stack] so [Positioned] children resolve.
Widget _host(Widget content) => MaterialApp(
  home: Scaffold(body: Stack(children: [content])),
);

const _fullAnim = AlwaysStoppedAnimation<double>(1.0);

// ── Tests ──────────────────────────────────────────────────────────────────

void main() {
  group('HudOverlay widget', () {
    // 1. Shows overlay when isLoading is true
    testWidgets('shows indicator when isLoading is true', (tester) async {
      await tester.pumpWidget(
        _wrap(const HudOverlay(isLoading: true, child: Text('Content'))),
      );
      await tester.pump(); // post-frame callback
      await tester.pump(const Duration(milliseconds: 250));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    // 1 (cont). Hides overlay when isLoading becomes false
    testWidgets('hides indicator when isLoading becomes false', (tester) async {
      bool loading = true;
      late StateSetter outerSetState;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (_, setState) {
            outerSetState = setState;
            return _wrap(
              HudOverlay(isLoading: loading, child: const Text('Content')),
            );
          },
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      outerSetState(() => loading = false);
      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    // 2. progress: 0.5 renders a semantics value node
    testWidgets('progress 0.5 renders semantics value "50%"', (tester) async {
      final handle = tester.ensureSemantics();

      await tester.pumpWidget(
        _wrap(
          const HudOverlay(isLoading: true, progress: 0.5, child: SizedBox()),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));

      // The Semantics widget wrapping the progress indicator has value '50%'.
      expect(
        tester.getSemantics(find.bySemanticsLabel('Loading')),
        matchesSemantics(label: 'Loading', value: '50%', isLiveRegion: true),
      );

      handle.dispose();
    });

    // 6. semanticsLabel is present in semantics tree
    testWidgets('semanticsLabel appears in tree when overlay is visible', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();

      await tester.pumpWidget(
        _wrap(
          const HudOverlay(
            isLoading: true,
            semanticsLabel: 'Please wait',
            child: SizedBox(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));

      expect(find.bySemanticsLabel('Please wait'), findsOneWidget);
      handle.dispose();
    });

    // 7. dismissible: true — tap outside triggers onDismiss
    testWidgets('dismissible:true triggers onDismiss on outside tap', (
      tester,
    ) async {
      bool dismissed = false;

      await tester.pumpWidget(
        _wrap(
          HudOverlay(
            isLoading: true,
            dismissible: true,
            onDismiss: () => dismissed = true,
            child: const SizedBox(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));

      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      expect(dismissed, isTrue);
    });

    // 8. MediaQuery.disableAnimations=true → instant appear
    testWidgets('disableAnimations:true shows overlay with zero duration', (
      tester,
    ) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: _wrap(const HudOverlay(isLoading: true, child: SizedBox())),
        ),
      );
      await tester.pump();
      await tester.pump(Duration.zero);

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  // ── HudService tests ───────────────────────────────────────────────────────
  group('HudService', () {
    // 3. wrap() dismisses overlay after future completes
    testWidgets('wrap() shows overlay and auto-dismisses after success', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const SizedBox()));
      await tester.pump(); // register HudScope

      unawaited(
        HudService.wrap<void>(
          Future<void>.delayed(const Duration(milliseconds: 50)),
          message: 'Working…',
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      // After future completes, showSuccess is called
      expect(HudService.isVisible(), isTrue);

      // Wait for 1500ms autoDismiss
      await tester.pump(const Duration(milliseconds: 1600));
      await tester.pumpAndSettle();
      expect(HudService.isVisible(), isFalse);
    });

    // 4. wrap() calls showError when future throws
    testWidgets('wrap() transitions to error state when future throws', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const SizedBox()));
      await tester.pump();

      final future = HudService.wrap<void>(
        Future<void>.error('oops'),
        errorMessage: 'Something went wrong',
      );
      await expectLater(future, throwsA('oops'));

      await tester.pump(const Duration(milliseconds: 50));
      expect(HudService.isVisible(), isTrue);

      await tester.pump(const Duration(milliseconds: 1600));
      await tester.pumpAndSettle();
      expect(HudService.isVisible(), isFalse);
    });

    // 5. Overlay is not visible after HudService.dismiss()
    testWidgets('overlay not visible after dismiss()', (tester) async {
      await tester.pumpWidget(_wrap(const SizedBox()));
      await tester.pump();

      HudService.show(message: 'Loading');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));
      expect(HudService.isVisible(), isTrue);

      HudService.dismiss();
      await tester.pumpAndSettle();
      expect(HudService.isVisible(), isFalse);
    });
  });

  // ── HudController tests ──────────────────────────────────────────────────
  group('HudController', () {
    testWidgets('show() sets loading state with progress and message', (
      tester,
    ) async {
      final c = await _mountController(tester);

      c.show(progress: 0.3, message: 'Hi');
      expect(c.status.state, HudState.loading);
      expect(c.status.progress, 0.3);
      expect(c.status.message, 'Hi');
      expect(c.status.isVisible, isTrue);

      // Let the fade-in complete so no ticker is active at teardown.
      await tester.pump(const Duration(milliseconds: 250));
    });

    testWidgets('updateProgress clamps and only applies while loading', (
      tester,
    ) async {
      final c = await _mountController(tester);

      // Ignored before any show().
      c.updateProgress(0.5);
      expect(c.status.state, HudState.hidden);
      expect(c.status.progress, isNull);

      c.show();
      c.updateProgress(1.5);
      expect(c.status.progress, 1.0);
      c.updateProgress(-0.2);
      expect(c.status.progress, 0.0);

      await tester.pump(const Duration(milliseconds: 250));
    });

    testWidgets('showSuccess transitions then auto-dismisses', (tester) async {
      final c = await _mountController(tester);

      c.show();
      c.showSuccess(
        message: 'Done',
        autoDismiss: const Duration(milliseconds: 100),
      );
      expect(c.status.state, HudState.success);
      expect(c.status.message, 'Done');

      await tester.pump(const Duration(milliseconds: 120)); // timer fires
      await tester.pump(const Duration(milliseconds: 300)); // reverse done
      expect(c.status.state, HudState.hidden);
    });

    testWidgets('showError transitions then auto-dismisses', (tester) async {
      final c = await _mountController(tester);

      c.show();
      c.showError(
        message: 'Oops',
        autoDismiss: const Duration(milliseconds: 100),
      );
      expect(c.status.state, HudState.error);
      expect(c.status.message, 'Oops');

      await tester.pump(const Duration(milliseconds: 120));
      await tester.pump(const Duration(milliseconds: 300));
      expect(c.status.state, HudState.hidden);
    });

    testWidgets('dismiss() hides after the reverse animation', (tester) async {
      final c = await _mountController(tester);

      c.show();
      await tester.pump(const Duration(milliseconds: 250)); // fade-in done
      expect(c.status.isVisible, isTrue);

      c.dismiss();
      await tester.pump(const Duration(milliseconds: 300));
      expect(c.status.state, HudState.hidden);
    });
  });

  // ── HudStatus tests ──────────────────────────────────────────────────────
  group('HudStatus', () {
    test('equality and hashCode', () {
      const a = HudStatus(state: HudState.loading, progress: 0.5, message: 'x');
      const b = HudStatus(state: HudState.loading, progress: 0.5, message: 'x');
      const c = HudStatus(state: HudState.error, message: 'x');
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a, isNot(equals(c)));
    });

    test('isVisible reflects state', () {
      expect(const HudStatus(state: HudState.hidden).isVisible, isFalse);
      expect(const HudStatus(state: HudState.loading).isVisible, isTrue);
      expect(const HudStatus(state: HudState.success).isVisible, isTrue);
      expect(const HudStatus(state: HudState.error).isVisible, isTrue);
    });

    test('toString includes its fields', () {
      const s = HudStatus(
        state: HudState.loading,
        progress: 0.25,
        message: 'm',
      );
      expect(s.toString(), contains('loading'));
      expect(s.toString(), contains('0.25'));
      expect(s.toString(), contains('m'));
    });
  });

  // ── HudTheme tests ───────────────────────────────────────────────────────
  group('HudTheme', () {
    test('copyWith overrides only the provided fields', () {
      const base = HudTheme();
      final t = base.copyWith(blur: 8, position: HudPosition.top);
      expect(t.blur, 8);
      expect(t.position, HudPosition.top);
      expect(t.barrierColor, base.barrierColor);
      expect(t.animationDuration, base.animationDuration);
    });

    test('equality and hashCode', () {
      const a = HudTheme(blur: 4, position: HudPosition.bottom);
      const b = HudTheme(blur: 4, position: HudPosition.bottom);
      const c = HudTheme(blur: 5, position: HudPosition.bottom);
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a, isNot(equals(c)));
    });
  });

  // ── HudOverlayContent rendering tests ────────────────────────────────────
  group('HudOverlayContent rendering', () {
    testWidgets('success state shows the default check icon', (tester) async {
      await tester.pumpWidget(
        _host(
          const HudOverlayContent(
            animation: _fullAnim,
            state: HudState.success,
            theme: HudTheme(),
            semanticsLabel: 'Loading',
          ),
        ),
      );
      expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
    });

    testWidgets('error state shows the default error icon', (tester) async {
      await tester.pumpWidget(
        _host(
          const HudOverlayContent(
            animation: _fullAnim,
            state: HudState.error,
            theme: HudTheme(),
            semanticsLabel: 'Loading',
          ),
        ),
      );
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('message text is rendered below the indicator', (tester) async {
      await tester.pumpWidget(
        _host(
          const HudOverlayContent(
            animation: _fullAnim,
            state: HudState.loading,
            message: 'Uploading…',
            theme: HudTheme(),
            semanticsLabel: 'Loading',
          ),
        ),
      );
      expect(find.text('Uploading…'), findsOneWidget);
    });

    testWidgets('custom indicator replaces the default spinner', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const HudOverlayContent(
            animation: _fullAnim,
            state: HudState.loading,
            theme: HudTheme(indicator: Text('SPIN')),
            semanticsLabel: 'Loading',
          ),
        ),
      );
      expect(find.text('SPIN'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('blur > 0 inserts a BackdropFilter', (tester) async {
      await tester.pumpWidget(
        _host(
          const HudOverlayContent(
            animation: _fullAnim,
            state: HudState.loading,
            theme: HudTheme(blur: 6),
            semanticsLabel: 'Loading',
          ),
        ),
      );
      expect(find.byType(BackdropFilter), findsOneWidget);
    });

    testWidgets('blur == 0 inserts no BackdropFilter', (tester) async {
      await tester.pumpWidget(
        _host(
          const HudOverlayContent(
            animation: _fullAnim,
            state: HudState.loading,
            theme: HudTheme(),
            semanticsLabel: 'Loading',
          ),
        ),
      );
      expect(find.byType(BackdropFilter), findsNothing);
    });

    testWidgets('top position anchors the card with Positioned(top: 80)', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const HudOverlayContent(
            animation: _fullAnim,
            state: HudState.loading,
            theme: HudTheme(position: HudPosition.top),
            semanticsLabel: 'Loading',
          ),
        ),
      );
      expect(
        find.byWidgetPredicate((w) => w is Positioned && w.top == 80),
        findsOneWidget,
      );
    });

    testWidgets(
      'bottom position anchors the card with Positioned(bottom: 80)',
      (tester) async {
        await tester.pumpWidget(
          _host(
            const HudOverlayContent(
              animation: _fullAnim,
              state: HudState.loading,
              theme: HudTheme(position: HudPosition.bottom),
              semanticsLabel: 'Loading',
            ),
          ),
        );
        expect(
          find.byWidgetPredicate((w) => w is Positioned && w.bottom == 80),
          findsOneWidget,
        );
      },
    );

    testWidgets('animationCurve is applied to the fade opacity', (
      tester,
    ) async {
      const curve = Curves.easeIn;
      const t = 0.5;
      await tester.pumpWidget(
        _host(
          const HudOverlayContent(
            animation: AlwaysStoppedAnimation<double>(t),
            state: HudState.loading,
            theme: HudTheme(animationCurve: curve),
            semanticsLabel: 'Loading',
          ),
        ),
      );

      final opacity = tester.widget<Opacity>(find.byType(Opacity).first);
      expect(opacity.opacity, closeTo(curve.transform(t), 1e-9));
      // Sanity: a non-linear curve must differ from the raw value.
      expect(opacity.opacity, isNot(closeTo(t, 1e-3)));
    });
  });

  // ── HudService — extended coverage ───────────────────────────────────────
  group('HudService extended', () {
    testWidgets('named overlays are tracked independently', (tester) async {
      await tester.pumpWidget(_wrap(const SizedBox()));
      await tester.pump();

      HudService.show(message: 'A', key: 'a');
      HudService.show(message: 'B', key: 'b');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));

      expect(HudService.isVisible(key: 'a'), isTrue);
      expect(HudService.isVisible(key: 'b'), isTrue);
      expect(HudService.isVisible(), isFalse); // unnamed never shown

      // Overlay 'b' keeps spinning, so pumpAndSettle would never settle here;
      // advance with explicit pumps instead.
      HudService.dismiss(key: 'a');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(HudService.isVisible(key: 'a'), isFalse);
      expect(HudService.isVisible(key: 'b'), isTrue);

      HudService.dismissAll();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(HudService.isVisible(key: 'b'), isFalse);
    });

    testWidgets('showSuccess without an active overlay is a no-op', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const SizedBox()));
      await tester.pump();

      HudService.showSuccess(message: 'ignored'); // must not throw
      await tester.pump();
      expect(HudService.isVisible(), isFalse);
    });

    testWidgets('trackStream reports progress then dismisses on done', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const SizedBox()));
      await tester.pump();

      final ctrl = StreamController<double>();
      HudService.trackStream(ctrl.stream, message: 'Up', key: 'up');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));
      expect(HudService.isVisible(key: 'up'), isTrue);

      ctrl.add(0.5);
      await tester.pump();
      expect(HudService.isVisible(key: 'up'), isTrue);

      await ctrl.close();
      await tester.pump();
      await tester.pumpAndSettle();
      expect(HudService.isVisible(key: 'up'), isFalse);
    });

    testWidgets('show() on an existing key updates the same overlay', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const SizedBox()));
      await tester.pump();

      HudService.show(message: 'first', key: 'dup');
      HudService.show(message: 'second', key: 'dup');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));

      expect(HudService.isVisible(key: 'dup'), isTrue);
      expect(find.text('second'), findsOneWidget);
      expect(find.text('first'), findsNothing);

      HudService.dismissAll();
      await tester.pumpAndSettle();
    });

    testWidgets('navigatorObserver dismisses overlays on route push when '
        'autoDismissOnNavigation is enabled', (tester) async {
      final navKey = GlobalKey<NavigatorState>();
      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: navKey,
          navigatorObservers: [HudService.navigatorObserver],
          home: const HudScope(
            autoDismissOnNavigation: true,
            child: Scaffold(body: SizedBox()),
          ),
        ),
      );
      await tester.pump(); // register scope (post-frame)

      HudService.show(message: 'Loading');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));
      expect(HudService.isVisible(), isTrue);

      unawaited(
        navKey.currentState!.push(
          MaterialPageRoute<void>(
            builder: (_) => const Scaffold(body: SizedBox()),
          ),
        ),
      );
      await tester.pump(); // didPush fires -> dismissAll
      await tester.pump(const Duration(milliseconds: 300)); // reverse done
      expect(HudService.isVisible(), isFalse);
    });

    testWidgets('navigatorObserver leaves overlays when the flag is off', (
      tester,
    ) async {
      final navKey = GlobalKey<NavigatorState>();
      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: navKey,
          navigatorObservers: [HudService.navigatorObserver],
          home: const HudScope(child: Scaffold(body: SizedBox())),
        ),
      );
      await tester.pump();

      HudService.show(message: 'Loading');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));
      expect(HudService.isVisible(), isTrue);

      unawaited(
        navKey.currentState!.push(
          MaterialPageRoute<void>(
            builder: (_) => const Scaffold(body: SizedBox()),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(HudService.isVisible(), isTrue);

      // Clean up the still-spinning overlay with explicit pumps.
      HudService.dismissAll();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
    });
  });

  // ── SemanticsRole tests ──────────────────────────────────────────────────
  group('Accessibility semantics', () {
    testWidgets('deterministic progress exposes a progressBar role', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _host(
          const HudOverlayContent(
            animation: _fullAnim,
            state: HudState.loading,
            progress: 0.5,
            theme: HudTheme(),
            semanticsLabel: 'Loading',
          ),
        ),
      );

      final node = tester.getSemantics(find.bySemanticsLabel('Loading'));
      expect(
        node,
        matchesSemantics(label: 'Loading', value: '50%', isLiveRegion: true),
      );
      expect(node.role, SemanticsRole.progressBar);
      handle.dispose();
    });
  });

  // ── Info state ────────────────────────────────────────────────────────────
  group('Info state', () {
    testWidgets('HudOverlayContent renders the default info icon', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const HudOverlayContent(
            animation: _fullAnim,
            state: HudState.info,
            theme: HudTheme(),
            semanticsLabel: 'Info',
          ),
        ),
      );
      expect(find.byIcon(Icons.info_outline), findsOneWidget);
    });

    testWidgets('controller.showInfo transitions then auto-dismisses', (
      tester,
    ) async {
      final c = await _mountController(tester);
      c.showInfo(message: 'FYI', autoDismiss: const Duration(seconds: 1));
      await tester.pump();
      expect(c.status.state, HudState.info);

      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(milliseconds: 300));
      expect(c.status.state, HudState.hidden);
    });

    testWidgets('HudService.showInfo creates an overlay when none is active', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const SizedBox()));
      await tester.pump();

      HudService.showInfo(message: 'Heads up');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));

      expect(find.byIcon(Icons.info_outline), findsOneWidget);
      expect(HudService.isVisible(), isTrue);

      HudService.dismissAll();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
    });
  });

  // ── Detail / secondary label ────────────────────────────────────────────
  group('Detail label', () {
    testWidgets('renders both message and detail below the indicator', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const HudOverlayContent(
            animation: _fullAnim,
            state: HudState.loading,
            theme: HudTheme(),
            semanticsLabel: 'Loading',
            message: 'Uploading',
            detail: '3 of 10 files',
          ),
        ),
      );
      expect(find.text('Uploading'), findsOneWidget);
      expect(find.text('3 of 10 files'), findsOneWidget);
    });

    testWidgets('controller threads detail through the status', (tester) async {
      final c = await _mountController(tester);
      c.show(message: 'M', detail: 'D');
      await tester.pump();
      expect(c.status.detail, 'D');
    });
  });

  // ── Cancel button ─────────────────────────────────────────────────────────
  group('Cancel button', () {
    testWidgets('shows a labelled button and fires onCancel when tapped', (
      tester,
    ) async {
      var cancelled = false;
      await tester.pumpWidget(
        _host(
          HudOverlayContent(
            animation: _fullAnim,
            state: HudState.loading,
            theme: const HudTheme(),
            semanticsLabel: 'Loading',
            onCancel: () => cancelled = true,
            cancelLabel: 'Stop',
          ),
        ),
      );

      expect(find.widgetWithText(TextButton, 'Stop'), findsOneWidget);
      await tester.tap(find.text('Stop'));
      expect(cancelled, isTrue);
    });

    testWidgets('no button is rendered when onCancel is null', (tester) async {
      await tester.pumpWidget(
        _host(
          const HudOverlayContent(
            animation: _fullAnim,
            state: HudState.loading,
            theme: HudTheme(),
            semanticsLabel: 'Loading',
          ),
        ),
      );
      expect(find.byType(TextButton), findsNothing);
    });
  });

  // ── Interactive mask ──────────────────────────────────────────────────────
  group('Interactive mask', () {
    testWidgets('non-interactive theme inserts an AbsorbPointer', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const HudOverlayContent(
            animation: _fullAnim,
            state: HudState.loading,
            theme: HudTheme(),
            semanticsLabel: 'Loading',
          ),
        ),
      );
      expect(
        find.descendant(
          of: find.byType(HudOverlayContent),
          matching: find.byType(AbsorbPointer),
        ),
        findsOneWidget,
      );
    });

    testWidgets(
      'interactive theme omits AbsorbPointer and ignores the barrier',
      (tester) async {
        await tester.pumpWidget(
          _host(
            const HudOverlayContent(
              animation: _fullAnim,
              state: HudState.loading,
              theme: HudTheme(interactive: true),
              semanticsLabel: 'Loading',
            ),
          ),
        );
        expect(
          find.descendant(
            of: find.byType(HudOverlayContent),
            matching: find.byType(AbsorbPointer),
          ),
          findsNothing,
        );
        // The barrier is wrapped in IgnorePointer so taps pass through.
        expect(
          find.descendant(
            of: find.byType(HudOverlayContent),
            matching: find.byType(IgnorePointer),
          ),
          findsOneWidget,
        );
      },
    );
  });

  // ── Grace period ──────────────────────────────────────────────────────────
  group('Grace period', () {
    testWidgets('overlay stays invisible until the grace period elapses', (
      tester,
    ) async {
      final c = await _mountController(tester);
      c.show(theme: const HudTheme(gracePeriod: Duration(milliseconds: 500)));
      await tester.pump();
      // Status is loading, but the fade has not begun.
      expect(c.status.state, HudState.loading);
      expect(c.animation.value, 0.0);

      await tester.pump(const Duration(milliseconds: 250));
      expect(c.animation.value, 0.0);

      // After the grace period the fade-in runs.
      await tester.pump(const Duration(milliseconds: 250));
      await tester.pump(const Duration(milliseconds: 250));
      expect(c.animation.value, greaterThan(0.0));

      c.dismiss();
      await tester.pump(const Duration(milliseconds: 300));
    });

    testWidgets('dismiss during grace cancels without ever showing', (
      tester,
    ) async {
      final c = await _mountController(tester);
      c.show(theme: const HudTheme(gracePeriod: Duration(milliseconds: 500)));
      await tester.pump();
      expect(c.animation.value, 0.0);

      c.dismiss();
      await tester.pump();
      expect(c.status.state, HudState.hidden);

      // Even after the original grace window, nothing appears.
      await tester.pump(const Duration(milliseconds: 600));
      expect(c.animation.value, 0.0);
      expect(c.status.state, HudState.hidden);
    });
  });

  // ── Minimum show duration ─────────────────────────────────────────────────
  group('Minimum show duration', () {
    testWidgets('a quick dismiss is deferred until the minimum elapses', (
      tester,
    ) async {
      final c = await _mountController(tester);
      c.show(
        theme: const HudTheme(minShowDuration: Duration(milliseconds: 600)),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200)); // fade-in
      expect(c.status.state, HudState.loading);

      // Request dismissal almost immediately — it should be held.
      c.dismiss();
      await tester.pump(const Duration(milliseconds: 100));
      expect(c.status.state, HudState.loading);

      // After the minimum show window the overlay finally fades out.
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pump(const Duration(milliseconds: 300));
      expect(c.status.state, HudState.hidden);
    });
  });

  // ── Length-based auto-dismiss ─────────────────────────────────────────────
  group('Length-based auto-dismiss', () {
    testWidgets('a long message extends the dismiss window beyond 1.5s', (
      tester,
    ) async {
      final c = await _mountController(tester);
      // 60 chars → 60*60 + 500 = 4100ms.
      c.showSuccess(message: 'x' * 60);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      expect(c.status.state, HudState.success);

      // Still visible at 1.5s (the old fixed default) — length extended it.
      await tester.pump(const Duration(milliseconds: 1500));
      expect(c.status.state, HudState.success);

      // Gone after the full computed window.
      await tester.pump(const Duration(milliseconds: 3000));
      await tester.pump(const Duration(milliseconds: 300));
      expect(c.status.state, HudState.hidden);
    });

    testWidgets('explicit autoDismiss is always respected', (tester) async {
      final c = await _mountController(tester);
      c.showError(
        message: 'x' * 60,
        autoDismiss: const Duration(milliseconds: 800),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      expect(c.status.state, HudState.error);

      await tester.pump(const Duration(milliseconds: 800));
      await tester.pump(const Duration(milliseconds: 300));
      expect(c.status.state, HudState.hidden);
    });
  });

  // ── Theme presets & new fields ────────────────────────────────────────────
  group('HudTheme presets and fields', () {
    test('light() preset has a white card and light scrim', () {
      final t = HudTheme.light();
      expect(t.containerDecoration, isNotNull);
      expect(t.containerDecoration!.color, Colors.white);
      expect(t.messageStyle!.color, const Color(0xFF1C1C1E));
    });

    test('dark() preset has a dark card and white text', () {
      final t = HudTheme.dark();
      expect(t.containerDecoration, isNotNull);
      expect(t.messageStyle!.color, Colors.white);
    });

    test('copyWith overrides the new fields', () {
      const base = HudTheme();
      final t = base.copyWith(
        enableHaptics: true,
        interactive: true,
        gracePeriod: const Duration(milliseconds: 300),
        minShowDuration: const Duration(milliseconds: 700),
      );
      expect(t.enableHaptics, isTrue);
      expect(t.interactive, isTrue);
      expect(t.gracePeriod, const Duration(milliseconds: 300));
      expect(t.minShowDuration, const Duration(milliseconds: 700));
    });

    test('equality accounts for the new fields', () {
      expect(
        const HudTheme(enableHaptics: true),
        isNot(equals(const HudTheme())),
      );
      expect(
        const HudTheme(interactive: true),
        isNot(equals(const HudTheme())),
      );
    });
  });
}
