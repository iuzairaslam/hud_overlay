import 'package:flutter/material.dart';
import 'package:hud_overlay/hud_overlay.dart';

import '../ui/demo_scaffold.dart';
import '../ui/demo_widgets.dart';
import '../ui/hud_presets.dart';
import '../ui/tokens.dart';

/// Demonstrates tap-outside-to-dismiss via `dismissible`.
class DismissibleDemo extends StatefulWidget {
  const DismissibleDemo({super.key});

  @override
  State<DismissibleDemo> createState() => _DismissibleDemoState();
}

class _DismissibleDemoState extends State<DismissibleDemo> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    return DemoScaffold(
      title: 'Dismissible barrier',
      stage: HudOverlay(
        isLoading: _busy,
        message: 'Tap anywhere to cancel',
        dismissible: true,
        onDismiss: () => setState(() => _busy = false),
        theme: Hud.light,
        child: const DemoStage(
          child: MockContent(emoji: '👆', accent: T.orange),
        ),
      ),
      dock: DemoDock(
        code: 'HudOverlay(dismissible: true)',
        description:
            'When dismissible, tapping the scrim closes the overlay and fires '
            'onDismiss — handy for optional, cancellable work.',
        children: [
          RunButton(
            label: 'Show dismissible',
            busy: _busy,
            color: T.orange,
            onPressed: () => setState(() => _busy = true),
          ),
          const SizedBox(height: 14),
          const Hint('After it appears, tap the dimmed background to dismiss.'),
        ],
      ),
    );
  }
}
