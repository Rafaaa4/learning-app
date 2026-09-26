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
    final rawAnswer = json['correct_answer'] ?? json['correctAnswerIndex'];
    return QuizQuestion(
      question: json['question'] as String? ?? 'Quiz Question',
      options: (json['options'] as List<dynamic>?)
              ?.map((o) => o.toString())
              .toList() ??
          [],
      correctAnswer: (rawAnswer as num?)?.toInt() ?? 0,
      explanation: json['explanation'] as String?,
      points: (json['points'] as num?)?.toInt() ?? 5,
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
