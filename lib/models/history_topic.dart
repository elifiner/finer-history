class HistoryTopic {
  final String id;
  final String displayName;
  final String assetPath;

  HistoryTopic({
    required this.id,
    required this.displayName,
    required this.assetPath,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HistoryTopic &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => displayName;
}
