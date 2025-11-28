import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mob_edu/config.dart';

class UserService {
  static const String baseUrluser = '$baseUrl/user';

  static const String _userDataKey = 'user_data';

  static Future<Map<String, dynamic>?> fetchUserData(String email) async {
    try {
      final encodedEmail = Uri.encodeComponent(email);
      final url = Uri.parse('$baseUrluser?email=$encodedEmail');

      print('🔄 Fetching user data from: $url');

      final response = await http
          .get(url, headers: {'Content-Type': 'application/json'})
          .timeout(
            Duration(seconds: 10),
            onTimeout: () => throw Exception('Request timed out'),
          );

      print('📡 Response status: ${response.statusCode}');
      print('📡 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;

        data['email'] = email;
        data['is_premium'] = data['is_premium'] ?? 0;

        return data;
      }

      return null;
    } catch (e) {
      print('❌ Error fetching user data: $e');
      return null;
    }
  }

  static Future<void> saveUserData(Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(data);
      await prefs.setString(_userDataKey, jsonString);
      print('💾 User data saved to SharedPreferences');
    } catch (e) {
      print('❌ Error saving user data: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>?> loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_userDataKey);

      if (jsonString == null || jsonString.isEmpty) {
        print('📁 No user data found in SharedPreferences');
        return null;
      }

      final data = jsonDecode(jsonString) as Map<String, dynamic>;
      print(
        '📁 Loaded user data from SharedPreferences: ${data['name']} ${data['surname']}',
      );
      return data;
    } catch (e) {
      print('❌ Error reading user data: $e');
      return null;
    }
  }

  static Future<void> clearUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userDataKey);
      print('🗑️ User data cleared');
    } catch (e) {
      print('❌ Error clearing user data: $e');
      rethrow;
    }
  }

  static Future<int?> getUserId() async {
    try {
      final userData = await loadUserData();
      if (userData != null && userData.containsKey('id')) {
        return userData['id'] as int;
      }
      print('⚠️ User ID not found in stored data');
      return null;
    } catch (e) {
      print('❌ Error getting user ID: $e');
      return null;
    }
  }

  static Future<bool> hasUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey(_userDataKey);
    } catch (e) {
      return false;
    }
  }
}
