enum HistoryTopic {
  israel,
  us,
  rome,
  greece,
  evolution;

  String get displayName {
    switch (this) {
      case HistoryTopic.israel:
        return 'Israel';
      case HistoryTopic.us:
        return 'United States';
      case HistoryTopic.rome:
        return 'Rome';
      case HistoryTopic.greece:
        return 'Greece';
      case HistoryTopic.evolution:
        return 'Evolution';
    }
  }

  String get assetPath {
    switch (this) {
      case HistoryTopic.israel:
        return 'assets/data/israel.json';
      case HistoryTopic.us:
        return 'assets/data/us.json';
      case HistoryTopic.rome:
        return 'assets/data/rome.json';
      case HistoryTopic.greece:
        return 'assets/data/greece.json';
      case HistoryTopic.evolution:
        return 'assets/data/evolution.json';
    }
  }
}

