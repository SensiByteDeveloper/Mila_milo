import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/player_provider.dart';
import '../providers/progress_provider.dart';
import '../services/schatkist_audio_service.dart';
import '../theme/app_theme.dart';
import 'dashboard_screen.dart';

/// De Groeiende Tuin: rustige achtergrond met zonnebloem (taal) en appelboom (rekenen).
/// Voortgang groeit visueel van zaadje tot bloei.
class GroeiendeTuinScreen extends ConsumerStatefulWidget {
  const GroeiendeTuinScreen({super.key});

  @override
  ConsumerState<GroeiendeTuinScreen> createState() => _GroeiendeTuinScreenState();
}

class _GroeiendeTuinScreenState extends ConsumerState<GroeiendeTuinScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _speelSchatkistAudio());
  }

  Future<void> _speelSchatkistAudio() async {
    final progress = ref.read(gameProgressProvider);
    final taalPunten = (progress.voltooideWoorden ~/ 7).clamp(0, 20);
    final rekenPunten = (progress.rekenGoedeBeurten ~/ 7).clamp(0, 20);
    final stap = (taalPunten > rekenPunten ? taalPunten : rekenPunten);
    if (stap >= 1) {
      await SchatkistAudioService().speelStapBericht(stap);
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = ref.watch(gameProgressProvider);
    final profile = ref.watch(playerProfileProvider);
    // Elk setje van 7 levert 1 punt op (max 20)
    final taalPunten = (progress.voltooideWoorden ~/ 7).clamp(0, 20);
    final rekenPunten = (progress.rekenGoedeBeurten ~/ 7).clamp(0, 20);
    final totaalPunten = taalPunten + rekenPunten;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              (profile?.gekozenAvatar ?? '').endsWith('_kat')
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
                    Colors.white.withValues(alpha: 0.6),
                    AppTheme.pastelAchtergrond.withValues(alpha: 0.85),
                  ],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFFFFD700).withValues(alpha: 0.08),
                    const Color(0xFFDAA520).withValues(alpha: 0.05),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // Terugknop linksboven + Oogst-balk + Info
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      onPressed: () {
                        if (Navigator.of(context).canPop()) {
                          Navigator.of(context).pop();
                        } else {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (_) => const DashboardScreen(),
                            ),
                            (route) => false,
                          );
                        }
                      },
                      icon: Icon(
                        Icons.arrow_back_ios_new,
                        color: AppTheme.tekstDonker.withValues(alpha: 0.7),
                        size: 22,
                      ),
                    ),
                    Expanded(
                      child: _OogstBalk(
                        taalPunten: taalPunten,
                        rekenPunten: rekenPunten,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const GroeistadiaOverzichtScreen(),
                        ),
                      ),
                      icon: Icon(
                        Icons.info_outline,
                        color: AppTheme.tekstDonker.withValues(alpha: 0.7),
                        size: 24,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Mali met tekstballon (bij voortgang)
                if (totaalPunten >= 1) ...[
                  Center(
                    child: _MaliSchatkistBallon(
                      stap: (taalPunten > rekenPunten ? taalPunten : rekenPunten),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // Groei-elementen naast elkaar
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: _TaalZonnebloem(stappen: taalPunten),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: _RekenAppelboom(stappen: rekenPunten),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Teksten voor Mali's ballon per stap (1–20). Vul stap 2–20 aan met opgenomen teksten.
const Map<int, String> _schatkistTeksten = {
  1: 'Ja goedzo, je eerste stap. Een zaadje wordt geplant, ga door om je plantje/ boompje te laten groeien.',
  2: 'Goed bezig! Stap 2 – je plantje begint te groeien.',
  3: 'Stap 3 – het gaat de goede kant op!',
  4: 'Stap 4 – mooi zo!',
  5: 'Stap 5 – je bent al een kwart!',
  6: 'Stap 6 – ga zo door!',
  7: 'Stap 7 – je doet het geweldig!',
  8: 'Stap 8 – bijna op de helft!',
  9: 'Stap 9 – super!',
  10: 'Stap 10 – al halverwege!',
  11: 'Stap 11 – goed bezig!',
  12: 'Stap 12 – bijna daar!',
  13: 'Stap 13 – je plantje wordt groot!',
  14: 'Stap 14 – nog even!',
  15: 'Stap 15 – drie kwart!',
  16: 'Stap 16 – bijna klaar!',
  17: 'Stap 17 – nog een paar stappen!',
  18: 'Stap 18 – bijna volgroeid!',
  19: 'Stap 19 – nog één stap!',
  20: 'Gefeliciteerd! Stap 20 – je plantje en boompje zijn volgroeid!',
};

/// Mali (mama) met tekstballon bij schatkist-voortgang.
class _MaliSchatkistBallon extends ConsumerWidget {
  const _MaliSchatkistBallon({required this.stap});

  final int stap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(playerProfileProvider);
    final dierSoort = (profile?.gekozenAvatar ?? '').endsWith('_kat') ? 'kat' : 'hamster';
    final maliAsset = 'assets/images/karakters/$dierSoort/mali_instructie.png';

    final tekst = _schatkistTeksten[stap.clamp(1, 20)] ?? _schatkistTeksten[1]!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _SchatkistGesprekBallon(tekst: tekst),
        const SizedBox(height: 4),
        SizedBox(
          width: 72,
          height: 88,
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

/// Gesprekballon voor schatkist (breder voor langere tekst).
class _SchatkistGesprekBallon extends StatelessWidget {
  const _SchatkistGesprekBallon({required this.tekst});

  final String tekst;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 220, maxWidth: 360),
      child: CustomPaint(
        painter: _SchatkistBubblePainter(),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Text(
            tekst,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppTheme.tekstDonker,
                  height: 1.35,
                ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class _SchatkistBubblePainter extends CustomPainter {
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

/// Oogst-balk: punten (1 punt per 7 opdrachten) met icoon + herhaalde iconen.
class _OogstBalk extends StatelessWidget {
  const _OogstBalk({
    required this.taalPunten,
    required this.rekenPunten,
  });

  final int taalPunten;
  final int rekenPunten;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.9),
              width: 1,
            ),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                _OogstItem(
                  icon: Icons.eco,
                  kleur: const Color(0xFFF9A825),
                  aantal: taalPunten,
                  label: 'Taal',
                ),
                const SizedBox(width: 24),
                _OogstItem(
                  icon: Icons.apple,
                  kleur: const Color(0xFFE53935),
                  aantal: rekenPunten,
                  label: 'Reken',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OogstItem extends StatelessWidget {
  const _OogstItem({
    required this.icon,
    required this.kleur,
    required this.aantal,
    required this.label,
  });

  final IconData icon;
  final Color kleur;
  final int aantal;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (aantal > 0)
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 2,
            runSpacing: 2,
            children: List.generate(
              aantal.clamp(0, 20),
              (_) => Icon(icon, color: kleur, size: 20),
            ),
          )
        else
          Icon(icon, color: kleur.withValues(alpha: 0.5), size: 24),
        const SizedBox(height: 4),
        Text(
          '$aantal',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.tekstDonker,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: AppTheme.tekstZacht,
          ),
        ),
      ],
    );
  }
}

/// Taal-Zonnebloem: groeit in 20 stappen. Stap 0=niks, 1=zaadje, 2+=groeit.
class _TaalZonnebloem extends StatelessWidget {
  const _TaalZonnebloem({required this.stappen});

  final int stappen;

  /// 0=niks, 1=zaadje, 2=sprietje, 3=stengel+bladeren, 4=langere stengel, 5=knop, 6=volle bloem
  int get _stage {
    if (stappen == 0) return 0;
    if (stappen == 1) return 1;
    if (stappen <= 5) return 2;
    if (stappen <= 10) return 3;
    if (stappen <= 15) return 4;
    if (stappen <= 18) return 5;
    return 6;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: FittedBox(
            fit: BoxFit.contain,
            child: SizedBox(
              width: 120,
              height: 120,
              child: _stage == 1
                  ? _ZaadjeAnimatie(
                      key: const ValueKey('taal_zaad'),
                      child: CustomPaint(
                        painter: _ZonnebloemPainter(stage: _stage),
                      ),
                    )
                  : CustomPaint(
                      painter: _ZonnebloemPainter(stage: _stage),
                    ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.abc, size: 18, color: AppTheme.klinkerBlauw),
                  const SizedBox(width: 6),
                  Text(
                    '$stappen / 20',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.tekstDonker,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

/// Reken-Appelboom: groeit in 20 stappen. Stap 0=niks, 1=zaadje, 2+=groeit.
class _RekenAppelboom extends StatelessWidget {
  const _RekenAppelboom({required this.stappen});

  final int stappen;

  /// 0=niks, 1=zaadje, 2=stammetje, 3=bladkroon, 4=bloesem, 5=appels
  int get _stage {
    if (stappen == 0) return 0;
    if (stappen == 1) return 1;
    if (stappen <= 5) return 2;
    if (stappen <= 12) return 3;
    if (stappen <= 19) return 4;
    return 5;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: FittedBox(
            fit: BoxFit.contain,
            child: SizedBox(
              width: 120,
              height: 120,
              child: _stage == 1
                  ? _ZaadjeAnimatie(
                      key: const ValueKey('reken_zaad'),
                      child: CustomPaint(
                        painter: _AppelboomPainter(stage: _stage),
                      ),
                    )
                  : CustomPaint(
                      painter: _AppelboomPainter(stage: _stage),
                    ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calculate, size: 18, color: AppTheme.medeklinkerRood),
                  const SizedBox(width: 6),
                  Text(
                    '$stappen / 20',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.tekstDonker,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

/// Animatie: zaadje wordt geplant (scale-in).
class _ZaadjeAnimatie extends StatefulWidget {
  const _ZaadjeAnimatie({super.key, required this.child});

  final Widget child;

  @override
  State<_ZaadjeAnimatie> createState() => _ZaadjeAnimatieState();
}

class _ZaadjeAnimatieState extends State<_ZaadjeAnimatie>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _scaleAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          alignment: Alignment.bottomCenter,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// CustomPainter voor zonnebloem in 7 groeistadia (0=niks, 1=zaad, 2-6=groeit).
class _ZonnebloemPainter extends CustomPainter {
  _ZonnebloemPainter({required this.stage});

  final int stage;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.85);
    final scale = size.shortestSide / 120;

    final ground = Paint()
      ..color = const Color(0xFF8D6E63)
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.9, size.width, size.height * 0.1),
      ground,
    );

    if (stage == 1) {
      // Zaadje (bruin ovaal, half in de grond)
      final seed = Paint()
        ..color = const Color(0xFF5D4037)
        ..style = PaintingStyle.fill;
      final seedCenter = Offset(size.width / 2, size.height * 0.88);
      canvas.save();
      canvas.translate(seedCenter.dx, seedCenter.dy);
      canvas.rotate(-0.2);
      canvas.drawOval(
        Rect.fromCenter(center: Offset.zero, width: 16 * scale, height: 10 * scale),
        seed,
      );
      canvas.restore();
      return;
    }

    if (stage >= 2) {
      // Sprietje / stengel
      final stem = Paint()
        ..color = const Color(0xFF558B2F)
        ..strokeWidth = 4 * scale
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      final stemHeight = stage == 2 ? 20 * scale : 60 * scale;
      canvas.drawLine(
        center,
        center + Offset(0, -stemHeight),
        stem,
      );
    }

    if (stage >= 3) {
      // Bladeren
      final leaf = Paint()
        ..color = const Color(0xFF7CB342)
        ..style = PaintingStyle.fill;
      final center = Offset(size.width / 2, size.height * 0.85);
      for (var i = 0; i < 2; i++) {
        final path = Path();
        path.moveTo(center.dx, center.dy - 30 * scale);
        path.quadraticBezierTo(
          center.dx + (i == 0 ? -20 : 20) * scale,
          center.dy - 30 * scale,
          center.dx + (i == 0 ? -15 : 15) * scale,
          center.dy - 50 * scale,
        );
        path.quadraticBezierTo(
          center.dx + (i == 0 ? -25 : 25) * scale,
          center.dy - 45 * scale,
          center.dx,
          center.dy - 30 * scale,
        );
        canvas.drawPath(path, leaf);
      }
    }

    if (stage >= 4) {
      // Langere stengel
      final stem = Paint()
        ..color = const Color(0xFF558B2F)
        ..strokeWidth = 6 * scale
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      final top = Offset(size.width / 2, size.height * 0.4);
      canvas.drawLine(
        Offset(size.width / 2, size.height * 0.85),
        top,
        stem,
      );
    }

    if (stage >= 5 && stage < 6) {
      // Knop
      final bud = Paint()
        ..color = const Color(0xFFF9A825)
        ..style = PaintingStyle.fill;
      final top = Offset(size.width / 2, size.height * 0.38);
      canvas.drawCircle(top, 18 * scale, bud);
      final budOutline = Paint()
        ..color = const Color(0xFFF57F17)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawCircle(top, 18 * scale, budOutline);
    }

    if (stage >= 6) {
      // Volledige zonnebloem
      final top = Offset(size.width / 2, size.height * 0.35);
      // Centrum (donker)
      final centerPaint = Paint()
        ..color = const Color(0xFF5D4037)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(top, 14 * scale, centerPaint);
      // Bloemblaadjes (gele cirkels in een ring)
      final petal = Paint()
        ..color = const Color(0xFFF9A825)
        ..style = PaintingStyle.fill;
      for (var i = 0; i < 16; i++) {
        final angle = (i / 16) * 2 * math.pi;
        final pos = top +
            Offset(22 * scale * math.cos(angle), 22 * scale * math.sin(angle));
        canvas.drawCircle(pos, 10 * scale, petal);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ZonnebloemPainter oldDelegate) =>
      oldDelegate.stage != stage;
}

/// CustomPainter voor appelboom in 6 groeistadia (0=niks, 1=zaad, 2-5=groeit).
class _AppelboomPainter extends CustomPainter {
  _AppelboomPainter({required this.stage});

  final int stage;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.85);
    final scale = size.shortestSide / 120;

    final ground = Paint()
      ..color = const Color(0xFF8D6E63)
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.9, size.width, size.height * 0.1),
      ground,
    );

    if (stage == 1) {
      // Zaadje (bruin ovaal, appelpit)
      final seed = Paint()
        ..color = const Color(0xFF5D4037)
        ..style = PaintingStyle.fill;
      final seedCenter = Offset(size.width / 2, size.height * 0.88);
      canvas.save();
      canvas.translate(seedCenter.dx, seedCenter.dy);
      canvas.rotate(0.2);
      canvas.drawOval(
        Rect.fromCenter(center: Offset.zero, width: 12 * scale, height: 8 * scale),
        seed,
      );
      canvas.restore();
      return;
    }

    if (stage >= 2) {
      // Dun stammetje
      final trunk = Paint()
        ..color = const Color(0xFF6D4C41)
        ..strokeWidth = (stage == 2 ? 4 : 6) * scale
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      final trunkHeight = stage == 2 ? 25 * scale : 50 * scale;
      canvas.drawLine(
        center,
        center + Offset(0, -trunkHeight),
        trunk,
      );
    }

    if (stage >= 3) {
      // Bladkroon (cirkel)
      final crown = Paint()
        ..color = const Color(0xFF558B2F)
        ..style = PaintingStyle.fill;
      final top = Offset(size.width / 2, size.height * 0.5);
      canvas.drawCircle(top, 35 * scale, crown);
      final trunk = Paint()
        ..color = const Color(0xFF6D4C41)
        ..strokeWidth = 8 * scale
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        center,
        top + Offset(0, 35 * scale),
        trunk,
      );
    }

    if (stage >= 4) {
      // Bloesem
      final blossom = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      final top = Offset(size.width / 2, size.height * 0.42);
      for (var i = 0; i < 5; i++) {
        final angle = (i / 5) * 2 * math.pi + 0.5;
        final pos = top + Offset(15 * scale * math.cos(angle), 15 * scale * math.sin(angle));
        canvas.drawCircle(pos, 4 * scale, blossom);
      }
    }

    if (stage >= 5) {
      // Volle boom met rode appels
      final apple = Paint()
        ..color = const Color(0xFFE53935)
        ..style = PaintingStyle.fill;
      final top = Offset(size.width / 2, size.height * 0.38);
      for (var i = 0; i < 8; i++) {
        final angle = (i / 8) * 2 * math.pi + 0.3;
        final pos = top + Offset(25 * scale * math.cos(angle), 25 * scale * math.sin(angle));
        canvas.drawCircle(pos, 10 * scale, apple);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _AppelboomPainter oldDelegate) =>
      oldDelegate.stage != stage;
}

/// Overzicht van alle groeistadia (zonnebloem + appelboom).
class GroeistadiaOverzichtScreen extends StatelessWidget {
  const GroeistadiaOverzichtScreen({super.key});

  static const _zonnebloemStages = [
    (0, '0 punten', 'Leeg veld'),
    (1, '1 punt', 'Zaadje wordt geplant'),
    (2, '2–5 punten', 'Sprietje / korte stengel'),
    (3, '6–10 punten', 'Stengel + bladeren'),
    (4, '11–15 punten', 'Langere stengel'),
    (5, '16–18 punten', 'Knop'),
    (6, '19–20 punten', 'Volledige zonnebloem'),
  ];

  static const _appelboomStages = [
    (0, '0 punten', 'Leeg veld'),
    (1, '1 punt', 'Zaadje wordt geplant'),
    (2, '2–5 punten', 'Dun stammetje'),
    (3, '6–12 punten', 'Bladkroon'),
    (4, '13–19 punten', 'Bloesem'),
    (5, '20 punten', 'Rode appels'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alle groeistadia'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE3F2FD),
              Color(0xFFE8F5E9),
              Color(0xFFF1F8E9),
              Color(0xFFE0F2F1),
            ],
            stops: [0.0, 0.35, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '1 punt = 7 opdrachten (max 20 punten)',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.tekstZacht,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Zonnebloem (taal)',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppTheme.klinkerBlauw,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 180,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _zonnebloemStages.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 16),
                    itemBuilder: (context, i) {
                      final (stage, range, desc) = _zonnebloemStages[i];
                      return _StageKaart(
                        child: CustomPaint(
                          painter: _ZonnebloemPainter(stage: stage),
                        ),
                        range: range,
                        beschrijving: desc,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Appelboom (rekenen)',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppTheme.medeklinkerRood,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 180,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _appelboomStages.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 16),
                    itemBuilder: (context, i) {
                      final (stage, range, desc) = _appelboomStages[i];
                      return _StageKaart(
                        child: CustomPaint(
                          painter: _AppelboomPainter(stage: stage),
                        ),
                        range: range,
                        beschrijving: desc,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StageKaart extends StatelessWidget {
  const _StageKaart({
    required this.child,
    required this.range,
    required this.beschrijving,
  });

  final Widget child;
  final String range;
  final String beschrijving;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 120,
            height: 120,
            child: child,
          ),
          const SizedBox(height: 8),
          Text(
            range,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppTheme.tekstDonker,
            ),
          ),
          Text(
            beschrijving,
            style: TextStyle(
              fontSize: 11,
              color: AppTheme.tekstZacht,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
