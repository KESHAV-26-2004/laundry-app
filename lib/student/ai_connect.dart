import 'package:http/http.dart' as http;
import 'dart:convert';

Future<String> getBotResponse(String userInput,String baseurl) async {
  final url = Uri.parse("$baseurl/get-response");

  final response = await http.post(
    url,
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({"message": userInput}),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data["response"];
  } else {
    return "Bot is unavailable right now.";
  }
}
