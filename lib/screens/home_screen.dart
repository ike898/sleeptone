import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/sound.dart';
import '../providers/sound_provider.dart';
import '../services/audio_manager.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  Timer? _sleepTimer;

  @override
  void dispose() {
    _sleepTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeSounds = ref.watch(activeSoundsProvider);
    final sleepTimer = ref.watch(sleepTimerProvider);
    final theme = Theme.of(context);
    final isPlaying = activeSounds.values.any((v) => v > 0);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Now playing / timer card
        if (isPlaying)
          Card(
            color: theme.colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.music_note,
                          color: theme.colorScheme.onPrimaryContainer),
                      const SizedBox(width: 8),
                      Text('Now Playing',
                          style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.onPrimaryContainer)),
                      const Spacer(),
                      if (sleepTimer != null)
                        Chip(
                          avatar: const Icon(Icons.timer, size: 16),
                          label: Text('${sleepTimer}m'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _TimerButton(
                          label: '15m',
                          onTap: () => _startTimer(15)),
                      _TimerButton(
                          label: '30m',
                          onTap: () => _startTimer(30)),
                      _TimerButton(
                          label: '60m',
                          onTap: () => _startTimer(60)),
                      _TimerButton(
                          label: 'Stop',
                          onTap: _stopAll,
                          isStop: true),
                    ],
                  ),
                ],
              ),
            ),
          ),
        if (isPlaying) const SizedBox(height: 16),

        // Sound grid
        Text('Sounds', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 1.3,
          ),
          itemCount: SleepSound.builtInSounds.length,
          itemBuilder: (ctx, i) {
            final sound = SleepSound.builtInSounds[i];
            final volume = activeSounds[sound.id] ?? 0.0;
            final isActive = volume > 0;

            return Card(
              color: isActive
                  ? theme.colorScheme.primaryContainer
                  : theme.colorScheme.surfaceContainerHighest,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  if (isActive) {
                    _setVolume(sound.id, 0);
                  } else {
                    _setVolume(sound.id, 0.5);
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(sound.icon, style: const TextStyle(fontSize: 28)),
                      const SizedBox(height: 4),
                      Text(sound.name,
                          style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight:
                                  isActive ? FontWeight.bold : null)),
                      if (isActive) ...[
                        const SizedBox(height: 4),
                        SizedBox(
                          height: 20,
                          child: Slider(
                            value: volume,
                            min: 0,
                            max: 1,
                            onChanged: (v) => _setVolume(sound.id, v),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 16),
        // Save mix button
        if (isPlaying)
          OutlinedButton.icon(
            onPressed: () => _showSaveMixDialog(context),
            icon: const Icon(Icons.save),
            label: const Text('Save This Mix'),
          ),
      ],
    );
  }

  void _setVolume(String soundId, double volume) {
    final current = Map<String, double>.from(
        ref.read(activeSoundsProvider));
    if (volume <= 0) {
      current.remove(soundId);
      AudioManager().stop(soundId);
    } else {
      current[soundId] = volume;
      AudioManager().setVolume(soundId, volume);
    }
    ref.read(activeSoundsProvider.notifier).state = current;
  }

  void _startTimer(int minutes) {
    _sleepTimer?.cancel();
    ref.read(sleepTimerProvider.notifier).state = minutes;

    _sleepTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      final remaining = ref.read(sleepTimerProvider);
      if (remaining == null || remaining <= 1) {
        timer.cancel();
        ref.read(sleepTimerProvider.notifier).state = null;
        AudioManager().fadeOutAll();
        ref.read(activeSoundsProvider.notifier).state = {};
      } else {
        ref.read(sleepTimerProvider.notifier).state = remaining - 1;
      }
    });
  }

  void _stopAll() {
    _sleepTimer?.cancel();
    ref.read(sleepTimerProvider.notifier).state = null;
    AudioManager().stopAll();
    ref.read(activeSoundsProvider.notifier).state = {};
  }

  void _showSaveMixDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Save Mix'),
        content: TextField(
          controller: nameCtrl,
          decoration: const InputDecoration(
            labelText: 'Mix Name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (nameCtrl.text.isNotEmpty) {
                ref.read(savedMixesProvider.notifier).saveMix(
                      name: nameCtrl.text,
                      volumes: Map<String, double>.from(
                          ref.read(activeSoundsProvider)),
                    );
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Mix "${nameCtrl.text}" saved')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class _TimerButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isStop;

  const _TimerButton(
      {required this.label, required this.onTap, this.isStop = false});

  @override
  Widget build(BuildContext context) {
    return isStop
        ? FilledButton(
            onPressed: onTap,
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: Text(label),
          )
        : OutlinedButton(onPressed: onTap, child: Text(label));
  }
}
