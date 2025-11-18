import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mob_edu/config.dart';

class QuoteService {
  Future<Map<String, String>> getDailyQuote(DateTime date) async {
    final formatted =
        "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    final url = "$baseUrl/mental-health-quote/$formatted";

    print("🔍 Requesting: $url");

    final response = await http.get(Uri.parse(url));

    print("📡 Status: ${response.statusCode}");
    print("📄 Body: ${response.body}");

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return {"quote": data["quote"], "author": data["author"] ?? ""};
    } else {
      throw Exception(
        "Failed to load quote: ${response.statusCode} - ${response.body}",
      );
    }
  }
}
