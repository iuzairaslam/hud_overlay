import 'package:flutter/material.dart';
import 'package:hud_overlay/hud_overlay.dart';

import '../ui/demo_scaffold.dart';
import '../ui/demo_widgets.dart';
import '../ui/tokens.dart';

/// Demonstrates `interactive` — a non-blocking overlay you can tap behind.
class InteractiveDemo extends StatefulWidget {
  const InteractiveDemo({super.key});

  @override
  State<InteractiveDemo> createState() => _InteractiveDemoState();
}

class _InteractiveDemoState extends State<InteractiveDemo> {
  bool _busy = false;
  bool _interactive = true;
  int _count = 0;

  Future<void> _run() async {
    setState(() => _busy = true);
    await Future<void>.delayed(const Duration(seconds: 4));
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = HudTheme(
      interactive: _interactive,
      barrierColor: _interactive ? Colors.transparent : const Color(0x55000000),
      messageStyle: T.hudDarkMessage,
      containerPadding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 20,
      ),
      containerDecoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(18)),
        boxShadow: [
          BoxShadow(
            color: Color(0x29000000),
            blurRadius: 28,
            offset: Offset(0, 10),
          ),
        ],
      ),
    );

    return DemoScaffold(
      title: 'Non-blocking overlay',
      stage: HudOverlay(
        isLoading: _busy,
        message: 'Working in background',
        theme: theme,
        child: DemoStage(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Tap count', style: T.body),
              const SizedBox(height: 8),
              Text(
                '$_count',
                style: const TextStyle(
                  fontSize: 56,
                  fontWeight: FontWeight.w800,
                  color: T.ink,
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => setState(() => _count++),
                style: FilledButton.styleFrom(
                  backgroundColor: T.green,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 14,
                  ),
                ),
                child: const Text('Tap me'),
              ),
            ],
          ),
        ),
      ),
      dock: DemoDock(
        code: 'HudTheme(interactive: $_interactive)',
        description:
            'When interactive, the scrim lets touches through — try tapping '
            '“Tap me” while the overlay is up.',
        children: [
          ToggleRow(
            label: 'Interactive (let taps through)',
            value: _interactive,
            onChanged: (v) => setState(() => _interactive = v),
          ),
          const SizedBox(height: 12),
          RunButton(label: 'Show for 4s', busy: _busy, onPressed: _run),
        ],
      ),
    );
  }
}
