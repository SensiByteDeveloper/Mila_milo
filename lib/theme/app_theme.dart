import 'package:flutter/material.dart';

/// Montessori-kleuren: Klinkers = Blauw, Medeklinkers = Rood.
/// Zachte pastel-achtergronden en grote, tablet-vriendelijke knoppen.
class AppTheme {
  // Montessori kleuren
  static const Color klinkerBlauw = Color(0xFF4A90D9);
  static const Color medeklinkerRood = Color(0xFFD94A4A);
  static const Color tellenGroen = Color(0xFF4CAF50);
  static const Color letterTuinGeel = Color(0xFFF9A825);

  // Pastel achtergronden
  static const Color pastelAchtergrond = Color(0xFFF5F0E8);
  static const Color pastelKaart = Color(0xFFFFFBF5);
  static const Color pastelAccent = Color(0xFFE8DCC8);

  // Tekst
  static const Color tekstDonker = Color(0xFF3D3A35);
  static const Color tekstZacht = Color(0xFF6B6560);

  // Mila (meisje) en Milo (jongetje) accenten
  static const Color milaRoze = Color(0xFFE8B4BC);
  static const Color miloBlauw = Color(0xFFB4C8E8);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: klinkerBlauw,
        brightness: Brightness.light,
        primary: klinkerBlauw,
        secondary: medeklinkerRood,
        surface: pastelAchtergrond,
        onSurface: tekstDonker,
      ),
      scaffoldBackgroundColor: pastelAchtergrond,
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: tekstDonker,
        ),
        headlineMedium: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: tekstDonker,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: tekstDonker,
        ),
        bodyLarge: TextStyle(
          fontSize: 18,
          color: tekstDonker,
        ),
        bodyMedium: TextStyle(
          fontSize: 16,
          color: tekstZacht,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(200, 64),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
        ),
      ),
      cardTheme: CardThemeData(
        color: pastelKaart,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        hintStyle: const TextStyle(color: tekstZacht, fontSize: 16),
      ),
    );
  }
}
