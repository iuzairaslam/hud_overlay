import 'package:flutter/material.dart';
import 'package:hud_overlay/hud_overlay.dart';

import '../ui/demo_scaffold.dart';
import '../ui/demo_widgets.dart';
import '../ui/tokens.dart';

/// Demonstrates custom success / error / info widgets via the theme.
class CustomStateWidgetsDemo extends StatefulWidget {
  const CustomStateWidgetsDemo({super.key});

  @override
  State<CustomStateWidgetsDemo> createState() => _CustomStateWidgetsDemoState();
}

class _CustomStateWidgetsDemoState extends State<CustomStateWidgetsDemo> {
  String _which = 'success';

  HudTheme get _theme => HudTheme.dark().copyWith(
    successWidget: _badge('🎊', T.green),
    errorWidget: _badge('🙈', T.red),
    infoWidget: _badge('💡', T.blue),
  );

  static Widget _badge(String emoji, Color color) => Container(
    width: 60,
    height: 60,
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.18),
      shape: BoxShape.circle,
    ),
    child: Center(child: Text(emoji, style: const TextStyle(fontSize: 30))),
  );

  void _run() {
    switch (_which) {
      case 'success':
        HudService.show(theme: _theme);
        Future<void>.delayed(
          const Duration(milliseconds: 450),
        ).then((_) => HudService.showSuccess(message: 'Nice!', theme: _theme));
      case 'error':
        HudService.show(theme: _theme);
        Future<void>.delayed(
          const Duration(milliseconds: 450),
        ).then((_) => HudService.showError(message: 'Oops', theme: _theme));
      default:
        HudService.showInfo(message: 'Heads up', theme: _theme);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DemoScaffold(
      title: 'Custom state widgets',
      stage: const DemoStage(
        child: MockContent(emoji: '🎭', accent: T.green),
      ),
      dock: DemoDock(
        code: 'HudTheme(successWidget / errorWidget / infoWidget)',
        description:
            'Replace the default check, error and info icons with any widget '
            'you like for fully branded result states.',
        children: [
          SegmentedRow<String>(
            label: 'State',
            value: _which,
            options: const {
              'success': 'Success',
              'error': 'Error',
              'info': 'Info',
            },
            onChanged: (v) => setState(() => _which = v),
          ),
          const SizedBox(height: 16),
          RunButton(
            label: 'Show state',
            icon: Icons.bolt_rounded,
            onPressed: _run,
          ),
        ],
      ),
    );
  }
}
