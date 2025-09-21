import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';

// 현재 사용자 상태를 관리하는 Provider (개발용 MockUser)
final authStateProvider = StreamProvider<MockUser?>((ref) {
  return AuthService.authStateChanges;
});

// 현재 사용자 정보 Provider (개발용 MockUser)
final currentUserProvider = Provider<MockUser?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.whenOrNull(data: (user) => user);
});

// 로그인 상태 Provider
final isLoggedInProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user != null;
});

// 익명 사용자 여부 Provider
final isAnonymousProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.isAnonymous ?? false;
});