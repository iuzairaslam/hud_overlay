import 'package:flutter/material.dart';
import 'package:hud_overlay/hud_overlay.dart';

import '../ui/demo_scaffold.dart';
import '../ui/demo_widgets.dart';
import '../ui/tokens.dart';

/// Demonstrates that each [HudOverlay] is scoped to its own subtree — two
/// regions load independently at the same time.
class ScopedOverlaysDemo extends StatefulWidget {
  const ScopedOverlaysDemo({super.key});

  @override
  State<ScopedOverlaysDemo> createState() => _ScopedOverlaysDemoState();
}

class _ScopedOverlaysDemoState extends State<ScopedOverlaysDemo> {
  bool _a = false;
  bool _b = false;

  Future<void> _run(bool which) async {
    setState(() => which ? _a = true : _b = true);
    await Future<void>.delayed(Duration(milliseconds: which ? 2000 : 3200));
    if (mounted) setState(() => which ? _a = false : _b = false);
  }

  @override
  Widget build(BuildContext context) {
    return DemoScaffold(
      title: 'Scoped overlays',
      stage: DemoStage(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Expanded(
                child: _Region(
                  busy: _a,
                  emoji: '🗂️',
                  label: 'Panel A',
                  accent: T.blue,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _Region(
                  busy: _b,
                  emoji: '📊',
                  label: 'Panel B',
                  accent: T.pink,
                ),
              ),
            ],
          ),
        ),
      ),
      dock: DemoDock(
        code: 'Overlay → HudOverlay (per region)',
        description:
            'A HudOverlay only covers the subtree it wraps. Load two regions '
            'at once — each is fully independent.',
        children: [
          Row(
            children: [
              Expanded(
                child: RunButton(
                  label: 'Panel A',
                  busy: _a,
                  onPressed: () => _run(true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: RunButton(
                  label: 'Panel B',
                  busy: _b,
                  color: T.pink,
                  onPressed: () => _run(false),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// A region that hosts its own local [Overlay] so the [HudOverlay] is confined
/// to this box rather than the whole screen.
class _Region extends StatelessWidget {
  const _Region({
    required this.busy,
    required this.emoji,
    required this.label,
    required this.accent,
  });

  final bool busy;
  final String emoji;
  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(T.radius),
        child: Overlay(
          initialEntries: [
            OverlayEntry(
              builder: (_) => HudOverlay(
                isLoading: busy,
                theme: HudTheme(
                  barrierColor: accent.withValues(alpha: 0.82),
                  containerDecoration: const BoxDecoration(),
                ),
                child: Container(
                  color: T.card,
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(emoji, style: const TextStyle(fontSize: 34)),
                      const SizedBox(height: 8),
                      Text(
                        label,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: T.ink,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
