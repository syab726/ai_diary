class EmotionInsight {
  final String id;
  final String type; // 'weekly', 'monthly', 'all_time'
  final String insightText;
  final DateTime periodStart;
  final DateTime periodEnd;
  final DateTime createdAt;

  EmotionInsight({
    required this.id,
    required this.type,
    required this.insightText,
    required this.periodStart,
    required this.periodEnd,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'insightText': insightText,
      'periodStart': periodStart.toIso8601String(),
      'periodEnd': periodEnd.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory EmotionInsight.fromMap(Map<String, dynamic> map) {
    return EmotionInsight(
      id: map['id'],
      type: map['type'],
      insightText: map['insightText'],
      periodStart: DateTime.parse(map['periodStart']),
      periodEnd: DateTime.parse(map['periodEnd']),
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
