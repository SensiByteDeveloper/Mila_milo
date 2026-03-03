import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/player_profile.dart';
import '../providers/player_provider.dart';
import '../providers/progress_provider.dart';
import '../theme/app_theme.dart';

/// Instellingen voor ouders (na Parent Gate).
/// Reset voortgang, leerjaar instellen. Stabiele terug-navigatie.
class OuderInstellingenScreen extends ConsumerStatefulWidget {
  const OuderInstellingenScreen({super.key});

  @override
  ConsumerState<OuderInstellingenScreen> createState() =>
      _OuderInstellingenScreenState();
}

class _OuderInstellingenScreenState extends ConsumerState<OuderInstellingenScreen> {
  String? _geselecteerdLeerjaar; // Lokaal gekozen, nog niet opgeslagen

  String _huidigLeerjaar(PlayerProfile? p) {
    if (p == null || !PlayerProfile.leerjaren.contains(p.leerjaar)) {
      return PlayerProfile.leerjaren.first;
    }
    return p.leerjaar;
  }

  bool get _heeftWijziging {
    final profile = ref.read(playerProfileProvider);
    final huidig = _huidigLeerjaar(profile);
    final gekozen = _geselecteerdLeerjaar ?? huidig;
    return gekozen != huidig;
  }

  void _opslaanEnTerug() {
    final profile = ref.read(playerProfileProvider);
    if (profile == null) return;
    final leerjaar = _geselecteerdLeerjaar ?? _huidigLeerjaar(profile);
    ref.read(playerProfileProvider.notifier).setProfile(
          profile.copyWith(leerjaar: leerjaar),
        );
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _resetVoortgang() async {
    final bevestig = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Voortgang wissen?'),
        content: const Text(
          'Weet je zeker dat je alle voortgang wilt wissen? '
          'De groeiende tuin wordt gereset.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Annuleren'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.medeklinkerRood,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Wissen'),
          ),
        ],
      ),
    );
    if (bevestig == true && mounted) {
      await ref.read(gameProgressProvider.notifier).reset();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Voortgang gewist')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(playerProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Instellingen'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.maybePop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Ouderinstellingen',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: AppTheme.klinkerBlauw,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // Advies
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.klinkerBlauw.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.klinkerBlauw.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.lightbulb_outline,
                                color: AppTheme.klinkerBlauw, size: 22),
                            const SizedBox(width: 8),
                            Text(
                              'Advies',
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(
                                    color: AppTheme.klinkerBlauw,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Het is aan te bevelen dat een kind begint op beginner. '
                          'Ze krijgen telkens setjes van 7 woorden en 7 rekensommen. '
                          'Zodra ze beide 20 keer hebben gedaan, gaan ze sowieso automatisch door naar gevorderd.\n\n'
                          'Na elke serie van 7 maken ze voortgang. Nadat ze een serie van 7 hebben afgerond navigeren ze automatisch naar hun schatkist, '
                          'waar ze hun zonnebloem of appelboom een klein stukje zien groeien. Elke 1/20 stap toont visueel voortgang.',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.tekstDonker,
                                height: 1.4,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Kies moeilijkheid
                  Text(
                    'Kies moeilijkheid',
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _geselecteerdLeerjaar ??
                        _huidigLeerjaar(profile),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    items: PlayerProfile.leerjaren
                        .map((j) => DropdownMenuItem(
                              value: j,
                              child: Text(
                                PlayerProfile.niveauLabels[j] ?? j,
                                style: const TextStyle(fontSize: 13),
                              ),
                            ))
                        .toList(),
                    onChanged: profile != null
                        ? (value) {
                            if (value != null) {
                              setState(() => _geselecteerdLeerjaar = value);
                            }
                          }
                        : null,
                  ),
                  if (_heeftWijziging) ...[
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: _opslaanEnTerug,
                      icon: const Icon(Icons.save),
                      label: const Text('Opslaan'),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTheme.klinkerBlauw,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        minimumSize: const Size(double.infinity, 52),
                      ),
                    ),
                  ],
                  const SizedBox(height: 32),

                  // Reset alle voortgang (grote rode knop)
                  FilledButton.icon(
                    onPressed: _resetVoortgang,
                    icon: const Icon(Icons.delete_forever, size: 28),
                    label: const Text('Reset alle voortgang'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.medeklinkerRood,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      minimumSize: const Size(double.infinity, 56),
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
