# Finer History

A fun, educational history timeline game built with Flutter. Players drag historical events to their correct chronological positions on a timeline.

## Features

- **Drag and Drop**: Intuitive drag-and-drop interface for placing events
- **Multiple Rounds**: Play multiple rounds of 10 events each
- **Scoring System**: Track correct and incorrect placements across rounds
- **Immediate Feedback**: Visual feedback for correct/incorrect placements with smooth animations
- **Customizable Events**: Easy to replace events by editing `assets/data/events.json`
- **Cross-Platform**: Runs on Web and Android (iOS support can be added)

## Getting Started

### Prerequisites

- Flutter SDK (3.9.2 or higher)
- Dart SDK (included with Flutter)

### Installation

1. Install Flutter dependencies:
```bash
flutter pub get
```

2. Run the app:
```bash
# For web
flutter run -d chrome

# For Android
flutter run
```

### Building for Production

```bash
# Build for web
flutter build web

# Build for Android
flutter build apk
```

## Customizing Events

To use your own set of historical events, edit `assets/data/events.json`. Each event should have:

- `year`: The year the event occurred (number)
- `title`: A short title for the event (string)
- `description`: A description of the event (string)

Example:
```json
{
  "year": 1948,
  "title": "Declaration of Independence",
  "description": "David Ben-Gurion declares the establishment of the State of Israel."
}
```

## How to Play

1. Drag the unplaced event card at the top to a position on the timeline
2. Click the "Place here" button to confirm placement
3. If correct, the card locks in place with a green border
4. If incorrect, the card slides to the correct position and highlights green
5. Continue until all 10 events are placed
6. View your score and start the next round

## Project Structure

```
flashback/
├── lib/
│   ├── models/
│   │   ├── event.dart           # Event data model
│   │   └── game_state.dart      # Game state model
│   ├── providers/
│   │   └── game_provider.dart   # Game logic and state management
│   ├── screens/
│   │   └── game_screen.dart     # Main game screen
│   ├── widgets/
│   │   ├── event_card.dart      # Event card widget
│   │   ├── timeline_widget.dart # Timeline visualization
│   │   └── score_summary.dart   # Round completion screen
│   └── main.dart                # App entry point
├── assets/
│   └── data/
│       └── events.json          # Historical events data
├── android/                     # Android platform files
├── web/                         # Web platform files
└── pubspec.yaml                 # Flutter dependencies
```

## Technologies Used

- Flutter (Material Design 3)
- Provider (State Management)
- Dart
- Flutter Drag and Drop API
- Flutter Animations

## License

MIT
