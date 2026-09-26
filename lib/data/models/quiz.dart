class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctAnswer;
  final String? explanation;
  final int points;

  QuizQuestion({
    required this.question,
    required this.options,
    required this.correctAnswer,
    this.explanation,
    this.points = 5,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      question: json['question'] as String? ?? 'Quiz Question',
      options: (json['options'] as List<dynamic>?)
              ?.map((o) => o.toString())
              .toList() ??
          [],
      correctAnswer: json['correct_answer'] as int? ?? 0,
      explanation: json['explanation'] as String?,
      points: json['points'] as int? ?? 5,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'options': options,
      'correct_answer': correctAnswer,
      if (explanation != null) 'explanation': explanation,
      'points': points,
    };
  }
}
