import 'dart:math';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Parent Gate: rekensom om te bevestigen dat een volwassene toegang heeft.
/// Alleen voor grote mensen.
class ParentGateDialog extends StatefulWidget {
  const ParentGateDialog({
    super.key,
    required this.onCorrect,
    required this.onCancel,
  });

  final VoidCallback onCorrect;
  final VoidCallback onCancel;

  @override
  State<ParentGateDialog> createState() => _ParentGateDialogState();
}

class _ParentGateDialogState extends State<ParentGateDialog> {
  late int _a;
  late int _b;
  late int _antwoord;
  final _controller = TextEditingController();
  String? _fout;

  @override
  void initState() {
    super.initState();
    _genereerSom();
  }

  void _genereerSom() {
    final r = Random();
    _a = 2 + r.nextInt(8); // 2-9 (enkel cijfer < 10)
    _b = 10 + r.nextInt(11); // 10-20
    _antwoord = _a * _b;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _controleer() {
    final invoer = int.tryParse(_controller.text.trim());
    if (invoer == _antwoord) {
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _fout = 'Dat klopt niet. Probeer het opnieuw.';
        _genereerSom();
        _controller.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Alleen voor grote mensen'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Los deze som op om door te gaan:',
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.tekstZacht,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              '$_a × $_b = ?',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.klinkerBlauw,
                  ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Antwoord',
              errorText: _fout,
              border: const OutlineInputBorder(),
            ),
            onSubmitted: (_) => _controleer(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            widget.onCancel();
            Navigator.of(context).pop(false);
          },
          child: const Text('Annuleren'),
        ),
        FilledButton(
          onPressed: _controleer,
          child: const Text('Controleren'),
        ),
      ],
    );
  }
}
