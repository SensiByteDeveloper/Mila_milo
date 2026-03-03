/// Voortgang van het kind: taal (zonnebloem) en rekenen (appelboom).
/// Beide groeien in 20 stappen.
class GameProgress {
  /// Aantal voltooide taalopdrachten (max 20).
  final int voltooideWoorden;

  /// Aantal goede rekenbeurten (max 20).
  final int rekenGoedeBeurten;

  /// Speciale bonussen (munten/schelpen).
  final int specialeBonussen;

  const GameProgress({
    this.voltooideWoorden = 0,
    this.rekenGoedeBeurten = 0,
    this.specialeBonussen = 0,
  });

  GameProgress copyWith({
    int? voltooideWoorden,
    int? rekenGoedeBeurten,
    int? specialeBonussen,
  }) {
    return GameProgress(
      voltooideWoorden: voltooideWoorden ?? this.voltooideWoorden,
      rekenGoedeBeurten: rekenGoedeBeurten ?? this.rekenGoedeBeurten,
      specialeBonussen: specialeBonussen ?? this.specialeBonussen,
    );
  }

  Map<String, dynamic> toJson() => {
        'voltooideWoorden': voltooideWoorden,
        'rekenGoedeBeurten': rekenGoedeBeurten,
        'specialeBonussen': specialeBonussen,
      };

  factory GameProgress.fromJson(Map<String, dynamic> json) {
    return GameProgress(
      voltooideWoorden: json['voltooideWoorden'] as int? ?? 0,
      rekenGoedeBeurten: json['rekenGoedeBeurten'] as int? ?? 0,
      specialeBonussen: json['specialeBonussen'] as int? ?? 0,
    );
  }
}
