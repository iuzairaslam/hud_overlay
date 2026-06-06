import 'package:flutter/material.dart';
import 'package:hud_overlay/hud_overlay.dart';

import '../ui/demo_scaffold.dart';
import '../ui/demo_widgets.dart';
import '../ui/tokens.dart';

/// Demonstrates the backdrop `blur` (frosted-glass) effect.
class BlurDemo extends StatefulWidget {
  const BlurDemo({super.key});

  @override
  State<BlurDemo> createState() => _BlurDemoState();
}

class _BlurDemoState extends State<BlurDemo> {
  bool _busy = false;
  double _blur = 8;

  Future<void> _run() async {
    setState(() => _busy = true);
    await Future<void>.delayed(const Duration(milliseconds: 2800));
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    return DemoScaffold(
      title: 'Backdrop blur',
      stage: HudOverlay(
        isLoading: _busy,
        message: 'Loading',
        theme: HudTheme(
          blur: _blur,
          barrierColor: const Color(0x22000000),
          messageStyle: T.hudDarkMessage,
          containerDecoration: const BoxDecoration(
            color: Color(0xF2FFFFFF),
            borderRadius: BorderRadius.all(Radius.circular(18)),
          ),
        ),
        child: const DemoStage(
          child: MockContent(emoji: '🌫️', accent: T.teal),
        ),
      ),
      dock: DemoDock(
        code: 'HudTheme(blur: ${_blur.toStringAsFixed(0)})',
        description:
            'Add a BackdropFilter behind the card for a frosted-glass look. '
            'Drag to set the blur radius, then preview.',
        children: [
          SliderRow(
            label: 'Blur',
            value: _blur,
            min: 0,
            max: 20,
            divisions: 20,
            color: T.teal,
            display: _blur.toStringAsFixed(0),
            onChanged: (v) => setState(() => _blur = v),
          ),
          const SizedBox(height: 8),
          RunButton(
            label: 'Preview blur',
            busy: _busy,
            color: T.teal,
            onPressed: _run,
          ),
        ],
      ),
    );
  }
}
