import 'package:just_audio/just_audio.dart';
import '../models/sound.dart';

class AudioManager {
  static final AudioManager _instance = AudioManager._();
  factory AudioManager() => _instance;
  AudioManager._();

  final Map<String, AudioPlayer> _players = {};

  Future<void> setVolume(String soundId, double volume) async {
    if (volume <= 0) {
      await stop(soundId);
      return;
    }

    var player = _players[soundId];
    if (player == null) {
      player = AudioPlayer();
      _players[soundId] = player;

      final sound = SleepSound.builtInSounds.firstWhere(
        (s) => s.id == soundId,
        orElse: () => SleepSound.builtInSounds.first,
      );

      try {
        await player.setAsset(sound.assetPath);
        await player.setLoopMode(LoopMode.one);
      } catch (_) {
        // Asset not found — will be silent until real audio files are added
      }
    }

    await player.setVolume(volume);
    if (!player.playing) {
      player.play();
    }
  }

  Future<void> stop(String soundId) async {
    final player = _players.remove(soundId);
    if (player != null) {
      await player.stop();
      await player.dispose();
    }
  }

  Future<void> stopAll() async {
    for (final entry in _players.entries.toList()) {
      await entry.value.stop();
      await entry.value.dispose();
    }
    _players.clear();
  }

  Future<void> fadeOutAll({Duration duration = const Duration(seconds: 10)}) async {
    if (_players.isEmpty) return;

    const steps = 20;
    final stepDuration = Duration(
        milliseconds: duration.inMilliseconds ~/ steps);

    final initialVolumes = <String, double>{};
    for (final entry in _players.entries) {
      initialVolumes[entry.key] = entry.value.volume;
    }

    for (int i = steps; i >= 0; i--) {
      final fraction = i / steps;
      for (final entry in _players.entries) {
        final initial = initialVolumes[entry.key] ?? 0;
        await entry.value.setVolume(initial * fraction);
      }
      await Future.delayed(stepDuration);
    }

    await stopAll();
  }

  bool get isPlaying => _players.isNotEmpty;
}
