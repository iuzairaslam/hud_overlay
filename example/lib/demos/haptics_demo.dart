import 'package:flutter/material.dart';
import 'package:hud_overlay/hud_overlay.dart';

import '../ui/demo_scaffold.dart';
import '../ui/demo_widgets.dart';
import '../ui/tokens.dart';

/// Demonstrates `enableHaptics` — feedback on success / error transitions.
class HapticsDemo extends StatefulWidget {
  const HapticsDemo({super.key});

  @override
  State<HapticsDemo> createState() => _HapticsDemoState();
}

class _HapticsDemoState extends State<HapticsDemo> {
  bool _haptics = true;

  HudTheme get _theme =>
      HudTheme.dark().copyWith(enableHaptics: _haptics);

  void _run(bool success) {
    HudService.show(theme: _theme);
    Future<void>.delayed(const Duration(milliseconds: 450)).then((_) {
      if (success) {
        HudService.showSuccess(message: 'Done!', theme: _theme);
      } else {
        HudService.showError(message: 'Failed', theme: _theme);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DemoScaffold(
      title: 'Haptic feedback',
      stage: const DemoStage(child: MockContent(emoji: '📳', accent: T.orange)),
      dock: DemoDock(
        code: 'HudTheme(enableHaptics: true)',
        description:
            'Fire a light impact on success/info and a heavy impact on error '
            'as the overlay reaches its terminal state.',
        children: [
          ToggleRow(
            label: 'Enable haptics',
            value: _haptics,
            color: T.orange,
            onChanged: (v) => setState(() => _haptics = v),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: RunButton(
                  label: 'Success',
                  color: T.green,
                  icon: Icons.check_rounded,
                  onPressed: () => _run(true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: RunButton(
                  label: 'Error',
                  color: T.red,
                  icon: Icons.close_rounded,
                  onPressed: () => _run(false),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Hint('Haptics are most noticeable on a physical device.'),
        ],
      ),
    );
  }
}
