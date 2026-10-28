import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class AIService {
  GenerativeModel? _model;
  static const int _maxPromptLength = 2000;

  AIService() {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey != null && apiKey.isNotEmpty) {
      _model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: apiKey,
      );
    }
  }

  /// Изпраща запитване към AI с валидация за гранични случаи
  Future<String> sendMessage(String prompt) async {
    // Edge case 1: Проверка за зареден модел / API ключ
    if (_model == null) {
      return 'Грешка: Не е намерен валиден API ключ за Gemini.';
    }

    // Edge case 2: Празен промпт или съдържащ само празни места
    final trimmedPrompt = prompt.trim();
    if (trimmedPrompt.isEmpty) {
      return 'Грешка: Заявката не може да бъде празна.';
    }

    // Edge case 3: Прекалено дълъг текст
    if (trimmedPrompt.length > _maxPromptLength) {
      return 'Грешка: Заявката е твърде дълга (максимум $_maxPromptLength символа).';
    }

    try {
      final response = await _model!.generateContent([Content.text(trimmedPrompt)]);
      final rawText = response.text ?? '';
      return formatResponse(rawText);
    } catch (e) {
      // Edge case 4: Обработка на изключения при мрежови грешки или проблем с API
      return 'Грешка при комуникацията с AI: $e';
    }
  }

  /// Почиства и форматира суровия текст от AI отговора
  String formatResponse(String rawText) {
    if (rawText.isEmpty) {
      return 'Няма върнат отговор от AI.';
    }

    String formatted = rawText.trim();
    formatted = formatted.replaceAll(RegExp(r'\n{3,}'), '\n\n');

    return formatted;
  }
}