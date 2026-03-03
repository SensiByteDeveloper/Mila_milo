# Overzicht audio-fragmenten voor opname

Alle audio-fragmenten die voor de Mila & Milo app moeten worden opgenomen.

---

## 1. Schatkist (Groeiende Tuin)

**Wanneer:** Na afronden van een setje van 7, wanneer de speler naar de schatkist navigeert. Per stap (1 t/m 20) een eigen fragment.

| # | Bestand | Spreker | Tekst |
|---|---------|---------|-------|
| 1 | `assets/audio/schatkist/stap_01.mp3` | Mama Mali | "Ja goedzo, je eerste stap. Een zaadje wordt geplant, ga door om je plantje/ boompje te laten groeien." |
| 2 | `assets/audio/schatkist/stap_02.mp3` | Mama Mali | *[Tekst voor stap 2 – bijv. over eerste groei]* |
| 3 | `assets/audio/schatkist/stap_03.mp3` | Mama Mali | *[Tekst voor stap 3]* |
| 4 | `assets/audio/schatkist/stap_04.mp3` | Mama Mali | *[Tekst voor stap 4]* |
| 5 | `assets/audio/schatkist/stap_05.mp3` | Mama Mali | *[Tekst voor stap 5]* |
| 6 | `assets/audio/schatkist/stap_06.mp3` | Mama Mali | *[Tekst voor stap 6]* |
| 7 | `assets/audio/schatkist/stap_07.mp3` | Mama Mali | *[Tekst voor stap 7]* |
| 8 | `assets/audio/schatkist/stap_08.mp3` | Mama Mali | *[Tekst voor stap 8]* |
| 9 | `assets/audio/schatkist/stap_09.mp3` | Mama Mali | *[Tekst voor stap 9]* |
| 10 | `assets/audio/schatkist/stap_10.mp3` | Mama Mali | *[Tekst voor stap 10 – halverwege]* |
| 11 | `assets/audio/schatkist/stap_11.mp3` | Mama Mali | *[Tekst voor stap 11]* |
| 12 | `assets/audio/schatkist/stap_12.mp3` | Mama Mali | *[Tekst voor stap 12]* |
| 13 | `assets/audio/schatkist/stap_13.mp3` | Mama Mali | *[Tekst voor stap 13]* |
| 14 | `assets/audio/schatkist/stap_14.mp3` | Mama Mali | *[Tekst voor stap 14]* |
| 15 | `assets/audio/schatkist/stap_15.mp3` | Mama Mali | *[Tekst voor stap 15]* |
| 16 | `assets/audio/schatkist/stap_16.mp3` | Mama Mali | *[Tekst voor stap 16]* |
| 17 | `assets/audio/schatkist/stap_17.mp3` | Mama Mali | *[Tekst voor stap 17]* |
| 18 | `assets/audio/schatkist/stap_18.mp3` | Mama Mali | *[Tekst voor stap 18]* |
| 19 | `assets/audio/schatkist/stap_19.mp3` | Mama Mali | *[Tekst voor stap 19 – bijna klaar]* |
| 20 | `assets/audio/schatkist/stap_20.mp3` | Mama Mali | *[Tekst voor stap 20 – volle bloei/boom, feest!]* |

---

## 2. Lettertuin (Oma Lomi's Lettertuin)

**Wanneer:** Bij tikken op een letter.

**Huidige situatie:** TTS (Text-to-Speech) spreekt: "Zeg mij maar na... [fonetische klank]"

| # | Bestand | Spreker | Tekst |
|---|---------|---------|-------|
| 2.1 | `assets/audio/lettertuin/intro.mp3` | Oma Lomi | "Zeg mij maar na..." (optioneel, voor eerste keer) |
| 2.2–2.27 | Per letter a–z | Oma Lomi | Alleen de fonetische klank: aa, buh, kuh, duh, ee, fuh, guh, huh, ie, juh, kuh, luh, muh, nuh, oo, puh, kwuh, ruh, sss, tuh, uu, vuh, wuh, ks, ie, zzz |

*Let op:* 26 letters = 26 fragmenten. Momenteel TTS; opname geeft consistentere stem.

---

## 3. Woordspel (Spelen met Woorden)

**Wanneer:** Bij correct gespeld woord (confetti).

| # | Bestand | Spreker | Tekst |
|---|---------|---------|-------|
| 3 | `assets/audio/woorden/goed.mp3` | Mama Mali | "Goed zo!" of "Heel goed!" |

---

## 4. Rekenspel (Tellen & Cijfers)

**Wanneer:** Bij correct antwoord (confetti).

| # | Bestand | Spreker | Tekst |
|---|---------|---------|-------|
| 4 | `assets/audio/rekenen/goed.mp3` | Papa Moli | "Goed zo!" of "Heel goed!" |

---

## 5. Promotiefeest

**Wanneer:** Bij promotie naar Niveau 2 (na 20 setjes van beide taal en rekenen).

| # | Bestand | Spreker | Tekst |
|---|---------|---------|-------|
| 5 | `assets/audio/promotie/gefeliciteerd.mp3` | Mama Mali / Papa Moli | "Gefeliciteerd! Je bent door naar gevorderd!" |

---

## Samenvatting

| Categorie | Aantal fragmenten | Prioriteit |
|-----------|-------------------|------------|
| Schatkist | 20 | Hoog |
| Lettertuin | 26 (of 1 intro + 26) | Medium |
| Woordspel | 1 | Medium |
| Rekenspel | 1 | Medium |
| Promotie | 1 | Laag |
| **Totaal** | **49** (of 50) | |

---

## Technische notities

- **Formaat:** MP3, 44.1 kHz, mono of stereo
- **Mapstructuur:** `assets/audio/[categorie]/[bestand].mp3`
- **Pubspec:** Voeg `assets/audio/` toe aan `flutter.assets` wanneer bestanden beschikbaar zijn
- **Service:** `SchatkistAudioService` in `lib/services/schatkist_audio_service.dart` – implementeer `speelStapBericht(int stap)` voor stap 1–20. Bestanden: `stap_01.mp3` t/m `stap_20.mp3`
