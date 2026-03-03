import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../providers/letter_audio_provider.dart';
import '../providers/player_provider.dart';
import '../theme/app_theme.dart';

/// Oma Lomi's Lettertuin: grid van letters als houten blokjes.
/// Bij tik: "Zeg mij maar na... [fonetische klank]" (buh, muh, ah).
class LetterTuinScreen extends ConsumerWidget {
  const LetterTuinScreen({super.key});

  static const _letters = [
    'a',
    'b',
    'c',
    'd',
    'e',
    'f',
    'g',
    'h',
    'i',
    'j',
    'k',
    'l',
    'm',
    'n',
    'o',
    'p',
    'q',
    'r',
    's',
    't',
    'u',
    'v',
    'w',
    'x',
    'y',
    'z',
  ];

  static const _crossAxisCount = 6;
  static const double _crossAxisSpacing = 8.0;
  static const double _mainAxisSpacing = 8.0;
  static const int _rowCount = 5; // 26 letters in 6 columns = 5 rows

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audio = ref.watch(letterAudioProvider);
    final profile = ref.watch(playerProfileProvider);
    final dierSoort = (profile?.gekozenAvatar ?? '').endsWith('_kat') ? 'kat' : 'hamster';
    final lomiAsset = 'assets/images/karakters/$dierSoort/lomi_instructie.png';

    return Scaffold(
      appBar: AppBar(
        title: const Text("Oma Lomi's Lettertuin"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _GesprekBallon(
                      tekst: 'Tik op een letter om de klank te horen',
                    ),
                    const SizedBox(height: 4),
                    SizedBox(
                      width: 80,
                      height: 96,
                      child: Image.asset(
                        lomiAsset,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Icon(Icons.face, size: 48),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final availableHeight = constraints.maxHeight;
                    final cellExtent = (availableHeight - (_rowCount - 1) * _mainAxisSpacing) / _rowCount;
                    return GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: _crossAxisCount,
                        mainAxisSpacing: _mainAxisSpacing,
                        crossAxisSpacing: _crossAxisSpacing,
                        mainAxisExtent: cellExtent.clamp(0.0, double.infinity),
                      ),
                      itemCount: _letters.length,
                      itemBuilder: (context, index) {
                        final letter = _letters[index];
                        return _LetterBlok(
                          letter: letter,
                          onTap: () => audio.speelLetterKlank(letter),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
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

/// Blokjes in rood (medeklinkers) en blauw (klinkers), met hoofdletter + kleine letter.
class _LetterBlok extends StatefulWidget {
  const _LetterBlok({
    required this.letter,
    required this.onTap,
  });

  final String letter;
  final VoidCallback onTap;

  @override
  State<_LetterBlok> createState() => _LetterBlokState();
}

class _LetterBlokState extends State<_LetterBlok>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  static const _klinkers = {'a', 'e', 'i', 'o', 'u'};

  Color _blokKleur(String letter) {
    return _klinkers.contains(letter.toLowerCase())
        ? AppTheme.klinkerBlauw
        : AppTheme.medeklinkerRood;
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
    );
    _scaleAnimation = Tween<double>(begin: 1, end: 0.92).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final kleur = _blokKleur(widget.letter);
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
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
          alignment: Alignment.center,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.letter.toUpperCase(),
                    style: GoogleFonts.lexend(
                      fontSize: 44,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.letter.toLowerCase(),
                    style: GoogleFonts.andika(
                      fontSize: 44,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      height: 1.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
