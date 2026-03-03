import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/player_profile.dart';
import '../providers/player_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/avatar_display.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _naamController = TextEditingController();
  DateTime? _geboortedatum;
  String _gekozenAvatar = 'Mila';

  @override
  void dispose() {
    _naamController.dispose();
    super.dispose();
  }

  Future<void> _selecteerDatum(BuildContext context) async {
    final nu = DateTime.now();
    final eersteKeuze = _geboortedatum ??
        DateTime(nu.year - 6, nu.month, nu.day); // ~6 jaar als default

    final picked = await showDatePicker(
      context: context,
      initialDate: eersteKeuze,
      firstDate: DateTime(nu.year - 12, 1, 1),
      lastDate: nu,
      locale: const Locale('nl', 'NL'),
      helpText: 'Wanneer ben je jarig?',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppTheme.klinkerBlauw,
                ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _geboortedatum = picked);
    }
  }

  void _voltooi() {
    final naam = _naamController.text.trim();
    if (naam.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Geef je naam op!'),
          backgroundColor: AppTheme.medeklinkerRood,
        ),
      );
      return;
    }
    if (_geboortedatum == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kies je verjaardag!'),
          backgroundColor: AppTheme.medeklinkerRood,
        ),
      );
      return;
    }

    ref.read(playerProfileProvider.notifier).setProfile(
          PlayerProfile(
            naam: naam,
            geboortedatum: _geboortedatum!,
            gekozenAvatar: _gekozenAvatar,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              Text(
                'Welkom bij Mila & Milo!',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: AppTheme.klinkerBlauw,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Text(
                'Laten we je even kennen.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.tekstZacht,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Naam
              Text(
                'Hoe heet je?',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _naamController,
                decoration: const InputDecoration(
                  hintText: 'Typ je naam...',
                  prefixIcon: Icon(Icons.person_outline, color: AppTheme.klinkerBlauw),
                ),
                textCapitalization: TextCapitalization.words,
                style: const TextStyle(fontSize: 18),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 24),

              // Geboortedatum
              Text(
                'Wanneer ben je jarig?',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () => _selecteerDatum(context),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, color: AppTheme.klinkerBlauw),
                      const SizedBox(width: 16),
                      Text(
                        _geboortedatum != null
                            ? DateFormat('d MMMM yyyy', 'nl_NL').format(_geboortedatum!)
                            : 'Tik om te kiezen',
                        style: TextStyle(
                          fontSize: 16,
                          color: _geboortedatum != null
                              ? AppTheme.tekstDonker
                              : AppTheme.tekstZacht,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Avatar keuze (4 opties: Mila/Milo hamster + Mila/Milo kat)
              Text(
                'Kies je vriendje:',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _AvatarKeuze(
                    avatarId: 'Mila',
                    dierSoort: 'hamster',
                    label: 'Mila',
                    gekozen: _gekozenAvatar == 'Mila',
                    onTap: () => setState(() => _gekozenAvatar = 'Mila'),
                  ),
                  const SizedBox(width: 8),
                  _AvatarKeuze(
                    avatarId: 'Milo',
                    dierSoort: 'hamster',
                    label: 'Milo',
                    gekozen: _gekozenAvatar == 'Milo',
                    onTap: () => setState(() => _gekozenAvatar = 'Milo'),
                  ),
                  const SizedBox(width: 8),
                  _AvatarKeuze(
                    avatarId: 'Mila_kat',
                    dierSoort: 'kat',
                    label: 'Mila',
                    gekozen: _gekozenAvatar == 'Mila_kat',
                    onTap: () => setState(() => _gekozenAvatar = 'Mila_kat'),
                  ),
                  const SizedBox(width: 8),
                  _AvatarKeuze(
                    avatarId: 'Milo_kat',
                    dierSoort: 'kat',
                    label: 'Milo',
                    gekozen: _gekozenAvatar == 'Milo_kat',
                    onTap: () => setState(() => _gekozenAvatar = 'Milo_kat'),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Start knop
              FilledButton(
                onPressed: _voltooi,
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.klinkerBlauw,
                  minimumSize: const Size(double.infinity, 52),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Start met spelen!'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _AvatarKeuze extends StatelessWidget {
  const _AvatarKeuze({
    required this.avatarId,
    required this.dierSoort,
    required this.label,
    required this.gekozen,
    required this.onTap,
  });

  final String avatarId;
  final String dierSoort;
  final String label;
  final bool gekozen;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          decoration: BoxDecoration(
            color: gekozen ? AppTheme.klinkerBlauw.withValues(alpha: 0.2) : AppTheme.pastelKaart,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: gekozen ? AppTheme.klinkerBlauw : Colors.grey.shade300,
              width: gekozen ? 3 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AvatarDisplay(
                avatarNaam: avatarId,
                grootte: 56,
                dierSoort: dierSoort,
                volledig: true,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: gekozen ? FontWeight.bold : FontWeight.normal,
                  color: AppTheme.tekstDonker,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
