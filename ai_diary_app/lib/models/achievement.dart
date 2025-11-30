/// 성취 타입
enum AchievementType {
  firstDiary,        // 첫 일기 작성
  consecutiveDays7,  // 7일 연속 작성
  consecutiveDays14, // 14일 연속 작성
  consecutiveDays30, // 30일 연속 작성
  diaryCount10,      // 10개 일기 작성
  diaryCount50,      // 50개 일기 작성
  diaryCount100,     // 100개 일기 작성
  firstAiImage,      // 첫 AI 이미지 생성
  firstPhotoUpload,  // 첫 사진 업로드 (프리미엄)
  allEmotions,       // 모든 감정 경험
}

/// 성취 모델
class Achievement {
  final AchievementType type;
  final String title;
  final String description;
  final String iconEmoji;
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final int progress;
  final int goal;

  const Achievement({
    required this.type,
    required this.title,
    required this.description,
    required this.iconEmoji,
    this.isUnlocked = false,
    this.unlockedAt,
    this.progress = 0,
    required this.goal,
  });

  Achievement copyWith({
    AchievementType? type,
    String? title,
    String? description,
    String? iconEmoji,
    bool? isUnlocked,
    DateTime? unlockedAt,
    int? progress,
    int? goal,
  }) {
    return Achievement(
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      iconEmoji: iconEmoji ?? this.iconEmoji,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      progress: progress ?? this.progress,
      goal: goal ?? this.goal,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'title': title,
      'description': description,
      'iconEmoji': iconEmoji,
      'isUnlocked': isUnlocked,
      'unlockedAt': unlockedAt?.toIso8601String(),
      'progress': progress,
      'goal': goal,
    };
  }

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      type: AchievementType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => AchievementType.firstDiary,
      ),
      title: json['title'] as String,
      description: json['description'] as String,
      iconEmoji: json['iconEmoji'] as String,
      isUnlocked: json['isUnlocked'] as bool? ?? false,
      unlockedAt: json['unlockedAt'] != null
          ? DateTime.parse(json['unlockedAt'] as String)
          : null,
      progress: json['progress'] as int? ?? 0,
      goal: json['goal'] as int,
    );
  }

  /// 진행률 (0.0 ~ 1.0)
  double get progressPercentage => progress / goal;

  /// 기본 성취 목록 생성
  static List<Achievement> createDefaults() {
    return [
      const Achievement(
        type: AchievementType.firstDiary,
        title: '첫 걸음',
        description: '첫 번째 일기를 작성했어요',
        iconEmoji: '✏️',
        goal: 1,
      ),
      const Achievement(
        type: AchievementType.firstAiImage,
        title: 'AI 예술가',
        description: '첫 AI 그림일기를 생성했어요',
        iconEmoji: '🎨',
        goal: 1,
      ),
      const Achievement(
        type: AchievementType.consecutiveDays7,
        title: '꾸준한 기록자',
        description: '7일 연속 일기를 작성했어요',
        iconEmoji: '🔥',
        goal: 7,
      ),
      const Achievement(
        type: AchievementType.consecutiveDays14,
        title: '습관의 힘',
        description: '14일 연속 일기를 작성했어요',
        iconEmoji: '💪',
        goal: 14,
      ),
      const Achievement(
        type: AchievementType.consecutiveDays30,
        title: '전설의 일기러',
        description: '30일 연속 일기를 작성했어요',
        iconEmoji: '👑',
        goal: 30,
      ),
      const Achievement(
        type: AchievementType.diaryCount10,
        title: '이야기 수집가',
        description: '10개의 일기를 작성했어요',
        iconEmoji: '📚',
        goal: 10,
      ),
      const Achievement(
        type: AchievementType.diaryCount50,
        title: '작가의 길',
        description: '50개의 일기를 작성했어요',
        iconEmoji: '📖',
        goal: 50,
      ),
      const Achievement(
        type: AchievementType.diaryCount100,
        title: '베스트셀러 작가',
        description: '100개의 일기를 작성했어요',
        iconEmoji: '🏆',
        goal: 100,
      ),
      const Achievement(
        type: AchievementType.firstPhotoUpload,
        title: '사진작가',
        description: '첫 사진을 업로드했어요',
        iconEmoji: '📸',
        goal: 1,
      ),
      const Achievement(
        type: AchievementType.allEmotions,
        title: '감정의 스펙트럼',
        description: '모든 종류의 감정을 경험했어요',
        iconEmoji: '🌈',
        goal: 8,
      ),
    ];
  }
}
