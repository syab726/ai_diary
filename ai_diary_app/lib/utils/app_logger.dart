import 'package:flutter/foundation.dart';

/// 앱 로거 유틸리티
///
/// 디버그 모드에서만 로그를 출력하고, 프로덕션 빌드에서는 완전히 제거됩니다.
///
/// 사용법:
/// ```dart
/// AppLogger.log('디버그 메시지');
/// AppLogger.error('에러 메시지');
/// AppLogger.info('정보 메시지');
/// ```
class AppLogger {
  /// 일반 로그 출력 (디버그 모드에서만)
  static void log(String message) {
    if (kDebugMode) {
      print(message);
    }
  }

  /// 에러 로그 출력 (디버그 모드에서만)
  static void error(String message) {
    if (kDebugMode) {
      print('❌ ERROR: $message');
    }
  }

  /// 정보 로그 출력 (디버그 모드에서만)
  static void info(String message) {
    if (kDebugMode) {
      print('ℹ️ INFO: $message');
    }
  }

  /// 경고 로그 출력 (디버그 모드에서만)
  static void warning(String message) {
    if (kDebugMode) {
      print('⚠️ WARNING: $message');
    }
  }

  /// 성공 로그 출력 (디버그 모드에서만)
  static void success(String message) {
    if (kDebugMode) {
      print('✅ SUCCESS: $message');
    }
  }
}
