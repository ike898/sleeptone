import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import '../models/sound.dart';

// Active sound volumes: soundId -> volume (0.0 = off, >0 = playing)
final activeSoundsProvider =
    StateProvider<Map<String, double>>((ref) => {});

// Sleep timer remaining in minutes (null = no timer)
final sleepTimerProvider = StateProvider<int?>((ref) => null);

// Saved mixes
final savedMixesProvider =
    AsyncNotifierProvider<MixesNotifier, List<SoundMix>>(MixesNotifier.new);

class MixesNotifier extends AsyncNotifier<List<SoundMix>> {
  @override
  Future<List<SoundMix>> build() async => _load();

  Future<File> get _file async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/mixes.json');
  }

  Future<List<SoundMix>> _load() async {
    try {
      final file = await _file;
      if (await file.exists()) {
        final json = jsonDecode(await file.readAsString()) as List;
        return json
            .map((e) => SoundMix.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}
    return [];
  }

  Future<void> _save(List<SoundMix> mixes) async {
    final file = await _file;
    await file
        .writeAsString(jsonEncode(mixes.map((m) => m.toJson()).toList()));
  }

  Future<void> saveMix({
    required String name,
    required Map<String, double> volumes,
  }) async {
    final mix = SoundMix(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      volumes: volumes,
      createdAt: DateTime.now(),
    );
    final current = [...(state.valueOrNull ?? []), mix];
    state = AsyncData(current);
    await _save(current);
  }

  Future<void> deleteMix(String id) async {
    final current =
        (state.valueOrNull ?? []).where((m) => m.id != id).toList();
    state = AsyncData(current);
    await _save(current);
  }
}
