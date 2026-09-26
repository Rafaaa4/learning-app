import '../data/models/challenge.dart';

class RuleCheckResult {
  final ValidationRule rule;
  final bool passed;
  final String feedback;

  RuleCheckResult({
    required this.rule,
    required this.passed,
    required this.feedback,
  });
}

class ValidationResult {
  final bool isPassed;
  final List<RuleCheckResult> ruleResults;
  final String summaryMessage;

  ValidationResult({
    required this.isPassed,
    required this.ruleResults,
    required this.summaryMessage,
  });
}

class ValidationService {
  static final ValidationService _instance = ValidationService._internal();
  factory ValidationService() => _instance;
  ValidationService._internal();

  /// Validates user code against challenge validation rules
  ValidationResult validateChallenge({
    required String code,
    required Challenge challenge,
    List<String> consoleOutputs = const [],
  }) {
    final rules = challenge.validation.rules;
    if (rules.isEmpty) {
      return ValidationResult(
        isPassed: true,
        ruleResults: [],
        summaryMessage: 'Great work! No validation rules specified.',
      );
    }

    final List<RuleCheckResult> results = [];
    final cleanCode = code.trim();

    for (final rule in rules) {
      final check = _evaluateRule(
        rule: rule,
        code: cleanCode,
        langType: challenge.validation.type,
        consoleOutputs: consoleOutputs,
      );
      results.add(check);
    }

    final allPassed = results.every((r) => r.passed);
    final passedCount = results.where((r) => r.passed).length;

    final summary = allPassed
        ? 'Excellent! All tests passed (+${challenge.points} XP) 🎉'
        : 'Almost there! $passedCount of ${results.length} checks passed.';

    return ValidationResult(
      isPassed: allPassed,
      ruleResults: results,
      summaryMessage: summary,
    );
  }

  RuleCheckResult _evaluateRule({
    required ValidationRule rule,
    required String code,
    required String langType,
    required List<String> consoleOutputs,
  }) {
    switch (rule.type) {
      case 'element_exists':
        final tag = (rule.element ?? '').trim().toLowerCase();
        if (tag.isEmpty) {
          return RuleCheckResult(rule: rule, passed: true, feedback: 'Rule skipped.');
        }
        // Match <tag ...> or <tag>
        final tagRegex = RegExp('<\\s*$tag(\\s+[^>]*)?>', caseSensitive: false);
        final found = tagRegex.hasMatch(code);
        return RuleCheckResult(
          rule: rule,
          passed: found,
          feedback: found
              ? 'Found <$tag> element.'
              : 'Missing <$tag> element. Please add it to your code.',
        );

      case 'text_contains':
        final target = (rule.value ?? '').trim();
        final found = code.toLowerCase().contains(target.toLowerCase());
        return RuleCheckResult(
          rule: rule,
          passed: found,
          feedback: found
              ? 'Code contains "$target".'
              : 'Expected to find "$target" in your code.',
        );

      case 'attribute_exists':
        final attr = (rule.attribute ?? rule.value ?? '').trim().toLowerCase();
        final attrRegex = RegExp('\\b$attr\\s*=', caseSensitive: false);
        final found = attrRegex.hasMatch(code);
        return RuleCheckResult(
          rule: rule,
          passed: found,
          feedback: found
              ? 'Attribute "$attr" found.'
              : 'Missing attribute "$attr".',
        );

      case 'regex_match':
        final pattern = rule.value ?? '';
        bool found = false;
        try {
          final regex = RegExp(pattern, caseSensitive: false, multiLine: true);
          found = regex.hasMatch(code);
        } catch (_) {
          found = code.contains(pattern);
        }
        return RuleCheckResult(
          rule: rule,
          passed: found,
          feedback: found
              ? 'Matched required structure.'
              : 'Structure does not match requirements: ${rule.displayName}',
        );

      case 'output_contains':
        final expected = (rule.value ?? '').trim().toLowerCase();
        final allLogs = consoleOutputs.join('\n').toLowerCase();
        final found = allLogs.contains(expected);
        return RuleCheckResult(
          rule: rule,
          passed: found,
          feedback: found
              ? 'Console output contains "$expected".'
              : 'Expected console output to contain "$expected". Found: "${consoleOutputs.join(', ')}"',
        );

      default:
        // Generic fallback check
        final target = rule.value ?? rule.element ?? '';
        final passed = target.isEmpty || code.contains(target);
        return RuleCheckResult(
          rule: rule,
          passed: passed,
          feedback: passed ? 'Requirement satisfied.' : 'Requirement not met: ${rule.displayName}',
        );
    }
  }
}
