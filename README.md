# Solar Stack Tower

A premium isometric 3D tower-building game built with Flutter and the Flame engine. Climb through the cosmos, from Earth to the furthest reaches of the Multiverse, in this hyper-casual stack-building experience.

## Features

- **Isometric Gameplay**: Beautifully hand-drawn isometric blocks with three-face shading and smooth projections.
- **Game Modes**:
  - **Classic**: Start from Earth and see how high you can climb. Pure high-score chasing.
  - **Journey**: Unlock checkpoints at every planet and resume your climb from any discovered world.
- **Cosmic Progression**: Travel through 26 unique zones across 3 Universes (The Sol-Veil, Quantum Realms, and The Multiverse).
- **Power-Ups**:
  - **Slow-Mo**: Calms the pace, allowing for precision placements.
  - **Wide**: Regrows your tower's footprint after a perfect drop.
  - **Magnet**: Automatically snaps the next block for a perfect alignment.
- **Dynamic Feedback**: Rising pitch audio chimes for perfect streaks, screen shakes, and particle effects.
- **Progression System**: Complete auto-advancing missions to earn coins and unlock new cosmic coordinates.
- **Monetization & Persistence**: Integrated AdMob for revives and interstitials, with all progress saved via `shared_preferences`.

## Project Structure

- `lib/game/`: Core game definitions, mission logic, and theme zone configurations.
- `lib/components/`: Isometric block rendering and particle systems.
- `lib/managers/`: Persistence (Score), Audio, and Ad management.
- `lib/overlays/`: Flutter-based UI overlays for menus, HUD, and game-over states.
- `lib/stack_game.dart`: The main Flame game loop and state management.

## Getting Started

### Prerequisites

- Flutter SDK (^3.12.1)
- Dart SDK (^3.12.1)

### Installation

1. Clone the repository.
2. Run `flutter pub get` to fetch dependencies.
3. Ensure you have an Android/iOS emulator or device connected.
4. Run `flutter run`.

## Visual Themes

The game features a sophisticated theme system that smoothly interpolates background gradients and block colors as you transition between planets. Each zone includes specific gameplay modifiers like speed multipliers and power-up spawn biases.

## Credits

Developed as a modern take on the hyper-casual "Stack" genre, optimized for mobile performance and premium visual feel.
