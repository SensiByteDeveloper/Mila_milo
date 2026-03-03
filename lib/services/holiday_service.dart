/// Controleert of vandaag een Christelijke feestdag of de verjaardag van de speler is.
class HolidayService {
  /// Checkt of de gegeven datum een Christelijke feestdag is.
  /// Ondersteunt: Kerst, Pasen, Hemelvaart, Pinksteren.
  static bool isChristelijkeFeestdag(DateTime datum) {
    return isKerst(datum) ||
        isPasen(datum) ||
        isHemelvaart(datum) ||
        isPinksteren(datum);
  }

  static bool isKerst(DateTime datum) {
    return datum.month == 12 && (datum.day == 25 || datum.day == 26);
  }

  static bool isPasen(DateTime datum) {
    final paasDatum = _berekenPasen(datum.year);
    return datum.year == paasDatum.year &&
        datum.month == paasDatum.month &&
        datum.day == paasDatum.day;
  }

  static bool isHemelvaart(DateTime datum) {
    final paasDatum = _berekenPasen(datum.year);
    final hemelvaart = paasDatum.add(const Duration(days: 39));
    return datum.year == hemelvaart.year &&
        datum.month == hemelvaart.month &&
        datum.day == hemelvaart.day;
  }

  static bool isPinksteren(DateTime datum) {
    final paasDatum = _berekenPasen(datum.year);
    final pinksteren = paasDatum.add(const Duration(days: 49));
    return datum.year == pinksteren.year &&
        datum.month == pinksteren.month &&
        datum.day == pinksteren.day;
  }

  /// Berekent Paaszondag volgens de Gregoriaanse kalender (Anonymous Gregorian algorithm).
  static DateTime _berekenPasen(int jaar) {
    final a = jaar % 19;
    final b = jaar ~/ 100;
    final c = jaar % 100;
    final d = b ~/ 4;
    final e = b % 4;
    final f = (b + 8) ~/ 25;
    final g = (b - f + 1) ~/ 3;
    final h = (19 * a + b - d - g + 15) % 30;
    final i = c ~/ 4;
    final k = c % 4;
    final l = (32 + 2 * e + 2 * i - h - k) % 7;
    final m = (a + 11 * h + 22 * l) ~/ 451;
    final maand = (h + l - 7 * m + 114) ~/ 31;
    final dag = ((h + l - 7 * m + 114) % 31) + 1;
    return DateTime(jaar, maand, dag);
  }

  /// Checkt of vandaag de verjaardag van de speler is.
  static bool isVerjaardag(DateTime geboortedatum, {DateTime? referentieDatum}) {
    final nu = referentieDatum ?? DateTime.now();
    return nu.month == geboortedatum.month && nu.day == geboortedatum.day;
  }

  /// Retourneert true als er confetti getoond moet worden (verjaardag).
  static bool toonConfetti(DateTime? geboortedatum, {DateTime? referentieDatum}) {
    if (geboortedatum == null) return false;
    return isVerjaardag(geboortedatum, referentieDatum: referentieDatum);
  }
}
