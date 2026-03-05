import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/mantra_metadata.dart';

/// Detail screen showing mantra meaning, benefits, deity info.
/// Navigated to from dashboard mantra cards.
class MantraDetailScreen extends StatelessWidget {
  final String mantraKey;
  const MantraDetailScreen({super.key, required this.mantraKey});

  @override
  Widget build(BuildContext context) {
    final meta = mantraMetadataRegistry[mantraKey];
    if (meta == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Mantra not found')),
      );
    }

    final theme = Theme.of(context);
    final isShort = meta.isShort;

    return Scaffold(
      appBar: AppBar(
        title: Text(meta.name),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Hero icon + name
          Center(
            child: Text(meta.icon, style: const TextStyle(fontSize: 64)),
          ),
          const SizedBox(height: 12),
          Center(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: _deityColor(meta.deity).withAlpha(30),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                _deityName(meta.deity),
                style: theme.textTheme.labelMedium?.copyWith(
                  color: _deityColor(meta.deity),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Mantra text — English + Telugu
          Card(
            color: theme.colorScheme.surfaceContainerLow,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // English romanized (primary)
                  Text(
                    meta.romanized,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w500,
                      height: 1.6,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (meta.telugu.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    // Telugu script
                    Text(
                      meta.telugu,
                      style: theme.textTheme.titleMedium?.copyWith(
                        height: 1.6,
                        color: theme.colorScheme.onSurface.withAlpha(180),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Meaning
          _SectionHeader(icon: Icons.translate, title: 'Meaning'),
          const SizedBox(height: 8),
          Text(meta.meaning, style: theme.textTheme.bodyLarge),
          const SizedBox(height: 20),

          // Benefits
          _SectionHeader(icon: Icons.spa_outlined, title: 'Benefits'),
          const SizedBox(height: 8),
          Text(meta.benefit, style: theme.textTheme.bodyLarge),
          const SizedBox(height: 20),

          // Details
          _SectionHeader(icon: Icons.info_outline, title: 'Details'),
          const SizedBox(height: 8),
          _DetailRow(
            label: 'Category',
            value: isShort ? 'Short (repetitive counting)' : 'Verse (word tracking)',
          ),
          _DetailRow(
            label: 'Duration',
            value: _durationLabel(meta.durationSeconds),
          ),
          _DetailRow(
            label: 'Traditional Count',
            value: meta.traditionalCount == 1
                ? 'Once per session'
                : '${meta.traditionalCount} times',
          ),
          if (isShort)
            _DetailRow(
              label: 'Word Count',
              value: '${meta.wordOrLineCount} words',
            )
          else
            _DetailRow(
              label: 'Lines',
              value: '${meta.wordOrLineCount} lines',
            ),
          const SizedBox(height: 32),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton.icon(
            onPressed: () {
              if (isShort) {
                context.push('/session/$mantraKey');
              } else {
                context.push('/verse/$mantraKey');
              }
            },
            icon: const Icon(Icons.play_arrow_rounded),
            label: Text(isShort ? 'Start Counting' : 'Start Recitation'),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _deityName(MantraDeity deity) {
    switch (deity) {
      case MantraDeity.universal:
        return 'Universal / Vedic';
      case MantraDeity.shiva:
        return 'Lord Shiva';
      case MantraDeity.vishnu:
        return 'Lord Vishnu';
      case MantraDeity.krishna:
        return 'Lord Krishna';
      case MantraDeity.hanuman:
        return 'Lord Hanuman';
      case MantraDeity.ganesha:
        return 'Lord Ganesha';
      case MantraDeity.devi:
        return 'Devi / Shakti';
      case MantraDeity.surya:
        return 'Surya / Sun God';
    }
  }

  Color _deityColor(MantraDeity deity) {
    switch (deity) {
      case MantraDeity.universal:
        return Colors.deepPurple;
      case MantraDeity.shiva:
        return Colors.blue;
      case MantraDeity.vishnu:
        return Colors.indigo;
      case MantraDeity.krishna:
        return Colors.teal;
      case MantraDeity.hanuman:
        return Colors.orange;
      case MantraDeity.ganesha:
        return Colors.red;
      case MantraDeity.devi:
        return Colors.pink;
      case MantraDeity.surya:
        return Colors.amber.shade800;
    }
  }

  String _durationLabel(double secs) {
    if (secs < 60) return '~${secs.round()} seconds per chant';
    if (secs < 3600) return '~${(secs / 60).round()} minutes per recitation';
    return '~${(secs / 60).round()} minutes per recitation';
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  const _SectionHeader({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
            )),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withAlpha(153),
                )),
          ),
          Expanded(
            child: Text(value, style: theme.textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
