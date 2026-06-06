import 'package:flutter/material.dart';
import 'package:hud_overlay/hud_overlay.dart';

import '../ui/demo_scaffold.dart';
import '../ui/demo_widgets.dart';
import '../ui/tokens.dart';
import '../widgets/pulsing_dot.dart';

/// Demonstrates swapping the spinner for any custom `indicator` widget.
class CustomIndicatorDemo extends StatefulWidget {
  const CustomIndicatorDemo({super.key});

  @override
  State<CustomIndicatorDemo> createState() => _CustomIndicatorDemoState();
}

class _CustomIndicatorDemoState extends State<CustomIndicatorDemo> {
  bool _busy = false;

  Future<void> _run() async {
    setState(() => _busy = true);
    await Future<void>.delayed(const Duration(milliseconds: 2800));
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    return DemoScaffold(
      title: 'Custom indicator',
      stage: HudOverlay(
        isLoading: _busy,
        message: 'Loading',
        theme: HudTheme(
          barrierColor: const Color(0x40000000),
          indicator: const PulsingDot(),
          messageStyle: T.hudDarkMessage,
          containerPadding: const EdgeInsets.symmetric(
            horizontal: 30,
            vertical: 26,
          ),
          containerDecoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(18)),
            boxShadow: [
              BoxShadow(
                color: Color(0x1F000000),
                blurRadius: 28,
                offset: Offset(0, 10),
              ),
            ],
          ),
        ),
        child: const DemoStage(
          child: MockContent(emoji: '✨', accent: T.pink),
        ),
      ),
      dock: DemoDock(
        code: 'HudTheme(indicator: PulsingDot())',
        description:
            'Drop in any widget as the indicator — a Lottie animation, a '
            'branded logo, or a custom painter.',
        children: [
          RunButton(
            label: 'Preview indicator',
            busy: _busy,
            color: T.pink,
            onPressed: _run,
          ),
        ],
      ),
    );
  }
}
