import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hud_overlay/hud_overlay.dart';

import '../ui/demo_scaffold.dart';
import '../ui/demo_widgets.dart';
import '../ui/tokens.dart';

/// Demonstrates `HudService.wrap()` — spinner → success/error around a Future.
class ServiceWrapDemo extends StatefulWidget {
  const ServiceWrapDemo({super.key});

  @override
  State<ServiceWrapDemo> createState() => _ServiceWrapDemoState();
}

class _ServiceWrapDemoState extends State<ServiceWrapDemo> {
  bool _shouldFail = false;

  Future<void> _run() async {
    final future = Future<void>.delayed(const Duration(milliseconds: 1200), () {
      if (_shouldFail) throw 'Network error';
    });
    await HudService.wrap<void>(
      future,
      message: 'Saving…',
      successMessage: 'Saved!',
      errorMessage: 'Failed',
    ).onError((_, __) {});
  }

  @override
  Widget build(BuildContext context) {
    return DemoScaffold(
      title: 'wrap a Future',
      stage: DemoStage(
        child: MockContent(
          emoji: _shouldFail ? '💥' : '✅',
          accent: _shouldFail ? T.red : T.green,
        ),
      ),
      dock: DemoDock(
        code: 'HudService.wrap(future, …)',
        description:
            'Show a spinner for the lifetime of a Future, then automatically '
            'flip to a success check or error icon based on the outcome.',
        children: [
          ToggleRow(
            label: 'Make it fail',
            value: _shouldFail,
            color: T.red,
            onChanged: (v) => setState(() => _shouldFail = v),
          ),
          const SizedBox(height: 12),
          RunButton(
            label: 'Run task',
            color: _shouldFail ? T.red : T.green,
            onPressed: () => unawaited(_run()),
          ),
        ],
      ),
    );
  }
}
