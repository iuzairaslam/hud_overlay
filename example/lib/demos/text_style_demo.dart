import 'package:flutter/material.dart';
import 'package:hud_overlay/hud_overlay.dart';

import '../ui/demo_scaffold.dart';
import '../ui/demo_widgets.dart';
import '../ui/tokens.dart';

/// Demonstrates fully customizable `messageStyle` and `detailStyle`.
class TextStyleDemo extends StatefulWidget {
  const TextStyleDemo({super.key});

  @override
  State<TextStyleDemo> createState() => _TextStyleDemoState();
}

class _TextStyleDemoState extends State<TextStyleDemo> {
  bool _busy = false;
  Color _color = T.pink;

  static final _palette = {
    T.pink: 'pink',
    T.blue: 'blue',
    T.green: 'green',
  };

  Future<void> _run() async {
    setState(() => _busy = true);
    await Future<void>.delayed(const Duration(milliseconds: 2800));
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    return DemoScaffold(
      title: 'Text styles',
      stage: HudOverlay(
        isLoading: _busy,
        message: 'Styled message',
        detail: 'with a matching detail line',
        theme: HudTheme(
          barrierColor: const Color(0x40000000),
          messageStyle: TextStyle(
            color: _color,
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.3,
          ),
          detailStyle: TextStyle(
            color: _color.withValues(alpha: 0.7),
            fontSize: 12.5,
            fontStyle: FontStyle.italic,
          ),
          containerPadding:
              const EdgeInsets.symmetric(horizontal: 30, vertical: 26),
          containerDecoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(18)),
            boxShadow: [
              BoxShadow(
                  color: Color(0x1F000000), blurRadius: 28, offset: Offset(0, 10)),
            ],
          ),
        ),
        child: DemoStage(child: MockContent(emoji: '🎨', accent: _color)),
      ),
      dock: DemoDock(
        code: 'HudTheme(messageStyle / detailStyle)',
        description:
            'The primary and secondary text are plain TextStyles — set any '
            'font, weight, size or color to match your brand.',
        children: [
          SegmentedRow<Color>(
            label: 'Text color',
            value: _color,
            options: _palette,
            onChanged: (v) => setState(() => _color = v),
          ),
          const SizedBox(height: 16),
          RunButton(
            label: 'Preview styles',
            busy: _busy,
            color: _color,
            onPressed: _run,
          ),
        ],
      ),
    );
  }
}
