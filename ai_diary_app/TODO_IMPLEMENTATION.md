# 광고 및 구매 시스템 구현 TODO

## 프로젝트 개요
- 무료 사용자: 광고 표시 (보상형 + 배너)
- 프리미엄 사용자: 광고 없음, 모든 기능 접근
- 현재 상태: pubspec.yaml 패키지 추가 완료

---

## Phase 1: 환경 설정 및 기본 파일 생성

### 1.1 .env 파일 생성
**파일 위치**: `/Users/kimjaeheung/Desktop/Desktop/Dev/project7_diary/ai_diary_app/.env`

**내용**:
```env
# AdMob 테스트 광고 ID (개발 중 사용)
ADMOB_ANDROID_APP_ID=ca-app-pub-3940256099942544~3347511713
ADMOB_IOS_APP_ID=ca-app-pub-3940256099942544~1458002511

# 보상형 광고 테스트 ID
ADMOB_REWARDED_AD_UNIT_ID_ANDROID=ca-app-pub-3940256099942544/5224354917
ADMOB_REWARDED_AD_UNIT_ID_IOS=ca-app-pub-3940256099942544/1712485313

# 배너 광고 테스트 ID
ADMOB_BANNER_AD_UNIT_ID_ANDROID=ca-app-pub-3940256099942544/6300978111
ADMOB_BANNER_AD_UNIT_ID_IOS=ca-app-pub-3940256099942544/2934735716

# 전면 광고 테스트 ID
ADMOB_INTERSTITIAL_AD_UNIT_ID_ANDROID=ca-app-pub-3940256099942544/1033173712
ADMOB_INTERSTITIAL_AD_UNIT_ID_IOS=ca-app-pub-3940256099942544/4411468910
```

**체크리스트**:
- [ ] .env 파일 생성
- [ ] .gitignore에 .env 추가되어 있는지 확인
- [ ] .env.example 파일 생성 (템플릿용)

---

### 1.2 .env.example 파일 생성
**파일 위치**: `/Users/kimjaeheung/Desktop/Desktop/Dev/project7_diary/ai_diary_app/.env.example`

**내용**:
```env
# AdMob 앱 ID
ADMOB_ANDROID_APP_ID=your_android_app_id_here
ADMOB_IOS_APP_ID=your_ios_app_id_here

# 보상형 광고 단위 ID
ADMOB_REWARDED_AD_UNIT_ID_ANDROID=your_android_rewarded_ad_id_here
ADMOB_REWARDED_AD_UNIT_ID_IOS=your_ios_rewarded_ad_id_here

# 배너 광고 단위 ID
ADMOB_BANNER_AD_UNIT_ID_ANDROID=your_android_banner_ad_id_here
ADMOB_BANNER_AD_UNIT_ID_IOS=your_ios_banner_ad_id_here

# 전면 광고 단위 ID
ADMOB_INTERSTITIAL_AD_UNIT_ID_ANDROID=your_android_interstitial_ad_id_here
ADMOB_INTERSTITIAL_AD_UNIT_ID_IOS=your_ios_interstitial_ad_id_here
```

**체크리스트**:
- [ ] .env.example 파일 생성
- [ ] Git에 커밋 (템플릿이므로 커밋 가능)

---

### 1.3 flutter pub get 실행
**작업**:
```bash
cd /Users/kimjaeheung/Desktop/Desktop/Dev/project7_diary/ai_diary_app
/Users/kimjaeheung/Desktop/Desktop/Dev/flutter/bin/flutter pub get
```

**체크리스트**:
- [ ] flutter pub get 실행
- [ ] 패키지 다운로드 완료 확인
- [ ] 오류 없이 완료되었는지 확인

---

## Phase 2: Android 네이티브 설정

### 2.1 AndroidManifest.xml 수정
**파일 위치**: `/Users/kimjaeheung/Desktop/Desktop/Dev/project7_diary/ai_diary_app/android/app/src/main/AndroidManifest.xml`

**수정 내용**:
1. `<application>` 태그 내부에 AdMob 앱 ID 추가:
```xml
<meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="ca-app-pub-3940256099942544~3347511713"/>
```

2. 인터넷 권한 확인 (이미 있을 가능성 높음):
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
```

**체크리스트**:
- [ ] AndroidManifest.xml 파일 읽기
- [ ] `<application>` 태그 내부에 meta-data 추가
- [ ] 인터넷 권한 확인
- [ ] 파일 저장 및 확인

---

### 2.2 build.gradle 확인
**파일 위치**: `/Users/kimjaeheung/Desktop/Desktop/Dev/project7_diary/ai_diary_app/android/app/build.gradle`

**확인 사항**:
1. minSdkVersion이 21 이상인지 확인:
```gradle
defaultConfig {
    minSdkVersion 21  // 최소 21 필요
}
```

2. (선택) Google Play Services 명시적 추가:
```gradle
dependencies {
    implementation 'com.google.android.gms:play-services-ads:23.0.0'
}
```

**체크리스트**:
- [ ] build.gradle 파일 읽기
- [ ] minSdkVersion 확인 (21 이상)
- [ ] 필요시 dependencies 추가

---

## Phase 3: iOS 네이티브 설정

### 3.1 Info.plist 수정
**파일 위치**: `/Users/kimjaeheung/Desktop/Desktop/Dev/project7_diary/ai_diary_app/ios/Runner/Info.plist`

**수정 내용**:
1. AdMob 앱 ID 추가:
```xml
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-3940256099942544~1458002511</string>
```

2. App Tracking Transparency 권한 추가:
```xml
<key>NSUserTrackingUsageDescription</key>
<string>맞춤형 광고를 제공하기 위해 추적 권한이 필요합니다.</string>
```

3. SKAdNetwork 식별자 추가 (Google AdMob 제공):
```xml
<key>SKAdNetworkItems</key>
<array>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>cstr6suwn9.skadnetwork</string>
  </dict>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>4fzdc2evr5.skadnetwork</string>
  </dict>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>v72qych5uu.skadnetwork</string>
  </dict>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>ludvb6z3bs.skadnetwork</string>
  </dict>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>2u9pt9hc89.skadnetwork</string>
  </dict>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>yclnxrl5pm.skadnetwork</string>
  </dict>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>t38b2kh725.skadnetwork</string>
  </dict>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>7ug5zh24hu.skadnetwork</string>
  </dict>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>9rd848q2bz.skadnetwork</string>
  </dict>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>n6fk4nfna4.skadnetwork</string>
  </dict>
</array>
```

**체크리스트**:
- [ ] Info.plist 파일 읽기
- [ ] GADApplicationIdentifier 추가
- [ ] NSUserTrackingUsageDescription 추가
- [ ] SKAdNetworkItems 추가
- [ ] 파일 저장 및 확인

---

### 3.2 Podfile 확인
**파일 위치**: `/Users/kimjaeheung/Desktop/Desktop/Dev/project7_diary/ai_diary_app/ios/Podfile`

**확인 사항**:
```ruby
platform :ios, '12.0'  # 최소 iOS 12 필요
```

**체크리스트**:
- [ ] Podfile 파일 읽기
- [ ] iOS 버전 12.0 이상 확인

---

## Phase 4: 유틸리티 파일 생성

### 4.1 AppLogger 유틸리티 생성
**파일 위치**: `/Users/kimjaeheung/Desktop/Desktop/Dev/project7_diary/ai_diary_app/lib/utils/app_logger.dart`

**내용**:
```dart
import 'package:flutter/foundation.dart';

/// 앱 전체에서 사용하는 로거
class AppLogger {
  static void log(String message) {
    if (kDebugMode) {
      print('[ArtDiary] $message');
    }
  }
}
```

**체크리스트**:
- [ ] lib/utils 폴더 생성 (이미 있으면 스킵)
- [ ] app_logger.dart 파일 생성
- [ ] 파일 저장 및 확인

---

## Phase 5: 광고 서비스 구현

### 5.1 AdService 생성
**파일 위치**: `/Users/kimjaeheung/Desktop/Desktop/Dev/project7_diary/ai_diary_app/lib/services/ad_service.dart`

**내용**: TODO_AD.md 5.2절 참조 (약 600줄)

**주요 기능**:
- AdMob 초기화
- 보상형 광고 로드/표시
- 배너 광고 로드/표시
- 전면 광고 로드/표시
- 광고 빈도 제한
- 오류 처리

**체크리스트**:
- [ ] ad_service.dart 파일 생성
- [ ] 전체 코드 작성 (TODO_AD.md 5.2절 코드 사용)
- [ ] import 문 확인
- [ ] 파일 저장 및 확인

---

### 5.2 AdBannerWidget 생성
**파일 위치**: `/Users/kimjaeheung/Desktop/Desktop/Dev/project7_diary/ai_diary_app/lib/widgets/ad_banner_widget.dart`

**내용**: TODO_AD.md 5.3절 참조 (약 100줄)

**주요 기능**:
- 프리미엄 사용자 확인
- 배너 광고 로드
- 광고 표시/숨김 처리
- 로딩 상태 UI

**체크리스트**:
- [ ] ad_banner_widget.dart 파일 생성
- [ ] 전체 코드 작성 (TODO_AD.md 5.3절 코드 사용)
- [ ] import 문 확인
- [ ] 파일 저장 및 확인

---

## Phase 6: main.dart 수정

### 6.1 main.dart에 AdMob 초기화 추가
**파일 위치**: `/Users/kimjaeheung/Desktop/Desktop/Dev/project7_diary/ai_diary_app/lib/main.dart`

**수정 사항**:

1. import 추가:
```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'services/ad_service.dart';
```

2. main() 함수 수정:
```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // .env 파일 로드
  await dotenv.load(fileName: ".env");

  // Firebase 초기화 (기존 코드 유지)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // AdMob 초기화
  await AdService.initialize();

  // 보상형 광고 미리 로드
  AdService().loadRewardedAd();

  // 전면 광고 미리 로드 (선택)
  AdService().loadInterstitialAd();

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}
```

**체크리스트**:
- [ ] main.dart 파일 읽기
- [ ] import 추가
- [ ] main() 함수 수정
- [ ] 파일 저장 및 확인

---

## Phase 7: 일기 작성 화면에 보상형 광고 통합

### 7.1 diary_create_screen.dart 수정
**파일 위치**: `/Users/kimjaeheung/Desktop/Desktop/Dev/project7_diary/ai_diary_app/lib/screens/diary_create_screen.dart`

**수정 사항**:

1. import 추가:
```dart
import '../services/ad_service.dart';
```

2. `_generateDiary()` 메서드 수정 (약 라인 500-600):
```dart
Future<void> _generateDiary() async {
  if (!_formKey.currentState!.validate()) return;

  final subscription = ref.read(subscriptionProvider);

  // 무료 사용자는 보상형 광고 시청 필수
  if (!subscription.isPremium) {
    setState(() {
      _progressMessage = '광고 준비 중...';
    });

    // 광고 서비스 호출
    final adWatched = await AdService.showRewardedAd();
    if (!adWatched) {
      // 광고 시청 실패 처리
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('광고를 시청해야 이미지를 생성할 수 있습니다.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }
  }

  // 기존 이미지 생성 로직 진행 (기존 코드 유지)
  setState(() {
    _isLoading = true;
    _isGeneratingImage = true;
    _progressMessage = '사진 분석 중...';
  });

  // ... 기존 코드 계속
}
```

**체크리스트**:
- [ ] diary_create_screen.dart 파일 읽기
- [ ] import 추가
- [ ] _generateDiary() 메서드 찾기
- [ ] 광고 체크 로직 추가 (subscription.isPremium 확인)
- [ ] 광고 시청 실패 시 SnackBar 표시
- [ ] 파일 저장 및 확인

---

## Phase 8: 일기 목록 화면에 배너 광고 통합

### 8.1 diary_list_screen.dart 수정
**파일 위치**: `/Users/kimjaeheung/Desktop/Desktop/Dev/project7_diary/ai_diary_app/lib/screens/diary_list_screen.dart`

**수정 사항**:

1. import 추가:
```dart
import '../widgets/ad_banner_widget.dart';
```

2. build() 메서드 수정 (Scaffold body 부분):
```dart
@override
Widget build(BuildContext context) {
  final subscription = ref.watch(subscriptionProvider);

  return Scaffold(
    appBar: AppBar(...),
    body: Stack(
      children: [
        // 기존 컨텐츠 (일기 목록)
        Padding(
          padding: EdgeInsets.only(
            bottom: subscription.isPremium ? 0 : 60, // 광고 높이만큼 패딩
          ),
          child: _buildDiaryList(),  // 기존 ListView 메서드
        ),

        // 배너 광고 (무료 사용자만)
        if (!subscription.isPremium)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: const AdBannerWidget(),
          ),
      ],
    ),
    floatingActionButton: FloatingActionButton(...),
  );
}
```

**체크리스트**:
- [ ] diary_list_screen.dart 파일 읽기
- [ ] import 추가
- [ ] build() 메서드의 body를 Stack으로 변경
- [ ] 기존 ListView를 Padding으로 감싸기 (하단 여백 추가)
- [ ] Positioned + AdBannerWidget 추가
- [ ] subscription.isPremium 조건 확인
- [ ] 파일 저장 및 확인

---

## Phase 9: 프리미엄 구독 화면에 광고 제거 혜택 추가

### 9.1 premium_subscription_screen.dart 수정
**파일 위치**: `/Users/kimjaeheung/Desktop/Desktop/Dev/project7_diary/ai_diary_app/lib/screens/premium_subscription_screen.dart`

**수정 사항**:

1. `_buildFeaturesList()` 메서드에 광고 제거 혜택 추가 (약 라인 117):
```dart
_buildFeatureItem(
  icon: Icons.block,
  iconColor: Colors.red,
  title: '광고 없는 경험',
  description: '모든 광고를 제거하고\n끊김 없는 일기 작성을 즐기세요',
),
```

위치: 기존 feature 목록 맨 위에 추가 (가장 먼저 표시)

**체크리스트**:
- [ ] premium_subscription_screen.dart 파일 읽기
- [ ] _buildFeaturesList() 메서드 찾기
- [ ] 광고 제거 혜택 항목 추가 (첫 번째 항목으로)
- [ ] 파일 저장 및 확인

---

## Phase 10: 테스트 및 검증

### 10.1 빌드 및 실행
**작업**:
```bash
# Flutter 프로세스 종료
pkill -f "flutter run"

# 에뮬레이터 종료
~/Library/Android/sdk/platform-tools/adb -s emulator-5554 emu kill

# 에뮬레이터 재시작
/Users/kimjaeheung/Desktop/Desktop/Dev/flutter/bin/flutter emulators --launch Medium_Phone_API_36.0

# 30초 대기 후 앱 실행
sleep 30
/Users/kimjaeheung/Desktop/Desktop/Dev/flutter/bin/flutter run -d emulator-5554
```

**체크리스트**:
- [ ] 빌드 오류 없이 완료
- [ ] 앱 정상 실행
- [ ] 크래시 없음

---

### 10.2 무료 사용자 테스트
**테스트 시나리오**:

1. **보상형 광고 테스트**:
   - [ ] 일기 작성 화면 진입
   - [ ] "AI 그림일기 생성" 버튼 클릭
   - [ ] 광고 로딩 확인
   - [ ] 테스트 광고 표시 확인
   - [ ] 광고 끝까지 시청
   - [ ] 이미지 생성 진행 확인

2. **배너 광고 테스트**:
   - [ ] 일기 목록 화면 진입
   - [ ] 화면 하단에 배너 광고 표시 확인
   - [ ] 배너 광고가 컨텐츠를 가리지 않는지 확인
   - [ ] 스크롤 시 배너 고정 확인

3. **광고 실패 테스트**:
   - [ ] 비행기 모드 활성화
   - [ ] 일기 생성 시도
   - [ ] fallback 동작 확인 (광고 없이 진행)

---

### 10.3 프리미엄 사용자 테스트
**테스트 시나리오**:

1. **프리미엄 전환**:
   - [ ] 설정 → 프리미엄 구독 화면 진입
   - [ ] "구독하기 (테스트)" 버튼 클릭
   - [ ] 프리미엄 활성화 확인

2. **광고 미표시 확인**:
   - [ ] 일기 작성 화면 진입
   - [ ] "AI 그림일기 생성" 버튼 클릭
   - [ ] 광고 없이 바로 이미지 생성 시작 확인
   - [ ] 일기 목록 화면에 배너 광고 없음 확인

---

## Phase 11: Git 커밋 및 푸시

### 11.1 변경사항 커밋
**작업**:
```bash
git add .
git commit -m "$(cat <<'EOF'
feat: 광고 시스템 구현 - AdMob 통합 완료

- Google AdMob SDK 통합 (보상형 광고, 배너 광고)
- 무료 사용자: 이미지 생성 전 보상형 광고 필수 시청
- 무료 사용자: 일기 목록 화면 하단 배너 광고 표시
- 프리미엄 사용자: 모든 광고 제거
- 광고 로드 실패 시 fallback 처리
- AdService, AdBannerWidget 구현
- Android/iOS 네이티브 설정 완료

🤖 Generated with Claude Code

Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"
```

**체크리스트**:
- [ ] git add 실행
- [ ] git commit 실행
- [ ] 커밋 메시지 확인

---

### 11.2 GitHub 푸시
**작업**:
```bash
git push origin main
```

**체크리스트**:
- [ ] git push 실행
- [ ] GitHub에서 커밋 확인

---

## Phase 12: 실제 광고 ID 적용 (출시 전)

### 12.1 AdMob 계정 생성
**작업**:
1. https://admob.google.com 접속
2. Google 계정으로 로그인
3. 앱 등록 (Android/iOS 각각)
4. 광고 단위 생성:
   - 보상형 광고 단위 (Android/iOS)
   - 배너 광고 단위 (Android/iOS)

**체크리스트**:
- [ ] AdMob 계정 생성
- [ ] Android 앱 등록
- [ ] iOS 앱 등록
- [ ] 광고 단위 생성 완료
- [ ] 광고 단위 ID 복사

---

### 12.2 .env 파일에 실제 ID 적용
**작업**:
1. .env 파일 열기
2. 테스트 ID를 실제 ID로 교체
3. .env 파일 저장

**주의**: .env 파일은 절대 Git에 커밋하지 않음

**체크리스트**:
- [ ] .env 파일 백업
- [ ] 실제 광고 ID로 교체
- [ ] .gitignore에 .env 있는지 재확인
- [ ] 파일 저장

---

### 12.3 Android/iOS 네이티브 설정 업데이트
**작업**:

1. **AndroidManifest.xml**:
```xml
<meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="실제_Android_앱_ID"/>
```

2. **Info.plist**:
```xml
<key>GADApplicationIdentifier</key>
<string>실제_iOS_앱_ID</string>
```

**체크리스트**:
- [ ] AndroidManifest.xml 업데이트
- [ ] Info.plist 업데이트
- [ ] 파일 저장

---

### 12.4 실제 광고로 테스트
**작업**:
1. 앱 재빌드
2. 실제 기기에서 테스트
3. 광고 표시 확인
4. AdMob 대시보드에서 광고 노출 확인

**주의**: 개발 중에는 자신의 광고를 클릭하지 말 것 (정책 위반)

**체크리스트**:
- [ ] 앱 재빌드
- [ ] 실제 기기에서 광고 표시 확인
- [ ] AdMob 대시보드 확인
- [ ] 정책 위반 없음 확인

---

## 추가 개선 사항 (선택)

### A. 전면 광고 추가
**파일 위치**: diary_create_screen.dart

**추가 위치**: 일기 저장 완료 후

**코드**:
```dart
Future<void> _saveDiary() async {
  // 일기 저장 로직 (기존 코드)
  await DatabaseService.insertDiary(diary);

  // 무료 사용자는 전면 광고 표시
  final subscription = ref.read(subscriptionProvider);
  if (!subscription.isPremium) {
    await AdService.showInterstitialAd();
  }

  // 다음 화면으로 이동
  Navigator.pop(context);
}
```

**체크리스트**:
- [ ] 전면 광고 추가 (선택)
- [ ] 빈도 제한 확인 (10분 간격)

---

### B. 통계 화면에 배너 광고 추가
**파일 위치**: emotion_stats_screen.dart

**수정 방법**: diary_list_screen.dart와 동일

**체크리스트**:
- [ ] emotion_stats_screen.dart 수정 (선택)
- [ ] Stack + AdBannerWidget 추가
- [ ] 테스트

---

### C. 광고 제거를 프리미엄 혜택 강조
**파일 위치**:
- diary_create_screen.dart
- diary_list_screen.dart

**추가 UI**: 무료 사용자가 광고 영역을 탭하면 프리미엄 안내 다이얼로그 표시

**체크리스트**:
- [ ] 광고 영역 탭 가능하도록 수정 (선택)
- [ ] 프리미엄 안내 다이얼로그 표시

---

## 체크리스트 요약

### Phase 1: 환경 설정
- [ ] .env 파일 생성
- [ ] .env.example 파일 생성
- [ ] flutter pub get 실행

### Phase 2-3: 네이티브 설정
- [ ] AndroidManifest.xml 수정
- [ ] build.gradle 확인
- [ ] Info.plist 수정
- [ ] Podfile 확인

### Phase 4-5: 서비스 구현
- [ ] AppLogger 생성
- [ ] AdService 생성
- [ ] AdBannerWidget 생성

### Phase 6-9: 앱 통합
- [ ] main.dart 수정
- [ ] diary_create_screen.dart 수정
- [ ] diary_list_screen.dart 수정
- [ ] premium_subscription_screen.dart 수정

### Phase 10: 테스트
- [ ] 빌드 및 실행
- [ ] 무료 사용자 테스트
- [ ] 프리미엄 사용자 테스트

### Phase 11: Git
- [ ] 변경사항 커밋
- [ ] GitHub 푸시

### Phase 12: 출시 준비 (나중에)
- [ ] AdMob 계정 생성
- [ ] 실제 광고 ID 적용
- [ ] 실제 광고로 테스트

---

## 참고 문서
- TODO_AD.md: 광고 통합 전체 계획
- pubspec.yaml: 패키지 의존성
- CLAUDE.md: 프로젝트 개발 가이드

## 주의사항
1. 핫리로드 작동 안 함 → 모든 수정 후 에뮬레이터 재시작 필요
2. .env 파일은 Git에 커밋하지 않음
3. 테스트 광고 ID로 개발, 출시 전 실제 ID로 교체
4. 무료 사용자만 광고 표시, 프리미엄은 광고 없음
5. 광고 로드 실패 시 fallback 허용 (사용자 경험 최우선)
