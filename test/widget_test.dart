import 'package:flutter_test/flutter_test.dart';
import 'package:sleeptone/models/sound.dart';

void main() {
  test('SoundMix JSON round-trip', () {
    final mix = SoundMix(
      id: '1',
      name: 'Test Mix',
      volumes: {'rain': 0.5, 'ocean': 0.8},
      createdAt: DateTime(2024, 1, 1),
    );
    final json = mix.toJson();
    final restored = SoundMix.fromJson(json);
    expect(restored.id, '1');
    expect(restored.name, 'Test Mix');
    expect(restored.volumes['rain'], 0.5);
    expect(restored.volumes['ocean'], 0.8);
  });

  test('Built-in sounds has 10 entries', () {
    expect(SleepSound.builtInSounds.length, 10);
  });
}
