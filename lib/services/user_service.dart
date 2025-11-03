import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class UserService {
  static Future<Map<String, dynamic>?> fetchUserData(String email) async {
    final url = Uri.parse('http://<your-server>/user?email=$email');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      print('Failed to fetch user data: ${response.body}');
      return null;
    }
  }

  static Future<File> _getUserFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/user.json');
  }

  static Future<void> saveUserData(Map<String, dynamic> data) async {
    final file = await _getUserFile();
    await file.writeAsString(jsonEncode(data));
  }

  static Future<Map<String, dynamic>?> loadUserData() async {
    final file = await _getUserFile();
    if (!await file.exists()) return null;

    try {
      final content = await file.readAsString();
      return jsonDecode(content);
    } catch (e) {
      print('Error reading user file: $e');
      return null;
    }
  }

  static Future<void> clearUserData() async {
    final file = await _getUserFile();
    if (await file.exists()) await file.delete();
  }
}
