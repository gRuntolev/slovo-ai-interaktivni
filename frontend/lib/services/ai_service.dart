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

  /// Изпраща запитване към AI и връща обработен/форматиран отговор
  Future<String> sendMessage(String prompt) async {
    if (_model == null) {
      return 'Грешка: Не е намерен валиден API ключ за Gemini.';
    }

    try {
      final response = await _model!.generateContent([Content.text(prompt)]);
      final rawText = response.text ?? '';
      return formatResponse(rawText);
    } catch (e) {
      return 'Грешка при комуникацията с AI: $e';
    }
  }

  /// Почиства и форматира суровия текст от AI отговора
  String formatResponse(String rawText) {
    if (rawText.isEmpty) {
      return 'Няма върнат отговор от AI.';
    }

    // Изчистване на излишни празни редове и интервали в началото/края
    String formatted = rawText.trim();

    // Премахване на повече от два последователни празни реда
    formatted = formatted.replaceAll(RegExp(r'\n{3,}'), '\n\n');

    return formatted;
  }
}