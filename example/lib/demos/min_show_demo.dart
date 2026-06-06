import 'package:flutter/material.dart';
import 'package:hud_overlay/hud_overlay.dart';

import '../ui/demo_scaffold.dart';
import '../ui/demo_widgets.dart';
import '../ui/tokens.dart';

/// Demonstrates `minShowDuration` — anti-flicker minimum visible time.
class MinShowDemo extends StatelessWidget {
  const MinShowDemo({super.key});

  static final _theme = HudTheme.dark().copyWith(
    minShowDuration: const Duration(milliseconds: 1000),
  );

  void _task() {
    HudService.show(message: 'Saving…', theme: _theme);
    // Finishes almost instantly — but stays up for the minimum.
    Future<void>.delayed(
      const Duration(milliseconds: 50),
    ).then((_) => HudService.dismiss());
  }

  @override
  Widget build(BuildContext context) {
    return DemoScaffold(
      title: 'Minimum show time',
      stage: const DemoStage(
        child: MockContent(emoji: '🫧', accent: T.teal),
      ),
      dock: DemoDock(
        code: 'HudTheme(minShowDuration: 1s)',
        description:
            'Once shown, the overlay stays for at least this long even if the '
            'work finishes instantly — preventing a jarring flicker.',
        children: [
          RunButton(
            label: 'Instant task (stays 1s)',
            color: T.teal,
            icon: Icons.timer_outlined,
            onPressed: _task,
          ),
        ],
      ),
    );
  }
}
