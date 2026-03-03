import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'letter_tuin_screen.dart';

/// Letters & Woorden: Schrijven & Lezen module.
/// Hub voor taal-activiteiten.
class LettersWoordenScreen extends StatelessWidget {
  const LettersWoordenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Letters & Woorden'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Schrijven & Lezen',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppTheme.klinkerBlauw,
                    ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView(
                  children: [
                    _ActiviteitKaart(
                      titel: "Oma Lomi's Lettertuin",
                      subtitel: 'Tik op letters om de klank te horen',
                      icon: Icons.abc,
                      kleur: AppTheme.klinkerBlauw,
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
            ],
          ),
        ),
      ),
    );
  }
}

class _ActiviteitKaart extends StatelessWidget {
  const _ActiviteitKaart({
    required this.titel,
    required this.subtitel,
    required this.icon,
    required this.kleur,
    required this.onTap,
  });

  final String titel;
  final String subtitel;
  final IconData icon;
  final Color kleur;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.pastelKaart,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: kleur.withValues(alpha: 0.3), width: 2),
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: kleur.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, size: 28, color: kleur),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titel,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: kleur,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      subtitel,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: kleur, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
