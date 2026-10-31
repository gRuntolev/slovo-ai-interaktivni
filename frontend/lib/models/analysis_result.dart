class AnalysisResult {
  final String originalText;
  final String correctedText;
  final List<String> explanations;
  final List<String> rules;

  AnalysisResult({
    required this.originalText,
    required this.correctedText,
    required this.explanations,
    required this.rules,
  });

  factory AnalysisResult.fromJson(Map<String, dynamic> json) {
    return AnalysisResult(
      originalText: json['originalText'] ?? '',
      correctedText: json['correctedText'] ?? '',
      explanations: List<String>.from(json['explanations'] ?? []),
      rules: List<String>.from(json['rules'] ?? []),
    );
  }
}