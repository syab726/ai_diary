# ArtDiary AI - 남은 작업 목록

**최종 업데이트:** 2025-10-21
**현재 완성도:** 90%

**Phase 1 진행 상황:**
- ✅ API 키 보안 처리 완료 (commit: 8d30871)
- ✅ 이미지 로딩 최적화 완료 (commit: 15e5043)
- ✅ 데이터베이스 인덱스 (이미 설정됨)
- ✅ 오프라인 감지 (ConnectivityProvider 이미 구현됨)
- ✅ 디버그 로그 정리 (~73% 완료)

**개발 전략:**
1. **Phase 1**: iOS/Android 공통 작업 (스토어 등록 불필요)
2. **Phase 2**: Android 결제 시스템 (Google Play 등록 $25)
3. **Phase 3**: iOS 결제 시스템 (App Store 등록 $99)
4. **Phase 4**: 대규모 사용자 증가 후 큐 시스템

---

## Phase 1: iOS/Android 공통 작업 (1주, 스토어 등록 불필요)

### 1. API 키 보안 처리 ⚠️ CRITICAL
**예상 시간:** 0.5일
**난이도:** 쉬움
**현재 문제:**
- Gemini API 키가 `lib/services/ai_service.dart` 17번째 줄에 하드코딩
- .env 파일은 있지만 실제로 사용되지 않음

**해결 방법:**
```dart
// ai_service.dart 수정
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AIService {
  static final String _geminiApiKey = dotenv.env['GEMINI_API_KEY']!;
  // ...
}
```

**체크리스트:**
- [ ] `ai_service.dart`에서 dotenv 사용하도록 수정
- [ ] `.env` 파일이 `.gitignore`에 있는지 확인
- [ ] 테스트 (앱 실행 확인)

---

### 2. 성능 최적화
**예상 시간:** 2-3일
**난이도:** 중간
**현재 문제:**
- 콘솔 경고: "Skipped 127 frames!"
- 일기 목록 스크롤 시 버벅임

**해결 방법:**

#### 2-1. 이미지 로딩 최적화
- [ ] 썸네일 생성 (256x256)
- [ ] 이미지 압축 (flutter_image_compress)
- [ ] 리스트뷰에 cacheExtent 설정
- [ ] 이미지 lazy loading

#### 2-2. 데이터베이스 최적화
- [ ] 인덱스 추가 (createdAt, emotion)
- [ ] 페이지네이션 구현 (한 번에 20개씩)
- [ ] 쿼리 최적화

#### 2-3. AI 처리 백그라운드화
- [ ] Isolate 사용 고려

**체크리스트:**
- [ ] 썸네일 생성 함수 작성
- [ ] 이미지 압축 적용
- [ ] 데이터베이스 인덱스 추가
- [ ] 페이지네이션 구현
- [ ] 테스트 (프레임 드롭 확인)

---

### 3. 오류 처리 개선
**예상 시간:** 1-2일
**난이도:** 쉬움-중간
**현재 문제:**
- 네트워크 오류 시 앱 멈춤
- AI 생성 실패 시 재시도 없음
- 에러 메시지가 불친절

**해결 방법:**

#### 3-1. 네트워크 오류 처리
```dart
Future<T> retryOnNetworkError<T>(Future<T> Function() fn) async {
  for (int i = 0; i < 3; i++) {
    try {
      return await fn().timeout(Duration(seconds: 30));
    } catch (e) {
      if (i == 2) rethrow;
      await Future.delayed(Duration(seconds: 2 * (i + 1)));
    }
  }
  throw Exception('Retry failed');
}
```

#### 3-2. 사용자 친화적 에러 메시지
- [ ] 네트워크 오류: "인터넷 연결을 확인해주세요"
- [ ] AI 생성 실패: "이미지 생성에 실패했습니다. 다시 시도해주세요"
- [ ] 저장 실패: "일기 저장에 실패했습니다"

#### 3-3. 오프라인 감지
- [ ] connectivity_plus 패키지 사용
- [ ] 오프라인 시 안내 배너 표시

**체크리스트:**
- [ ] retryOnNetworkError 헬퍼 함수 작성
- [ ] 모든 API 호출에 재시도 로직 적용
- [ ] 타임아웃 설정 (30초)
- [ ] 에러 메시지 한글화
- [ ] 오프라인 감지 및 안내
- [ ] 테스트

---

### 4. 디버그 로그 정리
**예상 시간:** 0.5일
**난이도:** 쉬움
**대상 파일:**
- `lib/services/ai_service.dart` (40+ print 문)
- `lib/services/database_service.dart` (20+ print 문)
- `lib/screens/*.dart` (30+ print 문)

**해결 방법:**
```dart
// 기존
print('AI 이미지 생성 시작');

// 변경
if (kDebugMode) print('AI 이미지 생성 시작');
```

**체크리스트:**
- [ ] 모든 print 문에 kDebugMode 체크 추가
- [ ] 또는 logger 패키지 도입
- [ ] Release 빌드 테스트 (로그 없는지 확인)

---

### 5. 이미지 최적화
**예상 시간:** 1일
**난이도:** 중간
**현재 문제:**
- AI 생성 이미지 크기 1-2MB
- 저장 공간 빠르게 소모

**해결 방법:**
- [ ] 이미지 압축 (품질 85%)
- [ ] 리사이징 (최대 1080x1080)
- [ ] WebP 형식 사용 고려

**패키지:** `flutter_image_compress`, `image`

---

### 6. 개인정보처리방침 + 이용약관
**예상 시간:** 1-2일
**난이도:** 쉬움-중간
**필요성:** 앱스토어 심사 필수

**작업:**
- [ ] 개인정보처리방침 작성 (변호사 검토 권장)
- [ ] 이용약관 작성
- [ ] 웹페이지 호스팅 (Firebase Hosting 또는 GitHub Pages)
- [ ] 앱에 링크 추가

**참고:**
- 개인정보처리방침 생성기: https://www.privacy.go.kr/
- Firebase Hosting: 무료

---

## Phase 2: Android 결제 시스템 (1주, Google Play 등록 필요)

**비용:** $25 (일회성)
**준비 사항:**
- Google 계정
- 신용카드
- 개발자 정보

### 7. Google Play Console 등록
**예상 시간:** 0.5일

**절차:**
1. [ ] Google Play Console 접속 (https://play.google.com/console)
2. [ ] 개발자 등록 ($25 결제)
3. [ ] 앱 생성
4. [ ] 앱 정보 입력 (이름, 설명, 카테고리)

---

### 8. Android 인앱 구독 설정
**예상 시간:** 1일

**작업:**
- [ ] Google Play Console에서 인앱 상품 생성
  - 월간 구독: `premium_monthly`
  - 연간 구독: `premium_yearly`
- [ ] 가격 설정 (예: 월 2,900원, 연 29,000원)
- [ ] 무료 평가판 설정 (7일)

---

### 9. Android 결제 코드 구현
**예상 시간:** 3-4일
**난이도:** 어려움

**작업:**
```dart
// lib/services/purchase_service.dart 완성

class PurchaseService {
  // 구독 상품 확인
  Future<void> initializePurchases() async {
    final available = await InAppPurchase.instance.isAvailable();
    if (!available) return;

    // 구독 상품 로드
    const Set<String> _kIds = {
      'premium_monthly',
      'premium_yearly',
    };
    final response = await InAppPurchase.instance.queryProductDetails(_kIds);
    // ...
  }

  // 구매 시작
  Future<void> buySubscription(String productId) async {
    // ...
  }

  // 구독 복원
  Future<void> restorePurchases() async {
    // ...
  }
}
```

**체크리스트:**
- [ ] PurchaseService 완성
- [ ] 구독 상태 확인 로직
- [ ] 구독 복원 기능
- [ ] 영수증 검증

---

### 10. Android 샌드박스 테스트
**예상 시간:** 1일

**테스트 항목:**
- [ ] 월간 구독 구매
- [ ] 연간 구독 구매
- [ ] 무료 평가판 확인
- [ ] 구독 취소
- [ ] 구독 복원
- [ ] 앱 재설치 후 구독 확인

---

## Phase 3: iOS 결제 시스템 (1주, App Store 등록 필요)

**비용:** $99/년
**준비 사항:**
- Apple ID
- 신용카드
- 개발자 정보

### 11. App Store Connect 등록
**예상 시간:** 0.5일

**절차:**
1. [ ] Apple Developer Program 가입 ($99/년)
2. [ ] App Store Connect 접속
3. [ ] 앱 생성
4. [ ] Bundle ID 설정: `com.aidiary.app.aiDiaryApp`
5. [ ] 앱 정보 입력

---

### 12. iOS 인앱 구독 설정
**예상 시간:** 1일

**작업:**
- [ ] App Store Connect에서 구독 그룹 생성
- [ ] 구독 상품 생성
  - 월간 구독: `premium_monthly`
  - 연간 구독: `premium_yearly`
- [ ] 가격 설정 (예: 월 $2.99, 연 $29.99)
- [ ] 무료 평가판 설정 (7일)

---

### 13. iOS 결제 코드 구현
**예상 시간:** 2-3일
**난이도:** 중간 (Android 코드 재사용)

**작업:**
- [ ] iOS 전용 코드 추가 (StoreKit 관련)
- [ ] 영수증 검증 로직 (iOS용)
- [ ] 프로바이더 연동

**참고:**
- Android 결제 로직 대부분 재사용 가능
- iOS 특화 부분만 추가 작업

---

### 14. iOS 샌드박스 테스트
**예상 시간:** 1일
**필요:** 실제 iOS 기기 (시뮬레이터 불가)

**테스트 항목:**
- [ ] 월간 구독 구매
- [ ] 연간 구독 구매
- [ ] 무료 평가판 확인
- [ ] 구독 취소
- [ ] 구독 복원
- [ ] 앱 재설치 후 구독 확인

---

## Phase 4: 대규모 사용자 증가 후 작업

### 15. AI 이미지 생성 큐 시스템
**예상 시간:** 2-3주
**난이도:** 매우 어려움
**필요 조건:** DAU 5,000-10,000명 초과 또는 API 한도 초과 발생 시

**현재 상황:**
- 동기적 처리 방식 (즉시 생성)
- Gemini API IPM 한도: 15 IPM
- 초기 사용자 수: 예상 10-100명/일
- **현재 방식으로 DAU 5,000-10,000명까지 충분함**

**큐 시스템이 필요한 시점:**
1. DAU 5,000-10,000명 초과
2. API 한도 초과 오류 빈발
3. 사용자 불만 접수 (생성 실패, 긴 대기 시간)

**구현 방안:**
- Firebase Cloud Functions 백엔드
- Firebase Pub/Sub 메시지 큐
- Firestore 상태 추적
- FCM 푸시 알림
- 로컬 SQLite는 그대로 유지 (사용자 데이터는 로컬에 저장)

**문제점:**
- 개발 시간: 2-3주
- 추가 비용: Firebase Functions, Pub/Sub (개발자 부담)
- 유지보수 복잡도 증가

**현실적 판단:**
- 초기에는 현재 방식 유지
- Firebase Analytics로 사용량 모니터링
- 실제 문제 발생 시 구축

**모니터링 지표:**
- DAU, MAU
- AI 이미지 생성 횟수/일
- API 한도 초과 오류 수
- 평균 대기 시간

---

## 예상 일정

### Phase 1: 공통 작업 (1주)
**총 소요 시간:** 약 7일
- Day 1: API 키 보안
- Day 2-4: 성능 최적화
- Day 5-6: 오류 처리 + 디버그 로그
- Day 7: 이미지 최적화 + 개인정보처리방침

### Phase 2: Android (1주)
**총 소요 시간:** 약 7일
- Day 1: Google Play 등록 + 인앱 상품 설정
- Day 2-5: Android 결제 코드 구현
- Day 6-7: 샌드박스 테스트 + 버그 수정

### Phase 3: iOS (1주)
**총 소요 시간:** 약 7일
- Day 1: App Store 등록 + 인앱 상품 설정
- Day 2-4: iOS 결제 코드 구현
- Day 5-7: 샌드박스 테스트 + 버그 수정

**전체 예상 기간: 3주**

---

## 배포 전 최종 체크리스트

### 보안
- [ ] API 키 환경변수 처리
- [ ] .env 파일 gitignore 확인
- [ ] Release 빌드 테스트

### 기능
- [ ] Android 결제 시스템 작동 확인 (샌드박스)
- [ ] iOS 결제 시스템 작동 확인 (샌드박스)
- [ ] 모든 핵심 기능 테스트

### 성능
- [ ] 프레임 드롭 해결 확인
- [ ] 이미지 로딩 속도 확인
- [ ] 메모리 사용량 확인

### 법적
- [ ] 개인정보처리방침 링크 확인
- [ ] 이용약관 링크 확인
- [ ] 오픈소스 라이선스 표기

### 스토어
- [ ] 앱 아이콘 최종 확인
- [ ] 스플래시 스크린 확인
- [ ] 스크린샷 준비 (5-8장)
- [ ] 앱 설명 작성 (한/영)
- [ ] Google Play 심사 제출
- [ ] App Store 심사 제출

---

## 선택 작업 (배포 후)

### Firebase 인증 완성 (선택)
**예상 시간:** 3-4일
**난이도:** 어려움
**필요성:** 낮음 (현재 로컬 저장만으로 충분)

**작업:**
- [ ] Firebase Console 수동 설정
- [ ] AuthService 재작성 (700+ 줄)
- [ ] LoginScreen UI 재작성
- [ ] Firestore/Storage 연동

**판단 기준:**
- 다중 기기 동기화 필요하면 → 구현
- 로컬 저장만으로 충분하면 → 보류

---

**참고 문서:**
- upgrade_todo.md: 상세한 개선 계획
- TODO.md: Firebase 인증 관련
- CLAUDE.md: 프로젝트 전체 정보
