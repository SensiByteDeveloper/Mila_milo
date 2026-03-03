import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/player_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/avatar_display.dart';

/// Scherm om de avatar te wijzigen: Mila/Milo (hamster) of Mila/Milo (kat).
class CharacterChoiceScreen extends ConsumerWidget {
  const CharacterChoiceScreen({super.key});

  static const List<Map<String, String>> _vriendjes = [
    {'id': 'Mila', 'label': 'Mila', 'dier': 'hamster'},
    {'id': 'Milo', 'label': 'Milo', 'dier': 'hamster'},
    {'id': 'Mila_kat', 'label': 'Mila', 'dier': 'kat'},
    {'id': 'Milo_kat', 'label': 'Milo', 'dier': 'kat'},
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(playerProfileProvider);
    if (profile == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kies je vriendje'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
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
                children: [
                  Text(
                    'Wie wil je vandaag zijn?',
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.72,
                    children: _vriendjes.map((v) {
                      final id = v['id']!;
                      final label = v['label']!;
                      final dier = v['dier']!;
                      final gekozen = profile.gekozenAvatar == id;
                      return _AvatarKeuze(
                        avatarId: id,
                        label: label,
                        dierSoort: dier,
                        gekozen: gekozen,
                        onTap: () async {
                          await ref.read(playerProfileProvider.notifier).setProfile(
                                profile.copyWith(gekozenAvatar: id),
                              );
                          if (context.mounted) {
                            Navigator.of(context).pop();
                          }
                        },
                      );
                    }).toList(),
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

class _AvatarKeuze extends StatelessWidget {
  const _AvatarKeuze({
    required this.avatarId,
    required this.label,
    required this.dierSoort,
    required this.gekozen,
    required this.onTap,
  });

  final String avatarId;
  final String label;
  final String dierSoort;
  final bool gekozen;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: gekozen
              ? AppTheme.klinkerBlauw.withValues(alpha: 0.2)
              : AppTheme.pastelKaart,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: gekozen ? AppTheme.klinkerBlauw : Colors.grey.shade300,
            width: gekozen ? 3 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AvatarDisplay(
              avatarNaam: avatarId.replaceAll('_kat', ''),
              grootte: 72,
              dierSoort: dierSoort,
              volledig: true,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: gekozen ? FontWeight.bold : FontWeight.normal,
                color: AppTheme.tekstDonker,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
