class CorrectionResult {
  final bool isExam;
  final String subject;
  final String structuredCorrection;
  final List<String> similarExercises;
  final String pedagogicalAdvice;

  CorrectionResult({
    required this.isExam,
    required this.subject,
    required this.structuredCorrection,
    required this.similarExercises,
    required this.pedagogicalAdvice,
  });

  factory CorrectionResult.fromJson(Map<String, dynamic> json) {
    return CorrectionResult(
      isExam: json['is_exam'] ?? false,
      subject: json['subject'] ?? 'Général',
      structuredCorrection: json['correction'] ?? '',
      similarExercises: List<String>.from(json['similar_exercises'] ?? []),
      pedagogicalAdvice: json['pedagogical_advice'] ?? '',
    );
  }
}
