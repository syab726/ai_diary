import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/cloud_sync_service.dart';
import '../utils/app_logger.dart';
import 'subscription_provider.dart';

/// 자동 백업 설정 상태
class AutoBackupState {
  final bool isEnabled;
  final DateTime? lastBackupTime;
  final bool isBackingUp;
  final String? lastError;

  const AutoBackupState({
    this.isEnabled = false,
    this.lastBackupTime,
    this.isBackingUp = false,
    this.lastError,
  });

  AutoBackupState copyWith({
    bool? isEnabled,
    DateTime? lastBackupTime,
    bool? isBackingUp,
    String? lastError,
  }) {
    return AutoBackupState(
      isEnabled: isEnabled ?? this.isEnabled,
      lastBackupTime: lastBackupTime ?? this.lastBackupTime,
      isBackingUp: isBackingUp ?? this.isBackingUp,
      lastError: lastError ?? this.lastError,
    );
  }
}

/// 자동 백업 Provider
class AutoBackupNotifier extends StateNotifier<AutoBackupState> {
  Timer? _timer;
  final Ref ref;

  AutoBackupNotifier(this.ref) : super(const AutoBackupState()) {
    _loadSettings();
  }

  /// 설정 불러오기
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isEnabled = prefs.getBool('auto_backup_enabled') ?? false;
      final lastBackupTimestamp = prefs.getInt('last_backup_time');

      state = state.copyWith(
        isEnabled: isEnabled,
        lastBackupTime: lastBackupTimestamp != null
            ? DateTime.fromMillisecondsSinceEpoch(lastBackupTimestamp)
            : null,
      );

      AppLogger.log('자동 백업 설정 로드: 활성화=$isEnabled');

      if (isEnabled) {
        _startTimer();
      }
    } catch (e) {
      AppLogger.log('자동 백업 설정 로드 오류: $e');
    }
  }

  /// 자동 백업 활성화/비활성화
  Future<void> setEnabled(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('auto_backup_enabled', enabled);

      state = state.copyWith(isEnabled: enabled);
      AppLogger.log('자동 백업 ${enabled ? "활성화" : "비활성화"}');

      if (enabled) {
        _startTimer();
        // 즉시 한 번 백업 실행
        await performBackup();
      } else {
        _stopTimer();
      }
    } catch (e) {
      AppLogger.log('자동 백업 설정 저장 오류: $e');
    }
  }

  /// 타이머 시작 (5분마다)
  void _startTimer() {
    _stopTimer(); // 기존 타이머 정리

    AppLogger.log('자동 백업 타이머 시작 (5분 간격)');

    // 5분마다 백업 체크
    _timer = Timer.periodic(const Duration(minutes: 5), (timer) {
      AppLogger.log('자동 백업 타이머 트리거');
      performBackup();
    });
  }

  /// 타이머 정지
  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
    AppLogger.log('자동 백업 타이머 정지');
  }

  /// 백업 실행
  Future<void> performBackup() async {
    if (!state.isEnabled) {
      AppLogger.log('자동 백업 비활성화 상태 - 건너뜀');
      return;
    }

    if (state.isBackingUp) {
      AppLogger.log('이미 백업 진행 중 - 건너뜀');
      return;
    }

    try {
      state = state.copyWith(isBackingUp: true, lastError: null);
      AppLogger.log('=== 자동 백업 시작 ===');

      // 프리미엄 사용자 확인
      final subscription = ref.read(subscriptionProvider);
      final isPremium = subscription.isPremium;

      AppLogger.log('사용자 유형: ${isPremium ? "프리미엄" : "무료"}');

      // CloudSyncService의 autoSync 호출
      // (내부적으로 마지막 동기화 시간 체크 후 5분 이상 경과 시에만 백업)
      await CloudSyncService.autoSync(isPremium: isPremium);

      // 마지막 백업 시간 저장
      final now = DateTime.now();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('last_backup_time', now.millisecondsSinceEpoch);

      state = state.copyWith(
        isBackingUp: false,
        lastBackupTime: now,
        lastError: null,
      );

      AppLogger.log('=== 자동 백업 완료 ===');
    } catch (e) {
      AppLogger.log('자동 백업 오류: $e');
      state = state.copyWith(
        isBackingUp: false,
        lastError: e.toString(),
      );
    }
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }
}

/// 자동 백업 상태 Provider
final autoBackupProvider = StateNotifierProvider<AutoBackupNotifier, AutoBackupState>((ref) {
  return AutoBackupNotifier(ref);
});
