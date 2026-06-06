import 'package:flutter/material.dart';
import 'package:hud_overlay/hud_overlay.dart';

import '../ui/demo_scaffold.dart';
import '../ui/demo_widgets.dart';
import '../ui/hud_presets.dart';
import '../ui/tokens.dart';

/// Demonstrates the built-in accessibility semantics.
class AccessibilityDemo extends StatefulWidget {
  const AccessibilityDemo({super.key});

  @override
  State<AccessibilityDemo> createState() => _AccessibilityDemoState();
}

class _AccessibilityDemoState extends State<AccessibilityDemo> {
  bool _busy = false;
  double? _progress;

  Future<void> _run() async {
    setState(() {
      _busy = true;
      _progress = 0;
    });
    for (var i = 1; i <= 10; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 280));
      if (!mounted) return;
      setState(() => _progress = i / 10);
    }
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final pct = _progress == null ? 0 : (_progress! * 100).round();
    return DemoScaffold(
      title: 'Accessibility',
      stage: HudOverlay(
        isLoading: _busy,
        progress: _progress,
        message: 'Loading $pct%',
        semanticsLabel: 'Loading content, $pct percent complete',
        theme: Hud.light,
        child: const DemoStage(child: MockContent(emoji: '♿', accent: T.green)),
      ),
      dock: DemoDock(
        code: 'semanticsLabel + progressBar role + liveRegion',
        description:
            'Overlays announce themselves to screen readers, expose a '
            'progressBar role with value/min/max, and update as a live region.',
        children: [
          RunButton(
            label: 'Run with announcements',
            busy: _busy,
            color: T.green,
            icon: Icons.record_voice_over_rounded,
            onPressed: _run,
          ),
          const SizedBox(height: 14),
          const Hint('Turn on VoiceOver (iOS) or TalkBack (Android) to hear '
              'the live progress announcements.'),
        ],
      ),
    );
  }
}
