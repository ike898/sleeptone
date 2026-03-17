import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/sound_provider.dart';
import '../services/audio_manager.dart';
import '../widgets/banner_ad_widget.dart';

class MixesScreen extends ConsumerWidget {
  const MixesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mixesAsync = ref.watch(savedMixesProvider);
    final theme = Theme.of(context);

    return Column(
      children: [
        Expanded(
          child: mixesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (mixes) {
              if (mixes.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.library_music,
                          size: 64,
                          color: theme.colorScheme.primary
                              .withValues(alpha: 0.5)),
                      const SizedBox(height: 16),
                      Text('No saved mixes yet',
                          style: theme.textTheme.bodyLarge),
                      const SizedBox(height: 8),
                      Text('Play sounds and tap "Save This Mix"',
                          style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant)),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: mixes.length,
                itemBuilder: (ctx, i) {
                  final mix = mixes[i];
                  return Dismissible(
                    key: Key(mix.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 16),
                      color: Colors.red,
                      child:
                          const Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (_) {
                      ref
                          .read(savedMixesProvider.notifier)
                          .deleteMix(mix.id);
                    },
                    child: Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              theme.colorScheme.primaryContainer,
                          child: Icon(Icons.music_note,
                              color:
                                  theme.colorScheme.onPrimaryContainer),
                        ),
                        title: Text(mix.name),
                        subtitle: Text(
                            '${mix.volumes.length} sounds'),
                        trailing: IconButton(
                          icon: const Icon(Icons.play_arrow),
                          onPressed: () => _loadMix(ref, mix.volumes),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        const BannerAdWidget(),
      ],
    );
  }

  void _loadMix(WidgetRef ref, Map<String, double> volumes) {
    // Stop current sounds
    AudioManager().stopAll();

    // Apply mix volumes
    for (final entry in volumes.entries) {
      AudioManager().setVolume(entry.key, entry.value);
    }
    ref.read(activeSoundsProvider.notifier).state =
        Map<String, double>.from(volumes);
  }
}
