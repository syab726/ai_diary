# iOS (App Store) 배포 가이드

**앱 정보:**
- 앱 이름: ArtDiary AI
- Bundle ID: `com.aidiary.app.aiDiaryApp`
- 대상: iOS 12.0 이상
- 예상 소요 시간: 7-10일
- 비용: $99/년 (Apple Developer Program)

---

## Phase 1: Apple Developer Program 등록

### 1-1. Apple ID 준비
- [ ] Apple ID 생성 또는 기존 계정 사용
  - [ ] https://appleid.apple.com 접속
  - [ ] Apple ID 생성 또는 로그인
  - [ ] 2단계 인증 설정 (필수)
- [ ] 결제 정보 등록 (신용카드/체크카드)

### 1-2. Apple Developer Program 가입
- [ ] https://developer.apple.com/programs 접속
- [ ] "Enroll" 클릭
- [ ] 계정 유형 선택
  - [ ] Individual (개인): 본인 이름으로 앱 배포
  - [ ] Organization (조직): 회사명으로 앱 배포 (사업자등록증 필요)
- [ ] 개인/조직 정보 입력
  - [ ] 이름, 주소, 전화번호
  - [ ] 조직의 경우: D-U-N-S 번호 필요 (무료 발급, 2주 소요)
- [ ] $99 연간 비용 결제
- [ ] 승인 대기 (일반적으로 24-48시간)

### 1-3. 개발자 계정 활성화 확인
- [ ] Apple로부터 승인 이메일 수신 확인
- [ ] https://developer.apple.com 로그인
- [ ] "Account" 메뉴에서 멤버십 상태 확인

---

## Phase 2: App Store Connect 설정

### 2-1. App Store Connect 접속
- [ ] https://appstoreconnect.apple.com 로그인
- [ ] Apple Developer 계정으로 로그인
- [ ] 계약, 세금 및 금융 거래 정보 작성 (인앱 결제 필수)
  - [ ] "계약, 세금 및 금융 거래" 메뉴 선택
  - [ ] Paid Apps 계약 동의
  - [ ] 세금 정보 입력 (W-8BEN 또는 W-9)
  - [ ] 은행 계좌 정보 입력 (수익 수령용)

### 2-2. 새 앱 만들기
- [ ] "나의 앱" 메뉴 선택
- [ ] "+" 버튼 클릭 → "새로운 앱"
- [ ] 앱 기본 정보 입력
  - [ ] 플랫폼: `iOS`
  - [ ] 이름: `ArtDiary AI`
  - [ ] 기본 언어: `한국어`
  - [ ] Bundle ID: `com.aidiary.app.aiDiaryApp` (Xcode에서 생성 필요)
  - [ ] SKU: `artdiary-ai-001` (고유 식별자)
  - [ ] 사용자 액세스: `전체 액세스`
- [ ] "생성" 클릭

---

## Phase 3: Xcode에서 Bundle ID 및 서명 설정

### 3-1. Xcode 프로젝트 열기
- [ ] Xcode에서 `ios/Runner.xcworkspace` 파일 열기
- [ ] "Runner" 프로젝트 선택

### 3-2. Bundle Identifier 설정
- [ ] "General" 탭 선택
- [ ] Bundle Identifier: `com.aidiary.app.aiDiaryApp`
- [ ] Version: `1.0.0`
- [ ] Build: `1`

### 3-3. Signing & Capabilities 설정
- [ ] "Signing & Capabilities" 탭 선택
- [ ] "Automatically manage signing" 체크
- [ ] Team: Apple Developer 계정 선택
- [ ] Signing Certificate 자동 생성 확인

### 3-4. Capabilities 추가
- [ ] "+" 버튼 클릭 → "In-App Purchase" 추가
- [ ] "+" 버튼 클릭 → "Push Notifications" 추가 (선택 사항)
- [ ] "+" 버튼 클릭 → "iCloud" 추가 (백업 기능 사용 시)

---

## Phase 4: App Store Connect 앱 정보 입력

### 4-1. 앱 정보
- [ ] "앱 정보" 섹션 선택
- [ ] 카테고리
  - [ ] 주 카테고리: `생산성` 또는 `라이프스타일`
  - [ ] 부 카테고리 (선택 사항): `건강 및 피트니스`
- [ ] 연령 등급
  - [ ] "연령 등급 편집" 클릭
  - [ ] 설문지 작성 (모두 "아니요" 권장)
  - [ ] 등급 확인: `4+` (예상)
- [ ] 저작권: `© 2025 Your Name` (또는 회사명)

### 4-2. 가격 및 서비스 국가 선택
- [ ] "가격 및 서비스 국가 선택" 섹션
- [ ] 가격: `무료`
- [ ] 서비스 국가
  - [ ] 대한민국
  - [ ] 미국
  - [ ] 일본
  - [ ] 기타 국가 (선택)

### 4-3. App Privacy (개인정보 보호)
- [ ] "App Privacy" 섹션 선택
- [ ] "시작하기" 클릭
- [ ] 데이터 수집 정보 입력
  - [ ] 연락처 정보: 이메일 (선택적)
  - [ ] 사용자 콘텐츠: 일기 데이터
  - [ ] 사용 현황 데이터: 비정상 종료 로그
- [ ] 데이터 사용 목적
  - [ ] 앱 기능: AI 이미지 생성
  - [ ] 제품 개인화: 감정 분석
  - [ ] 분석: 앱 성능 모니터링
- [ ] 데이터 연결 여부
  - [ ] 사용자와 연결됨: `예`
  - [ ] 추적에 사용됨: `아니요`
- [ ] 저장

---

## Phase 5: 인앱 구독 설정

### 5-1. 구독 그룹 생성
- [ ] "기능" → "인앱 구입" → "구독 그룹" 메뉴
- [ ] "구독 그룹 생성" 클릭
- [ ] 참조 이름: `Premium Subscription`
- [ ] "생성" 클릭

### 5-2. 월간 구독 상품 생성
- [ ] 구독 그룹에서 "+" 버튼 클릭
- [ ] 참조 이름: `Premium Monthly Subscription`
- [ ] 제품 ID: `premium_monthly` (Android와 동일)
- [ ] 구독 기간: `1개월`
- [ ] 구독 가격 설정
  - [ ] 대한민국: ₩2,900
  - [ ] 미국: $2.99
  - [ ] 일본: ¥350
  - [ ] 자동 환율 적용: 체크
- [ ] 무료 평가판
  - [ ] "무료 평가판 제공" 체크
  - [ ] 기간: `7일`
- [ ] 현지화된 설명
  - [ ] 구독 표시 이름: `프리미엄 월간 구독`
  - [ ] 설명: `모든 프리미엄 기능을 1개월 동안 이용할 수 있습니다`
- [ ] "저장" 클릭

### 5-3. 연간 구독 상품 생성
- [ ] 구독 그룹에서 "+" 버튼 클릭
- [ ] 참조 이름: `Premium Yearly Subscription`
- [ ] 제품 ID: `premium_yearly`
- [ ] 구독 기간: `1년`
- [ ] 구독 가격 설정
  - [ ] 대한민국: ₩29,000
  - [ ] 미국: $29.99
  - [ ] 일본: ¥3,500
- [ ] 무료 평가판
  - [ ] "무료 평가판 제공" 체크
  - [ ] 기간: `7일`
- [ ] 현지화된 설명
  - [ ] 구독 표시 이름: `프리미엄 연간 구독`
  - [ ] 설명: `모든 프리미엄 기능을 1년 동안 이용할 수 있습니다 (월간 대비 17% 할인)`
- [ ] "저장" 클릭

### 5-4. 구독 그룹 현지화
- [ ] 구독 그룹 이름 현지화
  - [ ] 한국어: `프리미엄 구독`
  - [ ] 영어: `Premium Subscription`
- [ ] "저장" 클릭

### 5-5. 구독 제출 준비
- [ ] "인앱 구입 심사 정보" 작성
  - [ ] 구독 검토 노트: 테스트 계정 정보 입력
  - [ ] 스크린샷 업로드 (구독 UI)
- [ ] "제출 준비 완료" 클릭

---

## Phase 6: 앱 스토어 등록정보 작성

### 6-1. 스크린샷 준비
- [ ] iPhone 스크린샷 (필수)
  - 6.7" Display (iPhone 15 Pro Max, 14 Pro Max)
    - [ ] 해상도: 1290 x 2796 픽셀
    - [ ] 메인 화면
    - [ ] 일기 작성 화면
    - [ ] AI 이미지 생성 결과
    - [ ] 감정 통계 화면
    - [ ] 설정 화면
  - 6.5" Display (iPhone 11 Pro Max, XS Max)
    - [ ] 해상도: 1242 x 2688 픽셀
    - [ ] 동일한 5장 스크린샷
- [ ] iPad 스크린샷 (선택 사항)
  - 12.9" iPad Pro
    - [ ] 해상도: 2048 x 2732 픽셀

### 6-2. 앱 미리보기 비디오 (선택 사항)
- [ ] 30초 이내 앱 시연 영상
- [ ] 주요 기능 소개
- [ ] 업로드

### 6-3. 앱 설명 작성
- [ ] 프로모션 텍스트 (170자 이내):
  ```
  AI가 그려주는 감정 일기장! 매일의 감정을 아름다운 그림으로 기록하고, 나만의 감정 패턴을 분석하세요. 지금 7일 무료 체험 시작!
  ```
- [ ] 설명 (4000자 이내):
  ```
  ArtDiary AI는 당신의 일상을 특별하게 만들어줍니다.

  ✨ 주요 기능
  - AI 이미지 생성: Gemini 2.5 Flash를 활용한 아름다운 일기 삽화
  - 감정 분석: 일기 내용을 분석하여 자동으로 감정 태그 추출
  - 감정 통계: 월간/연간 감정 변화 추이를 시각적으로 확인
  - 다양한 스타일: 10가지 이상의 이미지 스타일 선택 가능
  - 프리미엄 글꼴: 일기에 어울리는 10가지 감성 폰트
  - 사진 분석: 업로드한 사진을 AI가 분석하여 일기에 반영
  - iCloud 백업: 안전한 데이터 백업 및 기기 간 동기화

  📝 이렇게 사용하세요
  1. 오늘 하루를 자유롭게 작성하세요
  2. AI가 내용을 분석하여 아름다운 그림을 생성합니다
  3. 감정 통계로 나의 감정 변화를 확인하세요
  4. 추억을 언제든지 되돌아보며 성장하세요

  💎 프리미엄 혜택
  - 무제한 AI 이미지 생성 (무료: 1일 5회)
  - 고급 이미지 옵션 (조명, 날씨, 계절, 구도)
  - 사진 3장 업로드 (무료: 1장)
  - 프리미엄 글꼴 10종
  - 광고 제거

  🔒 개인정보 보호
  - 모든 일기는 기기에 안전하게 저장됩니다
  - 선택적 iCloud 백업 (암호화)
  - Face ID/Touch ID 잠금 지원

  📱 구독 정보
  - 월간 구독: ₩2,900/월
  - 연간 구독: ₩29,000/년 (17% 할인)
  - 7일 무료 평가판 제공
  - 언제든지 취소 가능

  구독은 iTunes 계정을 통해 청구되며, 무료 평가판 기간이 끝나면 자동으로 갱신됩니다. 자동 갱신은 현재 구독 기간이 끝나기 최소 24시간 전에 계정 설정에서 해제할 수 있습니다.

  개인정보처리방침: https://your-domain.com/privacy
  서비스 약관: https://your-domain.com/terms
  ```
- [ ] 키워드 (100자 이내, 쉼표로 구분):
  ```
  일기,다이어리,감정,AI,그림일기,감정분석,통계,프리미엄,무료체험
  ```
- [ ] 지원 URL: `https://your-domain.com/support`
- [ ] 마케팅 URL (선택 사항): `https://your-domain.com`

### 6-4. 연락처 정보
- [ ] 이름: 개발자 이름
- [ ] 전화번호: 지원 전화번호
- [ ] 이메일 주소: 지원 이메일

### 6-5. 앱 아이콘
- [ ] 1024 x 1024 PNG 파일 (투명도 없음)
- [ ] 업로드

---

## Phase 7: 빌드 및 업로드

### 7-1. `ios/Runner/Info.plist` 설정 확인
- [ ] CFBundleDisplayName: `ArtDiary AI`
- [ ] CFBundleShortVersionString: `1.0.0`
- [ ] CFBundleVersion: `1`
- [ ] 권한 설명 추가
  ```xml
  <key>NSPhotoLibraryUsageDescription</key>
  <string>일기에 사진을 추가하기 위해 사진 라이브러리 접근이 필요합니다</string>

  <key>NSCameraUsageDescription</key>
  <string>일기에 사진을 추가하기 위해 카메라 접근이 필요합니다</string>

  <key>NSPhotoLibraryAddUsageDescription</key>
  <string>AI 생성 이미지를 저장하기 위해 사진 라이브러리 접근이 필요합니다</string>
  ```

### 7-2. Archive 빌드 생성
- [ ] Xcode에서 "Product" → "Scheme" → "Runner" 선택
- [ ] "Product" → "Destination" → "Any iOS Device (arm64)" 선택
- [ ] "Product" → "Archive" 클릭
- [ ] 빌드 완료 대기 (5-10분)
- [ ] Organizer 창에서 아카이브 확인

### 7-3. App Store Connect에 업로드
- [ ] Organizer 창에서 "Distribute App" 클릭
- [ ] "App Store Connect" 선택 → "Next"
- [ ] "Upload" 선택 → "Next"
- [ ] 서명 옵션: "Automatically manage signing" → "Next"
- [ ] 업로드 시작
- [ ] 업로드 완료 대기 (5-15분)
- [ ] "Done" 클릭

### 7-4. TestFlight 처리 대기
- [ ] App Store Connect → "TestFlight" 메뉴
- [ ] "처리 중" 상태 확인
- [ ] 처리 완료 대기 (10-30분)
- [ ] "테스트 준비 완료" 상태 확인

---

## Phase 8: 코드 구현 (결제 시스템)

### 8-1. PurchaseService iOS 지원 확인
- [ ] `lib/services/purchase_service.dart` 확인
  - [ ] iOS StoreKit 설정 코드 확인
  - [ ] iOS 영수증 검증 로직 확인
  - [ ] `premium_yearly` 상품 ID 추가 확인

### 8-2. iOS 특화 기능 추가
- [ ] Face ID/Touch ID 잠금 기능 (선택 사항)
  - [ ] `local_auth` 패키지 사용
  - [ ] 설정 화면에 잠금 옵션 추가
- [ ] iCloud 백업 지원 (선택 사항)
  - [ ] CloudKit 연동
  - [ ] 자동 백업 설정

### 8-3. UI 최적화
- [ ] iOS 디자인 가이드라인 준수
  - [ ] Cupertino 위젯 사용 (선택 사항)
  - [ ] Safe Area 처리
  - [ ] Dynamic Type 지원
- [ ] iPad 지원 확인 (선택 사항)

---

## Phase 9: TestFlight 내부 테스트

### 9-1. 내부 테스터 추가
- [ ] App Store Connect → "TestFlight" 메뉴
- [ ] "내부 그룹" 선택
- [ ] "테스터 추가" 클릭
- [ ] Apple ID 이메일 입력
- [ ] 초대 이메일 발송

### 9-2. 테스터 앱 설치
- [ ] 테스터 기기에서 TestFlight 앱 다운로드
- [ ] 초대 수락
- [ ] ArtDiary AI 설치

### 9-3. 샌드박스 테스트
- [ ] Settings → App Store → Sandbox Account 설정
  - [ ] 테스트용 Apple ID 생성 (sandbox)
  - [ ] https://appstoreconnect.apple.com → "사용자 및 액세스" → "Sandbox 테스터" 추가
- [ ] 테스트 시나리오
  - [ ] 월간 구독 구매
    - [ ] 구매 플로우 진행
    - [ ] Sandbox 환경에서 결제 (실제 청구 안 됨)
    - [ ] 구독 활성화 확인
    - [ ] 프리미엄 기능 접근 확인
  - [ ] 연간 구독 구매
  - [ ] 구독 취소
    - [ ] Settings → Apple ID → Subscriptions
    - [ ] ArtDiary AI 구독 취소
    - [ ] 앱에서 상태 변경 확인
  - [ ] 구독 복원
    - [ ] 앱 재설치
    - [ ] "구독 복원" 버튼 클릭
    - [ ] 구독 상태 복원 확인
  - [ ] 무료 평가판
    - [ ] 7일 평가판 시작
    - [ ] 평가판 기간 확인
    - [ ] 취소 테스트

### 9-4. 버그 수정
- [ ] 테스트 중 발견된 버그 수정
- [ ] 새 빌드 업로드
- [ ] 재테스트

---

## Phase 10: App Store 심사 제출

### 10-1. 버전 정보 입력
- [ ] App Store Connect → "나의 앱" → ArtDiary AI 선택
- [ ] "1.0.0 버전 준비" 클릭
- [ ] 빌드 선택
  - [ ] TestFlight에서 처리된 빌드 선택
- [ ] "이번 버전의 새로운 기능" 입력 (4000자 이내):
  ```
  🎉 ArtDiary AI 첫 번째 버전 출시!

  ✨ 주요 기능
  - AI 이미지 생성으로 감성적인 일기 삽화
  - 감정 분석 및 통계
  - 월간/연간 감정 리포트
  - iCloud 백업
  - 프리미엄 구독 (무료 평가판 7일)

  📝 시작하기
  - 무료로 하루 5회 AI 이미지 생성
  - 프리미엄으로 무제한 이용 가능
  ```

### 10-2. 심사 정보 입력
- [ ] "앱 심사 정보" 섹션
- [ ] 연락처 정보
  - [ ] 이름
  - [ ] 전화번호
  - [ ] 이메일
- [ ] 데모 계정 (필요 시)
  - [ ] 사용자 이름: `demo@artdiary.ai`
  - [ ] 비밀번호: `DemoPassword123!`
  - [ ] 로그인이 필요한 경우에만 제공
- [ ] 참고 사항
  ```
  - 인앱 구독 테스트 시 Sandbox 계정을 사용해주세요
  - AI 이미지 생성은 Gemini API를 사용합니다
  - 무료 사용자는 1일 5회 제한이 있습니다
  ```

### 10-3. 광고 식별자 (IDFA) 설정
- [ ] "앱 광고 정보" 섹션
- [ ] 광고 식별자(IDFA) 사용 여부
  - [ ] `예` (AdMob 사용)
  - [ ] 광고 목적 체크

### 10-4. 수출 규정 준수
- [ ] "수출 규정 준수" 섹션
- [ ] 암호화 사용 여부: `예`
  - [ ] HTTPS 사용
  - [ ] 면제 사유: "표준 암호화만 사용"
- [ ] 저장

### 10-5. 콘텐츠 권한
- [ ] "콘텐츠 권한" 섹션
- [ ] 제3자 콘텐츠 사용 여부: `아니요`

### 10-6. 최종 확인 및 제출
- [ ] 모든 섹션 완료 확인 (초록색 체크)
- [ ] "심사용으로 제출" 버튼 클릭
- [ ] 최종 확인 팝업 → "제출" 클릭
- [ ] 심사 대기 상태 확인

---

## Phase 11: 심사 및 출시

### 11-1. 심사 상태 모니터링
- [ ] "심사 대기 중" 상태 (일반적으로 24-48시간)
- [ ] "심사 중" 상태 (몇 시간 ~ 1일)
- [ ] 심사 완료 알림 대기

### 11-2. 심사 거부 시 대응
- [ ] 거부 사유 확인
- [ ] 필요한 수정사항 반영
- [ ] 새 빌드 업로드 또는 메타데이터 수정
- [ ] 재제출

### 11-3. 승인 시 출시
- [ ] "판매 준비 완료" 상태 확인
- [ ] 자동 출시 또는 수동 출시 선택
  - [ ] 자동 출시: 승인 즉시 App Store에 공개
  - [ ] 수동 출시: 원하는 시간에 직접 출시
- [ ] 출시 완료 확인
- [ ] App Store에서 앱 검색 가능 확인

---

## Phase 12: 출시 후 모니터링 및 업데이트

### 12-1. Analytics 모니터링
- [ ] App Store Connect → "Analytics" 메뉴
- [ ] 일일 다운로드 수 확인
- [ ] 사용자 유지율 확인
- [ ] 구독 전환율 확인

### 12-2. 사용자 리뷰 및 평점 관리
- [ ] App Store Connect → "평점 및 리뷰" 메뉴
- [ ] 사용자 리뷰 읽기
- [ ] 응답 작성 (선택 사항)
- [ ] 평점 추이 모니터링

### 12-3. 비정상 종료 및 오류 추적
- [ ] Xcode → "Organizer" → "Crashes" 메뉴
- [ ] Firebase Crashlytics 대시보드
- [ ] 주요 크래시 패턴 분석
- [ ] 버그 수정 계획

### 12-4. 업데이트 배포
- [ ] 버그 수정 또는 기능 추가
- [ ] 버전 번호 증가
  - [ ] Info.plist에서 버전 업데이트
  - [ ] 예: 1.0.0 → 1.0.1 (버그 수정)
  - [ ] 예: 1.0.0 → 1.1.0 (기능 추가)
- [ ] 새 Archive 빌드
- [ ] App Store Connect에 업로드
- [ ] "이번 버전의 새로운 기능" 작성
- [ ] 심사 제출
- [ ] 승인 대기 및 출시

---

## 체크리스트 요약

**Apple Developer 설정:**
- [ ] Apple Developer Program 가입 ($99/년)
- [ ] App Store Connect 계약 및 금융 정보 입력
- [ ] 앱 생성 및 기본 정보 입력

**인앱 구독 설정:**
- [ ] 구독 그룹 생성
- [ ] 월간/연간 구독 상품 생성
- [ ] 가격 및 평가판 설정

**앱 스토어 등록정보:**
- [ ] 스크린샷 업로드 (iPhone 필수)
- [ ] 앱 설명 및 키워드 작성
- [ ] 앱 아이콘 업로드
- [ ] 개인정보 보호 정보 입력

**빌드 및 업로드:**
- [ ] Xcode에서 Bundle ID 설정
- [ ] Archive 빌드 생성
- [ ] App Store Connect에 업로드
- [ ] TestFlight 처리 완료

**테스트:**
- [ ] 내부 테스터 추가
- [ ] TestFlight 앱 설치
- [ ] Sandbox 환경에서 구독 테스트
- [ ] 버그 수정

**심사 및 출시:**
- [ ] 버전 정보 및 심사 정보 입력
- [ ] 심사 제출
- [ ] 승인 대기 (24-72시간)
- [ ] 출시 완료

---

**예상 일정:**
- Day 1: Apple Developer Program 가입
- Day 2: 승인 대기
- Day 3-4: App Store Connect 설정 및 인앱 구독 생성
- Day 5-6: 스크린샷 준비 및 등록정보 작성
- Day 7: Xcode 빌드 및 업로드
- Day 8: TestFlight 테스트
- Day 9: 심사 제출
- Day 10-12: 심사 대기 (1-3일)
- Day 13: 출시 완료

**참고 문서:**
- Apple Developer: https://developer.apple.com
- App Store Connect: https://appstoreconnect.apple.com
- App Store Review Guidelines: https://developer.apple.com/app-store/review/guidelines/
- Human Interface Guidelines: https://developer.apple.com/design/human-interface-guidelines/
- In-App Purchase: https://developer.apple.com/in-app-purchase/
- Flutter iOS 배포: https://docs.flutter.dev/deployment/ios

---

**중요 참고사항:**

1. **Xcode 최신 버전 필수**: App Store 제출 시 최신 Xcode 버전이 필요할 수 있습니다.

2. **실제 기기 테스트**: 시뮬레이터에서는 인앱 구매 테스트 불가, 실제 iOS 기기 필요.

3. **심사 가이드라인 준수**:
   - 앱이 설명한 기능을 모두 구현해야 함
   - 비정상 종료나 버그가 없어야 함
   - 사용자 개인정보 보호 준수
   - 디자인 가이드라인 준수

4. **거부 대응**:
   - 평균 거부율: 40% (특히 첫 제출)
   - 주요 거부 사유: 버그, 불완전한 기능, 메타데이터 불일치
   - 거부 시 빠르게 수정 후 재제출

5. **업데이트 주기**:
   - 버그 수정: 2-4주마다
   - 기능 추가: 1-3개월마다
   - iOS 버전 업데이트 대응: 즉시
