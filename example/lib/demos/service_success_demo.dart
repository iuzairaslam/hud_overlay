import 'package:flutter/material.dart';
import 'package:hud_overlay/hud_overlay.dart';

import '../ui/demo_scaffold.dart';
import '../ui/demo_widgets.dart';
import '../ui/tokens.dart';

/// Demonstrates `HudService.showSuccess()`.
class ServiceSuccessDemo extends StatelessWidget {
  const ServiceSuccessDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return DemoScaffold(
      title: 'showSuccess',
      stage: const DemoStage(
        child: MockContent(emoji: '🎉', accent: T.green),
      ),
      dock: DemoDock(
        code: "HudService.showSuccess(message: 'Done!')",
        description:
            'Transition an active overlay to a success checkmark that '
            'auto-dismisses. Duration scales with message length.',
        children: [
          RunButton(
            label: 'Show success',
            color: T.green,
            icon: Icons.check_rounded,
            onPressed: () {
              HudService.show();
              Future<void>.delayed(
                const Duration(milliseconds: 500),
              ).then((_) => HudService.showSuccess(message: 'Done!'));
            },
          ),
        ],
      ),
    );
  }
}
