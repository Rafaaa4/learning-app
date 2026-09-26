class ValidationRule {
  final String type; // 'element_exists', 'text_contains', 'attribute_exists', 'regex_match', 'output_contains'
  final String? element;
  final String? value;
  final String? attribute;
  final String? description;

  ValidationRule({
    required this.type,
    this.element,
    this.value,
    this.attribute,
    this.description,
  });

  factory ValidationRule.fromJson(Map<String, dynamic> json) {
    return ValidationRule(
      type: json['type'] as String? ?? 'text_contains',
      element: json['element'] as String?,
      value: json['value'] as String?,
      attribute: json['attribute'] as String?,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      if (element != null) 'element': element,
      if (value != null) 'value': value,
      if (attribute != null) 'attribute': attribute,
      if (description != null) 'description': description,
    };
  }

  String get displayName {
    if (description != null && description!.isNotEmpty) {
      return description!;
    }
    switch (type) {
      case 'element_exists':
        return 'Element <$element> must exist';
      case 'text_contains':
        return 'Must contain text: "$value"';
      case 'attribute_exists':
        return 'Must have attribute: $attribute';
      case 'regex_match':
        return 'Must match pattern: $value';
      case 'output_contains':
        return 'Console output must include: "$value"';
      default:
        return 'Validate $type rule';
    }
  }
}

class ChallengeValidation {
  final String type; // 'html', 'javascript', 'css', 'python'
  final List<ValidationRule> rules;

  ChallengeValidation({
    required this.type,
    required this.rules,
  });

  factory ChallengeValidation.fromJson(Map<String, dynamic> json) {
    return ChallengeValidation(
      type: json['type'] as String? ?? 'html',
      rules: (json['rules'] as List<dynamic>?)
              ?.map((r) => ValidationRule.fromJson(r as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'rules': rules.map((r) => r.toJson()).toList(),
    };
  }
}

class Challenge {
  final String title;
  final String description;
  final String starterCode;
  final String language;
  final ChallengeValidation validation;
  final String solution;
  final List<String> hints;
  final int points;

  Challenge({
    required this.title,
    required this.description,
    required this.starterCode,
    this.language = 'html',
    required this.validation,
    required this.solution,
    required this.hints,
    this.points = 10,
  });

  factory Challenge.fromJson(Map<String, dynamic> json) {
    return Challenge(
      title: json['title'] as String? ?? 'Coding Challenge',
      description: json['description'] as String? ?? '',
      starterCode: (json['starter_code'] ?? json['initialCode']) as String? ?? '',
      language: (json['validation'] != null && json['validation']['type'] != null)
          ? json['validation']['type'] as String
          : (json['language'] as String? ?? 'html'),
      validation: json['validation'] != null && json['validation'] is Map<String, dynamic>
          ? ChallengeValidation.fromJson(json['validation'] as Map<String, dynamic>)
          : ChallengeValidation(type: 'html', rules: []),
      solution: json['solution'] as String? ?? '',
      hints: (json['hints'] as List<dynamic>?)?.map((h) => h.toString()).toList() ?? [],
      points: (json['points'] as num?)?.toInt() ?? 10,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'starter_code': starterCode,
      'language': language,
      'validation': validation.toJson(),
      'solution': solution,
      'hints': hints,
      'points': points,
    };
  }
}
