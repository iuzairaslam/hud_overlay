import 'package:flutter/material.dart';

import '../ui/tokens.dart';
import 'feature.dart';

/// The home screen: a browsable gallery of every feature, grouped by API.
/// Each tile opens a dedicated, screenshot-ready demo screen.
class GalleryPage extends StatelessWidget {
  const GalleryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: T.bg,
      body: CustomScrollView(
        slivers: [
          const SliverAppBar.large(
            backgroundColor: T.bg,
            surfaceTintColor: Colors.transparent,
            title: Text(
              'hud_overlay',
              style: TextStyle(fontWeight: FontWeight.w800, color: T.ink),
            ),
          ),
          const SliverToBoxAdapter(child: _Intro()),
          for (final section in kSections) _SectionSliver(section: section),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }
}

class _Intro extends StatelessWidget {
  const _Intro();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: Text(
        'A context-optional, accessibility-first loading overlay. '
        'Tap any feature for a focused, live demo.',
        style: T.body,
      ),
    );
  }
}

class _SectionSliver extends StatelessWidget {
  const _SectionSliver({required this.section});
  final FeatureSection section;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          _SectionHeader(title: section.title, caption: section.caption),
          const SizedBox(height: 12),
          for (final f in section.features) ...[
            _FeatureTile(feature: f),
            const SizedBox(height: 10),
          ],
        ]),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.caption});
  final String title;
  final String caption;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: T.blue,
            fontFamily: 'monospace',
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 2),
        Text(caption, style: const TextStyle(fontSize: 13, color: T.sub)),
      ],
    );
  }
}

class _FeatureTile extends StatelessWidget {
  const _FeatureTile({required this.feature});
  final Feature feature;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: T.card,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute<void>(builder: feature.builder)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: feature.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    feature.emoji,
                    style: const TextStyle(fontSize: 22),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      feature.title,
                      style: const TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w600,
                        color: T.ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      feature.code,
                      style: const TextStyle(
                        fontSize: 12,
                        fontFamily: 'monospace',
                        color: T.sub,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: T.faint),
            ],
          ),
        ),
      ),
    );
  }
}
