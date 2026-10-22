# solar-stack-tower-flutter — Stack Tower Game Built with Flutter & the Flame Engine

A one-tap **tower-stacking game** for mobile, built with **Flutter** and the **Flame game engine**. Blocks slide across the screen — tap to drop them onto the tower, stack as high as you can, and try not to let the overhang trim your tower away.

The game is fully self-contained in Dart: the core game lives in `lib/stack_game.dart`, with dedicated folders for game components, managers, and UI overlays (menus/HUD). It includes sound effects via Flame Audio, local persistence for game data such as high scores, and AdMob integration.

## Features

- **Flame-powered gameplay** — the game loop and rendering run on the Flame engine (^1.37.0)
- **Classic stack-tower mechanics** — time your taps to land sliding blocks and build the tallest tower you can
- **Sound effects & audio** — Flame Audio (`flame_audio`) with bundled audio assets in `assets/audio/`, managed through an audio manager
- **Local persistence** — `shared_preferences` stores game data such as high scores between sessions
- **AdMob integration** — Google Mobile Ads SDK (`google_mobile_ads`) built in
- **Organized codebase** — `components/`, `game/`, `managers/`, and `overlays/` separate gameplay, state management, and UI
- **Custom app icon** — generated with flutter_launcher_icons

## Tech Stack

- Flutter + Dart (SDK ^3.12.1)
- Flame ^1.37.0 (game engine)
- flame_audio, shared_preferences, google_mobile_ads
- Material Design UI

## Project Structure

```
lib/
├── main.dart          # App entry point
├── stack_game.dart    # Core game class and logic
├── components/        # Game components
├── game/              # Game code
├── managers/          # Managers (audio, game state, …)
└── overlays/          # Menu / HUD overlays
```

## Getting Started

### Prerequisites

- Flutter SDK (with Dart SDK ^3.12.1)
- A device or emulator (Android/iOS)

### Run the game

```bash
git clone https://github.com/sh00von/solar-stack-tower-flutter.git
cd solar-stack-tower-flutter
flutter pub get
flutter run
```

---

⭐ Enjoy stacking? Star the repo — feedback, issues, and pull requests are welcome!
