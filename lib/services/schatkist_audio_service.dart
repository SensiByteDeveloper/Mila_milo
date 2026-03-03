/// Audio bij schatkist: mama Mali spreekt bij voortgang (stap 1 t/m 20).
/// Bestanden: assets/audio/schatkist/stap_01.mp3 t/m stap_20.mp3 (zie AUDIO_OVERZICHT.md)
class SchatkistAudioService {
  /// Speelt het bericht voor de gegeven stap (1–20).
  /// Wordt aangeroepen wanneer speler naar schatkist gaat na setje van 7.
  Future<void> speelStapBericht(int stap) async {
    if (stap < 1 || stap > 20) return;
    // TODO: Implementeer wanneer audio is opgenomen.
    // Bestand: assets/audio/schatkist/stap_XX.mp3 (XX = 01 t/m 20)
  }
}
