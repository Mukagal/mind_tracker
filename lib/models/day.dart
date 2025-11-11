class DayEntry {
  final String id;
  final DateTime date;
  final int? morningMood;
  final int? dayMood;
  final int? eveningMood;
  final int? nightMood;
  final String? diaryNote;
  final DateTime createdAt;
  final DateTime updatedAt;

  DayEntry({
    required this.id,
    required this.date,
    this.morningMood,
    this.dayMood,
    this.eveningMood,
    this.nightMood,
    this.diaryNote,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DayEntry.fromJson(Map<String, dynamic> json) {
    return DayEntry(
      id: json['id'].toString(),
      date: DateTime.parse(json['date']),
      morningMood: json['morning_mood'],
      dayMood: json['day_mood'],
      eveningMood: json['evening_mood'],
      nightMood: json['night_mood'],
      diaryNote: json['diary_note'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String().split('T')[0],
      'morning_mood': morningMood,
      'day_mood': dayMood,
      'evening_mood': eveningMood,
      'night_mood': nightMood,
      'diary_note': diaryNote,
    };
  }

  double? get averageMood {
    final moods = [
      morningMood,
      dayMood,
      eveningMood,
      nightMood,
    ].whereType<double>().toList();

    if (moods.isEmpty) return null;
    final total = moods.fold(0.0, (a, b) => a + b);
    return total / moods.length;
  }
}
