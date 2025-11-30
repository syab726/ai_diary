import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';

/// 네트워크 오류 처리 및 재시도 로직을 제공하는 헬퍼 클래스
class NetworkHelper {
  /// API 호출에 대한 재시도 로직 (Exponential Backoff)
  ///
  /// [fn]: 실행할 비동기 함수
  /// [maxAttempts]: 최대 재시도 횟수 (기본값: 3)
  /// [timeout]: 타임아웃 시간 (기본값: 30초)
  /// [retryableErrors]: 재시도 가능한 에러 타입들
  static Future<T> retryOnNetworkError<T>({
    required Future<T> Function() fn,
    int maxAttempts = 3,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    int attempt = 0;

    while (attempt < maxAttempts) {
      attempt++;

      try {
        if (kDebugMode) print('[NetworkHelper] 시도 $attempt/$maxAttempts');

        // 타임아웃 설정과 함께 함수 실행
        final result = await fn().timeout(
          timeout,
          onTimeout: () {
            throw TimeoutException(
              '요청 시간이 초과되었습니다 (${timeout.inSeconds}초)',
            );
          },
        );

        if (kDebugMode) print('[NetworkHelper] 요청 성공 (시도 $attempt)');
        return result;

      } on SocketException catch (e) {
        if (kDebugMode) print('[NetworkHelper] 네트워크 오류: $e');
        if (attempt == maxAttempts) {
          throw NetworkException('인터넷 연결을 확인해주세요');
        }

      } on TimeoutException catch (e) {
        if (kDebugMode) print('[NetworkHelper] 타임아웃 오류: $e');
        if (attempt == maxAttempts) {
          throw NetworkException('요청 시간이 초과되었습니다. 다시 시도해주세요');
        }

      } on HttpException catch (e) {
        if (kDebugMode) print('[NetworkHelper] HTTP 오류: $e');
        if (attempt == maxAttempts) {
          throw NetworkException('서버 연결에 실패했습니다');
        }

      } catch (e) {
        // 재시도 불가능한 오류는 바로 throw
        if (kDebugMode) print('[NetworkHelper] 재시도 불가능한 오류: $e');
        rethrow;
      }

      // Exponential backoff: 2초, 4초, 8초...
      final delaySeconds = 2 * attempt;
      if (attempt < maxAttempts) {
        if (kDebugMode) print('[NetworkHelper] $delaySeconds초 후 재시도...');
        await Future.delayed(Duration(seconds: delaySeconds));
      }
    }

    // 여기 도달할 수 없지만 컴파일 오류 방지
    throw NetworkException('알 수 없는 오류가 발생했습니다');
  }

  /// 사용자 친화적인 에러 메시지로 변환
  static String getErrorMessage(dynamic error) {
    if (error is NetworkException) {
      return error.message;
    } else if (error is SocketException) {
      return '인터넷 연결을 확인해주세요';
    } else if (error is TimeoutException) {
      return '요청 시간이 초과되었습니다. 다시 시도해주세요';
    } else if (error is HttpException) {
      return '서버 연결에 실패했습니다';
    } else if (error.toString().contains('API key')) {
      return 'API 인증에 실패했습니다';
    } else if (error.toString().contains('quota')) {
      return 'API 사용량이 초과되었습니다';
    } else {
      return '일시적인 오류가 발생했습니다. 잠시 후 다시 시도해주세요';
    }
  }
}

/// 커스텀 네트워크 예외 클래스
class NetworkException implements Exception {
  final String message;

  NetworkException(this.message);

  @override
  String toString() => message;
}
