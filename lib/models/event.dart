class Event {
  final String id;
  final int year;
  final String title;
  final String description;
  bool isCorrect;
  bool isIncorrect;
  bool wasIncorrect;

  Event({
    required this.id,
    required this.year,
    required this.title,
    required this.description,
    this.isCorrect = false,
    this.isIncorrect = false,
    this.wasIncorrect = false,
  });

  Event copyWith({
    String? id,
    int? year,
    String? title,
    String? description,
    bool? isCorrect,
    bool? isIncorrect,
    bool? wasIncorrect,
  }) {
    return Event(
      id: id ?? this.id,
      year: year ?? this.year,
      title: title ?? this.title,
      description: description ?? this.description,
      isCorrect: isCorrect ?? this.isCorrect,
      isIncorrect: isIncorrect ?? this.isIncorrect,
      wasIncorrect: wasIncorrect ?? this.wasIncorrect,
    );
  }

  factory Event.fromJson(Map<String, dynamic> json, int index) {
    return Event(
      id: 'event-$index',
      year: json['year'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
    );
  }
}

