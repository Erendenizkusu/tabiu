# Tabiu — real-time multiplayer Taboo

A party word-guessing game (**Taboo**) with **live multiplayer rooms**. One player describes
the secret word without using any of its forbidden "taboo" words; teammates race to guess it
before the timer runs out, while the opposing team watches for slips — all synchronized across
devices in real time.

## Tech

- **Flutter** (Android · iOS · Web)
- **Firebase** — Realtime Database for live room/round state, Authentication
- Feature-first architecture:

```
lib/
├── app/        # app shell, routing, theming
├── core/       # shared utilities, constants
├── data/       # Firebase repositories & models
├── features/   # game, room, lobby features
├── widgets/    # reusable UI components
└── main.dart
```

## Getting started

**Prerequisites:** Flutter SDK, a Firebase project.

```bash
flutter pub get
flutterfire configure     # regenerate firebase_options.dart for your own project
flutter run
```

> The Firebase config (`google-services.json`, `firebase_options.dart`) ships in the client
> by design and is safe to be public; security is enforced by **Firebase Realtime Database
> rules**, so make sure yours are locked down (not left in test mode).

## Screenshots

_Coming soon._

## Tech stack

`Flutter` · `Dart` · `Firebase Realtime Database` · `Firebase Auth`
