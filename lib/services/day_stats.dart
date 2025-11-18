import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mob_edu/models/day.dart';
import 'package:mob_edu/config.dart';
import 'user_service.dart';

class ApiService {
  static const String baseUrlday = '$baseUrl/api';

  static Future<int?> _getUserId() async {
    return await UserService.getUserId();
  }

  static Future<List<DayEntry>> getEntries(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final userId = await _getUserId();
      if (userId == null) {
        throw Exception('User not logged in');
      }

      final startStr = startDate.toIso8601String().split('T')[0];
      final endStr = endDate.toIso8601String().split('T')[0];

      print('Fetching entries from $startStr to $endStr for user $userId');

      final response = await http.get(
        Uri.parse(
          '$baseUrlday/entries?user_id=$userId&start=$startStr&end=$endStr',
        ),
      );

      print('Get entries response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print('Received ${data.length} entries');
        return data.map((json) => DayEntry.fromJson(json)).toList();
      } else {
        print('Error response: ${response.body}');
        throw Exception('Failed to load entries: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception in getEntries: $e');
      rethrow;
    }
  }

  static Future<DayEntry?> getEntryForDate(DateTime date) async {
    try {
      final userId = await _getUserId();
      if (userId == null) {
        throw Exception('User not logged in');
      }

      final dateStr = date.toIso8601String().split('T')[0];
      print('Fetching entry for $dateStr for user $userId');

      final response = await http.get(
        Uri.parse('$baseUrlday/entries/$dateStr?user_id=$userId'),
      );

      print('Get entry response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        print('Entry data: $jsonData');
        return DayEntry.fromJson(jsonData);
      } else if (response.statusCode == 404) {
        print('No entry found for $dateStr');
        return null;
      } else {
        print('Error response: ${response.body}');
        throw Exception('Failed to load entry: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception in getEntryForDate: $e');
      rethrow;
    }
  }

  static Future<DayEntry> updateMoodValue(
    DateTime date,
    String moodType,
    int value,
  ) async {
    try {
      final userId = await _getUserId();
      if (userId == null) {
        throw Exception('User not logged in');
      }

      final dateStr = date.toIso8601String().split('T')[0];

      print(
        'Updating mood: date=$dateStr, type=$moodType, value=$value, user=$userId',
      );

      final requestBody = {
        'mood_type': moodType,
        'value': value,
        'user_id': userId,
      };

      print('Request body: ${json.encode(requestBody)}');

      final response = await http.patch(
        Uri.parse('$baseUrlday/entries/$dateStr/mood'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );

      print('Update mood response: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        print('Updated entry: $jsonData');
        return DayEntry.fromJson(jsonData);
      } else {
        final errorBody = response.body;
        print('Error updating mood: $errorBody');
        throw Exception(
          'Failed to update mood: ${response.statusCode} - $errorBody',
        );
      }
    } catch (e) {
      print('Exception in updateMoodValue: $e');
      rethrow;
    }
  }

  static Future<void> updateDiaryNote(DateTime date, String note) async {
    try {
      final userId = await _getUserId();
      if (userId == null) {
        throw Exception('User not logged in');
      }

      final dateStr = date.toIso8601String().split('T')[0];

      print(
        'Updating diary: date=$dateStr, note length=${note.length}, user=$userId',
      );

      final requestBody = {'diary_note': note, 'user_id': userId};

      final response = await http.patch(
        Uri.parse('$baseUrlday/entries/$dateStr/diary'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );

      print('Update diary response: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode != 200) {
        final errorBody = response.body;
        print('Error updating diary: $errorBody');
        throw Exception(
          'Failed to update diary: ${response.statusCode} - $errorBody',
        );
      }

      print('✅ Diary updated successfully');
    } catch (e) {
      print('Exception in updateDiaryNote: $e');
      rethrow;
    }
  }
}
