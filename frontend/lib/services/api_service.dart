import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/analysis_result.dart';

class ApiService {
  // Поставете вашия API ключ от Google AI Studio тук
  static const String _apiKey = 'YOUR_API_KEY_HERE';

  static final GenerativeModel _model = GenerativeModel(
    model: 'gemini-3.8-flash',
    apiKey: _apiKey,
  );

  static Future<AnalysisResult> analyzeText(String text) async {
    try {
      final prompt = '''
Вие сте "Слово AI" – експерт по български език.
Анализирайте следния текст за правописни, граматични и пунктуационни грешки:

"$text"

Върнете отговора ЕДИНСТВЕНО като валиден JSON обект в следния формат без допълнителен маркдаун или текстови пояснения:
{
  "correctedText": "коригираният текст тук",
  "explanations": ["обяснение 1", "обяснение 2"]
},
''';

      final response = await _model.generateContent([Content.text(prompt)]);
      final rawText = response.text ?? '{}';

      final cleanJson = rawText
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();

      final data = jsonDecode(cleanJson);
      return AnalysisResult.fromJson(data);
    } catch (e) {
      throw Exception('Грешка при връзка с AI сервиза: $e');
    }
  }
}