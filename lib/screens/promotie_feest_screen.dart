import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../providers/player_provider.dart';
import '../providers/progress_provider.dart';
import '../theme/app_theme.dart';
import 'groeiende_tuin_screen.dart';

/// Full-screen feestmoment bij promotie naar Niveau 2.
/// 5 seconden confetti, gouden medaille, succes-tekst.
class PromotieFeestScreen extends ConsumerStatefulWidget {
  const PromotieFeestScreen({super.key});

  @override
  ConsumerState<PromotieFeestScreen> createState() => _PromotieFeestScreenState();
}

class _PromotieFeestScreenState extends ConsumerState<PromotieFeestScreen> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 5));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _confettiController.play();
      HapticFeedback.heavyImpact();
    });
    Future.delayed(const Duration(seconds: 5), () {
      if (!mounted) return;
      _promoteEnGaVerder();
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _promoteEnGaVerder() async {
    final profile = ref.read(playerProfileProvider);
    if (profile != null) {
      await ref.read(playerProfileProvider.notifier).setProfile(
            profile.copyWith(leerjaar: 'Niveau 2'),
          );
    }
    await ref.read(gameProgressProvider.notifier).resetVoorPromotie();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const GroeiendeTuinScreen()),
      (route) => route.isFirst,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: AppTheme.pastelAchtergrond,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD700).withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.amber.withValues(alpha: 0.5),
                          blurRadius: 24,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.emoji_events,
                      size: 120,
                      color: Color(0xFFFFD700),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Super! Je bent nu een echte expert.',
                    style: GoogleFonts.lexend(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.tekstDonker,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Op naar niveau 2!',
                    style: GoogleFonts.lexend(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.klinkerBlauw,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirection: 3.14159 / 2,
            maxBlastForce: 8,
            minBlastForce: 4,
            emissionFrequency: 0.03,
            numberOfParticles: 25,
            gravity: 0.15,
            colors: const [
              Color(0xFFFFD700),
              AppTheme.klinkerBlauw,
              AppTheme.medeklinkerRood,
              AppTheme.milaRoze,
              Colors.amber,
            ],
            shouldLoop: false,
          ),
        ),
      ],
    );
  }
}
