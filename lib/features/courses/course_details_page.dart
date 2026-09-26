import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/course.dart';
import '../../data/models/lesson.dart';
import '../../services/storage_service.dart';
import '../learning/lesson_renderer_page.dart';

class CourseDetailsPage extends StatefulWidget {
  final Course course;

  const CourseDetailsPage({super.key, required this.course});

  @override
  State<CourseDetailsPage> createState() => _CourseDetailsPageState();
}

class _CourseDetailsPageState extends State<CourseDetailsPage> {
  final StorageService _storageService = StorageService();

  @override
  Widget build(BuildContext context) {
    final course = widget.course;
    final progress = _storageService.getProgress();

    int completedCount = 0;
    for (final m in course.modules) {
      for (final l in m.lessons) {
        if (progress.isLessonCompleted(l.id)) {
          completedCount++;
        }
      }
    }

    final totalCount = course.totalLessons;
    final percent = totalCount > 0 ? (completedCount / totalCount) : 0.0;

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: CustomScrollView(
        slivers: [
          // Collapsible Custom App Bar
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: AppTheme.cardDark,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primary.withOpacity(0.85),
                      AppTheme.secondary.withOpacity(0.95),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(22, 70, 22, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            course.level.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.timer_outlined, color: Colors.white, size: 13),
                              const SizedBox(width: 4),
                              Text(
                                '${course.estimatedHours}h',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.warning.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppTheme.warning.withOpacity(0.6)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.bolt_rounded, color: AppTheme.warning, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                '${course.totalPoints} XP',
                                style: const TextStyle(
                                  color: AppTheme.warning,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      course.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Course Overview & Syllabus
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Progress Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.cardDark,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.cardBorderDark),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Course Progress',
                              style: TextStyle(
                                color: AppTheme.textPrimaryDark,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              '$completedCount / $totalCount lessons (${(percent * 100).toInt()}%)',
                              style: const TextStyle(
                                color: AppTheme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: percent,
                            minHeight: 8,
                            backgroundColor: AppTheme.surfaceDark,
                            color: AppTheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Description
                  Text(
                    course.description,
                    style: const TextStyle(
                      color: AppTheme.textSecondaryDark,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 26),

                  // Syllabus Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Course Syllabus',
                        style: TextStyle(
                          color: AppTheme.textPrimaryDark,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        '${course.modules.length} Modules',
                        style: const TextStyle(
                          color: AppTheme.textMutedDark,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Modules List
                  ...course.modules.map((module) => _buildModuleCard(module, progress)),

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardDark,
          border: const Border(top: BorderSide(color: AppTheme.cardBorderDark)),
        ),
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: () => _resumeNextLesson(course),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 24),
                const SizedBox(width: 8),
                Text(
                  completedCount == 0
                      ? 'Start Learning'
                      : (completedCount == totalCount ? 'Review Course' : 'Continue Learning'),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModuleCard(dynamic module, dynamic progress) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: AppTheme.cardDark,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppTheme.cardBorderDark),
        ),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            initiallyExpanded: true,
            iconColor: AppTheme.primary,
            collapsedIconColor: AppTheme.textMutedDark,
            title: Text(
              'Module ${module.order}: ${module.title}',
              style: const TextStyle(
                color: AppTheme.textPrimaryDark,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            subtitle: Text(
              module.description,
              style: const TextStyle(color: AppTheme.textMutedDark, fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            children: [
              const Divider(color: AppTheme.cardBorderDark, height: 1),
              ...module.lessons.map<Widget>((lesson) {
                final isCompleted = progress.isLessonCompleted(lesson.id);
                return InkWell(
                  onTap: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => LessonRendererPage(
                          course: widget.course,
                          lesson: lesson,
                        ),
                      ),
                    );
                    setState(() {});
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: isCompleted
                                ? AppTheme.success.withOpacity(0.18)
                                : AppTheme.surfaceDark,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isCompleted ? AppTheme.success : AppTheme.cardBorderDark,
                            ),
                          ),
                          child: Center(
                            child: isCompleted
                                ? const Icon(Icons.check_rounded, color: AppTheme.success, size: 18)
                                : Text(
                                    '${lesson.order}',
                                    style: const TextStyle(
                                      color: AppTheme.textSecondaryDark,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                lesson.title,
                                style: TextStyle(
                                  color: isCompleted ? AppTheme.textMutedDark : AppTheme.textPrimaryDark,
                                  fontSize: 14,
                                  fontWeight: isCompleted ? FontWeight.normal : FontWeight.w600,
                                  decoration: isCompleted ? TextDecoration.lineThrough : null,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  if (lesson.challenge != null) ...[
                                    const Icon(Icons.code_rounded, size: 12, color: AppTheme.accent),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        'Challenge (+${lesson.challenge!.points} XP)',
                                        style: const TextStyle(color: AppTheme.accent, fontSize: 11),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                  ],
                                  if (lesson.quiz.isNotEmpty) ...[
                                    const Icon(Icons.quiz_outlined, size: 12, color: AppTheme.warning),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        'Quiz (${lesson.quiz.length} Q)',
                                        style: const TextStyle(color: AppTheme.warning, fontSize: 11),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: AppTheme.textMutedDark,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }


  void _resumeNextLesson(Course course) {
    final progress = _storageService.getProgress();
    Lesson? nextLesson;

    for (final m in course.modules) {
      for (final l in m.lessons) {
        if (!progress.isLessonCompleted(l.id)) {
          nextLesson = l;
          break;
        }
      }
      if (nextLesson != null) break;
    }

    // If all completed, start from first lesson
    nextLesson ??= course.modules.first.lessons.first;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => LessonRendererPage(
          course: course,
          lesson: nextLesson!,
        ),
      ),
    ).then((_) => setState(() {}));
  }
}
