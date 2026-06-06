import 'package:flutter/material.dart';
import 'package:hud_overlay/hud_overlay.dart';

import '../ui/demo_scaffold.dart';
import '../ui/demo_widgets.dart';
import '../ui/tokens.dart';

/// Demonstrates `HudService.showError()`.
class ServiceErrorDemo extends StatelessWidget {
  const ServiceErrorDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return DemoScaffold(
      title: 'showError',
      stage: const DemoStage(child: MockContent(emoji: '⚠️', accent: T.red)),
      dock: DemoDock(
        code: "HudService.showError(message: 'Failed')",
        description:
            'Transition an active overlay to an error icon that auto-dismisses '
            '— and announces the failure to screen readers.',
        children: [
          RunButton(
            label: 'Show error',
            color: T.red,
            icon: Icons.priority_high_rounded,
            onPressed: () {
              HudService.show();
              Future<void>.delayed(const Duration(milliseconds: 500))
                  .then((_) =>
                      HudService.showError(message: 'Something went wrong'));
            },
          ),
        ],
      ),
    );
  }
}
