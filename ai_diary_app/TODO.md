# Firebase 로그인 기능 구현 TODO

## 현재 상태

### 완료된 작업
- [x] Firebase Android 설정 (google-services.json 추가)
- [x] Firebase iOS 설정 (GoogleService-Info.plist 추가)
- [x] main.dart Firebase 초기화
- [x] iOS AppDelegate.swift Firebase 초기화
- [x] 필요한 패키지 추가 (cloud_firestore, firebase_storage)
- [x] flutter pub get 실행
- [x] Firebase Authentication 제공업체 추가
  - [x] Google 인증
  - [x] Anonymous (익명) 인증
  - [x] Apple 인증 (부분 완료 - iOS 개발자 계정 필요)

### 진행 중인 작업
- [ ] Firebase Console 설정 완료
  - [x] Firebase Authentication 제공업체 설정
  - [ ] Firestore Database 생성
  - [ ] Firebase Storage 생성
  - [ ] 보안 규칙 설정

## 남은 작업

### 1. Firebase Console 설정 (수동 작업 필요)

#### Firestore Database 생성
1. Firebase Console → Firestore Database
2. "데이터베이스 만들기" 클릭
3. 테스트 모드로 시작 선택
4. 위치: asia-northeast3 (서울) 선택
5. 보안 규칙 설정:
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

#### Firebase Storage 생성
1. Firebase Console → Storage
2. "시작하기" 클릭
3. 테스트 모드로 시작
4. 위치: asia-northeast3 (서울) 선택
5. 보안 규칙 설정:
```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /users/{userId}/{allPaths=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

### 2. 코드 구현 (login.md 파일 참조)

- [ ] AuthService 완전 재작성 (Google/Apple/익명 로그인)
  - 파일: lib/services/auth_service.dart
  - 약 700+ 줄

- [ ] LoginScreen UI 재작성
  - 파일: lib/screens/login_screen.dart
  - 소셜 로그인 버튼 UI
  - 로그인 상태 처리

- [ ] AuthProvider 업데이트
  - 파일: lib/providers/auth_provider.dart
  - Firebase User 사용하도록 변경

- [ ] SubscriptionProvider Firestore 연동
  - 파일: lib/providers/subscription_provider.dart
  - Firestore에서 구독 정보 읽기/쓰기

- [ ] Settings 화면에 프로필 섹션 추가
  - 파일: lib/screens/settings_screen.dart
  - 로그인 정보 표시
  - 계정 연결/해제 기능

- [ ] BackupService Firebase Storage 연동
  - 파일: lib/services/backup_service.dart
  - 일기 데이터 백업/복원

### 3. iOS 관련 작업 (iOS 개발자 계정 필요 - 나중에 진행)

**중요: 현재 iOS 개발자 계정이 없어 보류 중**

- [ ] iOS 개발자 프로그램 가입 ($99/년)
- [ ] Apple Developer Console 설정
  - [ ] App ID 생성
  - [ ] Sign in with Apple Capability 활성화
  - [ ] Key 생성 (Apple 인증용)
- [ ] Xcode 설정
  - [ ] Sign in with Apple Capability 추가
  - [ ] Bundle ID 확인: com.aidiary.app.aiDiaryApp
- [ ] Firebase Console Apple 인증 완전 설정
  - [ ] Apple 팀 ID 입력
  - [ ] Key ID 입력
  - [ ] 비공개 키(.p8) 업로드
- [ ] 실제 iOS 기기에서 Apple 로그인 테스트

### 4. 테스트 (모든 구현 후)

- [ ] Google 로그인 테스트 (Android)
- [ ] Google 로그인 테스트 (iOS)
- [ ] Apple 로그인 테스트 (iOS - 실제 기기 필요)
- [ ] 익명 로그인 테스트
- [ ] 계정 연결 테스트
- [ ] 로그아웃 테스트
- [ ] Firestore 데이터 읽기/쓰기 테스트
- [ ] Firebase Storage 백업/복원 테스트

## 개발 우선순위

**현재 접근 방식: Android 우선 개발**

1. Firebase Console 설정 완료 (Firestore, Storage)
2. Android용 코드 구현 및 테스트
3. iOS 개발자 계정 가입
4. iOS용 Apple 로그인 완전 구현
5. 전체 플랫폼 통합 테스트

## 참고 문서

- login.md: 전체 구현 가이드 (12개 Phase)
- Firebase 공식 문서:
  - Android Apple 로그인: https://firebase.google.com/docs/auth/android/apple
  - iOS Apple 로그인: https://firebase.google.com/docs/auth/ios/apple

## 주의사항

- 핫리로드가 작동하지 않으므로 코드 수정 후 에뮬레이터 재시작 필요
- Apple 로그인은 실제 iOS 기기에서만 테스트 가능 (시뮬레이터 불가)
- Firebase Console 설정은 코드 구현 전에 완료해야 함
