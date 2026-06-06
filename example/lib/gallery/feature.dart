import 'package:flutter/material.dart';

import '../demos/accessibility_demo.dart';
import '../demos/basic_spinner_demo.dart';
import '../demos/blur_demo.dart';
import '../demos/cancel_button_demo.dart';
import '../demos/custom_indicator_demo.dart';
import '../demos/custom_state_widgets_demo.dart';
import '../demos/detail_demo.dart';
import '../demos/dismissible_demo.dart';
import '../demos/grace_period_demo.dart';
import '../demos/haptics_demo.dart';
import '../demos/interactive_demo.dart';
import '../demos/message_demo.dart';
import '../demos/min_show_demo.dart';
import '../demos/position_demo.dart';
import '../demos/presets_demo.dart';
import '../demos/progress_demo.dart';
import '../demos/scoped_overlays_demo.dart';
import '../demos/service_error_demo.dart';
import '../demos/service_info_demo.dart';
import '../demos/service_show_demo.dart';
import '../demos/service_stack_demo.dart';
import '../demos/service_stream_demo.dart';
import '../demos/service_success_demo.dart';
import '../demos/service_wrap_demo.dart';
import '../demos/text_style_demo.dart';
import '../ui/tokens.dart';

/// A single demonstrable capability of the package.
class Feature {
  const Feature({
    required this.emoji,
    required this.title,
    required this.code,
    required this.accent,
    required this.builder,
  });

  final String emoji;
  final String title;
  final String code;
  final Color accent;
  final WidgetBuilder builder;
}

/// A titled group of related features.
class FeatureSection {
  const FeatureSection({
    required this.title,
    required this.caption,
    required this.features,
  });

  final String title;
  final String caption;
  final List<Feature> features;
}

/// Every feature, grouped for the gallery — one dedicated screen each.
const List<FeatureSection> kSections = [
  FeatureSection(
    title: 'HudOverlay',
    caption: 'The context-aware widget — wrap any subtree.',
    features: [
      Feature(
        emoji: '🌀',
        title: 'Basic spinner',
        code: 'isLoading',
        accent: T.blue,
        builder: _basic,
      ),
      Feature(
        emoji: '💬',
        title: 'Message label',
        code: 'message',
        accent: T.blue,
        builder: _message,
      ),
      Feature(
        emoji: '📊',
        title: 'Determinate progress',
        code: 'progress',
        accent: T.purple,
        builder: _progress,
      ),
      Feature(
        emoji: '📚',
        title: 'Detail line',
        code: 'detail',
        accent: T.teal,
        builder: _detail,
      ),
      Feature(
        emoji: '👆',
        title: 'Dismissible barrier',
        code: 'dismissible',
        accent: T.orange,
        builder: _dismissible,
      ),
      Feature(
        emoji: '🛑',
        title: 'Cancel button',
        code: 'onCancel',
        accent: T.red,
        builder: _cancel,
      ),
      Feature(
        emoji: '🗂️',
        title: 'Scoped overlays',
        code: 'per-subtree',
        accent: T.pink,
        builder: _scoped,
      ),
    ],
  ),
  FeatureSection(
    title: 'HudService',
    caption: 'The context-free static API — call from anywhere.',
    features: [
      Feature(
        emoji: '⚡',
        title: 'show / dismiss',
        code: 'show()',
        accent: T.blue,
        builder: _serviceShow,
      ),
      Feature(
        emoji: '🔄',
        title: 'Wrap a Future',
        code: 'wrap()',
        accent: T.green,
        builder: _serviceWrap,
      ),
      Feature(
        emoji: '🎉',
        title: 'Success state',
        code: 'showSuccess()',
        accent: T.green,
        builder: _serviceSuccess,
      ),
      Feature(
        emoji: '⚠️',
        title: 'Error state',
        code: 'showError()',
        accent: T.red,
        builder: _serviceError,
      ),
      Feature(
        emoji: 'ℹ️',
        title: 'Info toast',
        code: 'showInfo()',
        accent: T.blue,
        builder: _serviceInfo,
      ),
      Feature(
        emoji: '📡',
        title: 'Track a stream',
        code: 'trackStream()',
        accent: T.purple,
        builder: _serviceStream,
      ),
      Feature(
        emoji: '🧱',
        title: 'Stacked overlays',
        code: 'key + dismissAll()',
        accent: T.orange,
        builder: _serviceStack,
      ),
    ],
  ),
  FeatureSection(
    title: 'HudTheme',
    caption: 'Style every pixel — presets and full customization.',
    features: [
      Feature(
        emoji: '🌗',
        title: 'Light & dark presets',
        code: 'HudTheme.light/dark()',
        accent: T.purple,
        builder: _presets,
      ),
      Feature(
        emoji: '🌫️',
        title: 'Backdrop blur',
        code: 'blur',
        accent: T.teal,
        builder: _blur,
      ),
      Feature(
        emoji: '🧭',
        title: 'Card position',
        code: 'position',
        accent: T.purple,
        builder: _position,
      ),
      Feature(
        emoji: '✨',
        title: 'Custom indicator',
        code: 'indicator',
        accent: T.pink,
        builder: _customIndicator,
      ),
      Feature(
        emoji: '🎭',
        title: 'Custom state widgets',
        code: 'success/error/info',
        accent: T.green,
        builder: _customStates,
      ),
      Feature(
        emoji: '🎨',
        title: 'Text styles',
        code: 'messageStyle',
        accent: T.pink,
        builder: _textStyle,
      ),
    ],
  ),
  FeatureSection(
    title: 'Behavior & a11y',
    caption: 'Polish that sets the package apart.',
    features: [
      Feature(
        emoji: '⏱️',
        title: 'Grace period',
        code: 'gracePeriod',
        accent: T.blue,
        builder: _grace,
      ),
      Feature(
        emoji: '🫧',
        title: 'Minimum show time',
        code: 'minShowDuration',
        accent: T.teal,
        builder: _minShow,
      ),
      Feature(
        emoji: '📳',
        title: 'Haptic feedback',
        code: 'enableHaptics',
        accent: T.orange,
        builder: _haptics,
      ),
      Feature(
        emoji: '🪂',
        title: 'Non-blocking overlay',
        code: 'interactive',
        accent: T.green,
        builder: _interactive,
      ),
      Feature(
        emoji: '♿',
        title: 'Accessibility',
        code: 'semantics',
        accent: T.green,
        builder: _accessibility,
      ),
    ],
  ),
];

// Tear-off builders (const-friendly).
Widget _basic(BuildContext c) => const BasicSpinnerDemo();
Widget _message(BuildContext c) => const MessageDemo();
Widget _progress(BuildContext c) => const ProgressDemo();
Widget _detail(BuildContext c) => const DetailDemo();
Widget _dismissible(BuildContext c) => const DismissibleDemo();
Widget _cancel(BuildContext c) => const CancelButtonDemo();
Widget _scoped(BuildContext c) => const ScopedOverlaysDemo();
Widget _serviceShow(BuildContext c) => const ServiceShowDemo();
Widget _serviceWrap(BuildContext c) => const ServiceWrapDemo();
Widget _serviceSuccess(BuildContext c) => const ServiceSuccessDemo();
Widget _serviceError(BuildContext c) => const ServiceErrorDemo();
Widget _serviceInfo(BuildContext c) => const ServiceInfoDemo();
Widget _serviceStream(BuildContext c) => const ServiceStreamDemo();
Widget _serviceStack(BuildContext c) => const ServiceStackDemo();
Widget _presets(BuildContext c) => const PresetsDemo();
Widget _blur(BuildContext c) => const BlurDemo();
Widget _position(BuildContext c) => const PositionDemo();
Widget _customIndicator(BuildContext c) => const CustomIndicatorDemo();
Widget _customStates(BuildContext c) => const CustomStateWidgetsDemo();
Widget _textStyle(BuildContext c) => const TextStyleDemo();
Widget _grace(BuildContext c) => const GracePeriodDemo();
Widget _minShow(BuildContext c) => const MinShowDemo();
Widget _haptics(BuildContext c) => const HapticsDemo();
Widget _interactive(BuildContext c) => const InteractiveDemo();
Widget _accessibility(BuildContext c) => const AccessibilityDemo();
