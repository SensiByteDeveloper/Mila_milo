# Build-instructies – Mila & Milo

## APK voor directe installatie (zelf installeren)

De release-APK staat hier:
```
build/app/outputs/flutter-apk/app-release.apk
```

**Installeren op Android:**
1. Kopieer `app-release.apk` naar je telefoon (USB, e-mail, cloud, enz.).
2. Open het bestand op je telefoon.
3. Sta installatie van onbekende bronnen toe als dat gevraagd wordt.
4. Installeer de app.

**Opnieuw bouwen:**
```bash
flutter build apk --release
```

---

## Play Store publicatie (App Bundle)

Voor de Play Store heb je een **App Bundle** (.aab) nodig, geen APK.

**Bouwen:**
```bash
flutter build appbundle --release
```

Het bestand komt hier:
```
build/app/outputs/bundle/release/app-release.aab
```

**Als de build faalt** met "failed to strip debug symbols":
- Voer `flutter doctor` uit en los eventuele meldingen op.
- Update Android Studio → SDK Manager → NDK en Build-Tools naar de nieuwste versie.
- Dit is een bekend Flutter/NDK-probleem; de APK-build werkt wel.

**Play Console:**
1. Ga naar [Google Play Console](https://play.google.com/console).
2. Maak een app aan (of kies een bestaande).
3. Ga naar **Release** → **Production** (of **Testing**).
4. Maak een nieuwe release aan.
5. Upload `app-release.aab`.
6. Vul de store listing in (beschrijving, screenshots, enz.).
7. Voltooi de release.

---

## Handige commando’s

| Doel | Commando |
|------|----------|
| APK (zelf installeren) | `flutter build apk --release` |
| App Bundle (Play Store) | `flutter build appbundle --release` |
| Debug APK (testen) | `flutter build apk` |
| Dependencies ophalen | `flutter pub get` |

---

## Let op voor publicatie

- **Signing:** Voor release-builds moet je een upload key configureren. Zie `android/key.properties` en `android/app/build.gradle`.
- **Versie:** Pas `version` in `pubspec.yaml` aan voor elke nieuwe release.
- **Privacybeleid:** De Play Store vraagt vaak om een privacybeleid-URL.
