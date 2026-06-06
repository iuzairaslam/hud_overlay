import 'package:flutter/material.dart';
import 'package:hud_overlay/hud_overlay.dart';

import '../ui/demo_scaffold.dart';
import '../ui/demo_widgets.dart';
import '../ui/tokens.dart';

/// Demonstrates `HudService.trackStream()` for stream-driven progress.
class ServiceStreamDemo extends StatelessWidget {
  const ServiceStreamDemo({super.key});

  Stream<double> _upload() async* {
    for (var i = 1; i <= 25; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 110));
      yield i / 25;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DemoScaffold(
      title: 'trackStream',
      stage: const DemoStage(child: MockContent(emoji: '📡', accent: T.purple)),
      dock: DemoDock(
        code: 'HudService.trackStream(progress\$)',
        description:
            'Drive determinate progress straight from a Stream<double>. The '
            'overlay dismisses automatically when the stream closes.',
        children: [
          RunButton(
            label: 'Upload from stream',
            color: T.purple,
            icon: Icons.cloud_upload_rounded,
            onPressed: () => HudService.trackStream(
              _upload(),
              message: 'Uploading…',
              key: 'stream',
            ),
          ),
        ],
      ),
    );
  }
}
