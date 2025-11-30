# 광고 기능 통합 계획서 (TODO_AD.md)

## 목차
1. [개요](#1-개요)
2. [광고 SDK 선택 및 설정](#2-광고-sdk-선택-및-설정)
3. [광고 유형 및 배치 전략](#3-광고-유형-및-배치-전략)
4. [프리미엄 사용자 광고 제거](#4-프리미엄-사용자-광고-제거)
5. [기술 구현 계획](#5-기술-구현-계획)
6. [사용자 경험 최적화](#6-사용자-경험-최적화)
7. [수익 최적화 전략](#7-수익-최적화-전략)
8. [테스트 및 검증](#8-테스트-및-검증)
9. [단계별 구현 로드맵](#9-단계별-구현-로드맵)

---

## 1. 개요

### 1.1 목표
- 무료 사용자에게 광고를 통한 수익화 모델 구축
- 프리미엄 사용자에게 광고 제거를 핵심 혜택으로 제공
- 사용자 경험을 해치지 않는 범위 내에서 광고 노출 최적화

### 1.2 현재 프로젝트 상태 분석
- ✅ 프리미엄 구독 시스템 구현 완료 (purchase_service.dart)
- ✅ subscriptionProvider를 통한 isPremium 상태 관리
- ✅ 무료/프리미엄 기능 구분 로직 적용 완료
- 🔲 광고 시스템 미구현

### 1.3 핵심 요구사항
1. **무료 사용자**: 이미지 생성 전 보상형 광고 필수 시청
2. **무료 사용자**: 일기 목록 및 상세 화면에 배너/전면 광고 표시
3. **프리미엄 사용자**: 모든 광고 제거
4. **광고 실패 처리**: 광고 로드 실패 시에도 기능 사용 가능하도록 fallback 제공

---

## 2. 광고 SDK 선택 및 설정

### 2.1 추천 SDK: Google AdMob

**선택 이유:**
- Flutter 공식 플러그인 제공 (google_mobile_ads)
- 높은 eCPM (수익성)
- 방대한 광고 네트워크
- 안정적인 광고 필
- 다양한 광고 형식 지원
- 자세한 문서 및 커뮤니티 지원

**대안 SDK (향후 고려):**
- Unity Ads (게임형 앱에 유리)
- AppLovin (높은 수익률)
- IronSource (중재 플랫폼)

### 2.2 AdMob 계정 설정

**단계:**
1. Google AdMob 계정 생성 (https://admob.google.com)
2. 앱 등록 (Android/iOS 각각)
3. 광고 단위(Ad Unit) 생성

**필요한 광고 단위:**

| 광고 유형 | 용도 | 우선순위 |
|---------|------|---------|
| Rewarded Ad (보상형) | 이미지 생성 전 필수 시청 | 최우선 |
| Banner Ad (배너) | 일기 목록 하단 고정 | 높음 |
| Interstitial Ad (전면) | 일기 작성 완료 후 | 중간 |
| Native Ad (네이티브) | 일기 상세 화면 (선택) | 낮음 |

**광고 단위 ID 저장 위치:**
```
.env 파일에 저장 (보안)
ADMOB_ANDROID_APP_ID=ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY
ADMOB_IOS_APP_ID=ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY
ADMOB_REWARDED_AD_UNIT_ID_ANDROID=ca-app-pub-XXXXXXXXXXXXXXXX/ZZZZZZZZZZ
ADMOB_REWARDED_AD_UNIT_ID_IOS=ca-app-pub-XXXXXXXXXXXXXXXX/ZZZZZZZZZZ
ADMOB_BANNER_AD_UNIT_ID_ANDROID=...
ADMOB_BANNER_AD_UNIT_ID_IOS=...
ADMOB_INTERSTITIAL_AD_UNIT_ID_ANDROID=...
ADMOB_INTERSTITIAL_AD_UNIT_ID_IOS=...
```

### 2.3 pubspec.yaml 패키지 추가

```yaml
dependencies:
  google_mobile_ads: ^5.2.0  # 최신 버전 확인
  flutter_dotenv: ^5.1.0     # .env 파일 관리
```

### 2.4 Android 설정

**파일: android/app/src/main/AndroidManifest.xml**

```xml
<manifest>
  <application>
    <!-- AdMob 앱 ID -->
    <meta-data
      android:name="com.google.android.gms.ads.APPLICATION_ID"
      android:value="${ADMOB_ANDROID_APP_ID}"/>
  </application>

  <!-- 인터넷 권한 (이미 있을 가능성 높음) -->
  <uses-permission android:name="android.permission.INTERNET"/>
  <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
</manifest>
```

**파일: android/app/build.gradle**

```gradle
android {
    defaultConfig {
        // minSdkVersion 21 이상 필요
        minSdkVersion 21
    }
}

dependencies {
    // 필요시 Google Play Services 명시
    implementation 'com.google.android.gms:play-services-ads:23.0.0'
}
```

### 2.5 iOS 설정

**파일: ios/Runner/Info.plist**

```xml
<dict>
  <!-- AdMob 앱 ID -->
  <key>GADApplicationIdentifier</key>
  <string>${ADMOB_IOS_APP_ID}</string>

  <!-- iOS 14+ App Tracking Transparency -->
  <key>NSUserTrackingUsageDescription</key>
  <string>맞춤형 광고를 제공하기 위해 추적 권한이 필요합니다.</string>

  <!-- SKAdNetwork 식별자 (Google AdMob 제공 목록) -->
  <key>SKAdNetworkItems</key>
  <array>
    <dict>
      <key>SKAdNetworkIdentifier</key>
      <string>cstr6suwn9.skadnetwork</string>
    </dict>
    <!-- 추가 SKAdNetwork IDs... (AdMob 문서 참조) -->
  </array>
</dict>
```

**파일: ios/Podfile**

```ruby
platform :ios, '12.0'  # 최소 iOS 12 필요
```

---

## 3. 광고 유형 및 배치 전략

### 3.1 보상형 광고 (Rewarded Ad) - 최우선

**배치 위치:**
- 일기 작성 화면에서 "AI 그림일기 생성" 버튼 클릭 시

**사용자 플로우:**
```
[사용자가 "AI 그림일기 생성" 버튼 클릭]
    ↓
[프리미엄 사용자인가?]
    ├─ YES → [즉시 이미지 생성 시작]
    └─ NO  → [보상형 광고 로드]
              ↓
         [광고가 로드되었는가?]
              ├─ YES → [광고 표시]
              │         ↓
              │    [사용자가 광고를 끝까지 시청했는가?]
              │         ├─ YES → [이미지 생성 시작]
              │         └─ NO  → [알림: "광고를 끝까지 시청해야 합니다"]
              │
              └─ NO  → [fallback: 광고 없이 이미지 생성 허용]
                       [로그: 광고 로드 실패 기록]
```

**핵심 구현 포인트:**
- 광고를 끝까지 시청한 경우에만 이미지 생성 진행
- 광고 로드 실패 시 사용자 경험 저하 방지 (일정 횟수까지 fallback 허용)
- 광고 시청 완료 검증 (onUserEarnedReward 콜백 확인)

**빈도 제한:**
- 연속 광고 시청 방지: 최소 5분 간격
- 광고 로드 실패 시 다음 요청까지 1분 대기

### 3.2 배너 광고 (Banner Ad)

**배치 위치:**
- 일기 목록 화면 (DiaryListScreen) - 화면 하단 고정
- 통계 화면 (EmotionStatsScreen) - 화면 하단 고정 (선택)

**사용자 플로우:**
```
[무료 사용자가 일기 목록 화면 진입]
    ↓
[화면 하단에 배너 광고 표시]
- 크기: 320x50 (표준 배너)
- 위치: SafeArea 내부, 하단 고정
- 스크롤과 독립적으로 고정 표시
```

**구현 방법:**
- Stack 위젯 사용하여 컨텐츠 위에 배너 고정
- 광고 높이만큼 컨텐츠 하단 패딩 추가 (overlap 방지)

### 3.3 전면 광고 (Interstitial Ad)

**배치 위치:**
- 일기 작성 완료 후 (저장 성공 시)
- 일기 목록에서 일기 상세로 이동 시 (너무 잦으면 UX 저해)

**사용자 플로우:**
```
[무료 사용자가 일기 저장 완료]
    ↓
[전면 광고 로드 여부 확인]
    ├─ 로드됨 → [광고 표시] → [5초 후 닫기 버튼 활성화]
    └─ 미로드 → [광고 없이 다음 화면으로 이동]
    ↓
[일기 상세 화면으로 이동]
```

**빈도 제한:**
- 일기당 1회만 (같은 세션에서 중복 표시 금지)
- 최소 10분 간격 유지
- 광고 피로도 방지

### 3.4 네이티브 광고 (Native Ad) - 선택 사항

**배치 위치:**
- 일기 상세 화면 (DiaryDetailScreen) - 컨텐츠 중간에 자연스럽게 통합

**장점:**
- 사용자 경험 방해 최소화
- 높은 CTR (클릭률)
- 앱 디자인과 조화

**단점:**
- 구현 복잡도 높음
- 초기 단계에서는 우선순위 낮음

---

## 4. 프리미엄 사용자 광고 제거

### 4.1 광고 표시 조건 체크

**모든 광고 로드/표시 전에 확인:**
```dart
final subscription = ref.read(subscriptionProvider);
if (subscription.isPremium) {
  // 광고 표시 안 함
  return;
}
// 광고 표시 진행
```

### 4.2 기존 코드 수정 지점

**파일: lib/screens/diary_create_screen.dart**

**수정 메서드: _generateDiary()**

```dart
Future<void> _generateDiary() async {
  if (!_formKey.currentState!.validate()) return;

  final subscription = ref.read(subscriptionProvider);

  // 무료 사용자는 보상형 광고 시청 필수
  if (!subscription.isPremium) {
    // 광고 서비스 호출
    final adWatched = await AdService.showRewardedAd();
    if (!adWatched) {
      // 광고 시청 실패 (사용자가 닫거나, 로드 실패)
      // fallback 로직 또는 재시도 안내
      return;
    }
  }

  // 이미지 생성 로직 진행 (기존 코드)
  setState(() {
    _isLoading = true;
    _isGeneratingImage = true;
    _progressMessage = '감정 분석 중...';
  });

  // ... 기존 코드 계속
}
```

**파일: lib/screens/diary_list_screen.dart**

**배너 광고 추가:**

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
          child: _buildDiaryList(),
        ),

        // 배너 광고 (무료 사용자만)
        if (!subscription.isPremium)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AdBannerWidget(),
          ),
      ],
    ),
  );
}
```

### 4.3 광고 제거 혜택 홍보

**프리미엄 안내 다이얼로그 수정:**

기존 `_showPremiumDialog()` 메서드에 광고 제거 혜택 추가:

```dart
_buildPremiumFeature(
  Icons.block,
  '광고 없는 경험',
  '모든 광고를 제거하고 끊김 없는 일기 작성과 감상을 즐기세요',
  Colors.red,
),
```

---

## 5. 기술 구현 계획

### 5.1 파일 구조

```
lib/
├── services/
│   └── ad_service.dart              # 광고 로드/표시 로직
├── providers/
│   └── ad_state_provider.dart       # 광고 상태 관리
├── models/
│   └── ad_config.dart               # 광고 설정 모델
└── widgets/
    ├── ad_banner_widget.dart        # 배너 광고 위젯
    └── ad_loading_dialog.dart       # 광고 로딩 중 다이얼로그
```

### 5.2 AdService 구현 (services/ad_service.dart)

```dart
import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../utils/app_logger.dart';

/// 광고 서비스
/// Google AdMob을 통한 광고 로드 및 표시를 관리합니다.
class AdService {
  // 싱글톤 패턴
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  // 광고 ID 가져오기
  static String get rewardedAdUnitId {
    if (Platform.isAndroid) {
      return dotenv.env['ADMOB_REWARDED_AD_UNIT_ID_ANDROID'] ?? '';
    } else if (Platform.isIOS) {
      return dotenv.env['ADMOB_REWARDED_AD_UNIT_ID_IOS'] ?? '';
    }
    return '';
  }

  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return dotenv.env['ADMOB_BANNER_AD_UNIT_ID_ANDROID'] ?? '';
    } else if (Platform.isIOS) {
      return dotenv.env['ADMOB_BANNER_AD_UNIT_ID_IOS'] ?? '';
    }
    return '';
  }

  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return dotenv.env['ADMOB_INTERSTITIAL_AD_UNIT_ID_ANDROID'] ?? '';
    } else if (Platform.isIOS) {
      return dotenv.env['ADMOB_INTERSTITIAL_AD_UNIT_ID_IOS'] ?? '';
    }
    return '';
  }

  // 광고 인스턴스
  RewardedAd? _rewardedAd;
  InterstitialAd? _interstitialAd;

  // 광고 로드 상태
  bool _isRewardedAdLoading = false;
  bool _isInterstitialAdLoading = false;

  // 마지막 광고 표시 시간 (빈도 제한용)
  DateTime? _lastRewardedAdTime;
  DateTime? _lastInterstitialAdTime;

  /// AdMob 초기화
  static Future<void> initialize() async {
    try {
      AppLogger.log('=== AdMob 초기화 시작 ===');
      await MobileAds.instance.initialize();
      AppLogger.log('AdMob 초기화 완료');
    } catch (e) {
      AppLogger.log('AdMob 초기화 오류: $e');
    }
  }

  /// 보상형 광고 로드
  Future<void> loadRewardedAd() async {
    if (_isRewardedAdLoading || _rewardedAd != null) {
      AppLogger.log('보상형 광고 이미 로드 중이거나 로드됨');
      return;
    }

    _isRewardedAdLoading = true;

    try {
      await RewardedAd.load(
        adUnitId: rewardedAdUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            AppLogger.log('보상형 광고 로드 성공');
            _rewardedAd = ad;
            _isRewardedAdLoading = false;

            // 광고 이벤트 리스너 설정
            _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
              onAdShowedFullScreenContent: (ad) {
                AppLogger.log('보상형 광고 표시됨');
              },
              onAdDismissedFullScreenContent: (ad) {
                AppLogger.log('보상형 광고 닫힘');
                ad.dispose();
                _rewardedAd = null;
                // 다음 광고 미리 로드
                loadRewardedAd();
              },
              onAdFailedToShowFullScreenContent: (ad, error) {
                AppLogger.log('보상형 광고 표시 실패: $error');
                ad.dispose();
                _rewardedAd = null;
              },
            );
          },
          onAdFailedToLoad: (error) {
            AppLogger.log('보상형 광고 로드 실패: $error');
            _isRewardedAdLoading = false;
            _rewardedAd = null;
          },
        ),
      );
    } catch (e) {
      AppLogger.log('보상형 광고 로드 예외: $e');
      _isRewardedAdLoading = false;
    }
  }

  /// 보상형 광고 표시
  /// 반환값: true = 광고 시청 완료, false = 광고 시청 실패
  static Future<bool> showRewardedAd() async {
    final instance = AdService();

    // 빈도 제한 체크 (최소 5분 간격)
    if (instance._lastRewardedAdTime != null) {
      final timeSinceLastAd = DateTime.now().difference(instance._lastRewardedAdTime!);
      if (timeSinceLastAd.inMinutes < 5) {
        AppLogger.log('광고 빈도 제한: ${5 - timeSinceLastAd.inMinutes}분 후 다시 시도');
        // fallback: 광고 없이 진행 허용
        return true;
      }
    }

    // 광고가 로드되지 않았으면 로드 시도
    if (instance._rewardedAd == null) {
      AppLogger.log('보상형 광고 미로드 상태, 로드 시작');
      await instance.loadRewardedAd();

      // 로드 완료 대기 (최대 5초)
      int attempts = 0;
      while (instance._rewardedAd == null && attempts < 10) {
        await Future.delayed(const Duration(milliseconds: 500));
        attempts++;
      }

      if (instance._rewardedAd == null) {
        AppLogger.log('보상형 광고 로드 타임아웃');
        // fallback: 광고 없이 진행 허용
        return true;
      }
    }

    // 광고 시청 완료 여부 플래그
    bool adWatched = false;

    try {
      await instance._rewardedAd!.show(
        onUserEarnedReward: (ad, reward) {
          AppLogger.log('보상형 광고 시청 완료: ${reward.amount} ${reward.type}');
          adWatched = true;
          instance._lastRewardedAdTime = DateTime.now();
        },
      );
    } catch (e) {
      AppLogger.log('보상형 광고 표시 오류: $e');
      return true; // fallback
    }

    return adWatched;
  }

  /// 전면 광고 로드
  Future<void> loadInterstitialAd() async {
    if (_isInterstitialAdLoading || _interstitialAd != null) {
      AppLogger.log('전면 광고 이미 로드 중이거나 로드됨');
      return;
    }

    _isInterstitialAdLoading = true;

    try {
      await InterstitialAd.load(
        adUnitId: interstitialAdUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            AppLogger.log('전면 광고 로드 성공');
            _interstitialAd = ad;
            _isInterstitialAdLoading = false;

            // 광고 이벤트 리스너 설정
            _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
              onAdShowedFullScreenContent: (ad) {
                AppLogger.log('전면 광고 표시됨');
              },
              onAdDismissedFullScreenContent: (ad) {
                AppLogger.log('전면 광고 닫힘');
                ad.dispose();
                _interstitialAd = null;
                // 다음 광고 미리 로드
                loadInterstitialAd();
              },
              onAdFailedToShowFullScreenContent: (ad, error) {
                AppLogger.log('전면 광고 표시 실패: $error');
                ad.dispose();
                _interstitialAd = null;
              },
            );
          },
          onAdFailedToLoad: (error) {
            AppLogger.log('전면 광고 로드 실패: $error');
            _isInterstitialAdLoading = false;
            _interstitialAd = null;
          },
        ),
      );
    } catch (e) {
      AppLogger.log('전면 광고 로드 예외: $e');
      _isInterstitialAdLoading = false;
    }
  }

  /// 전면 광고 표시
  static Future<void> showInterstitialAd() async {
    final instance = AdService();

    // 빈도 제한 체크 (최소 10분 간격)
    if (instance._lastInterstitialAdTime != null) {
      final timeSinceLastAd = DateTime.now().difference(instance._lastInterstitialAdTime!);
      if (timeSinceLastAd.inMinutes < 10) {
        AppLogger.log('전면 광고 빈도 제한: ${10 - timeSinceLastAd.inMinutes}분 후 다시 시도');
        return;
      }
    }

    if (instance._interstitialAd == null) {
      AppLogger.log('전면 광고 미로드 상태');
      return;
    }

    try {
      await instance._interstitialAd!.show();
      instance._lastInterstitialAdTime = DateTime.now();
    } catch (e) {
      AppLogger.log('전면 광고 표시 오류: $e');
    }
  }

  /// 메모리 정리
  static void dispose() {
    final instance = AdService();
    instance._rewardedAd?.dispose();
    instance._interstitialAd?.dispose();
    instance._rewardedAd = null;
    instance._interstitialAd = null;
    AppLogger.log('AdService 정리 완료');
  }
}
```

### 5.3 AdBannerWidget 구현 (widgets/ad_banner_widget.dart)

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../services/ad_service.dart';
import '../providers/subscription_provider.dart';
import '../utils/app_logger.dart';

/// 배너 광고 위젯
/// 무료 사용자에게만 표시됩니다.
class AdBannerWidget extends ConsumerStatefulWidget {
  const AdBannerWidget({super.key});

  @override
  ConsumerState<AdBannerWidget> createState() => _AdBannerWidgetState();
}

class _AdBannerWidgetState extends ConsumerState<AdBannerWidget> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  void _loadBannerAd() {
    final subscription = ref.read(subscriptionProvider);

    // 프리미엄 사용자는 광고 로드하지 않음
    if (subscription.isPremium) {
      AppLogger.log('프리미엄 사용자: 배너 광고 로드 안 함');
      return;
    }

    _bannerAd = BannerAd(
      adUnitId: AdService.bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          AppLogger.log('배너 광고 로드 성공');
          setState(() {
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          AppLogger.log('배너 광고 로드 실패: $error');
          ad.dispose();
          setState(() {
            _isAdLoaded = false;
          });
        },
        onAdOpened: (ad) {
          AppLogger.log('배너 광고 클릭됨');
        },
        onAdClosed: (ad) {
          AppLogger.log('배너 광고 닫힘');
        },
      ),
    );

    _bannerAd!.load();
  }

  @override
  Widget build(BuildContext context) {
    final subscription = ref.watch(subscriptionProvider);

    // 프리미엄 사용자는 광고 표시 안 함
    if (subscription.isPremium) {
      return const SizedBox.shrink();
    }

    // 광고 로드 전 또는 실패 시 빈 공간
    if (!_isAdLoaded || _bannerAd == null) {
      return Container(
        height: 60,
        color: Colors.grey[200],
        child: const Center(
          child: Text(
            '광고 로드 중...',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ),
      );
    }

    // 광고 표시
    return Container(
      height: 60,
      color: Colors.white,
      child: AdWidget(ad: _bannerAd!),
    );
  }
}
```

### 5.4 main.dart 수정

```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'services/ad_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // .env 파일 로드
  await dotenv.load(fileName: ".env");

  // Firebase 초기화 (기존 코드)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // AdMob 초기화
  await AdService.initialize();

  // 보상형 광고 미리 로드
  AdService().loadRewardedAd();

  // 전면 광고 미리 로드
  AdService().loadInterstitialAd();

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}
```

---

## 6. 사용자 경험 최적화

### 6.1 광고 로딩 중 UI

**문제:**
- 광고 로드에 시간이 걸릴 수 있음 (2-5초)
- 사용자가 기다리는 동안 피드백 필요

**해결책:**

```dart
// 광고 로딩 다이얼로그 표시
showDialog(
  context: context,
  barrierDismissible: false,
  builder: (context) => AlertDialog(
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CircularProgressIndicator(),
        const SizedBox(height: 16),
        const Text('광고 준비 중...'),
        const SizedBox(height: 8),
        Text(
          '잠시만 기다려주세요',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    ),
  ),
);

// 광고 로드 완료 후 다이얼로그 닫기
await AdService.showRewardedAd();
Navigator.of(context).pop(); // 다이얼로그 닫기
```

### 6.2 광고 실패 처리

**시나리오:**
1. 네트워크 오류로 광고 로드 실패
2. 광고 재고 부족 (fill rate 이슈)
3. 사용자가 광고를 중간에 닫음

**대응 전략:**

| 시나리오 | 대응 방법 |
|---------|---------|
| 광고 로드 실패 | 일정 횟수(3회)까지 fallback 허용, 이후 재시도 요청 |
| 사용자 광고 닫음 | 재시도 요청, 3회 실패 시 24시간 후 재시도 |
| 네트워크 오류 | 오프라인 모드 안내 후 광고 없이 진행 |

```dart
Future<bool> _tryShowRewardedAdWithRetry() async {
  int attempts = 0;
  const maxAttempts = 3;

  while (attempts < maxAttempts) {
    final success = await AdService.showRewardedAd();
    if (success) {
      return true;
    }

    attempts++;
    if (attempts < maxAttempts) {
      // 재시도 안내
      final retry = await _showRetryDialog();
      if (!retry) {
        break;
      }
    }
  }

  // 3회 실패 시 fallback
  AppLogger.log('광고 시청 실패 $attempts회, fallback 적용');
  return true;
}

Future<bool> _showRetryDialog() async {
  return await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('광고 로드 실패'),
      content: const Text('광고를 불러오는데 실패했습니다. 다시 시도하시겠습니까?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('나중에'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('재시도'),
        ),
      ],
    ),
  ) ?? false;
}
```

### 6.3 광고 빈도 제한

**목적:**
- 광고 피로도 감소
- 사용자 이탈 방지
- 앱 평점 유지

**전략:**

| 광고 유형 | 최소 간격 | 세션당 최대 횟수 |
|---------|---------|--------------|
| 보상형 광고 | 5분 | 제한 없음 |
| 전면 광고 | 10분 | 3회 |
| 배너 광고 | 항상 표시 | N/A |

**구현:**

```dart
class AdFrequencyManager {
  static final Map<String, DateTime> _lastAdTimes = {};
  static final Map<String, int> _sessionAdCounts = {};

  static bool canShowAd(String adType, {
    required Duration minInterval,
    int? maxSessionCount,
  }) {
    // 시간 간격 체크
    if (_lastAdTimes.containsKey(adType)) {
      final timeSince = DateTime.now().difference(_lastAdTimes[adType]!);
      if (timeSince < minInterval) {
        return false;
      }
    }

    // 세션 횟수 체크
    if (maxSessionCount != null) {
      final count = _sessionAdCounts[adType] ?? 0;
      if (count >= maxSessionCount) {
        return false;
      }
    }

    return true;
  }

  static void recordAdShown(String adType) {
    _lastAdTimes[adType] = DateTime.now();
    _sessionAdCounts[adType] = (_sessionAdCounts[adType] ?? 0) + 1;
  }
}
```

### 6.4 프리미엄 전환 유도

**전략:**
- 광고 시청 후 프리미엄 안내 메시지 (침입적이지 않게)
- 일정 횟수 광고 시청 후 할인 쿠폰 제공
- 무료 체험 기간 제공 (7일)

```dart
// 광고 시청 완료 후
if (_adWatchCount >= 10) {
  _showPremiumPromotionDialog(
    '광고 없이 편하게 일기를 작성하고 싶으신가요?',
    '지금 프리미엄으로 업그레이드하고 첫 달 20% 할인 받으세요!',
  );
}
```

---

## 7. 수익 최적화 전략

### 7.1 광고 중재 (Ad Mediation)

**정의:**
- 여러 광고 네트워크를 연결하여 eCPM 최적화
- 한 네트워크의 재고가 부족할 때 다른 네트워크로 폴백

**추천 플랫폼:**
- Google AdMob Mediation (통합 관리)
- IronSource Mediation
- AppLovin MAX

**장점:**
- Fill Rate 향상 (광고 재고 확보)
- eCPM 상승 (경쟁을 통한 가격 상승)
- 단일 SDK로 다중 네트워크 관리

**구현 우선순위:**
- Phase 1: AdMob 단독 (초기)
- Phase 2: Mediation 도입 (3개월 후)

### 7.2 광고 배치 A/B 테스트

**테스트 항목:**
1. 보상형 광고 타이밍 (이미지 생성 전 vs 후)
2. 배너 광고 위치 (상단 vs 하단)
3. 전면 광고 빈도 (일기 저장마다 vs 10분마다)
4. 광고 크기 (표준 배너 vs 대형 배너)

**분석 지표:**
- eCPM (광고당 수익)
- Fill Rate (광고 재고율)
- CTR (클릭률)
- 사용자 이탈률
- 세션 시간

### 7.3 예상 수익 시뮬레이션

**가정:**
- DAU (일일 활성 사용자): 1,000명
- 무료 사용자 비율: 80% (800명)
- 일기 작성 빈도: 하루 1회
- 광고 단가 (eCPM):
  - 보상형 광고: $15
  - 전면 광고: $8
  - 배너 광고: $2

**월 예상 수익 계산:**

```
보상형 광고 수익:
  800명 × 1회/일 × 30일 × ($15 / 1000) = $360

전면 광고 수익:
  800명 × 0.5회/일 × 30일 × ($8 / 1000) = $96

배너 광고 수익:
  800명 × 5노출/일 × 30일 × ($2 / 1000) = $240

총 월 수익: $696
```

**수익 증가 전략:**
- DAU 증가 (마케팅, ASO 최적화)
- 광고 단가 상승 (Mediation, 광고 최적화)
- 프리미엄 전환율 상승 (광고 불편함 강조)

---

## 8. 테스트 및 검증

### 8.1 개발 단계 테스트

**AdMob 테스트 광고 ID 사용:**

```dart
// 개발 중에는 테스트 광고 ID 사용 (정책 위반 방지)
static String get rewardedAdUnitId {
  if (kDebugMode) {
    // 테스트 광고 ID
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/5224354917';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/1712485313';
    }
  }

  // 프로덕션 광고 ID
  return dotenv.env['ADMOB_REWARDED_AD_UNIT_ID_...'] ?? '';
}
```

### 8.2 테스트 시나리오

**체크리스트:**

- [ ] 보상형 광고 로드 성공
- [ ] 보상형 광고 표시 성공
- [ ] 광고 끝까지 시청 시 이미지 생성 진행
- [ ] 광고 중간에 닫으면 이미지 생성 차단
- [ ] 광고 로드 실패 시 fallback 동작
- [ ] 프리미엄 사용자는 광고 표시 안 됨
- [ ] 배너 광고 로드 및 표시
- [ ] 배너 광고 클릭 시 외부 브라우저 열림
- [ ] 전면 광고 표시 및 닫기
- [ ] 광고 빈도 제한 동작
- [ ] 오프라인 상태에서 광고 처리
- [ ] iOS App Tracking Transparency 동작 (iOS 14+)
- [ ] Android 광고 ID 권한 처리 (Android 13+)

### 8.3 베타 테스트

**참가자:**
- 내부 팀원 (5명)
- 외부 베타 테스터 (20명)

**테스트 기간:**
- 2주

**수집 데이터:**
- 광고 로드 성공률
- 광고 표시 성공률
- 광고 시청 완료율
- 사용자 불편 사항 피드백
- 앱 크래시 로그

### 8.4 정책 준수 확인

**Google AdMob 정책:**
- ✅ 광고가 컨텐츠와 명확히 구분됨
- ✅ 실수로 광고 클릭 유도하지 않음
- ✅ 광고 차단 앱 사용 감지하지 않음
- ✅ 아동 대상 앱 규정 준수 (해당 시)
- ✅ 개인정보 처리방침에 광고 사용 명시

**앱스토어 정책:**
- ✅ 프리미엄 구독으로 광고 제거 제공
- ✅ 광고 시청 강제가 과도하지 않음
- ✅ 사용자 경험 저해하지 않음

---

## 9. 단계별 구현 로드맵

### Phase 1: 기본 광고 통합 (1주차)

**목표:**
- AdMob SDK 설정 완료
- 보상형 광고 통합 (이미지 생성 전)

**작업:**
1. [ ] pubspec.yaml에 google_mobile_ads, flutter_dotenv 추가
2. [ ] .env 파일 생성 및 광고 ID 설정
3. [ ] Android/iOS 네이티브 설정 (AndroidManifest.xml, Info.plist)
4. [ ] AdService 구현 (services/ad_service.dart)
5. [ ] main.dart에서 AdMob 초기화
6. [ ] diary_create_screen.dart에 보상형 광고 통합
7. [ ] 테스트 광고로 동작 확인

**검증:**
- 테스트 광고가 정상적으로 표시되는가?
- 광고 시청 완료 시 이미지 생성이 진행되는가?
- 광고 로드 실패 시 fallback이 동작하는가?

### Phase 2: 배너 및 전면 광고 추가 (2주차)

**목표:**
- 일기 목록 화면에 배너 광고 추가
- 일기 저장 후 전면 광고 추가

**작업:**
1. [ ] AdBannerWidget 구현 (widgets/ad_banner_widget.dart)
2. [ ] diary_list_screen.dart에 배너 광고 통합
3. [ ] emotion_stats_screen.dart에 배너 광고 통합 (선택)
4. [ ] diary_create_screen.dart에 전면 광고 통합 (저장 후)
5. [ ] 광고 빈도 제한 로직 구현
6. [ ] 테스트 및 UI 조정

**검증:**
- 배너 광고가 화면 하단에 고정 표시되는가?
- 배너 광고가 컨텐츠를 가리지 않는가?
- 전면 광고가 적절한 타이밍에 표시되는가?
- 광고 빈도 제한이 동작하는가?

### Phase 3: 프리미엄 연동 및 최적화 (3주차)

**목표:**
- 프리미엄 사용자 광고 제거
- 광고 로딩 UX 개선
- 광고 실패 처리 강화

**작업:**
1. [ ] 모든 광고 코드에 subscription.isPremium 체크 추가
2. [ ] 광고 로딩 다이얼로그 구현 (widgets/ad_loading_dialog.dart)
3. [ ] 광고 실패 재시도 로직 구현
4. [ ] AdFrequencyManager 구현
5. [ ] 프리미엄 안내 다이얼로그에 광고 제거 혜택 추가
6. [ ] 광고 시청 횟수 기반 프리미엄 유도 로직

**검증:**
- 프리미엄 사용자는 광고가 표시되지 않는가?
- 광고 로드 중 사용자 피드백이 있는가?
- 광고 실패 시 사용자가 혼란스럽지 않은가?

### Phase 4: 실제 광고 ID 적용 및 출시 준비 (4주차)

**목표:**
- 테스트 광고 → 실제 광고 전환
- 정책 준수 확인
- 성능 모니터링 설정

**작업:**
1. [ ] AdMob에서 실제 광고 단위 생성
2. [ ] .env에 실제 광고 ID 설정
3. [ ] 개인정보 처리방침에 광고 사용 명시
4. [ ] iOS App Tracking Transparency 프롬프트 추가
5. [ ] Android 광고 ID 권한 처리
6. [ ] Firebase Analytics에 광고 이벤트 로깅
7. [ ] 내부 테스트 (실제 광고로)
8. [ ] 베타 테스트 배포

**검증:**
- 실제 광고가 정상적으로 표시되는가?
- 광고 수익이 AdMob 대시보드에 집계되는가?
- 정책 위반 없이 승인되는가?
- 사용자 피드백이 긍정적인가?

### Phase 5: 모니터링 및 개선 (출시 후 1개월)

**목표:**
- 광고 성과 분석
- 사용자 피드백 수집
- 수익 최적화

**작업:**
1. [ ] AdMob 대시보드 모니터링 (eCPM, Fill Rate, CTR)
2. [ ] Firebase Analytics에서 광고 관련 이벤트 분석
3. [ ] 사용자 리뷰에서 광고 관련 피드백 확인
4. [ ] 광고 배치 A/B 테스트 (Firebase Remote Config)
5. [ ] 광고 빈도 조정
6. [ ] Mediation 도입 검토

**개선 지표:**
- 광고 수익 증가율
- 무료 사용자 이탈률 감소
- 프리미엄 전환율 증가
- 앱 평점 유지 (4.0 이상)

---

## 10. 리스크 및 대응 방안

### 10.1 사용자 이탈 리스크

**리스크:**
- 광고가 너무 많아 사용자가 앱을 삭제함

**대응:**
- 광고 빈도를 보수적으로 설정 (처음에는 적게)
- 사용자 피드백 모니터링
- 프리미엄 전환 유도 강화

### 10.2 광고 정책 위반 리스크

**리스크:**
- AdMob 정책 위반으로 계정 정지

**대응:**
- 정책 문서 철저히 숙지
- 실수로 광고 클릭 유도하지 않음
- 아동 대상 콘텐츠 규정 준수
- 정기적인 정책 업데이트 확인

### 10.3 광고 수익 저조 리스크

**리스크:**
- 예상보다 낮은 eCPM 또는 Fill Rate

**대응:**
- Mediation 도입으로 Fill Rate 향상
- 광고 배치 최적화 (A/B 테스트)
- DAU 증가 노력 (마케팅)

### 10.4 기술적 문제 리스크

**리스크:**
- 광고 SDK 버그로 앱 크래시
- 특정 기기에서 광고 미표시

**대응:**
- 광고 로드/표시를 try-catch로 감싸기
- 크래시 로그 모니터링 (Firebase Crashlytics)
- 베타 테스트에서 다양한 기기 테스트

---

## 11. 참고 자료

### 11.1 공식 문서
- [Google AdMob 공식 문서](https://developers.google.com/admob)
- [google_mobile_ads Flutter 플러그인](https://pub.dev/packages/google_mobile_ads)
- [AdMob 정책 센터](https://support.google.com/admob/answer/6128543)
- [iOS App Tracking Transparency 가이드](https://developer.apple.com/app-store/user-privacy-and-data-use/)

### 11.2 커뮤니티 리소스
- [Flutter 광고 통합 튜토리얼](https://www.youtube.com/results?search_query=flutter+admob+tutorial)
- [AdMob 최적화 팁](https://medium.com/tag/admob)

### 11.3 모범 사례
- 보상형 광고는 사용자에게 가치 제공 (이미지 생성)
- 배너 광고는 컨텐츠를 가리지 않도록 배치
- 전면 광고는 자연스러운 전환 시점에 표시 (화면 전환)
- 광고 빈도는 사용자 경험 최우선

---

## 12. 결론

이 계획서는 AI 그림일기 앱에 광고 기능을 통합하기 위한 세부적인 로드맵을 제공합니다.

**핵심 요점:**
1. **보상형 광고가 핵심**: 이미지 생성 전 필수 시청으로 수익 극대화
2. **프리미엄 혜택 강조**: 광고 제거를 핵심 가치로 제공
3. **사용자 경험 최우선**: 광고가 앱 사용을 방해하지 않도록 설계
4. **단계적 구현**: 4주에 걸쳐 안정적으로 배포

**예상 효과:**
- 월 $600-1,000 광고 수익 (DAU 1,000명 기준)
- 프리미엄 전환율 증가 (광고 불편함을 해소하려는 동기)
- 무료 사용자 유지 (과도하지 않은 광고)

**다음 단계:**
1. 이 계획서를 팀과 검토
2. Phase 1 작업 시작 (AdMob SDK 설정)
3. 주간 진행 상황 점검
4. 4주 후 베타 출시

광고 통합을 성공적으로 완료하면 지속 가능한 수익 모델을 구축할 수 있습니다.
