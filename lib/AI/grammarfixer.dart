import 'dart:convert';

import 'package:http/http.dart' as http;

class GrammarService {
  final String _apikey = '';
  Future<String?> fixGrammar(String text) async {
    if (text.trim().isEmpty) return null;
    try {
      final url = Uri.parse('https://api.openai.com/v1/chat/completions');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apikey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {
              'role': 'system',
              "content":
                  "You are a helpful grammar assistant. Correct the grammar, spelling, and punctuation of the user's text. Do not change the meaning. Return ONLY the corrected text, nothing else.",
            },
            {'role': 'user', 'content': text},
          ],
          'max_tokens': 100,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'].trim();
      } else {
        print("OpenAI Error: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Error fixing grammar: $e");
      return null;
    }
  }
}
