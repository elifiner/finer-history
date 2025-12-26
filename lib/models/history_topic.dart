enum HistoryTopic {
  israel,
  us,
  rome,
  greece;

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
    }
  }
}

