import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/mantra_metadata.dart';
import '../../data/models/verse_mantra.dart';
import 'verse_provider.dart';

/// Screen to browse and select a verse mantra for tracking.
class VersePickerScreen extends ConsumerWidget {
  const VersePickerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final verses = ref.watch(verseListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verse Mantras'),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: verses.length,
        itemBuilder: (context, index) {
          final verse = verses[index];
          return _VerseCard(verse: verse);
        },
      ),
    );
  }
}

class _VerseCard extends StatelessWidget {
  final VerseMantra verse;
  const _VerseCard({required this.verse});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final meta = mantraMetadataRegistry[verse.id];

    // Get first line's devanagari as preview
    final preview = verse.lines.isNotEmpty ? verse.lines.first.devanagari : '';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/verse/${verse.id}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Deity icon + language badge
                  Text(meta?.icon ?? '📖',
                      style: const TextStyle(fontSize: 22)),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _deityLabel(meta?.deity),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.arrow_forward_ios,
                      size: 16,
                      color: theme.colorScheme.onSurface.withAlpha(100)),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                meta?.name ?? verse.name,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              if (meta != null)
                Text(
                  meta.meaning,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withAlpha(153),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                )
              else
                Text(
                  verse.description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withAlpha(153),
                  ),
                ),
              const SizedBox(height: 8),
              // Preview text
              Text(
                preview,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: theme.colorScheme.onSurface.withAlpha(178),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              // Stats row
              Row(
                children: [
                  _Stat(
                      icon: Icons.short_text,
                      label: '${verse.totalLines} lines'),
                  const SizedBox(width: 16),
                  _Stat(
                      icon: Icons.text_fields,
                      label: '${verse.totalWords} words'),
                  if (meta != null) ...[
                    const SizedBox(width: 16),
                    _Stat(
                      icon: Icons.timer_outlined,
                      label: _durationLabel(meta.durationSeconds),
                    ),
                  ],
                ],
              ),
              if (meta != null) ...[
                const SizedBox(height: 8),
                Text(
                  meta.benefit,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: theme.colorScheme.primary.withAlpha(178),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _deityLabel(MantraDeity? deity) {
    switch (deity) {
      case MantraDeity.shiva:
        return 'SHIVA';
      case MantraDeity.vishnu:
        return 'VISHNU';
      case MantraDeity.krishna:
        return 'KRISHNA';
      case MantraDeity.hanuman:
        return 'HANUMAN';
      case MantraDeity.devi:
        return 'DEVI';
      case MantraDeity.surya:
        return 'SURYA';
      case MantraDeity.universal:
        return 'VEDIC';
      default:
        return 'SA';
    }
  }

  String _durationLabel(double secs) {
    if (secs < 60) return '${secs.round()}s';
    if (secs < 3600) return '${(secs / 60).round()}min';
    return '${(secs / 3600).round()}hr';
  }
}

class _Stat extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Stat({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: theme.colorScheme.onSurface.withAlpha(128)),
        const SizedBox(width: 4),
        Text(label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurface.withAlpha(128),
            )),
      ],
    );
  }
}
