/// Berekent de leeftijd en schoolgroep van een kind.
/// Peildatum voor schooljaar: 1 oktober.
class AgeCalculator {
  /// Peildatum: kinderen die op 1 oktober 4 jaar zijn, zitten in Groep 1.
  /// Groep 2 = 5 jaar, Groep 3 = 6 jaar, etc.
  static const int _peilMaand = 10; // oktober
  static const int _peilDag = 1;

  /// Berekent de huidige leeftijd in jaren.
  static int berekenLeeftijd(DateTime geboortedatum,
      {DateTime? referentieDatum}) {
    final nu = referentieDatum ?? DateTime.now();
    int leeftijd = nu.year - geboortedatum.year;
    if (nu.month < geboortedatum.month ||
        (nu.month == geboortedatum.month && nu.day < geboortedatum.day)) {
      leeftijd--;
    }
    return leeftijd;
  }

  /// Bepaalt in welke schoolgroep het kind zit (peildatum 1 oktober).
  /// Groep 1 = 4 jaar, Groep 2 = 5 jaar, ... Groep 8 = 11 jaar.
  static int bepaalGroep(DateTime geboortedatum, {DateTime? referentieDatum}) {
    final nu = referentieDatum ?? DateTime.now();
    final peildatum = DateTime(nu.year, _peilMaand, _peilDag);

    // Als we vóór 1 oktober zijn, gebruik vorig schooljaar als referentie
    final effectievePeildatum = nu.isBefore(peildatum)
        ? DateTime(nu.year - 1, _peilMaand, _peilDag)
        : peildatum;

    int leeftijdOpPeildatum = effectievePeildatum.year - geboortedatum.year;
    if (effectievePeildatum.month < geboortedatum.month ||
        (effectievePeildatum.month == geboortedatum.month &&
            effectievePeildatum.day < geboortedatum.day)) {
      leeftijdOpPeildatum--;
    }

    // Groep 1 = 4 jaar, Groep 2 = 5 jaar, etc.
    final groep = leeftijdOpPeildatum - 3;
    return groep.clamp(1, 8);
  }

  /// Retourneert een leesbare string voor de groep, bijv. "Groep 2".
  static String groepLabel(DateTime geboortedatum,
      {DateTime? referentieDatum}) {
    final groep = bepaalGroep(geboortedatum, referentieDatum: referentieDatum);
    return 'Groep $groep';
  }
}
