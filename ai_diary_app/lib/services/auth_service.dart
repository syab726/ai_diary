import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'dart:async';
import 'dart:io';

// 개발용 가짜 User 클래스
class MockUser {
  final String uid;
  final String? email;
  final String? displayName;
  final bool isAnonymous;
  
  MockUser({
    required this.uid,
    this.email,
    this.displayName,
    this.isAnonymous = false,
  });
}

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn();
  
  // 개발용 로컬 상태 관리
  static MockUser? _currentMockUser;
  static final StreamController<MockUser?> _authStateController = StreamController<MockUser?>.broadcast();

  // 현재 사용자 (개발용)
  static MockUser? get currentUser => _currentMockUser;

  // 인증 상태 스트림 (개발용)
  static Stream<MockUser?> get authStateChanges => _authStateController.stream;

  // Google 로그인
  static Future<User?> signInWithGoogle() async {
    try {
      // Google 로그인 시작
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // 사용자가 취소

      // Google 인증 자격 증명 가져오기
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Firebase 자격 증명 생성
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Firebase로 로그인
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      return userCredential.user;
    } catch (e) {
      print('Google 로그인 오류: $e');
      rethrow;
    }
  }

  // Apple 로그인 (iOS만)
  static Future<User?> signInWithApple() async {
    if (!Platform.isIOS) {
      throw UnsupportedError('Apple 로그인은 iOS에서만 사용 가능합니다');
    }

    try {
      // Apple 로그인 요청
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // OAuth 자격 증명 생성
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: credential.identityToken,
        accessToken: credential.authorizationCode,
      );

      // Firebase로 로그인
      final UserCredential userCredential = await _auth.signInWithCredential(oauthCredential);
      return userCredential.user;
    } catch (e) {
      print('Apple 로그인 오류: $e');
      rethrow;
    }
  }

  // 익명 로그인 (개발용)
  static Future<MockUser?> signInAnonymously() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500)); // 로딩 시뮬레이션
      _currentMockUser = MockUser(
        uid: 'anonymous-${DateTime.now().millisecondsSinceEpoch}',
        isAnonymous: true,
      );
      _authStateController.add(_currentMockUser);
      return _currentMockUser;
    } catch (e) {
      print('익명 로그인 오류: $e');
      rethrow;
    }
  }

  // 로그아웃 (개발용)
  static Future<void> signOut() async {
    try {
      await Future.delayed(const Duration(milliseconds: 200)); // 로딩 시뮬레이션
      _currentMockUser = null;
      _authStateController.add(null);
    } catch (e) {
      print('로그아웃 오류: $e');
      rethrow;
    }
  }

  // 계정 삭제
  static Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.delete();
      }
    } catch (e) {
      print('계정 삭제 오류: $e');
      rethrow;
    }
  }

  // 사용자 정보 업데이트
  static Future<void> updateProfile({String? displayName, String? photoURL}) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.updateDisplayName(displayName);
        await user.updatePhotoURL(photoURL);
      }
    } catch (e) {
      print('프로필 업데이트 오류: $e');
      rethrow;
    }
  }

  // 익명 사용자를 영구 계정으로 연결
  static Future<User?> linkWithGoogle() async {
    try {
      final user = _auth.currentUser;
      if (user == null || !user.isAnonymous) return null;

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await user.linkWithCredential(credential);
      return userCredential.user;
    } catch (e) {
      print('계정 연결 오류: $e');
      rethrow;
    }
  }
}