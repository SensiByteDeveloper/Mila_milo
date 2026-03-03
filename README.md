# Mila & Milo

Educatieve app voor kinderen (Groep 2 t/m 6) – Letters, Woorden en Rekenen.

## Fase 1: Architectuur & Onboarding

### Project Setup
- **State management:** Riverpod
- **PlayerProfile:** naam, geboortedatum, gekozenAvatar (Mila of Milo)
- **AgeCalculator:** leeftijd en schoolgroep (peildatum 1 oktober)

### Schermen
1. **Onboarding** – Naam, geboortedatum (kalender), avatar-keuze (Mila/Milo)
2. **Dashboard** – Begroeting met avatar, knoppen voor Letters & Woorden, Tellen & Cijfers, Letter-Tuin van Oma Lomi

### Gimmick
- **HolidayService** – Christelijke feestdagen (Kerst, Pasen, Hemelvaart, Pinksteren) en verjaardag
- Confetti op het dashboard als de speler jarig is

### Styling
- Montessori-kleuren: Klinkers = Blauw, Medeklinkers = Rood
- Zachte pastel-achtergronden, grote tablet-vriendelijke knoppen
- Lettertype: Nunito (via Google Fonts)

## Starten

```bash
# Dependencies installeren
flutter pub get

# Platformbestanden toevoegen (als android/ of ios/ nog ontbreekt)
flutter create . --org com.sensibyte --project-name mila_milo

# App starten
flutter run
```

## Projectstructuur

```
lib/
├── main.dart                 # App entry + routing
├── models/
│   └── player_profile.dart   # Spelerprofiel model
├── providers/
│   └── player_provider.dart  # Riverpod state
├── screens/
│   ├── onboarding_screen.dart
│   └── dashboard_screen.dart
├── services/
│   ├── age_calculator.dart   # Leeftijd & schoolgroep
│   ├── holiday_service.dart  # Feestdagen & verjaardag
│   └── player_storage_service.dart
├── theme/
│   └── app_theme.dart       # Montessori kleuren
└── widgets/
    └── avatar_display.dart  # Mila/Milo avatar
```
