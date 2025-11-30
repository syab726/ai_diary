import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../utils/app_logger.dart';

/// 네트워크 연결 상태 Provider
final connectivityProvider = StreamProvider<bool>((ref) {
  final connectivity = Connectivity();

  return connectivity.onConnectivityChanged.map((List<ConnectivityResult> results) {
    // 하나라도 연결된 상태가 있으면 온라인
    final isOnline = results.any((result) =>
      result != ConnectivityResult.none
    );

    AppLogger.log('네트워크 상태 변경: ${isOnline ? "온라인" : "오프라인"}');
    return isOnline;
  });
});

/// 현재 연결 상태를 즉시 확인하는 Provider
final currentConnectivityProvider = FutureProvider<bool>((ref) async {
  final connectivity = Connectivity();
  final results = await connectivity.checkConnectivity();

  final isOnline = results.any((result) =>
    result != ConnectivityResult.none
  );

  AppLogger.log('현재 네트워크 상태: ${isOnline ? "온라인" : "오프라인"}');
  return isOnline;
});
