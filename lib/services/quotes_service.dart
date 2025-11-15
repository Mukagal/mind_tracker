import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mob_edu/config.dart';

class QuoteService {
  static const String baseUrlquote = "$baseUrl/mental-health-quote";

  Future<Map<String, String>> getMotivationalQuote() async {
    final response = await http.get(Uri.parse(baseUrlquote));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return {"quote": data["quote"], "author": data["author"]};
    } else {
      throw Exception("Failed to load quote");
    }
  }
}
