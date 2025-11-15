import 'dart:convert';
import 'package:http/http.dart' as http;

class QuoteService {
  static const String baseUrl =
      "https://mind-tracker.onrender.com/mental-health-quote";

  Future<Map<String, String>> getMotivationalQuote() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return {"quote": data["quote"], "author": data["author"]};
    } else {
      throw Exception("Failed to load quote");
    }
  }
}
