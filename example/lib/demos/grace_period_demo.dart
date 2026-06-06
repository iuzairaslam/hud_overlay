import 'package:flutter/material.dart';
import 'package:hud_overlay/hud_overlay.dart';

import '../ui/demo_scaffold.dart';
import '../ui/demo_widgets.dart';
import '../ui/tokens.dart';

/// Demonstrates `gracePeriod` — fast operations never flash a spinner.
class GracePeriodDemo extends StatelessWidget {
  const GracePeriodDemo({super.key});

  static final _theme = HudTheme.dark().copyWith(
    gracePeriod: const Duration(milliseconds: 500),
  );

  void _task(int ms) {
    HudService.show(message: 'Loading…', theme: _theme);
    Future<void>.delayed(
      Duration(milliseconds: ms),
    ).then((_) => HudService.dismiss());
  }

  @override
  Widget build(BuildContext context) {
    return DemoScaffold(
      title: 'Grace period',
      stage: const DemoStage(
        child: MockContent(emoji: '⏱️', accent: T.blue),
      ),
      dock: DemoDock(
        code: 'HudTheme(gracePeriod: 500ms)',
        description:
            'The overlay waits before fading in. If work finishes within the '
            'grace period, nothing ever appears — no distracting flash.',
        children: [
          RunButton(
            label: 'Fast task (300ms) → no flash',
            icon: Icons.flash_on_rounded,
            onPressed: () => _task(300),
          ),
          const SizedBox(height: 12),
          RunButton(
            label: 'Slow task (2s) → shows',
            color: T.sub,
            icon: Icons.hourglass_bottom_rounded,
            onPressed: () => _task(2000),
          ),
        ],
      ),
    );
  }
}
