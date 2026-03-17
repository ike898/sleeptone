class SleepSound {
  final String id;
  final String name;
  final String icon;
  final String assetPath;
  final bool isBuiltIn;

  const SleepSound({
    required this.id,
    required this.name,
    required this.icon,
    required this.assetPath,
    this.isBuiltIn = true,
  });

  static const builtInSounds = [
    SleepSound(
      id: 'rain',
      name: 'Rain',
      icon: '\u{1F327}',
      assetPath: 'assets/sounds/rain.mp3',
    ),
    SleepSound(
      id: 'ocean',
      name: 'Ocean Waves',
      icon: '\u{1F30A}',
      assetPath: 'assets/sounds/ocean.mp3',
    ),
    SleepSound(
      id: 'forest',
      name: 'Forest',
      icon: '\u{1F332}',
      assetPath: 'assets/sounds/forest.mp3',
    ),
    SleepSound(
      id: 'fire',
      name: 'Campfire',
      icon: '\u{1F525}',
      assetPath: 'assets/sounds/fire.mp3',
    ),
    SleepSound(
      id: 'wind',
      name: 'Wind',
      icon: '\u{1F4A8}',
      assetPath: 'assets/sounds/wind.mp3',
    ),
    SleepSound(
      id: 'thunder',
      name: 'Thunder',
      icon: '\u{26C8}',
      assetPath: 'assets/sounds/thunder.mp3',
    ),
    SleepSound(
      id: 'birds',
      name: 'Birds',
      icon: '\u{1F426}',
      assetPath: 'assets/sounds/birds.mp3',
    ),
    SleepSound(
      id: 'creek',
      name: 'Creek',
      icon: '\u{1F4A7}',
      assetPath: 'assets/sounds/creek.mp3',
    ),
    SleepSound(
      id: 'whitenoise',
      name: 'White Noise',
      icon: '\u{1F4FB}',
      assetPath: 'assets/sounds/whitenoise.mp3',
    ),
    SleepSound(
      id: 'night',
      name: 'Night',
      icon: '\u{1F31C}',
      assetPath: 'assets/sounds/night.mp3',
    ),
  ];
}

class SoundMix {
  final String id;
  final String name;
  final Map<String, double> volumes; // soundId -> volume (0.0-1.0)
  final DateTime createdAt;

  SoundMix({
    required this.id,
    required this.name,
    required this.volumes,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'volumes': volumes,
        'createdAt': createdAt.toIso8601String(),
      };

  factory SoundMix.fromJson(Map<String, dynamic> json) => SoundMix(
        id: json['id'] as String,
        name: json['name'] as String,
        volumes: (json['volumes'] as Map<String, dynamic>)
            .map((k, v) => MapEntry(k, (v as num).toDouble())),
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
