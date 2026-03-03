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

/// Rekenobjecten in assets/images/objecten/ (exact overeenkomstig map-inhoud)
const _rekenObjecten = [
  'druif',
  'elastiekje',
  'euro',
  'keutel',
  'knikker',
  'marshmallow',
  'schelp',
  'steen',
  'tent',
];

/// Tellen & Cijfers: Visuele som met objecten, DragTarget voor antwoord,
/// Draggable cijfer-blokjes. Geen invulvelden.
class MathGameScreen extends ConsumerStatefulWidget {
  const MathGameScreen({super.key});

  @override
  ConsumerState<MathGameScreen> createState() => _MathGameScreenState();
}

class _MathGameScreenState extends ConsumerState<MathGameScreen> {
  late int _a;
  late int _b;
  late int _antwoord;
  int? _geplaatstAntwoord;
  bool _antwoordWrongPending = false;
  late String _object;
  late List<int> _beschikbareCijfers;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 1));
    _genereerSom();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _genereerSom() {
    final profile = ref.read(playerProfileProvider);
    final niveau = profile?.spelNiveau ?? SpelNiveau.niveau1;
    final r = Random();
    final maxGetal = niveau.maxRekenGetal;

    do {
      _a = 1 + r.nextInt(maxGetal);
      _b = 1 + r.nextInt(maxGetal);
      _antwoord = _a + _b;
    } while (_antwoord > 9);
    _object = _rekenObjecten[r.nextInt(_rekenObjecten.length)];
    _beschikbareCijfers = _maakCijferBlokken(r);
    _geplaatstAntwoord = null;
    setState(() {});
  }

  /// Cijfers 0-9 plus 2-4 fop-cijfers (niet het antwoord).
  List<int> _maakCijferBlokken(Random r) {
    final fopCount = 2 + r.nextInt(3);
    final fop = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
        .where((c) => c != _antwoord)
        .toList()
      ..shuffle();
    final extra = fop.take(fopCount).toList();
    final alle = [_antwoord, ...extra]..shuffle();
    return alle;
  }

  void _verwijderWrongAntwoord() {
    if (_geplaatstAntwoord != null) {
      setState(() {
        _beschikbareCijfers.add(_geplaatstAntwoord!);
        _geplaatstAntwoord = null;
        _antwoordWrongPending = false;
      });
    }
  }

  void _controleer() async {
    if (_geplaatstAntwoord != _antwoord) return;
    HapticFeedback.mediumImpact();
    _confettiController.play();
    await ref.read(gameProgressProvider.notifier).addRekenGoedeBeurt();
    _checkNavigatieNaOpdrachten();
    if (!mounted) return;
    await Future.delayed(const Duration(milliseconds: 2500));
    if (!mounted) return;
    _genereerSom();
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

  String get _objectAsset => 'assets/images/objecten/$_object.png';

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: const Text('Tellen & Cijfers'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.maybePop(context),
            ),
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                    child: _MoliMetBallon(),
                  ),
                  const SizedBox(height: 16),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return Center(
                        child: ClipRect(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: constraints.maxWidth - 32,
                              ),
                              child: IntrinsicHeight(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _ObjectenGroep(aantal: _a, objectAsset: _objectAsset),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 10),
                                      child: Text(
                                        '+',
                                        style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                              color: AppTheme.medeklinkerRood,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    ),
                                    _ObjectenGroep(aantal: _b, objectAsset: _objectAsset),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 10),
                                      child: Text(
                                        '= ?',
                                        style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                              color: AppTheme.tekstDonker,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: _AntwoordVak(
                      verwachtAntwoord: _antwoord,
                      waarde: _geplaatstAntwoord,
                      wrongPending: _antwoordWrongPending,
                      onAccept: (v) {
                        setState(() {
                          _geplaatstAntwoord = v;
                          _beschikbareCijfers.remove(v);
                        });
                        if (v == _antwoord) {
                          _controleer();
                        } else {
                          _antwoordWrongPending = true;
                          Future.delayed(const Duration(seconds: 2), () {
                            if (!mounted) return;
                            _verwijderWrongAntwoord();
                          });
                        }
                      },
                      onRemove: () {
                        if (_geplaatstAntwoord != null && !_antwoordWrongPending) {
                          setState(() {
                            _beschikbareCijfers.add(_geplaatstAntwoord!);
                            _geplaatstAntwoord = null;
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 10,
                    runSpacing: 10,
                    children: _beschikbareCijfers.asMap().entries.map((e) {
                      return _CijferBlok(
                        key: ValueKey('cijfer_${e.key}'),
                        cijfer: e.value,
                      );
                    }).toList(),
                    ),
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
              AppTheme.tellenGroen,
              AppTheme.klinkerBlauw,
              AppTheme.medeklinkerRood,
              Colors.amber,
            ],
            shouldLoop: false,
          ),
        ),
      ],
    );
  }
}

/// Moli (papa) met tekstballon, zoals Mali in het woordspel.
class _MoliMetBallon extends ConsumerWidget {
  const _MoliMetBallon();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(playerProfileProvider);
    final dierSoort = (profile?.gekozenAvatar ?? '').endsWith('_kat') ? 'kat' : 'hamster';
    final moliAsset = 'assets/images/karakters/$dierSoort/moli_blij.png';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _GesprekBallon(
          tekst: 'Sleep het juiste antwoord op het vakje met het vraagteken',
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 80,
          height: 96,
          child: Image.asset(
            moliAsset,
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
      constraints: const BoxConstraints(minWidth: 200, maxWidth: 340),
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

/// Subitising: Wrap met vaste breedte zodat objecten groeperen in max 3 per rij.
class _ObjectenGroep extends StatelessWidget {
  const _ObjectenGroep({
    required this.aantal,
    required this.objectAsset,
  });

  final int aantal;
  final String objectAsset;

  static const double _itemSize = 40;
  static const double _spacing = 6;

  @override
  Widget build(BuildContext context) {
    final n = aantal.clamp(0, 10);
    // Groepering: rijtjes van max 3. Voor 7: 2, 3, 2. Anders: 3,3,... of 3,2 etc.
    final groepen = <int>[];
    if (n == 7) {
      groepen.addAll([2, 3, 2]);
    } else {
      var rest = n;
      while (rest > 0) {
        groepen.add(rest >= 3 ? 3 : rest);
        rest -= rest >= 3 ? 3 : rest;
      }
    }
    final maxPerRij = groepen.isNotEmpty ? groepen.reduce((a, b) => a > b ? a : b) : 0;
    final rijBreedte = maxPerRij * _itemSize + (maxPerRij - 1) * _spacing;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$aantal',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: AppTheme.medeklinkerRood,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: rijBreedte,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: groepen.map((count) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    count,
                    (_) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Image.asset(
                        objectAsset,
                        width: _itemSize,
                        height: _itemSize,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Container(
                          width: _itemSize,
                          height: _itemSize,
                          color: AppTheme.tellenGroen.withValues(alpha: 0.3),
                          child: const Center(child: Text('•')),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _AntwoordVak extends StatelessWidget {
  const _AntwoordVak({
    required this.verwachtAntwoord,
    required this.waarde,
    required this.wrongPending,
    required this.onAccept,
    required this.onRemove,
  });

  final int verwachtAntwoord;
  final int? waarde;
  final bool wrongPending;
  final void Function(int) onAccept;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return DragTarget<int>(
      onWillAcceptWithDetails: (d) => waarde == null,
      onAcceptWithDetails: (d) => onAccept(d.data),
      builder: (context, candidateData, rejectedData) {
        return GestureDetector(
          onTap: waarde != null && !wrongPending ? onRemove : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: wrongPending
                  ? AppTheme.medeklinkerRood.withValues(alpha: 0.2)
                  : candidateData.isNotEmpty
                      ? AppTheme.tellenGroen.withValues(alpha: 0.2)
                      : AppTheme.pastelKaart,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: wrongPending
                    ? AppTheme.medeklinkerRood
                    : candidateData.isNotEmpty
                        ? AppTheme.tellenGroen
                        : AppTheme.tekstZacht.withValues(alpha: 0.5),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 4,
                  offset: const Offset(2, 3),
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
                child: waarde != null
                    ? Text(
                        '$waarde',
                        key: ValueKey('$waarde'),
                        style: GoogleFonts.lexend(
                        fontSize: 52,
                        fontWeight: FontWeight.bold,
                        color: wrongPending ? AppTheme.medeklinkerRood : AppTheme.tellenGroen,
                      ),
                    )
                    : Text(
                      '?',
                      key: const ValueKey('?'),
                      style: GoogleFonts.lexend(
                        fontSize: 52,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.tekstZacht,
                      ),
                    ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CijferBlok extends StatelessWidget {
  const _CijferBlok({super.key, required this.cijfer});

  final int cijfer;

  @override
  Widget build(BuildContext context) {
    return Draggable<int>(
      data: cijfer,
      feedback: Material(
        color: Colors.transparent,
        child: _blokContent(opacity: 0.9),
      ),
      childWhenDragging: Opacity(opacity: 0.3, child: _blokContent()),
      child: _blokContent(),
    );
  }

  static const double _blokSize = 72;
  static const double _fontSize = 52;

  Widget _blokContent({double opacity = 1}) {
    return Container(
      width: _blokSize,
      height: _blokSize + 8,
      decoration: BoxDecoration(
        color: AppTheme.tellenGroen.withValues(alpha: opacity),
        borderRadius: BorderRadius.circular(12),
        boxShadow: opacity >= 0.9
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 4,
                  offset: const Offset(2, 3),
                ),
                BoxShadow(
                  color: AppTheme.tellenGroen.withValues(alpha: 0.5),
                  blurRadius: 0,
                  offset: const Offset(0, 1),
                ),
              ]
            : null,
      ),
      child: Center(
        child: Text(
          '$cijfer',
          style: GoogleFonts.lexend(
            fontSize: _fontSize,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
