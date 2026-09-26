class UserProgress {
  final Set<String> completedLessonIds;
  final Set<String> completedChallengeIds;
  final Set<String> completedQuizIds;
  final int totalXp;
  final int streakDays;
  final DateTime lastActiveDate;

  UserProgress({
    Set<String>? completedLessonIds,
    Set<String>? completedChallengeIds,
    Set<String>? completedQuizIds,
    this.totalXp = 0,
    this.streakDays = 1,
    DateTime? lastActiveDate,
  })  : completedLessonIds = completedLessonIds ?? {},
        completedChallengeIds = completedChallengeIds ?? {},
        completedQuizIds = completedQuizIds ?? {},
        lastActiveDate = lastActiveDate ?? DateTime.now();

  factory UserProgress.fromJson(Map<String, dynamic> json) {
    return UserProgress(
      completedLessonIds: (json['completed_lesson_ids'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toSet() ??
          {},
      completedChallengeIds: (json['completed_challenge_ids'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toSet() ??
          {},
      completedQuizIds: (json['completed_quiz_ids'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toSet() ??
          {},
      totalXp: json['total_xp'] as int? ?? 0,
      streakDays: json['streak_days'] as int? ?? 1,
      lastActiveDate: json['last_active_date'] != null
          ? DateTime.tryParse(json['last_active_date'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'completed_lesson_ids': completedLessonIds.toList(),
      'completed_challenge_ids': completedChallengeIds.toList(),
      'completed_quiz_ids': completedQuizIds.toList(),
      'total_xp': totalXp,
      'streak_days': streakDays,
      'last_active_date': lastActiveDate.toIso8601String(),
    };
  }

  bool isLessonCompleted(String lessonId) => completedLessonIds.contains(lessonId);
  bool isChallengeCompleted(String challengeId) => completedChallengeIds.contains(challengeId);

  int get userLevel {
    // 100 XP per level
    return (totalXp / 100).floor() + 1;
  }

  int get currentLevelXpProgress {
    return totalXp % 100;
  }

  UserProgress copyWith({
    Set<String>? completedLessonIds,
    Set<String>? completedChallengeIds,
    Set<String>? completedQuizIds,
    int? totalXp,
    int? streakDays,
    DateTime? lastActiveDate,
  }) {
    return UserProgress(
      completedLessonIds: completedLessonIds ?? Set.from(this.completedLessonIds),
      completedChallengeIds: completedChallengeIds ?? Set.from(this.completedChallengeIds),
      completedQuizIds: completedQuizIds ?? Set.from(this.completedQuizIds),
      totalXp: totalXp ?? this.totalXp,
      streakDays: streakDays ?? this.streakDays,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
    );
  }
}
