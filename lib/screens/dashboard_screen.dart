import 'dart:math' as math;

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/player_provider.dart';
import '../providers/progress_provider.dart';
import '../providers/session_provider.dart';
import '../services/holiday_service.dart';
import '../theme/app_theme.dart';
import '../widgets/avatar_display.dart';
import '../widgets/parent_gate_dialog.dart';
import 'character_choice_screen.dart';
import 'groeiende_tuin_screen.dart';
import 'letter_tuin_screen.dart';
import 'math_game_screen.dart';
import 'ouder_instellingen_screen.dart';
import 'word_game_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  late ConfettiController _confettiController;
  bool _confettiGespeeld = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 4),
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _toonParentGate(BuildContext context) {
    showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => ParentGateDialog(
        onCorrect: () {},
        onCancel: () {},
      ),
    ).then((result) {
      if (result == true && context.mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const OuderInstellingenScreen(),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(playerProfileProvider);
    final progress = ref.watch(gameProgressProvider);
    final totaalOpdrachten = progress.voltooideWoorden + progress.rekenGoedeBeurten;
    final showShimmer = ref.watch(sessionCompletedProvider) ||
        (totaalOpdrachten > 0 && totaalOpdrachten % 7 == 0);

    if (profile == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final toonConfetti = HolidayService.toonConfetti(profile.geboortedatum);
    if (toonConfetti && !_confettiGespeeld) {
      _confettiGespeeld = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _confettiController.play();
      });
    }

    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            profile.gekozenAvatar.endsWith('_kat')
                ? 'assets/images/MilasFamilie_Kat.png'
                : 'assets/images/MilasFamilie_Hamster.png',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                Container(color: AppTheme.pastelAchtergrond),
          ),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withValues(alpha: 0.5),
                  Colors.white.withValues(alpha: 0.75),
                  AppTheme.pastelAchtergrond.withValues(alpha: 0.92),
                ],
              ),
            ),
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: () => _toonParentGate(context),
                            icon: const Icon(Icons.settings),
                            color: AppTheme.tekstDonker,
                            iconSize: 28,
                          ),
                          _SchatkistKnop(
                            onTap: () {
                              ref.read(sessionCompletedProvider.notifier).state = false;
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const GroeiendeTuinScreen(),
                                ),
                              );
                            },
                            shimmerActief: showShimmer,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const CharacterChoiceScreen(),
                                  ),
                                );
                              },
                              child: AvatarDisplay(
                                avatarNaam: profile.gekozenAvatar,
                                grootte: 100,
                                volledig: true,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.9),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.08),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                toonConfetti
                                    ? 'Gefeliciteerd met je verjaardag, ${profile.naam}! 🎂'
                                    : 'Hoi ${profile.naam}! Zullen we spelen?',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(color: AppTheme.tekstDonker),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      _GroteKaart(
                        titel: 'Spelen met Woorden',
                        subtitel: 'Letters slepen en woorden spellen',
                        kleur: AppTheme.klinkerBlauw,
                        icon: Icons.abc,
                        onTap: () {
                          if (context.mounted) {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const WordGameScreen(),
                              ),
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      _GroteKaart(
                        titel: 'Spelen met Cijfers',
                        subtitel: 'Tellen en sommen maken',
                        kleur: AppTheme.tellenGroen,
                        icon: Icons.calculate,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const MathGameScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      _GroteKaart(
                        titel: "Oma Lomi's Lettertuin",
                        subtitel: 'Letters ontdekken',
                        kleur: AppTheme.letterTuinGeel,
                        icon: Icons.eco,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const LetterTuinScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        if (toonConfetti)
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: math.pi / 2,
              maxBlastForce: 5,
              minBlastForce: 2,
              emissionFrequency: 0.05,
              numberOfParticles: 20,
              gravity: 0.2,
              colors: const [
                AppTheme.klinkerBlauw,
                AppTheme.medeklinkerRood,
                AppTheme.milaRoze,
                AppTheme.miloBlauw,
                Colors.amber,
                Colors.green,
              ],
              shouldLoop: false,
            ),
          ),
      ],
    );
  }
}

class _GroteKaart extends StatelessWidget {
  const _GroteKaart({
    required this.titel,
    required this.subtitel,
    required this.kleur,
    required this.icon,
    required this.onTap,
  });

  final String titel;
  final String subtitel;
  final Color kleur;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.pastelKaart,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: kleur.withValues(alpha: 0.4), width: 2),
          ),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: kleur.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, size: 36, color: kleur),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titel,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: kleur,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      subtitel,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: kleur, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _SchatkistKnop extends StatefulWidget {
  const _SchatkistKnop({
    required this.onTap,
    required this.shimmerActief,
  });

  final VoidCallback onTap;
  final bool shimmerActief;

  @override
  State<_SchatkistKnop> createState() => _SchatkistKnopState();
}

class _SchatkistKnopState extends State<_SchatkistKnop>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _shimmerAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(covariant _SchatkistKnop oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.shimmerActief && !_shimmerController.isAnimating) {
      _shimmerController.repeat();
    } else if (!widget.shimmerActief) {
      _shimmerController.stop();
      _shimmerController.reset();
    }
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _shimmerAnimation,
        builder: (context, _) {
          final intensity = widget.shimmerActief ? _shimmerAnimation.value : 0.0;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Color.lerp(
                  const Color(0xFFB8860B),
                  const Color(0xFFDAA520),
                  intensity * 0.5 + 0.5,
                )!,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFDAA520)
                      .withValues(alpha: 0.3 + intensity * 0.3),
                  blurRadius: 8 + intensity * 8,
                  spreadRadius: intensity * 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.eco,
                  color: const Color(0xFFB8860B),
                  size: 28,
                ),
                const SizedBox(height: 4),
                Text(
                  'Mijn Schatkist',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.tekstDonker,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
