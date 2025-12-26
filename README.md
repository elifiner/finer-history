# Flashback Timeline Game

A fun, educational history timeline game built with Vue.js. Players drag historical events to their correct chronological positions on a timeline.

## Features

- **Drag and Drop**: Intuitive drag-and-drop interface for placing events
- **Multiple Rounds**: Play multiple rounds of 10 events each
- **Scoring System**: Track correct and incorrect placements across rounds
- **Immediate Feedback**: Visual feedback for correct/incorrect placements
- **Customizable Events**: Easy to replace events by editing `src/data/events.json`

## Getting Started

### Prerequisites

- Node.js (v16 or higher)
- npm or yarn

### Installation

1. Install dependencies:
```bash
npm install
```

2. Start the development server:
```bash
npm run dev
```

3. Open your browser to the URL shown in the terminal (typically `http://localhost:5173`)

### Building for Production

```bash
npm run build
```

The built files will be in the `dist` directory.

## Customizing Events

To use your own set of historical events, edit `src/data/events.json`. Each event should have:

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
├── src/
│   ├── components/
│   │   ├── GameBoard.vue      # Main game logic
│   │   ├── Timeline.vue        # Timeline visualization
│   │   ├── EventCard.vue       # Event card component
│   │   └── ScoreSummary.vue    # Round completion screen
│   ├── data/
│   │   └── events.json         # Historical events data
│   ├── styles/
│   │   └── main.css            # Global styles
│   ├── App.vue
│   └── main.js
├── index.html
├── package.json
└── vite.config.js
```

## Technologies Used

- Vue 3 (Composition API)
- Vite
- HTML5 Drag and Drop API
- CSS3 Animations

## License

MIT

