import 'package:flutter/material.dart';

import 'tokens.dart';

/// Consistent layout for every feature demo screen.
///
/// The [stage] fills the screen as a clean backdrop the overlay sits over,
/// and the [dock] is a fixed bottom sheet hosting the controls. This gives
/// each feature a focused, presentation-ready screen for screenshots.
class DemoScaffold extends StatelessWidget {
  const DemoScaffold({
    super.key,
    required this.title,
    required this.stage,
    required this.dock,
  });

  final String title;
  final Widget stage;
  final Widget dock;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: T.bg,
      appBar: AppBar(
        backgroundColor: T.bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: T.ink,
          ),
        ),
        iconTheme: const IconThemeData(color: T.blue),
      ),
      body: Column(
        children: [
          Expanded(child: stage),
          dock,
        ],
      ),
    );
  }
}
