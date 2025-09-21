enum SubscriptionTier {
  free('무료', 'Free'),
  premium('프리미엄', 'Premium');

  const SubscriptionTier(this.displayNameKo, this.displayNameEn);
  
  final String displayNameKo;
  final String displayNameEn;
}

class UserSubscription {
  final SubscriptionTier tier;
  final DateTime? subscriptionStart;
  final DateTime? subscriptionEnd;
  final int imageGenerationsUsed;
  final int imageGenerationsLimit;
  final int imageModificationsUsed;
  final int imageModificationsLimit;

  const UserSubscription({
    this.tier = SubscriptionTier.free,
    this.subscriptionStart,
    this.subscriptionEnd,
    this.imageGenerationsUsed = 0,
    this.imageGenerationsLimit = 5, // 무료 사용자는 월 5개
    this.imageModificationsUsed = 0,
    this.imageModificationsLimit = 0, // 무료 사용자는 수정 불가
  });

  bool get isPremium => tier == SubscriptionTier.premium;
  
  bool get isSubscriptionActive {
    if (!isPremium) return false;
    if (subscriptionEnd == null) return false;
    return DateTime.now().isBefore(subscriptionEnd!);
  }

  bool get canGenerateImage {
    if (isPremium && isSubscriptionActive) return true;
    return imageGenerationsUsed < imageGenerationsLimit;
  }

  bool get canModifyImage {
    if (!isPremium) return false;
    if (!isSubscriptionActive) return false;
    return imageModificationsUsed < imageModificationsLimit;
  }

  int get remainingGenerations {
    if (isPremium && isSubscriptionActive) return -1; // 무제한
    return imageGenerationsLimit - imageGenerationsUsed;
  }

  int get remainingModifications {
    if (!isPremium) return 0;
    if (!isSubscriptionActive) return 0;
    if (isPremium && isSubscriptionActive) return -1; // 무제한
    return imageModificationsLimit - imageModificationsUsed;
  }

  UserSubscription copyWith({
    SubscriptionTier? tier,
    DateTime? subscriptionStart,
    DateTime? subscriptionEnd,
    int? imageGenerationsUsed,
    int? imageGenerationsLimit,
    int? imageModificationsUsed,
    int? imageModificationsLimit,
  }) {
    return UserSubscription(
      tier: tier ?? this.tier,
      subscriptionStart: subscriptionStart ?? this.subscriptionStart,
      subscriptionEnd: subscriptionEnd ?? this.subscriptionEnd,
      imageGenerationsUsed: imageGenerationsUsed ?? this.imageGenerationsUsed,
      imageGenerationsLimit: imageGenerationsLimit ?? this.imageGenerationsLimit,
      imageModificationsUsed: imageModificationsUsed ?? this.imageModificationsUsed,
      imageModificationsLimit: imageModificationsLimit ?? this.imageModificationsLimit,
    );
  }

  UserSubscription incrementGenerations() {
    return copyWith(imageGenerationsUsed: imageGenerationsUsed + 1);
  }

  UserSubscription incrementModifications() {
    return copyWith(imageModificationsUsed: imageModificationsUsed + 1);
  }

  // 프리미엄 구독 시작
  UserSubscription startPremiumSubscription() {
    final now = DateTime.now();
    return copyWith(
      tier: SubscriptionTier.premium,
      subscriptionStart: now,
      subscriptionEnd: now.add(const Duration(days: 30)), // 월 구독
      imageModificationsLimit: 100, // 프리미엄은 월 100회 수정
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'tier': tier.name,
      'subscriptionStart': subscriptionStart?.toIso8601String(),
      'subscriptionEnd': subscriptionEnd?.toIso8601String(),
      'imageGenerationsUsed': imageGenerationsUsed,
      'imageGenerationsLimit': imageGenerationsLimit,
      'imageModificationsUsed': imageModificationsUsed,
      'imageModificationsLimit': imageModificationsLimit,
    };
  }

  factory UserSubscription.fromMap(Map<String, dynamic> map) {
    return UserSubscription(
      tier: SubscriptionTier.values.firstWhere(
        (tier) => tier.name == map['tier'],
        orElse: () => SubscriptionTier.free,
      ),
      subscriptionStart: map['subscriptionStart'] != null 
          ? DateTime.parse(map['subscriptionStart'])
          : null,
      subscriptionEnd: map['subscriptionEnd'] != null
          ? DateTime.parse(map['subscriptionEnd'])
          : null,
      imageGenerationsUsed: map['imageGenerationsUsed'] ?? 0,
      imageGenerationsLimit: map['imageGenerationsLimit'] ?? 5,
      imageModificationsUsed: map['imageModificationsUsed'] ?? 0,
      imageModificationsLimit: map['imageModificationsLimit'] ?? 0,
    );
  }
}