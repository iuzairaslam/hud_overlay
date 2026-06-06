import 'package:flutter/material.dart';
import 'package:hud_overlay/hud_overlay.dart';

import '../ui/demo_scaffold.dart';
import '../ui/demo_widgets.dart';
import '../ui/hud_presets.dart';
import '../ui/tokens.dart';

/// Demonstrates the secondary `detail` line beneath the message.
class DetailDemo extends StatefulWidget {
  const DetailDemo({super.key});

  @override
  State<DetailDemo> createState() => _DetailDemoState();
}

class _DetailDemoState extends State<DetailDemo> {
  bool _busy = false;

  Future<void> _run() async {
    setState(() => _busy = true);
    await Future<void>.delayed(const Duration(milliseconds: 2800));
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    return DemoScaffold(
      title: 'Detail line',
      stage: HudOverlay(
        isLoading: _busy,
        message: 'Syncing library',
        detail: 'This can take a moment…',
        theme: Hud.light,
        child: const DemoStage(child: MockContent(emoji: '📚', accent: T.teal)),
      ),
      dock: DemoDock(
        code: "HudOverlay(detail: 'This can take a moment…')",
        description:
            'Pair a primary message with a quieter secondary line for extra '
            'context — perfect for longer operations.',
        children: [
          RunButton(
            label: 'Sync library',
            busy: _busy,
            color: T.teal,
            icon: Icons.sync_rounded,
            onPressed: _run,
          ),
        ],
      ),
    );
  }
}
