import 'package:flutter_tts/flutter_tts.dart';

/// Fonetische klanken voor letters (Montessori: alleen klank, geen alfabetnaam).
final Map<String, String> _fonetischeKlanken = {
  'a': 'aa', 'b': 'buh', 'c': 'kuh', 'd': 'duh', 'e': 'ee',
  'f': 'fuh', 'g': 'guh', 'h': 'huh', 'i': 'ie', 'j': 'juh',
  'k': 'kuh', 'l': 'luh', 'm': 'muh', 'n': 'nuh', 'o': 'oo',
  'p': 'puh', 'q': 'kwuh', 'r': 'ruh', 's': 'sss', 't': 'tuh',
  'u': 'uu', 'v': 'vuh', 'w': 'wuh', 'x': 'ks', 'y': 'ie',
  'z': 'zzz',
};

/// Spreekt "Zeg mij maar na... [fonetische klank]" uit.
class LetterAudioService {
  LetterAudioService() {
    _tts.setLanguage('nl-NL');
  }

  final FlutterTts _tts = FlutterTts();

  Future<void> speelLetterKlank(String letter) async {
    final klank = _fonetischeKlanken[letter.toLowerCase()] ?? letter;
    await _tts.speak('Zeg mij maar na... $klank');
  }
}
