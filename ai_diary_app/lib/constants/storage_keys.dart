/// SharedPreferences 저장소 키 상수
///
/// 무료 사용자 일일 광고 제한을 위한 데이터 키들을 정의합니다.
class StorageKeys {
  /// 오늘 시청한 광고 개수
  ///
  /// 무료 사용자가 하루에 시청한 보상형 광고의 개수를 저장합니다.
  /// 자정(00:00)에 자동으로 0으로 리셋됩니다.
  ///
  /// 타입: int
  /// 범위: 0 ~ 3 (하루 최대 3개 제한)
  static const String dailyAdCount = 'daily_ad_count';

  /// 마지막 광고 시청 날짜
  ///
  /// 마지막으로 광고를 시청한 날짜를 ISO 8601 형식으로 저장합니다.
  /// 날짜가 바뀌었는지 확인하여 dailyAdCount를 리셋하는 데 사용됩니다.
  ///
  /// 타입: String (ISO 8601 형식, 예: "2025-10-18")
  /// 예시: "2025-10-18"
  static const String lastAdDate = 'last_ad_date';
}
