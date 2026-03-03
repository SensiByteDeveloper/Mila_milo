import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Tellen & Cijfers: Rekenen module.
/// Hub voor reken-activiteiten.
class TellenCijfersScreen extends StatelessWidget {
  const TellenCijfersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tellen & Cijfers'),
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
                'Rekenen',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppTheme.medeklinkerRood,
                    ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Center(
                  child: Text(
                    'Kies een activiteit om te beginnen.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppTheme.tekstZacht,
                        ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
