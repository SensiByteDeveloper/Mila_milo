import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'providers/player_provider.dart';
import 'screens/dashboard_screen.dart';
import 'screens/onboarding_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('nl_NL', null);
  runApp(
    const ProviderScope(
      child: MilaMiloApp(),
    ),
  );
}

class MilaMiloApp extends ConsumerWidget {
  const MilaMiloApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Mila & Milo',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('nl', 'NL'),
        Locale('en'),
      ],
      locale: const Locale('nl', 'NL'),
      theme: AppTheme.lightTheme.copyWith(
        textTheme: GoogleFonts.nunitoTextTheme(AppTheme.lightTheme.textTheme),
      ),
      home: const _HomeRouter(),
    );
  }
}

class _HomeRouter extends ConsumerWidget {
  const _HomeRouter();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(playerProfileProvider);

    if (profile == null) {
      return const OnboardingScreen();
    }
    return const DashboardScreen();
  }
}
