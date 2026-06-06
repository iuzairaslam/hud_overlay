import 'package:flutter/material.dart';
import 'package:hud_overlay/hud_overlay.dart';

import '../ui/demo_scaffold.dart';
import '../ui/demo_widgets.dart';
import '../ui/tokens.dart';

/// Demonstrates `HudService.showInfo()` — a standalone informational toast.
class ServiceInfoDemo extends StatelessWidget {
  const ServiceInfoDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return DemoScaffold(
      title: 'showInfo',
      stage: const DemoStage(child: MockContent(emoji: 'ℹ️', accent: T.blue)),
      dock: DemoDock(
        code: "HudService.showInfo(message: 'Copied')",
        description:
            'Unlike success/error, showInfo creates its own overlay if none is '
            'active — making it a quick standalone "toast".',
        children: [
          RunButton(
            label: 'Show info toast',
            icon: Icons.info_outline_rounded,
            onPressed: () =>
                HudService.showInfo(message: 'Link copied to clipboard'),
          ),
        ],
      ),
    );
  }
}
