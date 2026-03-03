# Web-app deployen naar GitHub Pages

Deze Flutter-app kan als webapp worden gespeeld in de browser via GitHub Pages.

## Automatische deploy

1. **GitHub Pages inschakelen**
   - Ga naar je repository op GitHub
   - **Settings** → **Pages**
   - Bij "Build and deployment" kies **GitHub Actions**

2. **Push naar main/master**
   - Bij elke push naar `main` of `master` wordt de webapp automatisch gebouwd en gedeployed
   - De app is bereikbaar op: `https://<jouw-username>.github.io/<repository-naam>/`

## Lokaal testen

```bash
flutter pub get
flutter run -d chrome
```

Of voor een productie-build:

```bash
flutter build web --base-href "/"
flutter run -d web-server --web-port=8080
```

## Let op

- **Spraak (TTS)**: In de browser werkt tekst-naar-spraak via de Web Speech API. De eerste spraak vereist vaak een gebruikersactie (klik) vanwege browser-beveiliging.
- **Opslag**: Voortgang wordt opgeslagen in `localStorage` van de browser.
