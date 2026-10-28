import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class AIService {
  GenerativeModel? _model;

  AIService() {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey != null && apiKey.isNotEmpty) {
      _model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: apiKey,
      );
    }
  }

  Future<String> sendMessage(String prompt) async {
    if (_model == null) {
      return 'Грешка: Не е намерен валиден API ключ за Gemini.';
    }

    try {
      final response = await _model!.generateContent([Content.text(prompt)]);
      return response.text ?? 'Няма върнат отговор от AI.';
    } catch (e) {
      return 'Грешка при комуникацията с AI: $e';
    }
  }
}