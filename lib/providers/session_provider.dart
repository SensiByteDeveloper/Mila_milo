import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Of de Schatkist shimmer actief moet zijn (na voltooide sessie van 7 opdrachten).
final sessionCompletedProvider = StateProvider<bool>((ref) => false);
