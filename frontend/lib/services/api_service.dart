import 'dart:convert';
import 'package:firebase_vertexai/firebase_vertexai.dart';
import '../models/analysis_result.dart';

class ApiService {
  // ignore: deprecated_member_use
  static final GenerativeModel _model = FirebaseVertexAI.instance.generativeModel(
    model: 'gemini-2.0-flash',
  );

  static Future<AnalysisResult> analyzeText(String text) async {
    try {
      final prompt = '''
Вие сте "Слово AI" – експерт по български език.
Анализирайте следния текст за правописни, граматични и пунктуационни грешки:

"$text"

Върнете отговора ЕДИНСТВЕНО като валиден JSON обект в следния формат без допълнителен форматиран текст:
{
  "correctedText": "коригираният текст тук",
  "explanations": ["обяснение 1", "обяснение 2"]
}
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