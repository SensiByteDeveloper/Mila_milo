import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Toont de gekozen avatar (Mila of Milo) met echte assets.
/// [volledig]: bij true (kat-versies) wordt de afbeelding in zijn geheel getoond,
/// zonder cirkel-crop.
class AvatarDisplay extends StatelessWidget {
  const AvatarDisplay({
    super.key,
    required this.avatarNaam,
    this.grootte = 120,
    this.dierSoort = 'hamster',
    this.volledig = false,
  });

  final String avatarNaam; // 'Mila', 'Milo', 'Mila_kat', 'Milo_kat'
  final double grootte;
  final String dierSoort; // 'hamster' of 'kat' (overschrijft parse van avatarNaam)
  final bool volledig; // true = afbeelding in zijn geheel, geen cirkel

  bool get _isKat => avatarNaam.toLowerCase().endsWith('_kat') || dierSoort == 'kat';
  String get _baseNaam => avatarNaam.toLowerCase().replaceAll('_kat', '');
  String get _effectieveDierSoort =>
      avatarNaam.toLowerCase().endsWith('_kat') ? 'kat' : dierSoort;

  String get _assetPath {
    return 'assets/images/karakters/$_effectieveDierSoort/${_baseNaam}_blij.png';
  }

  static Color _kleurVoorAvatar(String naam) {
    switch (naam.toLowerCase()) {
      case 'mila':
        return AppTheme.milaRoze;
      case 'milo':
        return AppTheme.miloBlauw;
      case 'lomi':
        return Colors.amber.shade300;
      case 'moli':
        return Colors.green.shade300;
      default:
        return AppTheme.milaRoze;
    }
  }

  @override
  Widget build(BuildContext context) {
    final kleur = _kleurVoorAvatar(_baseNaam);
    final toonVolledig = volledig || _isKat;

    if (toonVolledig) {
      return SizedBox(
        width: grootte,
        height: grootte * 1.3,
        child: Image.asset(
          _assetPath,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => Center(
            child: Text(
              '🐹',
              style: TextStyle(fontSize: grootte * 0.5),
            ),
          ),
        ),
      );
    }

    return Container(
      width: grootte,
      height: grootte,
      decoration: BoxDecoration(
        color: kleur.withValues(alpha: 0.3),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.asset(
        _assetPath,
        width: grootte,
        height: grootte,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Center(
          child: Text(
            '🐹',
            style: TextStyle(fontSize: grootte * 0.5),
          ),
        ),
      ),
    );
  }
}
