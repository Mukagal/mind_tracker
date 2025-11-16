import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mob_edu/config.dart';

class QuoteService {
  Future<Map<String, String>> getDailyQuote(DateTime date) async {
    final formatted = "${date.year}-${date.month}-${date.day}";
    final url = "$baseUrl/mental-health-quote/$formatted";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return {"quote": data["quote"], "author": data["author"] ?? ""};
    } else {
      throw Exception("Failed to load quote");
    }
  }
}
