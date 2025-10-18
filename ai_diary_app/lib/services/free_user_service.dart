import 'package:shared_preferences/shared_preferences.dart';
import '../constants/storage_keys.dart';

/// 무료 사용자 일일 제한 관리 서비스
///
/// 무료 사용자의 하루 광고 시청 횟수를 관리하고,
/// 자정에 자동으로 카운터를 리셋하는 로직을 제공합니다.
class FreeUserService {
  /// 싱글톤 인스턴스
  static final FreeUserService _instance = FreeUserService._internal();
  factory FreeUserService() => _instance;
  FreeUserService._internal();

  /// SharedPreferences 인스턴스
  SharedPreferences? _prefs;

  /// SharedPreferences 초기화
  Future<void> initialize() async {
    try {
      _prefs ??= await SharedPreferences.getInstance();
    } catch (e) {
      print('[FreeUserService] SharedPreferences 초기화 실패: $e');
      rethrow;
    }
  }

  /// 오늘 시청한 광고 개수 가져오기
  ///
  /// 자동으로 날짜 변경을 확인하여 필요 시 카운터를 리셋합니다.
  ///
  /// Returns: 오늘 시청한 광고 개수 (0 ~ 3)
  Future<int> getDailyAdCount() async {
    await initialize();
    await _checkAndResetDaily();
    return _prefs!.getInt(StorageKeys.dailyAdCount) ?? 0;
  }

  /// 광고 시청 횟수 증가
  ///
  /// 광고를 시청할 때마다 카운터를 1 증가시킵니다.
  ///
  /// Returns: 증가된 후의 광고 개수
  Future<int> incrementAdCount() async {
    try {
      await initialize();
      await _checkAndResetDaily();

      final currentCount = _prefs!.getInt(StorageKeys.dailyAdCount) ?? 0;
      final newCount = currentCount + 1;

      await _prefs!.setInt(StorageKeys.dailyAdCount, newCount);
      await _updateLastAdDate();

      print('[FreeUserService] 광고 시청 횟수 증가: $currentCount → $newCount');

      return newCount;
    } catch (e) {
      print('[FreeUserService] incrementAdCount 실패: $e');
      rethrow;
    }
  }

  /// 남은 일일 광고 횟수 확인
  ///
  /// Returns: 오늘 남은 광고 시청 가능 횟수 (0 ~ 3)
  Future<int> getRemainingAdCount() async {
    final count = await getDailyAdCount();
    const maxDaily = 3;
    return (maxDaily - count).clamp(0, maxDaily);
  }

  /// 오늘 광고를 더 볼 수 있는지 확인
  ///
  /// Returns: true - 광고 시청 가능 / false - 하루 제한 도달
  Future<bool> canWatchAd() async {
    final remaining = await getRemainingAdCount();
    return remaining > 0;
  }

  /// 날짜 변경 확인 및 카운터 리셋
  ///
  /// 마지막 광고 시청 날짜와 현재 날짜를 비교하여
  /// 날짜가 바뀌었으면 카운터를 0으로 리셋합니다.
  Future<void> _checkAndResetDaily() async {
    await initialize();

    final today = _getTodayString();
    final lastDate = _prefs!.getString(StorageKeys.lastAdDate);

    // 날짜가 바뀌었으면 카운터 리셋
    if (lastDate != today) {
      print('[FreeUserService] 날짜 변경 감지: $lastDate → $today, 카운터 리셋');
      await _prefs!.setInt(StorageKeys.dailyAdCount, 0);
      await _prefs!.setString(StorageKeys.lastAdDate, today);
    }
  }

  /// 마지막 광고 시청 날짜 업데이트
  Future<void> _updateLastAdDate() async {
    await initialize();
    final today = _getTodayString();
    await _prefs!.setString(StorageKeys.lastAdDate, today);
  }

  /// 오늘 날짜를 ISO 8601 형식 문자열로 반환
  ///
  /// Returns: "YYYY-MM-DD" 형식의 날짜 문자열
  String _getTodayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  /// 다음 리셋 시간 계산
  ///
  /// 자정(00:00)까지 남은 시간을 계산합니다.
  ///
  /// Returns: 다음 리셋까지 남은 시간 (Duration)
  Duration getTimeUntilReset() {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    return tomorrow.difference(now);
  }

  /// 다음 리셋 시간을 문자열로 반환
  ///
  /// "5시간 30분 후" 형식으로 반환합니다.
  ///
  /// Returns: 리셋까지 남은 시간 문자열
  String getTimeUntilResetString() {
    final duration = getTimeUntilReset();
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return '$hours시간 ${minutes}분 후';
    } else {
      return '$minutes분 후';
    }
  }

  /// 테스트용: 카운터 강제 리셋
  ///
  /// 개발 및 테스트 시에만 사용하세요.
  Future<void> resetForTesting() async {
    await initialize();
    await _prefs!.setInt(StorageKeys.dailyAdCount, 0);
    await _prefs!.setString(StorageKeys.lastAdDate, _getTodayString());
    print('[FreeUserService] 테스트용 카운터 리셋 완료');
  }

  /// 테스트용: 특정 카운트로 설정
  ///
  /// 개발 및 테스트 시에만 사용하세요.
  Future<void> setAdCountForTesting(int count) async {
    await initialize();
    await _prefs!.setInt(StorageKeys.dailyAdCount, count);
    await _prefs!.setString(StorageKeys.lastAdDate, _getTodayString());
    print('[FreeUserService] 테스트용 카운터 설정: $count');
  }
}
