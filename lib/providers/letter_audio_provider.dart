import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/letter_audio_service.dart';

final letterAudioProvider = Provider<LetterAudioService>((ref) {
  return LetterAudioService();
});
