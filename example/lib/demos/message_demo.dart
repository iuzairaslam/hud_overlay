import 'package:flutter/material.dart';
import 'package:hud_overlay/hud_overlay.dart';

import '../ui/demo_scaffold.dart';
import '../ui/demo_widgets.dart';
import '../ui/hud_presets.dart';

/// Demonstrates a labelled spinner via the `message` parameter.
class MessageDemo extends StatefulWidget {
  const MessageDemo({super.key});

  @override
  State<MessageDemo> createState() => _MessageDemoState();
}

class _MessageDemoState extends State<MessageDemo> {
  bool _busy = false;
  String _message = 'Uploading photo…';

  static const _options = {
    'Uploading photo…': 'Upload',
    'Saving changes…': 'Save',
    'Signing you in…': 'Sign in',
  };

  Future<void> _run() async {
    setState(() => _busy = true);
    await Future<void>.delayed(const Duration(milliseconds: 2500));
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    return DemoScaffold(
      title: 'Message label',
      stage: HudOverlay(
        isLoading: _busy,
        message: _message,
        theme: Hud.light,
        child: const DemoStage(child: MockContent(emoji: '💬')),
      ),
      dock: DemoDock(
        code: "HudOverlay(message: '$_message')",
        description:
            'Add a short label beneath the indicator to tell users exactly '
            'what is happening.',
        children: [
          SegmentedRow<String>(
            label: 'Message',
            value: _message,
            options: _options,
            onChanged: (v) => setState(() => _message = v),
          ),
          const SizedBox(height: 16),
          RunButton(label: 'Show with message', busy: _busy, onPressed: _run),
        ],
      ),
    );
  }
}
