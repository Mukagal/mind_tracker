import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mob_edu/models/insights.dart';
import 'package:mob_edu/config.dart';

class InsightsService {
  static const String baseUrlins = '$baseUrl/api';

  Future<List<Insight>> getInsightsForDate(DateTime date) async {
    try {
      final dateString =
          "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

      final response = await http
          .get(
            Uri.parse('$baseUrlins/insights/$dateString'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Insight.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load insights: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching insights: $e');
      return _getMockInsights(date);
    }
  }

  Future<Insight> getInsightById(int id) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrlins/insight/$id'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return Insight.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load insight: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching insight: $e');
      rethrow;
    }
  }

  List<Insight> _getMockInsights(DateTime date) {
    final dateString =
        "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

    return [
      Insight(
        id: 1,
        title: 'Managing Daily Stress',
        description:
            'Learn effective techniques to manage stress in your daily life.',
        category: 'Stress Management',
        date: dateString,
        fullContent:
            'Stress is a natural response to challenging situations. Here are evidence-based techniques: 1) Practice deep breathing for 5 minutes daily. 2) Engage in regular physical activity. 3) Maintain a consistent sleep schedule. 4) Connect with supportive friends and family. 5) Set realistic goals and priorities.',
      ),
      Insight(
        id: 2,
        title: 'Better Sleep Hygiene',
        description:
            'Discover how to improve your sleep quality through proven practices.',
        category: 'Sleep & Wellbeing',
        date: dateString,
        fullContent:
            'Quality sleep is essential for mental health. Key practices include: keeping a regular sleep schedule, creating a relaxing bedtime routine, making your bedroom comfortable and cool, avoiding caffeine and screens before bed, and getting regular exercise during the day.',
      ),
      Insight(
        id: 3,
        title: 'Mindfulness for Beginners',
        description:
            'An introduction to mindfulness meditation and its benefits.',
        category: 'Mindfulness',
        date: dateString,
        fullContent:
            'Mindfulness means paying attention to the present moment without judgment. Start with just 5 minutes daily: find a quiet space, focus on your breath, notice when your mind wanders, and gently return attention to breathing. Regular practice can reduce anxiety and improve emotional wellbeing.',
      ),
    ];
  }
}
