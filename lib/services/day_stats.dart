import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mob_edu/models/day.dart';

class ApiService {
  static const String baseUrl = 'https://mind-tracker.onrender.com/api';

  static Future<List<DayEntry>> getEntries(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/entries?start=${startDate.toIso8601String().split('T')[0]}&end=${endDate.toIso8601String().split('T')[0]}',
      ),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => DayEntry.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load entries');
    }
  }

  static Future<DayEntry?> getEntryForDate(DateTime date) async {
    final dateStr = date.toIso8601String().split('T')[0];
    final response = await http.get(Uri.parse('$baseUrl/entries/$dateStr'));

    if (response.statusCode == 200) {
      return DayEntry.fromJson(json.decode(response.body));
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception('Failed to load entry');
    }
  }

  static Future<DayEntry> updateMoodValue(
    DateTime date,
    String moodType,
    int value,
  ) async {
    final dateStr = date.toIso8601String().split('T')[0];
    final response = await http.patch(
      Uri.parse('$baseUrl/entries/$dateStr/mood'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'mood_type': moodType, 'value': value}),
    );

    if (response.statusCode == 200) {
      return DayEntry.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update mood value');
    }
  }

  static Future<void> updateDiaryNote(DateTime date, String note) async {
    final dateStr = date.toIso8601String().split('T')[0];
    final response = await http.patch(
      Uri.parse('$baseUrl/entries/$dateStr/diary'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'diary_note': note}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update diary note');
    }
  }
}
