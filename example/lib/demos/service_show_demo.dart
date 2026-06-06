import 'package:flutter/material.dart';
import 'package:hud_overlay/hud_overlay.dart';

import '../ui/demo_scaffold.dart';
import '../ui/demo_widgets.dart';

/// Demonstrates the context-free `HudService.show()` / `dismiss()`.
class ServiceShowDemo extends StatelessWidget {
  const ServiceShowDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return DemoScaffold(
      title: 'show / dismiss',
      stage: const DemoStage(child: MockContent(emoji: '⚡')),
      dock: DemoDock(
        code: 'HudService.show(); HudService.dismiss();',
        description:
            'Show an overlay from anywhere — no BuildContext needed. Call it '
            'from a BLoC, a repository, or a plain Dart service.',
        children: [
          RunButton(
            label: 'show() for 2s',
            onPressed: () {
              HudService.show(message: 'Working…');
              Future<void>.delayed(const Duration(seconds: 2))
                  .then((_) => HudService.dismiss());
            },
          ),
          const SizedBox(height: 14),
          const Hint('No widget wrapping required — HudScope wires up the '
              'global overlay once at app startup.'),
        ],
      ),
    );
  }
}
