import 'package:flutter/material.dart';
import 'package:hud_overlay/hud_overlay.dart';

import '../ui/demo_scaffold.dart';
import '../ui/demo_widgets.dart';
import '../ui/tokens.dart';

/// Demonstrates the ready-made `HudTheme.light()` / `HudTheme.dark()` presets.
class PresetsDemo extends StatefulWidget {
  const PresetsDemo({super.key});

  @override
  State<PresetsDemo> createState() => _PresetsDemoState();
}

class _PresetsDemoState extends State<PresetsDemo> {
  bool _busy = false;
  bool _dark = true;

  Future<void> _run() async {
    setState(() => _busy = true);
    await Future<void>.delayed(const Duration(milliseconds: 2500));
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    return DemoScaffold(
      title: 'Light & dark presets',
      stage: HudOverlay(
        isLoading: _busy,
        message: 'Loading',
        theme: _dark ? HudTheme.dark() : HudTheme.light(),
        child: DemoStage(
          child: MockContent(
            emoji: _dark ? '🌙' : '☀️',
            accent: _dark ? T.purple : T.orange,
          ),
        ),
      ),
      dock: DemoDock(
        code: _dark ? 'HudTheme.dark()' : 'HudTheme.light()',
        description:
            'Two batteries-included presets with sensible cards, scrims and '
            'text colors. Fine-tune either with copyWith().',
        children: [
          SegmentedRow<bool>(
            label: 'Preset',
            value: _dark,
            options: const {true: 'dark()', false: 'light()'},
            onChanged: (v) => setState(() => _dark = v),
          ),
          const SizedBox(height: 16),
          RunButton(label: 'Preview preset', busy: _busy, onPressed: _run),
        ],
      ),
    );
  }
}
