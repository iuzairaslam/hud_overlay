import 'package:flutter/material.dart';
import 'package:hud_overlay/hud_overlay.dart';

import '../ui/demo_scaffold.dart';
import '../ui/demo_widgets.dart';
import '../ui/hud_presets.dart';

/// Demonstrates the simplest case: a plain spinner driven by `isLoading`.
class BasicSpinnerDemo extends StatefulWidget {
  const BasicSpinnerDemo({super.key});

  @override
  State<BasicSpinnerDemo> createState() => _BasicSpinnerDemoState();
}

class _BasicSpinnerDemoState extends State<BasicSpinnerDemo> {
  bool _busy = false;

  Future<void> _run() async {
    setState(() => _busy = true);
    await Future<void>.delayed(const Duration(milliseconds: 2500));
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    return DemoScaffold(
      title: 'Basic spinner',
      stage: HudOverlay(
        isLoading: _busy,
        theme: Hud.light,
        child: const DemoStage(child: MockContent(emoji: '🌀')),
      ),
      dock: DemoDock(
        code: 'HudOverlay(isLoading: true)',
        description:
            'Wrap any widget and flip a single boolean. An indeterminate '
            'spinner fades in over your content and blocks input.',
        children: [
          RunButton(label: 'Show spinner', busy: _busy, onPressed: _run),
          const SizedBox(height: 14),
          const Hint(
            'The adaptive indicator renders as a Cupertino spinner '
            'on iOS and a Material spinner on Android.',
          ),
        ],
      ),
    );
  }
}
