import 'package:flutter/material.dart';
import 'package:hud_overlay/hud_overlay.dart';

import '../ui/demo_scaffold.dart';
import '../ui/demo_widgets.dart';
import '../ui/tokens.dart';

/// Demonstrates multiple keyed overlays stacked at once + `dismissAll()`.
class ServiceStackDemo extends StatelessWidget {
  const ServiceStackDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return DemoScaffold(
      title: 'Stacked overlays',
      stage: const DemoStage(
        child: MockContent(emoji: '🧱', accent: T.orange),
      ),
      dock: DemoDock(
        code: "HudService.show(key: '…')  •  dismissAll()",
        description:
            'Each key gets its own overlay, so several can be live at once. '
            'Clear them all with a single dismissAll().',
        children: [
          RunButton(
            label: 'Stack 3 overlays',
            color: T.orange,
            icon: Icons.layers_rounded,
            onPressed: () {
              HudService.show(
                key: 'top',
                message: 'Task A',
                theme: HudTheme.dark().copyWith(position: HudPosition.top),
              );
              HudService.show(
                key: 'center',
                message: 'Task B',
                theme: HudTheme.dark(),
              );
              HudService.show(
                key: 'bottom',
                message: 'Task C',
                theme: HudTheme.dark().copyWith(position: HudPosition.bottom),
              );
            },
          ),
          const SizedBox(height: 12),
          RunButton(
            label: 'dismissAll()',
            color: T.sub,
            icon: Icons.clear_all_rounded,
            onPressed: HudService.dismissAll,
          ),
        ],
      ),
    );
  }
}
