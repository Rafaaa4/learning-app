import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/course.dart';
import '../../data/models/lesson.dart';
import '../../data/models/challenge.dart';
import '../../data/models/quiz.dart';
import '../../services/validation_service.dart';
import '../../services/execution_service.dart';
import '../../services/storage_service.dart';

class LessonRendererPage extends StatefulWidget {
  final Course course;
  final Lesson lesson;

  const LessonRendererPage({
    super.key,
    required this.course,
    required this.lesson,
  });

  @override
  State<LessonRendererPage> createState() => _LessonRendererPageState();
}

class _LessonRendererPageState extends State<LessonRendererPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ValidationService _validationService = ValidationService();
  final ExecutionService _executionService = ExecutionService();
  final StorageService _storageService = StorageService();

  late TextEditingController _codeController;
  ValidationResult? _validationResult;
  List<String> _simulatedLogs = [];
  bool _isChallengeSolved = false;

  // Quiz state
  final Map<int, int> _selectedQuizAnswers = {};
  final Map<int, bool> _quizSubmitted = {};
  int _quizXpEarned = 0;

  @override
  void initState() {
    super.initState();
    final hasChallenge = widget.lesson.challenge != null;
    final hasQuiz = widget.lesson.quiz.isNotEmpty;

    int tabCount = 1;
    if (hasChallenge) tabCount++;
    if (hasQuiz) tabCount++;

    _tabController = TabController(length: tabCount, vsync: this);

    final challenge = widget.lesson.challenge;
    _codeController = TextEditingController(
      text: challenge != null ? challenge.starterCode : '',
    );

    final progress = _storageService.getProgress();
    if (challenge != null && progress.isChallengeCompleted(challenge.title)) {
      _isChallengeSolved = true;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  void _runAndTest() {
    final challenge = widget.lesson.challenge;
    if (challenge == null) return;

    final userCode = _codeController.text;
    final logs = _executionService.simulateJsConsoleLogs(userCode);

    final result = _validationService.validateChallenge(
      code: userCode,
      challenge: challenge,
      consoleOutputs: logs,
    );

    setState(() {
      _simulatedLogs = logs;
      _validationResult = result;
    });

    if (result.isPassed && !_isChallengeSolved) {
      _storageService.completeChallenge(
        challengeId: challenge.title,
        points: challenge.points,
      );
      _storageService.completeLesson(lessonId: widget.lesson.id);

      setState(() {
        _isChallengeSolved = true;
      });

      _showSuccessCelebration(challenge.points);
    }
  }

  void _showSuccessCelebration(int xp) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(26),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: AppTheme.success.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded, color: AppTheme.success, size: 48),
            ),
            const SizedBox(height: 16),
            const Text(
              'Challenge Passed! 🎉',
              style: TextStyle(
                color: AppTheme.textPrimaryDark,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You satisfied all automated validation rules and earned +$xp XP.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.textSecondaryDark, fontSize: 14),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  if (widget.lesson.quiz.isNotEmpty) {
                    _tabController.animateTo(2);
                  }
                },
                child: Text(
                  widget.lesson.quiz.isNotEmpty ? 'Proceed to Quiz 📝' : 'Continue 🚀',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showHintsDialog(List<String> hints) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppTheme.cardBorderDark),
        ),
        title: const Row(
          children: [
            Icon(Icons.lightbulb_outline, color: AppTheme.warning),
            SizedBox(width: 8),
            Text('Challenge Hints', style: TextStyle(color: AppTheme.textPrimaryDark, fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: hints.isEmpty
              ? [const Text('No hints available for this challenge.', style: TextStyle(color: AppTheme.textSecondaryDark))]
              : hints
                  .map((h) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('💡 ', style: TextStyle(fontSize: 16)),
                            Expanded(
                              child: Text(
                                h,
                                style: const TextStyle(color: AppTheme.textPrimaryDark, fontSize: 13, height: 1.4),
                              ),
                            ),
                          ],
                        ),
                      ))
                  .toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close', style: TextStyle(color: AppTheme.primary)),
          ),
        ],
      ),
    );
  }

  void _showSolutionDialog(String solution) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppTheme.cardBorderDark),
        ),
        title: const Row(
          children: [
            Icon(Icons.visibility_outlined, color: AppTheme.accent),
            SizedBox(width: 8),
            Text('Challenge Solution', style: TextStyle(color: AppTheme.textPrimaryDark, fontSize: 18)),
          ],
        ),
        content: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.codeBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.cardBorderDark),
          ),
          child: SelectableText(
            solution,
            style: const TextStyle(
              fontFamily: 'monospace',
              color: AppTheme.codeString,
              fontSize: 13,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.textMutedDark)),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _codeController.text = solution;
              });
              Navigator.of(ctx).pop();
            },
            child: const Text('Copy to Editor'),
          ),
        ],
      ),
    );
  }

  void _submitQuizQuestion(int qIdx, int selectedOption, QuizQuestion question) {
    setState(() {
      _selectedQuizAnswers[qIdx] = selectedOption;
      _quizSubmitted[qIdx] = true;
      if (selectedOption == question.correctAnswer) {
        _quizXpEarned += question.points;
      }
    });

    if (selectedOption == question.correctAnswer) {
      _storageService.recordQuizCompletion(
        quizId: '${widget.lesson.id}-q$qIdx',
        score: question.points,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final lesson = widget.lesson;
    final hasChallenge = lesson.challenge != null;
    final hasQuiz = lesson.quiz.isNotEmpty;

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        title: Text(
          lesson.title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primary,
          indicatorWeight: 3,
          labelColor: AppTheme.primary,
          unselectedLabelColor: AppTheme.textMutedDark,
          tabs: [
            const Tab(icon: Icon(Icons.menu_book_rounded, size: 20), text: 'Theory'),
            if (hasChallenge)
              Tab(
                icon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.code_rounded, size: 20),
                    if (_isChallengeSolved) ...[
                      const SizedBox(width: 4),
                      const Icon(Icons.check_circle, color: AppTheme.success, size: 14),
                    ],
                  ],
                ),
                text: 'Challenge',
              ),
            if (hasQuiz)
              const Tab(icon: Icon(Icons.quiz_rounded, size: 20), text: 'Quiz'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTheoryTab(lesson),
          if (hasChallenge) _buildChallengeTab(lesson.challenge!),
          if (hasQuiz) _buildQuizTab(lesson.quiz),
        ],
      ),
      bottomNavigationBar: _buildBottomStatusBar(),
    );
  }

  Widget _buildTheoryTab(Lesson lesson) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order & Module Tag
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
            ),
            child: Text(
              'Lesson ${lesson.order}',
              style: const TextStyle(
                color: AppTheme.primary,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 12),

          Text(
            lesson.title,
            style: const TextStyle(
              color: AppTheme.textPrimaryDark,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),

          const SizedBox(height: 16),

          // Explanation Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppTheme.cardDark,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.cardBorderDark),
            ),
            child: Text(
              lesson.content.explanation,
              style: const TextStyle(
                color: AppTheme.textPrimaryDark,
                fontSize: 15,
                height: 1.6,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Code Examples
          if (lesson.content.examples.isNotEmpty) ...[
            const Text(
              'Interactive Examples',
              style: TextStyle(
                color: AppTheme.textPrimaryDark,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            ...lesson.content.examples.map((ex) => _buildCodeSnippetCard(ex)),
            const SizedBox(height: 20),
          ],

          // Key Points
          if (lesson.content.keyPoints.isNotEmpty) ...[
            const Text(
              'Key Takeaways',
              style: TextStyle(
                color: AppTheme.textPrimaryDark,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.cardDark,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.cardBorderDark),
              ),
              child: Column(
                children: lesson.content.keyPoints.map((point) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.check_circle_outline, color: AppTheme.accent, size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            point,
                            style: const TextStyle(
                              color: AppTheme.textPrimaryDark,
                              fontSize: 14,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],

          const SizedBox(height: 30),

          // Next Step Action
          if (lesson.challenge != null)
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () => _tabController.animateTo(1),
                icon: const Icon(Icons.code_rounded),
                label: const Text('Start Coding Challenge →'),
              ),
            )
          else if (lesson.quiz.isNotEmpty)
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () => _tabController.animateTo(1),
                icon: const Icon(Icons.quiz_outlined),
                label: const Text('Take Lesson Quiz →'),
              ),
            ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildCodeSnippetCard(CodeExample ex) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppTheme.codeBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.cardBorderDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top bar of snippet
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(width: 10, height: 10, decoration: const BoxDecoration(color: Color(0xFFFF5F56), shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    Container(width: 10, height: 10, decoration: const BoxDecoration(color: Color(0xFFFFBD2E), shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    Container(width: 10, height: 10, decoration: const BoxDecoration(color: Color(0xFF27C93F), shape: BoxShape.circle)),
                    const SizedBox(width: 12),
                    Text(
                      ex.title,
                      style: const TextStyle(color: AppTheme.textSecondaryDark, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.copy_rounded, color: AppTheme.textMutedDark, size: 16),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: ex.code));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Code copied to clipboard!'), duration: Duration(seconds: 1)),
                    );
                  },
                ),
              ],
            ),
          ),
          const Divider(color: AppTheme.cardBorderDark, height: 1),
          Padding(
            padding: const EdgeInsets.all(14),
            child: SelectableText(
              ex.code,
              style: const TextStyle(
                fontFamily: 'monospace',
                color: AppTheme.codeText,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ),
          if (ex.explanation != null && ex.explanation!.isNotEmpty) ...[
            const Divider(color: AppTheme.cardBorderDark, height: 1),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                ex.explanation!,
                style: const TextStyle(color: AppTheme.textMutedDark, fontSize: 12),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildChallengeTab(Challenge challenge) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Challenge Header Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.primary.withOpacity(0.12), AppTheme.accent.withOpacity(0.06)],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      challenge.title,
                      style: const TextStyle(
                        color: AppTheme.textPrimaryDark,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.warning.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '+${challenge.points} XP',
                        style: const TextStyle(
                          color: AppTheme.warning,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  challenge.description,
                  style: const TextStyle(
                    color: AppTheme.textSecondaryDark,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Code Editor Toolbar
          Row(
            children: [
              const Text(
                'Code Editor',
                style: TextStyle(
                  color: AppTheme.textPrimaryDark,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                icon: const Icon(Icons.refresh_rounded, size: 16, color: AppTheme.textMutedDark),
                label: const Text('Reset', style: TextStyle(color: AppTheme.textMutedDark, fontSize: 12)),
                onPressed: () {
                  setState(() {
                    _codeController.text = challenge.starterCode;
                  });
                },
              ),
              TextButton.icon(
                icon: const Icon(Icons.lightbulb_outline, size: 16, color: AppTheme.warning),
                label: const Text('Hint', style: TextStyle(color: AppTheme.warning, fontSize: 12)),
                onPressed: () => _showHintsDialog(challenge.hints),
              ),
              TextButton.icon(
                icon: const Icon(Icons.visibility_outlined, size: 16, color: AppTheme.accent),
                label: const Text('Solution', style: TextStyle(color: AppTheme.accent, fontSize: 12)),
                onPressed: () => _showSolutionDialog(challenge.solution),
              ),
            ],
          ),

          // Monospace Code Editor
          Container(
            decoration: BoxDecoration(
              color: AppTheme.codeBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.cardBorderDark),
            ),
            child: TextField(
              controller: _codeController,
              maxLines: 8,
              style: const TextStyle(
                fontFamily: 'monospace',
                color: AppTheme.codeText,
                fontSize: 13.5,
                height: 1.5,
              ),
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.all(16),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                hintText: '// Type code here...',
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Run & Test Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _runAndTest,
              icon: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 24),
              label: const Text('Run Tests & Validate ⚡'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Validation Rules & Output
          if (_validationResult != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.cardDark,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _validationResult!.isPassed
                      ? AppTheme.success.withOpacity(0.5)
                      : AppTheme.cardBorderDark,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _validationResult!.isPassed
                            ? Icons.check_circle_rounded
                            : Icons.info_outline_rounded,
                        color: _validationResult!.isPassed ? AppTheme.success : AppTheme.warning,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _validationResult!.summaryMessage,
                        style: TextStyle(
                          color: _validationResult!.isPassed ? AppTheme.success : AppTheme.textPrimaryDark,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Divider(color: AppTheme.cardBorderDark, height: 1),
                  const SizedBox(height: 10),
                  ..._validationResult!.ruleResults.map((ruleCheck) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            ruleCheck.passed ? Icons.check_rounded : Icons.close_rounded,
                            color: ruleCheck.passed ? AppTheme.success : AppTheme.error,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              ruleCheck.feedback,
                              style: TextStyle(
                                color: ruleCheck.passed ? AppTheme.textPrimaryDark : AppTheme.error,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],

          if (_simulatedLogs.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF070A0F),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.cardBorderDark),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.terminal_rounded, size: 14, color: AppTheme.textMutedDark),
                      SizedBox(width: 6),
                      Text('Console Output', style: TextStyle(color: AppTheme.textMutedDark, fontSize: 11)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ..._simulatedLogs.map((log) => Text(
                        '> $log',
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          color: Color(0xFF58A6FF),
                          fontSize: 12,
                        ),
                      )),
                ],
              ),
            ),
          ],

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildQuizTab(List<QuizQuestion> questions) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Knowledge Check',
                style: TextStyle(
                  color: AppTheme.textPrimaryDark,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.warning.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '+$_quizXpEarned XP',
                  style: const TextStyle(
                    color: AppTheme.warning,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          ...List.generate(questions.length, (qIdx) {
            final q = questions[qIdx];
            final selected = _selectedQuizAnswers[qIdx];
            final isSubmitted = _quizSubmitted[qIdx] ?? false;

            return Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppTheme.cardDark,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppTheme.cardBorderDark),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Q${qIdx + 1}',
                          style: const TextStyle(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          q.question,
                          style: const TextStyle(
                            color: AppTheme.textPrimaryDark,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  ...List.generate(q.options.length, (optIdx) {
                    final optText = q.options[optIdx];
                    final isOptionSelected = selected == optIdx;
                    final isCorrect = optIdx == q.correctAnswer;

                    Color tileColor = AppTheme.surfaceDark;
                    Color borderColor = AppTheme.cardBorderDark;
                    if (isSubmitted) {
                      if (isCorrect) {
                        tileColor = AppTheme.success.withOpacity(0.15);
                        borderColor = AppTheme.success;
                      } else if (isOptionSelected) {
                        tileColor = AppTheme.error.withOpacity(0.15);
                        borderColor = AppTheme.error;
                      }
                    } else if (isOptionSelected) {
                      tileColor = AppTheme.primary.withOpacity(0.15);
                      borderColor = AppTheme.primary;
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: InkWell(
                        onTap: isSubmitted
                            ? null
                            : () => _submitQuizQuestion(qIdx, optIdx, q),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: tileColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: borderColor),
                          ),
                          child: Row(
                            children: [
                              Text(
                                '${String.fromCharCode(65 + optIdx)}.',
                                style: TextStyle(
                                  color: isOptionSelected ? AppTheme.primary : AppTheme.textMutedDark,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  optText,
                                  style: const TextStyle(
                                    color: AppTheme.textPrimaryDark,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              if (isSubmitted && isCorrect)
                                const Icon(Icons.check_circle, color: AppTheme.success, size: 18)
                              else if (isSubmitted && isOptionSelected && !isCorrect)
                                const Icon(Icons.cancel, color: AppTheme.error, size: 18),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),

                  if (isSubmitted && q.explanation != null) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceDark,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '💡 ${q.explanation}',
                        style: const TextStyle(color: AppTheme.textSecondaryDark, fontSize: 12),
                      ),
                    ),
                  ],
                ],
              ),
            );
          }),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildBottomStatusBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(
        color: AppTheme.cardDark,
        border: Border(top: BorderSide(color: AppTheme.cardBorderDark)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.bolt_rounded, color: AppTheme.warning, size: 20),
              const SizedBox(width: 6),
              Text(
                'Total XP: ${_storageService.getProgress().totalXp}',
                style: const TextStyle(
                  color: AppTheme.textPrimaryDark,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () {
              // Navigate to next lesson in syllabus
              _navigateToNextLesson();
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            child: const Text('Next Lesson →', style: TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }

  void _navigateToNextLesson() {
    final modules = widget.course.modules;
    Lesson? next;
    bool foundCurrent = false;

    for (final m in modules) {
      for (final l in m.lessons) {
        if (foundCurrent) {
          next = l;
          break;
        }
        if (l.id == widget.lesson.id) {
          foundCurrent = true;
        }
      }
      if (next != null) break;
    }

    if (next != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => LessonRendererPage(
            course: widget.course,
            lesson: next!,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎉 Congratulations! You have completed all lessons in this course!'),
          backgroundColor: AppTheme.success,
        ),
      );
      Navigator.of(context).pop();
    }
  }
}
