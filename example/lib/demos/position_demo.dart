import 'package:flutter/material.dart';
import 'package:hud_overlay/hud_overlay.dart';

import '../ui/demo_scaffold.dart';
import '../ui/demo_widgets.dart';
import '../ui/hud_presets.dart';
import '../ui/tokens.dart';

/// Demonstrates anchoring the card to the top, center or bottom.
class PositionDemo extends StatefulWidget {
  const PositionDemo({super.key});

  @override
  State<PositionDemo> createState() => _PositionDemoState();
}

class _PositionDemoState extends State<PositionDemo> {
  bool _busy = false;
  HudPosition _pos = HudPosition.center;

  Future<void> _run() async {
    setState(() => _busy = true);
    await Future<void>.delayed(const Duration(milliseconds: 2500));
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    return DemoScaffold(
      title: 'Card position',
      stage: HudOverlay(
        isLoading: _busy,
        message: 'Loading',
        theme: Hud.light.copyWith(position: _pos),
        child: const DemoStage(
          child: MockContent(emoji: '🧭', accent: T.purple),
        ),
      ),
      dock: DemoDock(
        code: 'HudTheme(position: HudPosition.${_pos.name})',
        description:
            'Anchor the indicator card to the top, center or bottom third of '
            'the screen.',
        children: [
          SegmentedRow<HudPosition>(
            label: 'Position',
            value: _pos,
            options: const {
              HudPosition.top: 'Top',
              HudPosition.center: 'Center',
              HudPosition.bottom: 'Bottom',
            },
            onChanged: (v) => setState(() => _pos = v),
          ),
          const SizedBox(height: 16),
          RunButton(
            label: 'Preview position',
            busy: _busy,
            color: T.purple,
            onPressed: _run,
          ),
        ],
      ),
    );
  }
}
