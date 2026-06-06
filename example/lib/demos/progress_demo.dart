import 'package:flutter/material.dart';
import 'package:hud_overlay/hud_overlay.dart';

import '../ui/demo_scaffold.dart';
import '../ui/demo_widgets.dart';
import '../ui/hud_presets.dart';
import '../ui/tokens.dart';

/// Demonstrates deterministic progress (0.0 → 1.0).
class ProgressDemo extends StatefulWidget {
  const ProgressDemo({super.key});

  @override
  State<ProgressDemo> createState() => _ProgressDemoState();
}

class _ProgressDemoState extends State<ProgressDemo> {
  bool _busy = false;
  double? _progress;

  Future<void> _run() async {
    setState(() {
      _busy = true;
      _progress = 0;
    });
    for (var i = 1; i <= 20; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 130));
      if (!mounted) return;
      setState(() => _progress = i / 20);
    }
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final pct = _progress == null ? 0 : (_progress! * 100).round();
    return DemoScaffold(
      title: 'Determinate progress',
      stage: HudOverlay(
        isLoading: _busy,
        progress: _progress,
        message: _progress == null ? null : '$pct%',
        theme: Hud.light,
        child: const DemoStage(child: MockContent(emoji: '📊', accent: T.purple)),
      ),
      dock: DemoDock(
        code: 'HudOverlay(progress: 0.0 → 1.0)',
        description:
            'Pass a value between 0 and 1 to switch the spinner into a '
            'determinate ring and announce percentage to screen readers.',
        children: [
          RunButton(
            label: 'Start download',
            busy: _busy,
            color: T.purple,
            icon: Icons.download_rounded,
            onPressed: _run,
          ),
          const SizedBox(height: 14),
          const Hint('Exposes a progressBar semantics role with min/max/value '
              'for assistive technologies.'),
        ],
      ),
    );
  }
}
