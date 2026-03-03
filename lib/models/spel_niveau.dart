/// Spelniveau voor woorden en rekenen.
/// Niveau 3 is voorbereid voor toekomstige uitbreiding.
enum SpelNiveau {
  niveau1,
  niveau2,
  niveau3,
}

extension SpelNiveauExt on SpelNiveau {
  String get displayNaam {
    switch (this) {
      case SpelNiveau.niveau1:
        return 'Niveau 1';
      case SpelNiveau.niveau2:
        return 'Niveau 2';
      case SpelNiveau.niveau3:
        return 'Niveau 3';
    }
  }

  /// Max woordlengte: Niveau 1 = 3, Niveau 2+ = 4+.
  int get maxWoordLetters {
    switch (this) {
      case SpelNiveau.niveau1:
        return 3;
      case SpelNiveau.niveau2:
      case SpelNiveau.niveau3:
        return 99;
    }
  }

  /// Max addend voor rekenen (som blijft <= 9): Niveau 1 = 5, Niveau 2 = 9.
  int get maxRekenGetal {
    switch (this) {
      case SpelNiveau.niveau1:
        return 5;
      case SpelNiveau.niveau2:
      case SpelNiveau.niveau3:
        return 9;
    }
  }

  /// Volgende niveau (Niveau 2 is voor nu eindstation).
  SpelNiveau? get next {
    switch (this) {
      case SpelNiveau.niveau1:
        return SpelNiveau.niveau2;
      case SpelNiveau.niveau2:
      case SpelNiveau.niveau3:
        return null;
    }
  }
}
