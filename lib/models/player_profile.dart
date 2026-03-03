import 'spel_niveau.dart';

/// Model voor het profiel van een speler in Mila & Milo.
class PlayerProfile {
  final String naam;
  final DateTime geboortedatum;
  final String gekozenAvatar; // 'Mila', 'Milo', 'Lomi', 'Moli'
  final String leerjaar; // 'Niveau 1', 'Niveau 2', 'Niveau 3'

  static const List<String> leerjaren = [
    'Niveau 1',
    'Niveau 2',
  ];

  /// Display labels voor ouderinstellingen.
  static const Map<String, String> niveauLabels = {
    'Niveau 1': 'Beginner (MKM: maan, vis, zon + tellen tot 10)',
    'Niveau 2': 'Gevorderd (MKMM: boom, tent, kast + sommen tot 20)',
  };

  SpelNiveau get spelNiveau {
    if (leerjaar == 'Niveau 2') return SpelNiveau.niveau2;
    if (leerjaar == 'Niveau 3') return SpelNiveau.niveau3;
    return SpelNiveau.niveau1;
  }

  const PlayerProfile({
    required this.naam,
    required this.geboortedatum,
    required this.gekozenAvatar,
    this.leerjaar = 'Niveau 1',
  });

  PlayerProfile copyWith({
    String? naam,
    DateTime? geboortedatum,
    String? gekozenAvatar,
    String? leerjaar,
  }) {
    return PlayerProfile(
      naam: naam ?? this.naam,
      geboortedatum: geboortedatum ?? this.geboortedatum,
      gekozenAvatar: gekozenAvatar ?? this.gekozenAvatar,
      leerjaar: leerjaar ?? this.leerjaar,
    );
  }

  Map<String, dynamic> toJson() => {
        'naam': naam,
        'geboortedatum': geboortedatum.toIso8601String(),
        'gekozenAvatar': gekozenAvatar,
        'leerjaar': leerjaar,
      };

  static String _mapLeerjaar(String? v) {
    if (v == null) return 'Niveau 1';
    if (v == 'Niveau 3') return 'Niveau 2'; // Niveau 3 nog niet actief
    if (v.startsWith('Groep 1') || v == 'Niveau 1') return 'Niveau 1';
    return 'Niveau 2';
  }

  factory PlayerProfile.fromJson(Map<String, dynamic> json) {
    return PlayerProfile(
      naam: json['naam'] as String,
      geboortedatum: DateTime.parse(json['geboortedatum'] as String),
      gekozenAvatar: json['gekozenAvatar'] as String? ?? 'Mila',
      leerjaar: _mapLeerjaar(json['leerjaar'] as String?),
    );
  }
}
