import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/spel_niveau.dart';
import '../providers/player_provider.dart';
import '../providers/progress_provider.dart';
import '../providers/session_provider.dart';
import '../theme/app_theme.dart';
import 'groeiende_tuin_screen.dart';
import 'promotie_feest_screen.dart';

/// MKM (medeklinker-klinker-medeklinker): max 3 letters, bv. maan, vis, zon.
const _woordenMKM = [
  'maan', 'vis', 'zon', 'sok', 'pen', 'mes', 'bus', 'hut', 'kip', 'vos', 'mus',
];

/// MKMM (4+ letters): bv. boom, tent, kast.
const _woordenMKMM = [
  'boom', 'tent', 'kast', 'huis', 'kaas', 'roos', 'boek', 'deur', 'fiets', 'hand', 'kind',
];

const _klinkers = {'a', 'e', 'i', 'o', 'u'};
bool _isKlinker(String letter) => _klinkers.contains(letter.toLowerCase());

/// Extra letters voor fop (niet in het woord).
const _fopLetters = ['x', 'q', 'j', 'w', 'z', 'y', 'k', 'f'];

/// Blokgrootte voor letterblokjes (gigantische letters).
const _blokBreedte = 72.0;
const _blokHoogte = 80.0;
const _letterFontSize = 52.0;

/// Letters & Woorden: Montessori drag & drop. Fopletters, snap-back bij fout,
/// 3D-blokjes (blauw/rood), 2,5 sec pauze na correct.
class WordGameScreen extends ConsumerStatefulWidget {
  const WordGameScreen({super.key});

  @override
  ConsumerState<WordGameScreen> createState() => _WordGameScreenState();
}

class _WordGameScreenState extends ConsumerState<WordGameScreen> {
  int _woordIndex = 0;
  late List<String?> _geplaatsteLetters;
  late List<String> _beschikbareLetters;
  late ConfettiController _confettiController;
  final Set<int> _wrongPendingSlots = {};

  List<String> get _woordenLijst {
    final niveau = ref.read(playerProfileProvider)?.spelNiveau ?? SpelNiveau.niveau1;
    if (niveau == SpelNiveau.niveau1) {
      return _woordenMKM.where((w) => w.length <= 3).toList();
    }
    return _woordenMKMM.where((w) => w.length >= 4).toList();
  }

  String get _woord => _woordenLijst[_woordIndex];
  String get _assetPath => 'assets/images/woorden/$_woord.png';

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 1));
    _resetWoord();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _resetWoord() {
    final letters = _woord.split('');
    final fopCount = 2 + Random().nextInt(3);
    final fop = _fopLetters
        .where((l) => !letters.contains(l))
        .toList()
      ..shuffle();
    final extra = fop.take(fopCount).toList();
    final alleLetters = [...letters, ...extra]..shuffle();
    setState(() {
      _geplaatsteLetters = List.filled(letters.length, null);
      _beschikbareLetters = alleLetters;
    });
  }

  Future<void> _volgendeWoord() async {
    await ref.read(gameProgressProvider.notifier).addVoltooidWoord();
    _checkNavigatieNaOpdrachten();
    if (!mounted) return;
    await Future.delayed(const Duration(milliseconds: 2500));
    if (!mounted) return;
    setState(() {
      _woordIndex = (_woordIndex + 1) % _woordenLijst.length;
      _resetWoord();
    });
  }

  void _checkNavigatieNaOpdrachten() {
    final progress = ref.read(gameProgressProvider);
    final profile = ref.read(playerProfileProvider);
    final totaal = progress.voltooideWoorden + progress.rekenGoedeBeurten;
    if (totaal > 0 && totaal % 7 == 0 && mounted) {
      ref.read(sessionCompletedProvider.notifier).state = true;
      final taalPunten = (progress.voltooideWoorden ~/ 7).clamp(0, 20);
      final rekenPunten = (progress.rekenGoedeBeurten ~/ 7).clamp(0, 20);
      final promotie =
          (profile?.leerjaar ?? 'Niveau 1') == 'Niveau 1' &&
          taalPunten >= 20 &&
          rekenPunten >= 20;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => promotie
              ? const PromotieFeestScreen()
              : const GroeiendeTuinScreen(),
        ),
        (route) => route.isFirst,
      );
    }
  }

  void _plaatsLetter(int slotIndex, String letter) {
    if (_geplaatsteLetters[slotIndex] != null) return;
    final correct = letter.toLowerCase() == _woord[slotIndex].toLowerCase();
    setState(() {
      _geplaatsteLetters[slotIndex] = letter;
      _beschikbareLetters.remove(letter);
    });
    if (correct) {
      HapticFeedback.lightImpact();
      if (_geplaatsteLetters.every((l) => l != null)) {
        final gespeld = _geplaatsteLetters.join('').toLowerCase() == _woord;
        if (gespeld) {
          _confettiController.play();
          _volgendeWoord();
        }
      }
    } else {
      _wrongPendingSlots.add(slotIndex);
      Future.delayed(const Duration(seconds: 2), () {
        if (!mounted) return;
        _verwijderWrongLetter(slotIndex);
      });
    }
  }

  void _verwijderWrongLetter(int slotIndex) {
    final letter = _geplaatsteLetters[slotIndex];
    if (letter != null) {
      setState(() {
        _geplaatsteLetters[slotIndex] = null;
        _beschikbareLetters.add(letter);
        _wrongPendingSlots.remove(slotIndex);
      });
    }
  }

  void _verwijderLetter(int slotIndex) {
    if (_wrongPendingSlots.contains(slotIndex)) return;
    final letter = _geplaatsteLetters[slotIndex];
    if (letter != null) {
      setState(() {
        _geplaatsteLetters[slotIndex] = null;
        _beschikbareLetters.add(letter);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: const Text('Spelen met Woorden'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.maybePop(context),
            ),
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Center(
                    child: _MaliMetBallon(),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    flex: 2,
                    child: Center(
                      child: Image.asset(
                        _assetPath,
                        fit: BoxFit.contain,
                        height: 140,
                        errorBuilder: (_, __, ___) => Container(
                          height: 120,
                          color: AppTheme.pastelKaart,
                          child: Center(
                            child: Text(
                              _woord,
                              style: Theme.of(context).textTheme.headlineLarge,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                  _woord.length,
                      (i) => _LetterVak(
                        verwachteLetter: _woord[i],
                        letter: _geplaatsteLetters[i],
                        toonGlow: _geplaatsteLetters[i] != null &&
                            _geplaatsteLetters[i]!.toLowerCase() == _woord[i].toLowerCase(),
                        wrongPending: _wrongPendingSlots.contains(i),
                        onAccept: (l) => _plaatsLetter(i, l),
                        onRemove: () => _verwijderLetter(i),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 12.0,
                    runSpacing: 12.0,
                    children: [
                      for (var i = 0; i < _beschikbareLetters.length; i++)
                        _LetterBlok(
                          key: ValueKey('avail_$i'),
                          letter: _beschikbareLetters[i],
                          kleur: _isKlinker(_beschikbareLetters[i])
                              ? AppTheme.klinkerBlauw
                              : AppTheme.medeklinkerRood,
                        ),
                    ],
              ),
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
            maxBlastForce: 5,
            minBlastForce: 2,
            emissionFrequency: 0.05,
            numberOfParticles: 15,
            gravity: 0.2,
            colors: const [
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

/// Mali (mama) met tekstballon, zoals Oma Lomi in de lettertuin.
class _MaliMetBallon extends ConsumerWidget {
  const _MaliMetBallon();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(playerProfileProvider);
    final dierSoort = (profile?.gekozenAvatar ?? '').endsWith('_kat') ? 'kat' : 'hamster';
    final maliAsset = 'assets/images/karakters/$dierSoort/mali_instructie.png';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _GesprekBallon(tekst: 'Sleep de letters op de juiste plek'),
        const SizedBox(height: 4),
        SizedBox(
          width: 80,
          height: 96,
          child: Image.asset(
            maliAsset,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const Icon(Icons.face, size: 48),
          ),
        ),
      ],
    );
  }
}

/// Gesprekballonnetje voor instructietekst.
class _GesprekBallon extends StatelessWidget {
  const _GesprekBallon({required this.tekst});

  final String tekst;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 200, maxWidth: 320),
      child: CustomPaint(
        painter: _BubblePainter(),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Text(
            tekst,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.tekstDonker,
                ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class _BubblePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const radius = 16.0;
    const tailWidth = 12.0;
    const tailHeight = 10.0;

    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height - tailHeight),
      const Radius.circular(radius),
    );

    canvas.save();
    canvas.translate(2, 3);
    canvas.drawRRect(
      rect,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.06)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    canvas.restore();

    final fillPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final borderPaint = Paint()
      ..color = AppTheme.tekstZacht.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawRRect(rect, fillPaint);
    canvas.drawRRect(rect, borderPaint);

    final tailPath = Path()
      ..moveTo(size.width / 2 - tailWidth / 2, size.height - tailHeight)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width / 2 + tailWidth / 2, size.height - tailHeight)
      ..close();
    canvas.drawPath(tailPath, fillPaint);
    canvas.drawPath(tailPath, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _LetterVak extends StatelessWidget {
  const _LetterVak({
    required this.verwachteLetter,
    required this.letter,
    required this.toonGlow,
    required this.wrongPending,
    required this.onAccept,
    required this.onRemove,
  });

  final String verwachteLetter;
  final String? letter;
  final bool toonGlow;
  final bool wrongPending;
  final void Function(String) onAccept;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return DragTarget<String>(
      onWillAcceptWithDetails: (d) => letter == null,
      onAcceptWithDetails: (d) => onAccept(d.data),
      builder: (context, candidateData, rejectedData) {
        return GestureDetector(
          onTap: letter != null && !wrongPending ? onRemove : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: _blokBreedte,
            height: _blokHoogte,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: wrongPending
                  ? AppTheme.medeklinkerRood.withValues(alpha: 0.2)
                  : candidateData.isNotEmpty
                      ? AppTheme.klinkerBlauw.withValues(alpha: 0.2)
                      : AppTheme.pastelKaart,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: wrongPending
                    ? AppTheme.medeklinkerRood
                    : candidateData.isNotEmpty
                        ? AppTheme.klinkerBlauw
                        : AppTheme.tekstZacht.withValues(alpha: 0.5),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 4,
                  offset: const Offset(2, 3),
                ),
                if (toonGlow)
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.6),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
              ],
            ),
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: child,
                ),
                child: letter != null
                    ? Text(
                        letter!.toUpperCase(),
                        key: ValueKey(letter),
                        style: GoogleFonts.lexend(
                        fontSize: _letterFontSize,
                        fontWeight: FontWeight.bold,
                        color: wrongPending
                            ? AppTheme.medeklinkerRood
                            : _isKlinker(letter!)
                                ? AppTheme.klinkerBlauw
                                : AppTheme.medeklinkerRood,
                      ),
                    )
                    : const SizedBox.shrink(key: ValueKey('empty')),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _LetterBlok extends StatelessWidget {
  const _LetterBlok({
    super.key,
    required this.letter,
    required this.kleur,
  });

  final String letter;
  final Color kleur;

  @override
  Widget build(BuildContext context) {
    return Draggable<String>(
      data: letter,
      feedback: Material(
        color: Colors.transparent,
        child: _blokContent(),
      ),
      childWhenDragging: Opacity(opacity: 0.3, child: _blokContent()),
      child: _blokContent(),
    );
  }

  Widget _blokContent() {
    return Container(
      width: _blokBreedte,
      height: _blokHoogte,
      decoration: BoxDecoration(
        color: kleur,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 4,
            offset: const Offset(2, 3),
          ),
          BoxShadow(
            color: kleur.withValues(alpha: 0.5),
            blurRadius: 0,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Center(
        child: Text(
          letter.toUpperCase(),
          style: GoogleFonts.lexend(
            fontSize: _letterFontSize,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
