import 'package:flutter/material.dart';

import 'tokens.dart';

/// A large, clean preview area that fills the screen and sits behind the
/// overlay. Gives every screenshot a realistic "app content" backdrop.
class DemoStage extends StatelessWidget {
  const DemoStage({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(color: T.bg),
      child: Center(child: child),
    );
  }
}

/// A neutral mock "content sheet" so an overlay has something to cover,
/// making screenshots feel like a real screen rather than a blank canvas.
class MockContent extends StatelessWidget {
  const MockContent({
    super.key,
    this.emoji = '🪟',
    this.label = 'Your screen',
    this.accent = T.blue,
  });

  final String emoji;
  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
      decoration: BoxDecoration(
        color: T.card,
        borderRadius: BorderRadius.circular(T.radius),
        boxShadow: T.shadow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 30)),
            ),
          ),
          const SizedBox(height: 16),
          Text(label, style: T.title),
          const SizedBox(height: 16),
          _bar(width: 200),
          const SizedBox(height: 8),
          _bar(width: 150),
        ],
      ),
    );
  }

  Widget _bar({required double width}) => Container(
    width: width,
    height: 10,
    decoration: BoxDecoration(
      color: const Color(0xFFEDEDF2),
      borderRadius: BorderRadius.circular(5),
    ),
  );
}

/// The bottom "control dock": a rounded white sheet that hosts the code hint,
/// description and interactive controls for the feature being demonstrated.
class DemoDock extends StatelessWidget {
  const DemoDock({
    super.key,
    required this.code,
    required this.description,
    required this.children,
  });

  final String code;
  final String description;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
      decoration: const BoxDecoration(
        color: T.card,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 24,
            offset: Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CodeChip(code),
            const SizedBox(height: 10),
            Text(description, style: T.body),
            const SizedBox(height: 18),
            ...children,
          ],
        ),
      ),
    );
  }
}

/// A monospace API hint chip, e.g. `HudOverlay(dismissible: true)`.
class CodeChip extends StatelessWidget {
  const CodeChip(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: T.bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text, style: T.code),
    );
  }
}

/// Primary pill action button used to trigger a demo.
class RunButton extends StatelessWidget {
  const RunButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.busy = false,
    this.color = T.blue,
    this.icon = Icons.play_arrow_rounded,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool busy;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: FilledButton.icon(
        onPressed: busy ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: color,
          disabledBackgroundColor: color.withValues(alpha: 0.5),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        icon: busy
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Icon(icon, size: 20),
        label: Text(
          busy ? 'Running…' : label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

/// A labelled switch row for boolean config options.
class ToggleRow extends StatelessWidget {
  const ToggleRow({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.color = T.green,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 15, color: T.ink),
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.white,
            activeTrackColor: color,
          ),
        ],
      ),
    );
  }
}

/// A labelled slider row with a trailing value display.
class SliderRow extends StatelessWidget {
  const SliderRow({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    required this.min,
    required this.max,
    required this.display,
    this.divisions,
    this.color = T.blue,
  });

  final String label;
  final double value;
  final ValueChanged<double> onChanged;
  final double min;
  final double max;
  final int? divisions;
  final String display;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: const TextStyle(fontSize: 15, color: T.ink)),
            const Spacer(),
            CodeChip(display),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: color,
            thumbColor: color,
            overlayColor: color.withValues(alpha: 0.15),
            inactiveTrackColor: T.bg,
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

/// A compact segmented control for choosing one option among a few.
class SegmentedRow<T_ extends Object> extends StatelessWidget {
  const SegmentedRow({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String label;
  final T_ value;
  final Map<T_, String> options;
  final ValueChanged<T_> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 15, color: T.ink)),
        const SizedBox(height: 10),
        SegmentedButton<T_>(
          segments: options.entries
              .map((e) => ButtonSegment<T_>(value: e.key, label: Text(e.value)))
              .toList(),
          selected: {value},
          showSelectedIcon: false,
          onSelectionChanged: (s) => onChanged(s.first),
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.resolveWith((states) {
              return states.contains(WidgetState.selected) ? T.blue : T.bg;
            }),
            foregroundColor: WidgetStateProperty.resolveWith((states) {
              return states.contains(WidgetState.selected)
                  ? Colors.white
                  : T.ink;
            }),
            side: WidgetStateProperty.all(BorderSide.none),
          ),
        ),
      ],
    );
  }
}

/// A small informational note under controls.
class Hint extends StatelessWidget {
  const Hint(this.text, {super.key, this.icon = Icons.lightbulb_outline});
  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: T.sub),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 12.5, height: 1.4, color: T.sub),
          ),
        ),
      ],
    );
  }
}
