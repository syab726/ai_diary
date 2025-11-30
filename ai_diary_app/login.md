# 로그인 및 회원가입 시스템 구현 가이드

## 현재 상황 분석

### 기존 구현 상태
```dart
// lib/screens/login_screen.dart
- 익명 로그인만 구현됨 (개발용)
- 무료/프리미엄 버튼으로 임시 구분
- 실제 회원 인증 없음

// lib/services/auth_service.dart
- MockUser 클래스 사용 (가짜 사용자)
- Google/Apple 로그인 코드 존재하나 미사용
- Firebase 주석 처리됨

// main.dart
- Firebase 초기화 코드 주석 처리 (68-71 라인)
```

### 문제점
1. 사용자 계정이 없어서 기기 변경 시 데이터 복구 불가
2. 클라우드 백업 불가능 (사용자 UID 필요)
3. 프리미엄 구독 결제 연동 불가
4. 여러 기기에서 동기화 불가

---

## 구현 목표

### 최종 로그인 화면 구성
```
┌─────────────────────────────────┐
│      ArtDiary AI 로고           │
│                                 │
│  ┌───────────────────────────┐  │
│  │  Google로 계속하기        │  │ ← 메인 추천
│  └───────────────────────────┘  │
│                                 │
│  ┌───────────────────────────┐  │
│  │  Apple로 계속하기         │  │ ← iOS 필수
│  └───────────────────────────┘  │
│                                 │
│  ────────── 또는 ──────────    │
│                                 │
│  [ 무료 체험 시작 ]            │ ← 익명 로그인
│                                 │
│  (나중에 계정 연결 유도)        │
└─────────────────────────────────┘
```

### 사용자 유형
1. **익명 사용자** (Anonymous)
   - 계정 없이 체험
   - 로컬 데이터만
   - 기기 변경 시 데이터 손실
   - 나중에 Google/Apple 계정 연결 가능

2. **Google 사용자**
   - Google 계정으로 로그인
   - 클라우드 백업 가능 (프리미엄)
   - 여러 기기 동기화

3. **Apple 사용자**
   - Apple 계정으로 로그인
   - iOS 앱스토어 필수 요구사항
   - 클라우드 백업 가능 (프리미엄)

---

## Phase 1: Firebase 프로젝트 설정

### 1-1. Firebase Console에서 프로젝트 생성

**웹사이트:** https://console.firebase.google.com

**단계:**
```
1. "프로젝트 추가" 클릭
2. 프로젝트 이름: "artdiary-ai" 또는 원하는 이름
3. Google Analytics: 선택 (권장)
4. 프로젝트 생성 완료
```

### 1-2. Android 앱 등록

**Firebase Console > 프로젝트 설정 > Android 앱 추가**

```
Android 패키지 이름: com.aidiary.app.ai_diary_app
(android/app/src/main/AndroidManifest.xml에서 확인)

앱 닉네임: ArtDiary AI Android
```

**google-services.json 다운로드:**
```bash
# 다운로드한 파일을 프로젝트에 배치
ai_diary_app/
  └── android/
      └── app/
          └── google-services.json  ← 여기에 배치
```

**android/build.gradle 수정:**
```gradle
buildscript {
    dependencies {
        // 이미 있을 수 있음, 없으면 추가
        classpath 'com.google.gms:google-services:4.4.0'
    }
}
```

**android/app/build.gradle 수정:**
```gradle
// 파일 맨 아래에 추가
apply plugin: 'com.google.gms.google-services'
```

### 1-3. iOS 앱 등록

**Firebase Console > 프로젝트 설정 > iOS 앱 추가**

```
iOS 번들 ID: com.aidiary.app.aiDiaryApp
(ios/Runner.xcodeproj에서 확인)

앱 닉네임: ArtDiary AI iOS
```

**GoogleService-Info.plist 다운로드:**
```bash
# Xcode에서 프로젝트에 추가
ai_diary_app/
  └── ios/
      └── Runner/
          └── GoogleService-Info.plist  ← Xcode로 드래그 앤 드롭
```

**주의:** Xcode에서 "Copy items if needed" 체크!

### 1-4. Firebase Authentication 활성화

**Firebase Console > Authentication > Sign-in method**

**활성화할 로그인 방법:**
```
1. Google
   - 상태: 사용 설정
   - 지원 이메일: 본인 Gmail 주소

2. Apple
   - 상태: 사용 설정
   - Apple Developer 설정 필요 (아래 참고)

3. 익명 (Anonymous)
   - 상태: 사용 설정
   - 무료 체험용
```

---

## Phase 2: Apple 로그인 설정 (iOS 전용)

### 2-1. Apple Developer 설정

**웹사이트:** https://developer.apple.com/account

**단계:**
```
1. Certificates, Identifiers & Profiles 이동
2. Identifiers 선택
3. 앱 Bundle ID 찾기 (com.aidiary.app.aiDiaryApp)
4. Sign in with Apple 체크박스 활성화
5. 저장
```

### 2-2. Xcode 설정

**Xcode에서:**
```
1. Runner 프로젝트 선택
2. Signing & Capabilities 탭
3. "+ Capability" 클릭
4. "Sign in with Apple" 추가
```

### 2-3. Firebase Console에서 Apple 설정

**필요한 정보:**
```
- Service ID: (Firebase가 자동 생성)
- Team ID: Apple Developer 계정에서 확인
- Key ID: Apple Developer에서 생성
- Private Key: .p8 파일 다운로드
```

---

## Phase 3: Firestore Database 설정

### 3-1. Firestore Database 생성

**Firebase Console > Firestore Database > 데이터베이스 만들기**

**시작 모드:**
```
테스트 모드로 시작 (나중에 보안 규칙 적용)
```

**위치:**
```
asia-northeast3 (서울) 또는
asia-northeast1 (도쿄)
```

### 3-2. 데이터 구조 설계

```
firestore/
├── users/                          # 사용자 컬렉션
│   └── {userId}/                   # 문서 ID = Firebase Auth UID
│       ├── profile/                # 서브컬렉션: 프로필
│       │   └── main                # 기본 프로필 정보
│       │       ├── email: string
│       │       ├── displayName: string
│       │       ├── photoURL: string
│       │       ├── createdAt: timestamp
│       │       └── lastLoginAt: timestamp
│       │
│       ├── subscription/           # 서브컬렉션: 구독 정보
│       │   └── current             # 현재 구독 상태
│       │       ├── isPremium: boolean
│       │       ├── plan: string (free/premium_monthly/premium_yearly)
│       │       ├── startDate: timestamp
│       │       ├── expiryDate: timestamp
│       │       ├── autoRenew: boolean
│       │       └── lastPaymentDate: timestamp
│       │
│       └── settings/               # 서브컬렉션: 사용자 설정
│           └── preferences
│               ├── language: string
│               ├── theme: string
│               ├── fontSize: number
│               ├── fontFamily: string
│               ├── autoBackupEnabled: boolean
│               └── backupFrequency: string
│
└── app_metadata/                   # 앱 전역 메타데이터
    └── version
        └── current: string
```

### 3-3. Firestore 보안 규칙

**Firebase Console > Firestore Database > 규칙**

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // 인증된 사용자만 접근 가능
    function isSignedIn() {
      return request.auth != null;
    }

    // 본인 확인
    function isOwner(userId) {
      return isSignedIn() && request.auth.uid == userId;
    }

    // 사용자 데이터
    match /users/{userId} {
      // 본인만 읽기/쓰기 가능
      allow read, write: if isOwner(userId);

      // 프로필
      match /profile/{document=**} {
        allow read, write: if isOwner(userId);
      }

      // 구독 정보
      match /subscription/{document=**} {
        allow read: if isOwner(userId);
        // 구독 정보는 서버(Cloud Functions)에서만 쓰기
        allow write: if false;
      }

      // 설정
      match /settings/{document=**} {
        allow read, write: if isOwner(userId);
      }
    }

    // 앱 메타데이터는 모두 읽기 가능
    match /app_metadata/{document=**} {
      allow read: if true;
      allow write: if false;
    }
  }
}
```

---

## Phase 4: Firebase Storage 설정

### 4-1. Storage 생성

**Firebase Console > Storage > 시작하기**

**보안 규칙:**
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {

    // 사용자별 백업 폴더
    match /backups/{userId}/{allPaths=**} {
      // 본인만 업로드/다운로드 가능
      allow read, write: if request.auth != null && request.auth.uid == userId;

      // 파일 크기 제한: 50MB
      allow write: if request.resource.size < 50 * 1024 * 1024;
    }

    // 사용자 프로필 이미지
    match /profile_images/{userId}/{imageId} {
      allow read: if true;
      allow write: if request.auth != null && request.auth.uid == userId;

      // 이미지 크기 제한: 5MB
      allow write: if request.resource.size < 5 * 1024 * 1024
                   && request.resource.contentType.matches('image/.*');
    }
  }
}
```

---

## Phase 5: AuthService 업데이트

### 5-1. lib/services/auth_service.dart 전면 개편

**파일 위치:** `lib/services/auth_service.dart`

**완전한 구현:**

```dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'dart:io';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn();
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 현재 사용자
  static User? get currentUser => _auth.currentUser;

  // 인증 상태 스트림
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ========================================
  // Google 로그인
  // ========================================
  static Future<User?> signInWithGoogle() async {
    try {
      // 1. Google 로그인 시작
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        print('Google 로그인 취소됨');
        return null;
      }

      // 2. Google 인증 자격 증명 가져오기
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // 3. Firebase 자격 증명 생성
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 4. Firebase에 로그인
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        // 5. Firestore에 사용자 정보 저장/업데이트
        await _createOrUpdateUserInFirestore(user, 'google');
        print('Google 로그인 성공: ${user.email}');
      }

      return user;
    } catch (e) {
      print('Google 로그인 오류: $e');
      rethrow;
    }
  }

  // ========================================
  // Apple 로그인 (iOS 전용)
  // ========================================
  static Future<User?> signInWithApple() async {
    try {
      // iOS가 아니면 불가
      if (!Platform.isIOS) {
        throw Exception('Apple 로그인은 iOS에서만 가능합니다');
      }

      // 1. Apple 로그인 시작
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // 2. OAuth 프로바이더 생성
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      // 3. Firebase에 로그인
      final UserCredential userCredential = await _auth.signInWithCredential(oauthCredential);
      final User? user = userCredential.user;

      if (user != null) {
        // Apple은 이름을 처음에만 제공하므로 업데이트
        if (appleCredential.givenName != null || appleCredential.familyName != null) {
          await user.updateDisplayName(
            '${appleCredential.familyName ?? ''}${appleCredential.givenName ?? ''}'.trim()
          );
        }

        // 4. Firestore에 사용자 정보 저장/업데이트
        await _createOrUpdateUserInFirestore(user, 'apple');
        print('Apple 로그인 성공: ${user.email}');
      }

      return user;
    } catch (e) {
      print('Apple 로그인 오류: $e');
      rethrow;
    }
  }

  // ========================================
  // 익명 로그인 (무료 체험)
  // ========================================
  static Future<User?> signInAnonymously() async {
    try {
      final UserCredential userCredential = await _auth.signInAnonymously();
      final User? user = userCredential.user;

      if (user != null) {
        // Firestore에 익명 사용자 정보 저장
        await _createOrUpdateUserInFirestore(user, 'anonymous');
        print('익명 로그인 성공: ${user.uid}');
      }

      return user;
    } catch (e) {
      print('익명 로그인 오류: $e');
      rethrow;
    }
  }

  // ========================================
  // 익명 계정을 Google/Apple 계정으로 연결
  // ========================================
  static Future<User?> linkAnonymousWithGoogle() async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null || !currentUser.isAnonymous) {
        throw Exception('현재 익명 사용자가 아닙니다');
      }

      // 1. Google 로그인
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 2. 익명 계정에 Google 계정 연결
      final UserCredential userCredential = await currentUser.linkWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        // Firestore 업데이트
        await _updateUserProvider(user.uid, 'google');
        print('익명 계정이 Google 계정으로 연결됨: ${user.email}');
      }

      return user;
    } catch (e) {
      print('계정 연결 오류: $e');
      rethrow;
    }
  }

  static Future<User?> linkAnonymousWithApple() async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null || !currentUser.isAnonymous) {
        throw Exception('현재 익명 사용자가 아닙니다');
      }

      if (!Platform.isIOS) {
        throw Exception('Apple 로그인은 iOS에서만 가능합니다');
      }

      // 1. Apple 로그인
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      // 2. 익명 계정에 Apple 계정 연결
      final UserCredential userCredential = await currentUser.linkWithCredential(oauthCredential);
      final User? user = userCredential.user;

      if (user != null) {
        // Firestore 업데이트
        await _updateUserProvider(user.uid, 'apple');
        print('익명 계정이 Apple 계정으로 연결됨: ${user.email}');
      }

      return user;
    } catch (e) {
      print('계정 연결 오류: $e');
      rethrow;
    }
  }

  // ========================================
  // 로그아웃
  // ========================================
  static Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      print('로그아웃 성공');
    } catch (e) {
      print('로그아웃 오류: $e');
      rethrow;
    }
  }

  // ========================================
  // 계정 삭제
  // ========================================
  static Future<void> deleteAccount() async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) throw Exception('로그인된 사용자가 없습니다');

      // 1. Firestore에서 사용자 데이터 삭제
      await _deleteUserDataFromFirestore(user.uid);

      // 2. Storage에서 사용자 파일 삭제 (백업 파일 등)
      // TODO: Cloud Functions로 처리 권장

      // 3. Firebase Auth에서 계정 삭제
      await user.delete();

      print('계정 삭제 완료');
    } catch (e) {
      print('계정 삭제 오류: $e');
      rethrow;
    }
  }

  // ========================================
  // Firestore 헬퍼 함수들
  // ========================================

  // 사용자 생성 또는 업데이트
  static Future<void> _createOrUpdateUserInFirestore(User user, String provider) async {
    final userDoc = _firestore.collection('users').doc(user.uid);
    final docSnapshot = await userDoc.get();

    final now = FieldValue.serverTimestamp();

    if (!docSnapshot.exists) {
      // 신규 사용자: 전체 데이터 생성
      await userDoc.set({
        'createdAt': now,
        'lastLoginAt': now,
      });

      // 프로필 서브컬렉션
      await userDoc.collection('profile').doc('main').set({
        'email': user.email,
        'displayName': user.displayName,
        'photoURL': user.photoURL,
        'provider': provider,
        'isAnonymous': user.isAnonymous,
      });

      // 구독 서브컬렉션 (무료로 시작)
      await userDoc.collection('subscription').doc('current').set({
        'isPremium': false,
        'plan': 'free',
        'startDate': now,
        'expiryDate': null,
        'autoRenew': false,
      });

      // 설정 서브컬렉션 (기본값)
      await userDoc.collection('settings').doc('preferences').set({
        'language': 'ko',
        'theme': 'light',
        'fontSize': 16.0,
        'fontFamily': 'system',
        'autoBackupEnabled': false,
        'backupFrequency': 'daily',
      });

      print('새 사용자 Firestore에 생성: ${user.uid}');
    } else {
      // 기존 사용자: 마지막 로그인 시간만 업데이트
      await userDoc.update({
        'lastLoginAt': now,
      });

      print('기존 사용자 로그인 시간 업데이트: ${user.uid}');
    }
  }

  // 익명 사용자가 정식 계정으로 전환 시 provider 업데이트
  static Future<void> _updateUserProvider(String uid, String provider) async {
    final userDoc = _firestore.collection('users').doc(uid);

    await userDoc.collection('profile').doc('main').update({
      'provider': provider,
      'isAnonymous': false,
    });

    print('사용자 provider 업데이트: $provider');
  }

  // 사용자 데이터 삭제
  static Future<void> _deleteUserDataFromFirestore(String uid) async {
    final userDoc = _firestore.collection('users').doc(uid);

    // 서브컬렉션 삭제
    await _deleteCollection(userDoc.collection('profile'));
    await _deleteCollection(userDoc.collection('subscription'));
    await _deleteCollection(userDoc.collection('settings'));

    // 메인 문서 삭제
    await userDoc.delete();

    print('Firestore에서 사용자 데이터 삭제 완료: $uid');
  }

  // 컬렉션 전체 삭제 헬퍼
  static Future<void> _deleteCollection(CollectionReference collection) async {
    final snapshots = await collection.get();
    for (var doc in snapshots.docs) {
      await doc.reference.delete();
    }
  }

  // ========================================
  // 사용자 정보 조회
  // ========================================

  // 현재 사용자의 프리미엄 여부 확인
  static Future<bool> isPremiumUser() async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) return false;

      final subscriptionDoc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('subscription')
          .doc('current')
          .get();

      if (!subscriptionDoc.exists) return false;

      final data = subscriptionDoc.data();
      return data?['isPremium'] ?? false;
    } catch (e) {
      print('프리미엄 확인 오류: $e');
      return false;
    }
  }

  // 사용자 프로필 가져오기
  static Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) return null;

      final profileDoc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('profile')
          .doc('main')
          .get();

      return profileDoc.data();
    } catch (e) {
      print('프로필 조회 오류: $e');
      return null;
    }
  }

  // 사용자 설정 가져오기
  static Future<Map<String, dynamic>?> getUserSettings() async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) return null;

      final settingsDoc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('settings')
          .doc('preferences')
          .get();

      return settingsDoc.data();
    } catch (e) {
      print('설정 조회 오류: $e');
      return null;
    }
  }

  // 사용자 설정 업데이트
  static Future<void> updateUserSettings(Map<String, dynamic> settings) async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) throw Exception('로그인된 사용자가 없습니다');

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('settings')
          .doc('preferences')
          .update(settings);

      print('사용자 설정 업데이트 완료');
    } catch (e) {
      print('설정 업데이트 오류: $e');
      rethrow;
    }
  }
}
```

---

## Phase 6: main.dart Firebase 초기화

### 6-1. main.dart 수정

**파일 위치:** `lib/main.dart`

**변경 내용:**

```dart
// 기존 (68-71 라인):
// await Firebase.initializeApp(
//   options: DefaultFirebaseOptions.currentPlatform,
// );

// 수정 후:
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

**주석 제거하여 Firebase 초기화 활성화**

---

## Phase 7: 로그인 화면 UI 개편

### 7-1. lib/screens/login_screen.dart 전면 재작성

**파일 위치:** `lib/screens/login_screen.dart`

**완전한 구현:**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';
import '../providers/subscription_provider.dart';
import '../l10n/app_localizations.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _isLoading = false;

  // Google 로그인
  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);

    try {
      final user = await AuthService.signInWithGoogle();
      if (user != null && mounted) {
        // 프리미엄 여부 확인하여 상태 설정
        final isPremium = await AuthService.isPremiumUser();
        if (isPremium) {
          ref.read(subscriptionProvider.notifier).setPremiumUser();
        } else {
          ref.read(subscriptionProvider.notifier).setFreeUser();
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('환영합니다, ${user.displayName ?? user.email}님!'),
            backgroundColor: Colors.green,
          ),
        );

        context.go('/list');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Google 로그인 실패: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Apple 로그인
  Future<void> _signInWithApple() async {
    setState(() => _isLoading = true);

    try {
      final user = await AuthService.signInWithApple();
      if (user != null && mounted) {
        // 프리미엄 여부 확인하여 상태 설정
        final isPremium = await AuthService.isPremiumUser();
        if (isPremium) {
          ref.read(subscriptionProvider.notifier).setPremiumUser();
        } else {
          ref.read(subscriptionProvider.notifier).setFreeUser();
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('환영합니다, ${user.displayName ?? user.email}님!'),
            backgroundColor: Colors.green,
          ),
        );

        context.go('/list');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Apple 로그인 실패: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // 익명 로그인 (무료 체험)
  Future<void> _signInAnonymously() async {
    setState(() => _isLoading = true);

    try {
      final user = await AuthService.signInAnonymously();
      if (user != null && mounted) {
        ref.read(subscriptionProvider.notifier).setFreeUser();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('무료 체험을 시작합니다'),
            backgroundColor: Colors.orange,
          ),
        );

        context.go('/list');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('체험 시작 실패: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 로고 또는 앱 아이콘
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: const Color(0xFF6B73FF),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6B73FF).withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.auto_stories,
                    size: 60,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 32),

                // 앱 이름
                Text(
                  'ArtDiary AI',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF6B73FF),
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'AI가 그려주는 나만의 그림일기',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),

                const SizedBox(height: 48),

                // 로딩 중이면 표시
                if (_isLoading)
                  const CircularProgressIndicator()
                else ...[
                  // Google 로그인 버튼
                  _buildSocialLoginButton(
                    onPressed: _signInWithGoogle,
                    icon: Icons.g_mobiledata,
                    label: 'Google로 계속하기',
                    backgroundColor: Colors.white,
                    textColor: Colors.black87,
                  ),

                  const SizedBox(height: 16),

                  // Apple 로그인 버튼 (iOS만)
                  if (Theme.of(context).platform == TargetPlatform.iOS)
                    _buildSocialLoginButton(
                      onPressed: _signInWithApple,
                      icon: Icons.apple,
                      label: 'Apple로 계속하기',
                      backgroundColor: Colors.black,
                      textColor: Colors.white,
                    ),

                  if (Theme.of(context).platform == TargetPlatform.iOS)
                    const SizedBox(height: 24),

                  // 구분선
                  if (Theme.of(context).platform != TargetPlatform.iOS)
                    const SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.grey[300])),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          '또는',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                      Expanded(child: Divider(color: Colors.grey[300])),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // 무료 체험 버튼
                  TextButton(
                    onPressed: _signInAnonymously,
                    child: Text(
                      '무료 체험 시작',
                      style: TextStyle(
                        fontSize: 16,
                        color: const Color(0xFF6B73FF),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 안내 문구
                  Text(
                    '※ 나중에 계정을 연결하여 데이터를 보관할 수 있습니다',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 소셜 로그인 버튼 위젯
  Widget _buildSocialLoginButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required Color backgroundColor,
    required Color textColor,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 24, color: textColor),
        label: Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          elevation: 2,
          shadowColor: Colors.black26,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: backgroundColor == Colors.white
                ? BorderSide(color: Colors.grey[300]!)
                : BorderSide.none,
          ),
        ),
      ),
    );
  }
}
```

---

## Phase 8: AuthProvider 업데이트

### 8-1. lib/providers/auth_provider.dart 수정

**파일 위치:** `lib/providers/auth_provider.dart`

**기존 MockUser 제거하고 실제 Firebase User 사용:**

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

// 현재 라우트 저장용 Provider (언어 변경 후 복귀용)
final currentRouteProvider = StateProvider<String?>((ref) => null);

// 인증 상태 스트림 Provider
final authStateProvider = StreamProvider<User?>((ref) {
  return AuthService.authStateChanges;
});

// 현재 사용자 Provider
final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.whenOrNull(data: (user) => user);
});

// 익명 사용자 여부 Provider
final isAnonymousProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.isAnonymous ?? false;
});
```

---

## Phase 9: SubscriptionProvider와 Firestore 연동

### 9-1. lib/providers/subscription_provider.dart 업데이트

**파일 위치:** `lib/providers/subscription_provider.dart`

**Firestore와 실시간 동기화:**

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

// 구독 상태 모델
class SubscriptionState {
  final bool isPremium;
  final String plan; // free, premium_monthly, premium_yearly
  final DateTime? expiryDate;
  final bool autoRenew;

  SubscriptionState({
    required this.isPremium,
    this.plan = 'free',
    this.expiryDate,
    this.autoRenew = false,
  });

  SubscriptionState copyWith({
    bool? isPremium,
    String? plan,
    DateTime? expiryDate,
    bool? autoRenew,
  }) {
    return SubscriptionState(
      isPremium: isPremium ?? this.isPremium,
      plan: plan ?? this.plan,
      expiryDate: expiryDate ?? this.expiryDate,
      autoRenew: autoRenew ?? this.autoRenew,
    );
  }
}

// Firestore에서 구독 정보 실시간 스트림
final subscriptionStreamProvider = StreamProvider<SubscriptionState>((ref) {
  final user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    return Stream.value(SubscriptionState(isPremium: false));
  }

  return FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('subscription')
      .doc('current')
      .snapshots()
      .map((snapshot) {
    if (!snapshot.exists) {
      return SubscriptionState(isPremium: false);
    }

    final data = snapshot.data()!;
    return SubscriptionState(
      isPremium: data['isPremium'] ?? false,
      plan: data['plan'] ?? 'free',
      expiryDate: data['expiryDate'] != null
          ? (data['expiryDate'] as Timestamp).toDate()
          : null,
      autoRenew: data['autoRenew'] ?? false,
    );
  });
});

// 구독 상태 Provider (호환성 유지)
final subscriptionProvider = StateNotifierProvider<SubscriptionNotifier, SubscriptionState>((ref) {
  return SubscriptionNotifier(ref);
});

class SubscriptionNotifier extends StateNotifier<SubscriptionState> {
  final Ref _ref;

  SubscriptionNotifier(this._ref) : super(SubscriptionState(isPremium: false)) {
    // Firestore 스트림 구독
    _ref.listen(subscriptionStreamProvider, (previous, next) {
      next.whenData((subscriptionState) {
        state = subscriptionState;
      });
    });
  }

  // 무료 사용자로 설정 (하위 호환)
  void setFreeUser() {
    state = SubscriptionState(isPremium: false, plan: 'free');
  }

  // 프리미엄 사용자로 설정 (하위 호환)
  void setPremiumUser() {
    state = SubscriptionState(isPremium: true, plan: 'premium_monthly');
  }

  // Firestore에 프리미엄 상태 저장
  Future<void> updatePremiumStatus({
    required bool isPremium,
    String plan = 'premium_monthly',
    DateTime? expiryDate,
    bool autoRenew = true,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('subscription')
        .doc('current')
        .update({
      'isPremium': isPremium,
      'plan': plan,
      'expiryDate': expiryDate != null ? Timestamp.fromDate(expiryDate) : null,
      'autoRenew': autoRenew,
      'lastPaymentDate': FieldValue.serverTimestamp(),
    });
  }
}
```

---

## Phase 10: 설정 화면에 계정 정보 추가

### 10-1. lib/screens/settings_screen.dart에 프로필 섹션 추가

**추가할 위젯:**

```dart
// 설정 화면 맨 위에 추가
Widget _buildProfileSection(User? user) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Row(
      children: [
        // 프로필 이미지
        CircleAvatar(
          radius: 30,
          backgroundImage: user?.photoURL != null
              ? NetworkImage(user!.photoURL!)
              : null,
          child: user?.photoURL == null
              ? const Icon(Icons.person, size: 30)
              : null,
        ),

        const SizedBox(width: 16),

        // 사용자 정보
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user?.displayName ?? user?.email ?? '익명 사용자',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                user?.email ?? '계정을 연결하지 않았습니다',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              if (user?.isAnonymous == true)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: TextButton.icon(
                    onPressed: () {
                      // 계정 연결 다이얼로그 표시
                      _showLinkAccountDialog(context);
                    },
                    icon: const Icon(Icons.link, size: 16),
                    label: const Text('계정 연결하기'),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ),
            ],
          ),
        ),

        // 로그아웃 버튼
        IconButton(
          onPressed: () async {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('로그아웃'),
                content: const Text('정말 로그아웃하시겠습니까?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('취소'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('로그아웃'),
                  ),
                ],
              ),
            );

            if (confirm == true) {
              await AuthService.signOut();
              if (context.mounted) {
                context.go('/login');
              }
            }
          },
          icon: const Icon(Icons.logout),
          tooltip: '로그아웃',
        ),
      ],
    ),
  );
}

// 계정 연결 다이얼로그
void _showLinkAccountDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('계정 연결'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('데이터를 안전하게 보관하려면 계정을 연결하세요.'),
          const SizedBox(height: 16),

          // Google 연결 버튼
          ElevatedButton.icon(
            onPressed: () async {
              try {
                Navigator.pop(context);
                await AuthService.linkAnonymousWithGoogle();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Google 계정이 연결되었습니다'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('연결 실패: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            icon: const Icon(Icons.g_mobiledata),
            label: const Text('Google 계정 연결'),
          ),

          const SizedBox(height: 8),

          // Apple 연결 버튼 (iOS만)
          if (Theme.of(context).platform == TargetPlatform.iOS)
            ElevatedButton.icon(
              onPressed: () async {
                try {
                  Navigator.pop(context);
                  await AuthService.linkAnonymousWithApple();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Apple 계정이 연결되었습니다'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('연결 실패: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              icon: const Icon(Icons.apple),
              label: const Text('Apple 계정 연결'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소'),
        ),
      ],
    ),
  );
}
```

---

## Phase 11: 백업 시스템과 Firebase Storage 연동

### 11-1. lib/services/backup_service.dart 생성

**Firebase Storage를 사용한 클라우드 백업:**

```dart
import 'dart:io';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'database_service.dart';

class BackupService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // 클라우드 백업 (프리미엄 전용)
  static Future<String?> uploadBackupToCloud() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('로그인된 사용자가 없습니다');

      // 1. 백업 데이터 생성
      final diaries = await DatabaseService.getAllDiariesForBackup();
      final backupData = {
        'app_name': 'ArtDiary AI',
        'backup_date': DateTime.now().toIso8601String(),
        'version': '1.0.0',
        'user_id': user.uid,
        'total_entries': diaries.length,
        'entries': diaries.map((diary) => diary.toMap()).toList(),
      };

      // 2. JSON 문자열로 변환
      final jsonString = jsonEncode(backupData);

      // 3. 임시 파일에 저장
      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final tempFile = File('${directory.path}/backup_$timestamp.json');
      await tempFile.writeAsString(jsonString);

      // 4. Firebase Storage에 업로드
      final storageRef = _storage.ref().child('backups/${user.uid}/backup_$timestamp.json');
      final uploadTask = storageRef.putFile(tempFile);

      // 업로드 진행률 모니터링 (선택사항)
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
        print('업로드 진행률: ${progress.toStringAsFixed(2)}%');
      });

      // 5. 업로드 완료 대기
      await uploadTask;

      // 6. 다운로드 URL 가져오기
      final downloadUrl = await storageRef.getDownloadURL();

      // 7. 임시 파일 삭제
      await tempFile.delete();

      print('클라우드 백업 완료: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print('클라우드 백업 오류: $e');
      rethrow;
    }
  }

  // 클라우드에서 백업 복원
  static Future<void> restoreFromCloud(String backupFileName) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('로그인된 사용자가 없습니다');

      // 1. Storage에서 파일 다운로드
      final storageRef = _storage.ref().child('backups/${user.uid}/$backupFileName');
      final directory = await getTemporaryDirectory();
      final localFile = File('${directory.path}/restore_temp.json');

      await storageRef.writeToFile(localFile);

      // 2. JSON 파싱
      final jsonString = await localFile.readAsString();
      final backupData = jsonDecode(jsonString);

      // 3. 데이터베이스에 복원
      // TODO: 복원 로직 구현

      // 4. 임시 파일 삭제
      await localFile.delete();

      print('클라우드 복원 완료');
    } catch (e) {
      print('클라우드 복원 오류: $e');
      rethrow;
    }
  }

  // 사용자의 모든 클라우드 백업 목록 가져오기
  static Future<List<String>> getCloudBackupList() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return [];

      final storageRef = _storage.ref().child('backups/${user.uid}');
      final result = await storageRef.listAll();

      return result.items.map((item) => item.name).toList();
    } catch (e) {
      print('백업 목록 조회 오류: $e');
      return [];
    }
  }

  // 오래된 백업 자동 삭제 (최근 10개만 유지)
  static Future<void> cleanOldBackups() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final backupList = await getCloudBackupList();
      if (backupList.length <= 10) return;

      // 파일명으로 정렬 (timestamp 기준)
      backupList.sort();

      // 오래된 파일 삭제
      final filesToDelete = backupList.take(backupList.length - 10);
      for (final fileName in filesToDelete) {
        final storageRef = _storage.ref().child('backups/${user.uid}/$fileName');
        await storageRef.delete();
        print('오래된 백업 삭제: $fileName');
      }
    } catch (e) {
      print('백업 정리 오류: $e');
    }
  }
}
```

---

## Phase 12: 테스트 및 검증

### 12-1. 테스트 체크리스트

```
□ Firebase 프로젝트 생성 완료
□ Android google-services.json 배치 완료
□ iOS GoogleService-Info.plist 배치 완료
□ Firebase Authentication 활성화 (Google, Apple, Anonymous)
□ Firestore Database 생성 완료
□ Firebase Storage 생성 완료
□ 보안 규칙 설정 완료

□ Google 로그인 동작 확인
□ Apple 로그인 동작 확인 (iOS)
□ 익명 로그인 동작 확인
□ 익명 → Google/Apple 계정 연결 동작 확인

□ Firestore에 사용자 데이터 저장 확인
□ 프리미엄 상태 실시간 동기화 확인
□ 클라우드 백업 업로드 확인
□ 클라우드 백업 복원 확인

□ 로그아웃 동작 확인
□ 계정 삭제 동작 확인
```

---

## 보안 및 개인정보 고려사항

### 1. 개인정보 처리방침 필수
- 앱스토어 제출 시 필수
- 웹사이트에 게시 필요
- Firebase가 수집하는 정보 명시

### 2. Apple 로그인 관련
- iOS 앱에서 다른 소셜 로그인 제공 시 Apple 로그인 필수
- "Sign in with Apple" 버튼을 가장 상단에 배치 (애플 가이드라인)
- 사용자가 이메일 숨김 기능 사용 가능 (relay email)

### 3. Firebase 보안 규칙 중요
- Firestore/Storage 보안 규칙 반드시 설정
- 테스트 모드는 30일 후 자동 만료
- 프로덕션 배포 전 규칙 검토 필수

---

## 비용 및 할당량

### Firebase 무료 플랜 (Spark Plan)

```
Authentication: 무제한
Firestore:
  - 저장: 1GB
  - 읽기: 50,000/일
  - 쓰기: 20,000/일
  - 삭제: 20,000/일

Storage:
  - 저장: 5GB
  - 다운로드: 1GB/일
  - 업로드: 무제한

→ 약 1만 명의 활성 사용자까지 무료로 충분
```

---

## 다음 단계

**Phase 1-5 완료 후:**
1. In-App Purchase 연동 (구독 결제)
2. 푸시 알림 (Firebase Cloud Messaging)
3. 앱 분석 (Firebase Analytics)
4. 충돌 리포트 (Firebase Crashlytics)
5. 원격 구성 (Firebase Remote Config)

**최종 목표:**
- 완전한 클라우드 동기화
- 크로스 플랫폼 데이터 공유
- 안정적인 프리미엄 구독 시스템

---

## 문제 해결

### 자주 발생하는 오류

**1. Firebase 초기화 실패**
```
해결: google-services.json / GoogleService-Info.plist 파일 위치 확인
```

**2. Google 로그인 실패 (Android)**
```
해결: SHA-1 인증서 지문을 Firebase Console에 등록
명령어: keytool -list -v -alias androiddebugkey -keystore ~/.android/debug.keystore
```

**3. Apple 로그인 실패 (iOS)**
```
해결: Xcode의 Signing & Capabilities에서 Sign in with Apple 추가 확인
```

**4. Firestore 권한 거부**
```
해결: 보안 규칙 확인 및 사용자 인증 상태 확인
```

---

## 요약

이 문서의 모든 Phase를 완료하면:

1. Google/Apple 소셜 로그인 완료
2. 익명 체험 및 계정 연결 기능
3. Firestore에 사용자 데이터 안전 저장
4. Firebase Storage 클라우드 백업
5. 프리미엄 구독 준비 완료

**예상 개발 시간:** 3-5일 (Firebase 설정 포함)
