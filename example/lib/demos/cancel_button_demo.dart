import 'package:flutter/material.dart';
import 'package:hud_overlay/hud_overlay.dart';

import '../ui/demo_scaffold.dart';
import '../ui/demo_widgets.dart';
import '../ui/hud_presets.dart';
import '../ui/tokens.dart';

/// Demonstrates an in-card cancel button via `onCancel`.
class CancelButtonDemo extends StatefulWidget {
  const CancelButtonDemo({super.key});

  @override
  State<CancelButtonDemo> createState() => _CancelButtonDemoState();
}

class _CancelButtonDemoState extends State<CancelButtonDemo> {
  bool _busy = false;
  String _status = '';

  @override
  Widget build(BuildContext context) {
    return DemoScaffold(
      title: 'Cancel button',
      stage: HudOverlay(
        isLoading: _busy,
        message: 'Downloading update',
        detail: '48 MB of 120 MB',
        onCancel: () => setState(() {
          _busy = false;
          _status = 'Download cancelled';
        }),
        cancelLabel: 'Stop',
        theme: Hud.light.copyWith(
          cancelButtonStyle: TextButton.styleFrom(foregroundColor: T.red),
        ),
        child: DemoStage(
          child: MockContent(
            emoji: _status.isEmpty ? '⬇️' : '🛑',
            label: _status.isEmpty ? 'Your screen' : _status,
            accent: T.red,
          ),
        ),
      ),
      dock: DemoDock(
        code: 'HudOverlay(onCancel: () { … })',
        description:
            'Provide onCancel to render a labelled button inside the card, '
            'letting users abort long-running work.',
        children: [
          RunButton(
            label: 'Start download',
            busy: _busy,
            color: T.red,
            icon: Icons.download_rounded,
            onPressed: () => setState(() {
              _busy = true;
              _status = '';
            }),
          ),
        ],
      ),
    );
  }
}
