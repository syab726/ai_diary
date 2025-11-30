# Android (Google Play) 배포 가이드

**앱 정보:**
- 앱 이름: ArtDiary AI
- Bundle ID: `com.aidiary.app.ai_diary_app`
- 대상: Android 5.0 (API 21) 이상
- 예상 소요 시간: 7-10일
- 비용: $25 (일회성 개발자 등록비)

---

## Phase 1: Google Play Console 개발자 등록

### 1-1. 개발자 계정 생성
- [ ] Google Play Console 접속: https://play.google.com/console
- [ ] Google 계정으로 로그인 (또는 새 계정 생성)
- [ ] "개발자 계정 만들기" 클릭
- [ ] 개발자 프로필 작성
  - [ ] 개발자 이름 입력
  - [ ] 이메일 주소 확인
  - [ ] 연락처 정보 입력 (전화번호, 주소)
- [ ] $25 등록비 결제 (신용카드/체크카드)
  - [ ] 카드 정보 입력
  - [ ] 결제 완료 확인
- [ ] 개발자 배포 계약 동의
  - [ ] Google Play 개발자 배포 계약 읽기
  - [ ] 계약 동의 체크
- [ ] 미국 수출 규정 준수 확인
- [ ] 계정 확인 완료 (1-2일 소요 가능)

### 1-2. 계정 설정
- [ ] 판매자 계정 설정 (인앱 결제 필수)
  - [ ] "설정" → "판매자 계정" 메뉴 선택
  - [ ] 사업자 정보 입력 (개인/법인)
  - [ ] 은행 계좌 정보 입력 (수익 수령용)
  - [ ] 세금 정보 입력
- [ ] 개발자 페이지 URL 설정 (선택 사항)
- [ ] 개인정보처리방침 URL 준비 (필수)

---

## Phase 2: 앱 생성 및 기본 정보 입력

### 2-1. 새 앱 만들기
- [ ] Google Play Console 대시보드에서 "앱 만들기" 클릭
- [ ] 앱 세부정보 입력
  - [ ] 앱 이름: `ArtDiary AI`
  - [ ] 기본 언어: `한국어`
  - [ ] 앱 또는 게임: `앱`
  - [ ] 무료 또는 유료: `무료`
- [ ] 앱 만들기 확인

### 2-2. 앱 카테고리 및 세부정보
- [ ] "앱 콘텐츠" → "앱 카테고리" 메뉴
  - [ ] 앱 카테고리: `생산성` 또는 `라이프스타일`
  - [ ] 태그 추가 (최대 5개): 일기, AI, 그림일기, 감정 분석, 다이어리
- [ ] "스토어 설정" → "기본 스토어 등록정보" 메뉴
  - [ ] 앱 이름: `ArtDiary AI`
  - [ ] 간단한 설명 (80자 이내):
    ```
    AI가 그려주는 감정 일기장. 매일의 감정을 아름다운 그림으로 기록하세요.
    ```
  - [ ] 자세한 설명 (4000자 이내):
    ```
    ArtDiary AI는 당신의 일상을 특별하게 만들어줍니다.

    ✨ 주요 기능
    - AI 이미지 생성: Gemini 2.5 Flash를 활용한 아름다운 일기 삽화
    - 감정 분석: 일기 내용을 분석하여 자동으로 감정 태그 추출
    - 감정 통계: 월간/연간 감정 변화 추이를 시각적으로 확인
    - 다양한 스타일: 10가지 이상의 이미지 스타일 선택 가능
    - 프리미엄 글꼴: 일기에 어울리는 10가지 감성 폰트
    - 사진 분석: 업로드한 사진을 AI가 분석하여 일기에 반영
    - 클라우드 백업: Google Drive를 통한 안전한 데이터 백업

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
    - 선택적 클라우드 백업 (암호화)
    - 로그인 불필요 (선택 사항)
    ```

### 2-3. 그래픽 자산 준비 및 업로드
- [ ] 앱 아이콘 (512x512 PNG)
  - [ ] 파일 생성: `app_icon_512.png`
  - [ ] Google Play Console에 업로드
- [ ] 기능 그래픽 (1024x500 PNG 또는 JPG)
  - [ ] 파일 생성: `feature_graphic.png`
  - [ ] 앱의 핵심 기능을 시각적으로 표현
  - [ ] 업로드
- [ ] 스크린샷 (최소 2장, 권장 4-8장)
  - 휴대전화 스크린샷 (16:9 비율 권장)
    - [ ] 메인 화면 (일기 목록)
    - [ ] 일기 작성 화면
    - [ ] AI 이미지 생성 결과
    - [ ] 감정 통계 화면
    - [ ] 설정 화면
    - [ ] 프리미엄 기능 소개
  - 7인치 태블릿 (선택 사항)
  - 10인치 태블릿 (선택 사항)

### 2-4. 연락처 정보
- [ ] 이메일 주소: 사용자 지원용 이메일 입력
- [ ] 웹사이트 (선택 사항)
- [ ] 전화번호 (선택 사항)

---

## Phase 3: 인앱 결제 설정

### 3-1. 인앱 상품 만들기
- [ ] "수익 창출" → "제품" → "구독" 메뉴 선택
- [ ] "구독 만들기" 클릭

#### 월간 구독 상품
- [ ] 제품 ID: `premium_monthly`
- [ ] 이름: `프리미엄 월간 구독`
- [ ] 설명: `모든 프리미엄 기능을 1개월 동안 이용할 수 있습니다`
- [ ] 결제 주기: `1개월`
- [ ] 가격 설정
  - [ ] 대한민국: ₩2,900
  - [ ] 미국: $2.99
  - [ ] 일본: ¥350
  - [ ] 기타 국가: 자동 환율 적용
- [ ] 무료 평가판: `7일` (선택 사항)
- [ ] 유예 기간: `3일` (권장)
- [ ] 구독 재신청 설정: 활성화
- [ ] 저장

#### 연간 구독 상품
- [ ] 제품 ID: `premium_yearly`
- [ ] 이름: `프리미엄 연간 구독`
- [ ] 설명: `모든 프리미엄 기능을 1년 동안 이용할 수 있습니다 (월간 대비 17% 할인)`
- [ ] 결제 주기: `1년`
- [ ] 가격 설정
  - [ ] 대한민국: ₩29,000
  - [ ] 미국: $29.99
  - [ ] 일본: ¥3,500
- [ ] 무료 평가판: `7일`
- [ ] 유예 기간: `3일`
- [ ] 저장

### 3-2. 구독 그룹 설정
- [ ] "기본 구독 그룹" 생성
- [ ] `premium_monthly`와 `premium_yearly`를 같은 그룹에 추가
- [ ] 업그레이드/다운그레이드 정책 설정
  - [ ] 월간 → 연간: 즉시 업그레이드
  - [ ] 연간 → 월간: 만료 후 변경
- [ ] 저장

---

## Phase 4: 앱 콘텐츠 설정

### 4-1. 개인정보처리방침
- [ ] 개인정보처리방침 웹페이지 작성
  - [ ] 수집하는 정보: 일기 데이터, 이메일 (선택)
  - [ ] 정보 사용 목적: AI 이미지 생성, 클라우드 백업
  - [ ] 제3자 공유: Google (Firebase, Gemini API)
  - [ ] 데이터 보관 기간
  - [ ] 사용자 권리 (삭제, 수정)
- [ ] URL 입력: https://your-domain.com/privacy
- [ ] "앱 콘텐츠" → "개인정보처리방침" 메뉴에서 URL 등록

### 4-2. 데이터 보안
- [ ] "앱 콘텐츠" → "데이터 보안" 메뉴
- [ ] 데이터 수집 및 보안 질문 응답
  - [ ] 앱에서 사용자 데이터를 수집하거나 공유합니까? `예`
  - [ ] 수집되는 데이터 유형
    - [ ] 개인 정보: 이름, 이메일 (선택적)
    - [ ] 앱 활동: 일기 내용, 감정 데이터
    - [ ] 앱 정보 및 성능: 비정상 종료 로그
  - [ ] 데이터 처리 방법
    - [ ] 전송 중 암호화: `예`
    - [ ] 저장 중 암호화: `예`
    - [ ] 사용자가 데이터 삭제 요청 가능: `예`
- [ ] 저장

### 4-3. 광고
- [ ] "앱 콘텐츠" → "광고" 메뉴
- [ ] 앱에 광고가 포함되어 있습니까? `예`
  - [ ] AdMob 광고 사용
  - [ ] 무료 사용자에게만 표시
- [ ] 저장

### 4-4. 콘텐츠 등급
- [ ] "앱 콘텐츠" → "콘텐츠 등급" 메뉴
- [ ] 설문지 작성
  - [ ] 폭력: 없음
  - [ ] 성적 콘텐츠: 없음
  - [ ] 언어: 없음
  - [ ] 민감한 주제: 없음
  - [ ] 약물: 없음
  - [ ] 사용자 생성 콘텐츠: `예` (일기 작성)
- [ ] 등급 확인: `만 3세 이상` (예상)
- [ ] 저장

### 4-5. 타겟 연령층 및 콘텐츠
- [ ] "앱 콘텐츠" → "타겟 연령층" 메뉴
- [ ] 타겟 연령층 선택: `13세 이상` 또는 `만 3세 이상`
- [ ] 저장

### 4-6. 뉴스 앱 (해당 없음)
- [ ] "앱 콘텐츠" → "뉴스 앱" 메뉴
- [ ] 뉴스 앱입니까? `아니요`

---

## Phase 5: 앱 릴리스 빌드 준비

### 5-1. 서명 키 생성
- [ ] Android Studio 또는 keytool 사용
  ```bash
  keytool -genkey -v -keystore ~/upload-keystore.jks \
    -keyalg RSA -keysize 2048 -validity 10000 \
    -alias upload
  ```
- [ ] 키 정보 안전하게 보관
  - [ ] 키스토어 비밀번호
  - [ ] 키 비밀번호
  - [ ] 별칭 (alias)

### 5-2. `key.properties` 설정
- [ ] `android/key.properties` 파일 생성
  ```properties
  storePassword=<비밀번호>
  keyPassword=<비밀번호>
  keyAlias=upload
  storeFile=/Users/username/upload-keystore.jks
  ```
- [ ] `.gitignore`에 `key.properties` 추가 확인

### 5-3. `android/app/build.gradle` 설정
- [ ] 서명 설정 확인
  ```gradle
  def keystoreProperties = new Properties()
  def keystorePropertiesFile = rootProject.file('key.properties')
  if (keystorePropertiesFile.exists()) {
      keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
  }

  android {
      ...
      signingConfigs {
          release {
              keyAlias keystoreProperties['keyAlias']
              keyPassword keystoreProperties['keyPassword']
              storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
              storePassword keystoreProperties['storePassword']
          }
      }
      buildTypes {
          release {
              signingConfig signingConfigs.release
              minifyEnabled true
              shrinkResources true
          }
      }
  }
  ```

### 5-4. Release APK/AAB 빌드
- [ ] AAB (Android App Bundle) 빌드 (권장)
  ```bash
  flutter build appbundle --release
  ```
- [ ] 빌드 결과 확인: `build/app/outputs/bundle/release/app-release.aab`
- [ ] APK 빌드 (선택 사항)
  ```bash
  flutter build apk --release
  ```

---

## Phase 6: Google Play Console에 앱 업로드

### 6-1. 프로덕션 트랙 설정
- [ ] "프로덕션" → "새 버전 만들기" 클릭
- [ ] AAB 파일 업로드
  - [ ] `app-release.aab` 파일 드래그 앤 드롭
  - [ ] 업로드 완료 대기
- [ ] 버전 이름: `1.0.0`
- [ ] 버전 코드: `1` (자동 설정됨)

### 6-2. 출시 노트 작성
- [ ] 한국어 출시 노트:
  ```
  🎉 ArtDiary AI 첫 번째 버전 출시!

  ✨ 주요 기능
  - AI 이미지 생성으로 감성적인 일기 삽화
  - 감정 분석 및 통계
  - 월간/연간 감정 리포트
  - Google Drive 백업
  - 프리미엄 구독 (무료 평가판 7일)

  📝 시작하기
  - 무료로 하루 5회 AI 이미지 생성
  - 프리미엄으로 무제한 이용 가능
  ```
- [ ] 영어 출시 노트 (선택 사항)

### 6-3. 국가 및 지역 선택
- [ ] "국가/지역" 탭
- [ ] 출시할 국가 선택
  - [ ] 대한민국
  - [ ] 미국
  - [ ] 일본
  - [ ] 기타 (선택)
- [ ] 저장

---

## Phase 7: 검토 및 제출

### 7-1. 최종 체크리스트
- [ ] 모든 필수 항목 완료 확인
  - [ ] 앱 콘텐츠 (개인정보처리방침, 데이터 보안, 광고, 콘텐츠 등급)
  - [ ] 스토어 등록정보 (설명, 스크린샷, 아이콘)
  - [ ] 인앱 상품 (구독 설정)
  - [ ] 가격 및 배포 (무료)
  - [ ] 앱 콘텐츠 (개인정보처리방침)
- [ ] 앱 미리보기 확인

### 7-2. 심사 제출
- [ ] "검토" 탭에서 모든 항목 확인
- [ ] "프로덕션으로 출시 검토" 버튼 클릭
- [ ] 최종 확인 후 "출시 시작" 클릭
- [ ] 심사 대기 (일반적으로 1-3일 소요)

---

## Phase 8: 코드 구현 (결제 시스템)

### 8-1. PurchaseService 완성
- [ ] `lib/services/purchase_service.dart` 수정
  - [ ] `premium_yearly` 상품 ID 추가
  - [ ] `hasActiveSubscription()` 구현
  - [ ] 구독 상태 저장/로드 (SharedPreferences)

### 8-2. PurchaseStateProvider 연동
- [ ] `lib/providers/purchase_state_provider.dart` 확인
- [ ] 구독 상태 변경 시 UI 업데이트
- [ ] 프리미엄 기능 잠금/해제 로직

### 8-3. UI 구현
- [ ] 프리미엄 구독 화면 (`premium_subscription_screen.dart`)
  - [ ] 월간/연간 가격 표시
  - [ ] 기능 비교표
  - [ ] 구매 버튼
  - [ ] 복원 버튼
- [ ] 설정 화면에서 구독 관리 메뉴 추가

---

## Phase 9: 샌드박스 테스트

### 9-1. 테스트 계정 설정
- [ ] Google Play Console → "설정" → "라이선스 테스트"
- [ ] 테스트 Gmail 계정 추가
- [ ] AAB 파일을 내부 테스트 트랙에 업로드

### 9-2. 테스트 기기 설정
- [ ] Google Play에서 앱 다운로드 (내부 테스트)
- [ ] 테스트 계정으로 로그인

### 9-3. 테스트 시나리오
- [ ] 월간 구독 구매 테스트
  - [ ] 구매 플로우 진행
  - [ ] 결제는 실제로 청구되지 않음 (샌드박스)
  - [ ] 구독 활성화 확인
  - [ ] 프리미엄 기능 접근 확인
- [ ] 연간 구독 구매 테스트
- [ ] 구독 취소 테스트
  - [ ] Google Play → 구독 관리에서 취소
  - [ ] 앱에서 구독 상태 변경 확인
- [ ] 구독 복원 테스트
  - [ ] 앱 재설치
  - [ ] "구독 복원" 버튼 클릭
  - [ ] 구독 상태 복원 확인
- [ ] 무료 평가판 테스트
  - [ ] 7일 평가판 시작
  - [ ] 평가판 기간 동안 프리미엄 기능 사용
  - [ ] 평가판 만료 후 상태 확인

---

## Phase 10: 출시 후 모니터링

### 10-1. Google Play Console 모니터링
- [ ] 일일 다운로드 수 확인
- [ ] 사용자 리뷰 및 평점 확인
- [ ] 비정상 종료 보고서 확인
- [ ] ANR (Application Not Responding) 보고서 확인

### 10-2. 업데이트 배포
- [ ] 버그 수정 또는 기능 추가
- [ ] 버전 번호 증가 (예: 1.0.0 → 1.0.1)
- [ ] 새 AAB 빌드
- [ ] Google Play Console에 업로드
- [ ] 출시 노트 작성
- [ ] 심사 제출

---

## 체크리스트 요약

**Google Play Console 설정:**
- [ ] 개발자 등록 ($25)
- [ ] 판매자 계정 설정
- [ ] 앱 생성 및 기본 정보
- [ ] 그래픽 자산 업로드
- [ ] 인앱 구독 상품 생성
- [ ] 앱 콘텐츠 설정
- [ ] 개인정보처리방침 URL

**앱 빌드:**
- [ ] 서명 키 생성
- [ ] Release AAB 빌드
- [ ] Google Play Console 업로드

**코드 구현:**
- [ ] PurchaseService 완성
- [ ] PurchaseStateProvider 연동
- [ ] 프리미엄 구독 UI

**테스트:**
- [ ] 샌드박스 구매 테스트
- [ ] 구독 복원 테스트
- [ ] 무료 평가판 테스트

**출시:**
- [ ] 심사 제출
- [ ] 승인 대기
- [ ] 출시 완료

---

**예상 일정:**
- Day 1: Google Play Console 등록 및 앱 생성
- Day 2-3: 인앱 상품 설정 및 앱 콘텐츠 작성
- Day 4-5: 코드 구현 (결제 시스템)
- Day 6-7: 샌드박스 테스트 및 버그 수정
- Day 8: 최종 빌드 및 심사 제출
- Day 9-11: 심사 대기 (1-3일)
- Day 12: 출시 완료

**참고 문서:**
- Google Play Console 가이드: https://support.google.com/googleplay/android-developer
- 인앱 결제 문서: https://developer.android.com/google/play/billing
- Flutter 앱 배포: https://docs.flutter.dev/deployment/android
