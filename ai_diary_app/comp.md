# AI 그림일기 앱 - 하이브리드 수익화 모델 완전 구현 가이드

**작성일**: 2025-10-18
**버전**: v1.3 하이브리드 모델
**목적**: 5개 Hard Limit → 보상형 광고 하이브리드 모델로 전환

---

## 📋 목차

1. [전략 개요](#1-전략-개요)
2. [UX 전문가 관점: 보상형 광고 최적화](#2-ux-전문가-관점-보상형-광고-최적화)
3. [기술 구현 상세](#3-기술-구현-상세)
4. [사용자 시나리오별 플로우](#4-사용자-시나리오별-플로우)
5. [UI/UX 디자인 상세](#5-uiux-디자인-상세)
6. [구현 단계별 가이드](#6-구현-단계별-가이드)
7. [테스트 시나리오](#7-테스트-시나리오)
8. [성과 측정 지표](#8-성과-측정-지표)

---

## 1. 전략 개요

### 1.1 현재 문제점

**Hard Paywall (5개 제한) 문제:**
- ❌ 사용자 이탈률 극대화
- ❌ 습관 형성 전 차단 (5일 이내)
- ❌ 무료→유료 전환 기회 상실
- ❌ 부정적 입소문 ("5개만 쓸 수 있대")
- ❌ 광고 수익 기회 완전 차단

### 1.2 하이브리드 모델 목표

**3 Tier 구조:**

```
┌─────────────────────────────────────────────────────────┐
│ Tier 1: 무료 사용자 (Free with Ads)                     │
├─────────────────────────────────────────────────────────┤
│ • 최초 5개: 완전 무료 (진입장벽 제거)                   │
│ • 6개부터: 보상형 광고 시청으로 1개씩 생성              │
│ • 하루 최대 3개까지 광고로 생성 가능                    │
│ • 자정(00:00)에 일일 카운터 자동 리셋                   │
│ • 기본 스타일만 사용 가능 (6개)                         │
│ • 고급 옵션 잠금                                        │
│ • 재생성 불가 (프리미엄 전용)                           │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│ Tier 2: 프리미엄 월정액 ($4.99/월)                      │
├─────────────────────────────────────────────────────────┤
│ • 무제한 이미지 생성                                    │
│ • 광고 완전 제거                                        │
│ • 프리미엄 스타일 12개 전체 사용                        │
│ • 고급 옵션 전체 활성화                                 │
│ • 무제한 재생성 기능                                    │
│ • 클라우드 자동 백업                                    │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│ Tier 3: 프리미엄 연간 ($49.99/년)                       │
├─────────────────────────────────────────────────────────┤
│ • Tier 2의 모든 기능                                    │
│ • 17% 할인 혜택 (연간 $10 절약)                         │
│ • 최고 가치 옵션                                        │
└─────────────────────────────────────────────────────────┘
```

### 1.3 수익 예측

**DAU 1,000명 기준:**

| 구분 | 무료 980명 | 프리미엄 20명 (2%) | 총계 |
|------|-----------|-------------------|------|
| 광고 수익 | $1,764/월 | - | $1,764 |
| 구독 수익 | - | $350/월 | $350 |
| **총 수익** | - | - | **$2,114/월** |
| API 비용 | $180/월 | - | $180 |
| 서버 비용 | $150/월 | - | $150 |
| **순이익** | - | - | **$1,784/월** |

---

## 2. UX 전문가 관점: 보상형 광고 최적화

### 2.1 광고 UX 핵심 원칙

**원칙 1: 가치 교환의 명확성 (Value Exchange)**
```
사용자에게 명확히 보여줘야 할 것:
1. 무엇을 얻는가? → "일기 1개 생성"
2. 무엇을 해야 하는가? → "30초 광고 시청"
3. 선택권이 있는가? → "지금 볼까요? / 나중에"
```

**원칙 2: 비강제성 (Non-Intrusive)**
```
❌ 나쁜 예: 갑자기 광고 팝업
✅ 좋은 예: 사용자가 일기 생성 버튼을 누른 후 → 안내 다이얼로그
```

**원칙 3: 진행 상황 가시성 (Progress Visibility)**
```
사용자가 항상 알아야 할 것:
- 오늘 몇 개 생성했나? (예: "오늘 2/3개 생성")
- 언제 리셋되나? (예: "내일 00:00에 초기화")
```

**원칙 4: 긍정적 프레이밍 (Positive Framing)**
```
❌ 부정적: "광고를 봐야 합니다"
✅ 긍정적: "광고를 보고 무료로 계속 사용하세요"

❌ 제한 강조: "하루 3개만 가능합니다"
✅ 혜택 강조: "매일 3개 무료 생성!"
```

### 2.2 광고 노출 시점 최적화

#### 시나리오 1: 6번째 일기 생성 시 (첫 광고)

**타이밍**: 사용자가 "일기 생성" 버튼 클릭 직후

**다이얼로그 구조:**
```
┌─────────────────────────────────────────┐
│  🎉 축하합니다!                         │
│                                         │
│  5개의 일기를 작성하셨네요!             │
│  이제 광고를 보고 무료로 계속 사용하세요│
│                                         │
│  ✨ 광고 시청 → 일기 1개 생성           │
│  📅 매일 3개까지 무료 생성              │
│                                         │
│  [💎 프리미엄 알아보기]  [📺 광고 보기]│
└─────────────────────────────────────────┘
```

**UX 포인트:**
1. **축하 메시지**: 5개 달성을 긍정적으로 프레이밍
2. **명확한 가치 교환**: "광고 시청 → 일기 1개"
3. **일일 할당량 강조**: "매일 3개까지"로 희소성 부여
4. **양쪽 CTA**: 프리미엄과 광고 모두 제공 (선택권)

#### 시나리오 2: 일일 광고 3회 달성 후

**타이밍**: 사용자가 "일기 생성" 버튼 클릭 직후

**다이얼로그 구조:**
```
┌─────────────────────────────────────────┐
│  ⏰ 오늘의 무료 생성 완료!               │
│                                         │
│  오늘은 이미 3개를 생성하셨습니다.      │
│                                         │
│  ⏳ 내일 00:00에 다시 3개 생성 가능     │
│                                         │
│  또는 지금 바로 무제한 사용하려면?      │
│                                         │
│  💎 프리미엄 혜택:                      │
│  • 무제한 이미지 생성                   │
│  • 광고 완전 제거                       │
│  • 프리미엄 스타일 12개                 │
│  • 무제한 재생성                        │
│                                         │
│  [나중에]          [프리미엄 알아보기]  │
└─────────────────────────────────────────┘
```

**UX 포인트:**
1. **긍정적 완료 메시지**: "완료"로 성취감 부여
2. **타이머 표시**: 리셋 시간 명시로 기대감 조성
3. **프리미엄 가치 강조**: 제한 없음을 부각
4. **Soft Sell**: 강요하지 않고 제안

#### 시나리오 3: 일기 목록 화면 - 진행 상황 표시

**위치**: 일기 목록 화면 상단 (배너 광고 위)

**디자인:**
```
┌───────────────────────────────────────────────┐
│  무료 사용자                                  │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━│
│  오늘 생성: 2/3개 📊  |  내일 초기화 ⏰      │
│                                               │
│  [💎 무제한 사용하기 - 광고 제거]            │
└───────────────────────────────────────────────┘
```

**UX 포인트:**
1. **상시 가시성**: 언제나 진행 상황 확인 가능
2. **게이미피케이션**: 진행 바로 동기 부여
3. **업그레이드 CTA**: 항상 프리미엄 옵션 제공
4. **비침습적**: 방해하지 않으면서도 정보 전달

### 2.3 광고 로딩 UX

**광고 준비 중 화면:**
```
┌─────────────────────────────────────────┐
│                                         │
│         🎬 광고 준비 중...              │
│                                         │
│         ⏳ 잠시만 기다려주세요           │
│                                         │
│    (스피너 애니메이션)                  │
│                                         │
│  💡 TIP: 광고 시청 완료 시              │
│     자동으로 일기가 생성됩니다           │
│                                         │
└─────────────────────────────────────────┘
```

**광고 시청 중 - 기대감 조성:**
```
화면 상단 또는 오버레이:
┌─────────────────────────────────────────┐
│  📺 광고 시청 중... (23초 남음)          │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━│
│  완료 후 자동으로 일기 생성이 시작됩니다 │
└─────────────────────────────────────────┘
```

**광고 시청 완료:**
```
┌─────────────────────────────────────────┐
│                                         │
│         ✅ 광고 시청 완료!              │
│                                         │
│      일기 생성을 시작합니다...          │
│                                         │
│    (체크마크 애니메이션 → 페이드아웃)   │
│                                         │
└─────────────────────────────────────────┘
```

### 2.4 광고 실패 시 UX

**광고 로드 실패:**
```
┌─────────────────────────────────────────┐
│  ⚠️ 광고를 불러올 수 없습니다           │
│                                         │
│  네트워크 연결을 확인하고                │
│  다시 시도해주세요.                     │
│                                         │
│  [다시 시도]         [나중에]           │
└─────────────────────────────────────────┘
```

**광고 시청 중단:**
```
┌─────────────────────────────────────────┐
│  😢 광고 시청이 완료되지 않았습니다     │
│                                         │
│  광고를 끝까지 시청해야                 │
│  일기를 생성할 수 있습니다.             │
│                                         │
│  [다시 보기]         [취소]             │
└─────────────────────────────────────────┘
```

### 2.5 심리학적 최적화

#### A. 손실 회피 심리 (Loss Aversion)

**적용:**
```
❌ "3개만 남았습니다"
✅ "오늘 1개 더 생성 가능합니다!"
```

**이유**: 남은 기회를 긍정적으로 표현하여 동기 부여

#### B. 즉시성 편향 (Present Bias)

**적용:**
```
일기 생성 버튼 클릭 → 즉시 광고 다이얼로그
(지연 없이 바로 가치 교환 제시)
```

**이유**: 사용자의 의도가 명확할 때 바로 제안

#### C. 사회적 증거 (Social Proof)

**적용:**
```
다이얼로그에 추가:
"✨ 오늘 1,234명이 광고를 보고 일기를 작성했습니다"
```

**이유**: 다른 사용자도 하고 있다는 안정감

#### D. 진행 효과 (Progress Effect)

**적용:**
```
5개 무료 완료 시:
"🎉 5개 달성! 이제 광고로 계속 무료 사용하세요"
```

**이유**: 이미 투자한 시간/노력을 강조 (Sunk Cost)

---

## 3. 기술 구현 상세

### 3.1 데이터 모델

#### SharedPreferences 키 설계

```dart
// 일일 광고 카운터 관련
static const String KEY_DAILY_AD_COUNT = 'daily_ad_count';
static const String KEY_LAST_AD_DATE = 'last_ad_date';

// 총 일기 개수 (5개 무료 체크용)
// DatabaseService.getAllDiaries().length 사용

// 광고 시청 완료 플래그 (임시)
static const String KEY_AD_REWARD_PENDING = 'ad_reward_pending';
```

#### 일일 카운터 리셋 로직

```dart
Future<void> _checkAndResetDailyCounter() async {
  final prefs = await SharedPreferences.getInstance();

  final lastDate = prefs.getString(KEY_LAST_AD_DATE);
  final today = DateTime.now().toIso8601String().split('T')[0]; // "2025-10-18"

  if (lastDate != today) {
    // 날짜가 바뀌었으면 카운터 리셋
    await prefs.setInt(KEY_DAILY_AD_COUNT, 0);
    await prefs.setString(KEY_LAST_AD_DATE, today);
    print('[무료 제한] 일일 카운터 리셋: $today');
  }
}
```

### 3.2 무료 사용자 일기 생성 플로우

```dart
Future<void> _generateDiary() async {
  if (!_formKey.currentState!.validate()) return;

  final subscription = ref.read(subscriptionProvider);

  // 1단계: 일일 카운터 리셋 체크
  await _checkAndResetDailyCounter();

  // 2단계: 프리미엄 사용자는 바로 생성
  if (subscription.isPremium) {
    await _createDiary();
    return;
  }

  // 3단계: 무료 사용자 - 총 일기 개수 체크
  final allDiaries = await DatabaseService.getAllDiaries();
  final totalCount = allDiaries.length;

  if (totalCount < 5) {
    // 3-1. 최초 5개: 광고 없이 무료 생성
    print('[무료 제한] 최초 5개 무료 생성: ${totalCount + 1}/5');
    await _createDiary();
    return;
  }

  // 4단계: 6개부터 - 일일 광고 카운터 체크
  final prefs = await SharedPreferences.getInstance();
  final dailyAdCount = prefs.getInt(KEY_DAILY_AD_COUNT) ?? 0;

  if (dailyAdCount >= 3) {
    // 4-1. 오늘 이미 3개 생성함 → 프리미엄 안내
    _showDailyLimitDialog();
    return;
  }

  // 5단계: 광고 시청 안내 다이얼로그 표시
  final shouldShowAd = await _showAdExplanationDialog(
    isFirstTime: totalCount == 5, // 6번째 일기인지 체크
    dailyCount: dailyAdCount,
  );

  if (!shouldShowAd) {
    return; // 사용자가 취소
  }

  // 6단계: 보상형 광고 표시
  final adWatched = await AdService().showRewardedAd(
    onRewarded: () {
      print('[무료 제한] 광고 시청 완료 - 일기 생성 허용');
    },
  );

  if (!adWatched) {
    // 광고 로드 실패 또는 시청 중단
    _showAdFailedDialog();
    return;
  }

  // 7단계: 일일 카운터 증가 후 일기 생성
  await prefs.setInt(KEY_DAILY_AD_COUNT, dailyAdCount + 1);
  await prefs.setString(KEY_LAST_AD_DATE,
    DateTime.now().toIso8601String().split('T')[0]);

  print('[무료 제한] 광고 시청 후 생성: ${dailyAdCount + 1}/3');

  await _createDiary();
}

// 실제 일기 생성 로직 (기존 코드)
Future<void> _createDiary() async {
  setState(() {
    _isLoading = true;
    _isGeneratingImage = true;
    _progressMessage = _selectedPhotos.isNotEmpty ? '사진 분석 중...' : '감정 분석 중...';
  });

  // ... 기존 일기 생성 로직
}
```

### 3.3 다이얼로그 구현

#### 3.3.1 광고 안내 다이얼로그 (첫 번째)

```dart
Future<bool> _showAdExplanationDialog({
  required bool isFirstTime,
  required int dailyCount,
}) async {
  return await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      contentPadding: const EdgeInsets.all(24),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 아이콘
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple.shade400, Colors.blue.shade500],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.stars,
              size: 48,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 24),

          // 제목
          Text(
            isFirstTime ? '축하합니다!' : '광고를 보고 계속 사용하세요',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 12),

          // 설명
          if (isFirstTime) ...[
            const Text(
              '5개의 일기를 작성하셨네요!\n이제 광고를 보고 무료로 계속 사용하세요',
              style: TextStyle(
                fontSize: 15,
                color: Color(0xFF718096),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ] else ...[
            Text(
              '오늘 ${dailyCount}/3개 생성했습니다',
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF718096),
              ),
              textAlign: TextAlign.center,
            ),
          ],

          const SizedBox(height: 24),

          // 혜택 카드
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                _buildBenefitRow(
                  icon: Icons.play_circle_outline,
                  text: '30초 광고 시청',
                  color: Colors.blue,
                ),
                const SizedBox(height: 8),
                const Icon(Icons.arrow_downward, color: Colors.grey, size: 20),
                const SizedBox(height: 8),
                _buildBenefitRow(
                  icon: Icons.auto_stories,
                  text: '일기 1개 생성',
                  color: Colors.green,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 일일 할당량
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.orange.shade700),
                const SizedBox(width: 8),
                Text(
                  '매일 3개까지 무료 생성',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.orange.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text(
            '나중에',
            style: TextStyle(color: Colors.grey),
          ),
        ),
        FilledButton.icon(
          onPressed: () => Navigator.pop(context, true),
          icon: const Icon(Icons.play_arrow, size: 20),
          label: const Text('광고 보기'),
          style: FilledButton.styleFrom(
            backgroundColor: Colors.blue,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
      ],
      actionsAlignment: MainAxisAlignment.spaceBetween,
    ),
  ) ?? false;
}

Widget _buildBenefitRow({
  required IconData icon,
  required String text,
  required Color color,
}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(icon, color: color, size: 20),
      const SizedBox(width: 8),
      Text(
        text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    ],
  );
}
```

#### 3.3.2 일일 제한 다이얼로그

```dart
void _showDailyLimitDialog() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      contentPadding: const EdgeInsets.all(24),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 아이콘
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange.shade400, Colors.orange.shade600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.schedule,
              size: 48,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 24),

          const Text(
            '오늘의 무료 생성 완료!',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 12),

          const Text(
            '오늘은 이미 3개를 생성하셨습니다.',
            style: TextStyle(
              fontSize: 15,
              color: Color(0xFF718096),
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 20),

          // 리셋 시간 표시
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.access_time, color: Colors.blue.shade700, size: 24),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '내일 00:00에',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF718096),
                      ),
                    ),
                    Text(
                      '다시 3개 생성 가능',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          const Text(
            '또는 지금 바로 무제한 사용하려면?',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF718096),
            ),
          ),

          const SizedBox(height: 16),

          // 프리미엄 혜택
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.amber.shade50, Colors.orange.shade50],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.diamond, color: Colors.amber.shade700, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      '프리미엄 혜택',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber.shade900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildPremiumFeature(Icons.all_inclusive, '무제한 이미지 생성'),
                _buildPremiumFeature(Icons.block, '광고 완전 제거'),
                _buildPremiumFeature(Icons.palette, '프리미엄 스타일 12개'),
                _buildPremiumFeature(Icons.refresh, '무제한 재생성'),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            '나중에',
            style: TextStyle(color: Colors.grey),
          ),
        ),
        FilledButton.icon(
          onPressed: () {
            Navigator.pop(context);
            context.go('/settings'); // 프리미엄 구독 화면으로
          },
          icon: const Icon(Icons.diamond, size: 18),
          label: const Text('프리미엄 알아보기'),
          style: FilledButton.styleFrom(
            backgroundColor: Colors.amber,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
      actionsAlignment: MainAxisAlignment.spaceBetween,
    ),
  );
}

Widget _buildPremiumFeature(IconData icon, String text) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      children: [
        Icon(icon, size: 18, color: Colors.amber.shade700),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF2D3748),
          ),
        ),
      ],
    ),
  );
}
```

#### 3.3.3 광고 실패 다이얼로그

```dart
void _showAdFailedDialog() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: const Row(
        children: [
          Icon(Icons.error_outline, color: Colors.orange, size: 28),
          SizedBox(width: 12),
          Text(
            '광고 시청 실패',
            style: TextStyle(fontSize: 18),
          ),
        ],
      ),
      content: const Text(
        '광고를 불러올 수 없거나 시청이 중단되었습니다.\n\n'
        '네트워크 연결을 확인하고 다시 시도해주세요.',
        style: TextStyle(fontSize: 15, height: 1.5),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('확인'),
        ),
      ],
    ),
  );
}
```

### 3.4 일기 목록 화면 - 진행 상황 표시

**diary_list_screen.dart 상단에 추가:**

```dart
class DiaryListScreen extends ConsumerStatefulWidget {
  // ... 기존 코드
}

class _DiaryListScreenState extends ConsumerState<DiaryListScreen> {
  int _dailyAdCount = 0;
  String _nextResetTime = '';

  @override
  void initState() {
    super.initState();
    _loadDailyProgress();
  }

  Future<void> _loadDailyProgress() async {
    final prefs = await SharedPreferences.getInstance();

    // 카운터 리셋 체크
    final lastDate = prefs.getString('last_ad_date');
    final today = DateTime.now().toIso8601String().split('T')[0];

    if (lastDate != today) {
      await prefs.setInt('daily_ad_count', 0);
      await prefs.setString('last_ad_date', today);
    }

    // 다음 리셋 시간 계산
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final midnight = DateTime(tomorrow.year, tomorrow.month, tomorrow.day);
    final duration = midnight.difference(DateTime.now());

    setState(() {
      _dailyAdCount = prefs.getInt('daily_ad_count') ?? 0;
      _nextResetTime = '${duration.inHours}시간 ${duration.inMinutes % 60}분 후';
    });
  }

  @override
  Widget build(BuildContext context) {
    final subscription = ref.watch(subscriptionProvider);

    return Scaffold(
      body: Column(
        children: [
          // 무료 사용자만 진행 상황 표시
          if (!subscription.isPremium)
            _buildDailyProgressBanner(),

          // 기존 일기 목록
          Expanded(
            child: _buildDiaryList(),
          ),

          // 배너 광고 (무료 사용자만)
          if (!subscription.isPremium)
            const AdBannerWidget(),
        ],
      ),
    );
  }

  Widget _buildDailyProgressBanner() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade50, Colors.purple.shade50],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.auto_stories, color: Colors.blue.shade700, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    '무료 사용자',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => context.go('/settings'),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.amber.shade400, Colors.orange.shade500],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.diamond, size: 14, color: Colors.white),
                      SizedBox(width: 4),
                      Text(
                        '무제한 사용',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // 진행 바
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '오늘 생성: $_dailyAdCount/3개',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.blue.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '리셋: $_nextResetTime',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF718096),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: _dailyAdCount / 3,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _dailyAdCount >= 3 ? Colors.orange : Colors.blue,
                      ),
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
```

---

## 4. 사용자 시나리오별 플로우

### 시나리오 A: 신규 사용자 (1~5번째 일기)

```
[사용자 행동]
일기 작성 화면 진입
 ↓
일기 내용 입력
 ↓
"일기 생성" 버튼 클릭
 ↓
[시스템 처리]
총 일기 개수 체크 (< 5개)
 ↓
광고 없이 바로 이미지 생성 시작
 ↓
[사용자 경험]
"감정 분석 중..." → "이미지 생성 중..."
 ↓
일기 생성 완료 ✅
```

**UX 포인트:**
- 완전 무료로 빠른 성공 경험
- 습관 형성 기간 (5일 권장)
- 광고 없는 쾌적한 첫 경험

### 시나리오 B: 6번째 일기 (첫 광고)

```
[사용자 행동]
일기 작성 화면 진입
 ↓
일기 내용 입력
 ↓
"일기 생성" 버튼 클릭
 ↓
[시스템 처리]
총 일기 개수 체크 (= 5개)
 ↓
일일 광고 카운터 체크 (0/3)
 ↓
[다이얼로그 표시]
"🎉 축하합니다! 5개의 일기를 작성하셨네요!"
"이제 광고를 보고 무료로 계속 사용하세요"
 ↓
[사용자 선택]
Option 1: "광고 보기" 클릭
  ↓
  보상형 광고 전체 화면 표시
  ↓
  30초 광고 시청 (완료 시 자동 진행)
  ↓
  "✅ 광고 시청 완료!" 메시지
  ↓
  일기 생성 시작
  ↓
  일일 카운터 1/3 증가

Option 2: "프리미엄 알아보기" 클릭
  ↓
  프리미엄 구독 화면 이동

Option 3: "나중에" 클릭
  ↓
  일기 목록 화면으로 돌아감
```

**UX 포인트:**
- 축하 메시지로 긍정적 프레이밍
- 명확한 가치 교환 안내
- 3가지 선택지 제공 (자율성)

### 시나리오 C: 7~8번째 일기 (일일 제한 내)

```
[사용자 행동]
일기 작성 화면 진입
 ↓
일기 내용 입력
 ↓
"일기 생성" 버튼 클릭
 ↓
[시스템 처리]
총 일기 개수 체크 (> 5개)
 ↓
일일 광고 카운터 체크 (1/3 또는 2/3)
 ↓
[다이얼로그 표시]
"광고를 보고 계속 사용하세요"
"오늘 1/3개 생성했습니다" (또는 2/3)
 ↓
[사용자 선택]
"광고 보기" 클릭
 ↓
보상형 광고 표시 → 시청 → 생성
```

**UX 포인트:**
- 진행 상황 명시 (게이미피케이션)
- 반복 학습 효과 (광고 = 무료 사용)

### 시나리오 D: 일일 제한 도달 (4번째 시도)

```
[사용자 행동]
일기 작성 화면 진입
 ↓
일기 내용 입력
 ↓
"일기 생성" 버튼 클릭
 ↓
[시스템 처리]
일일 광고 카운터 체크 (3/3) ❌
 ↓
[다이얼로그 표시]
"⏰ 오늘의 무료 생성 완료!"
"오늘은 이미 3개를 생성하셨습니다"
"⏳ 내일 00:00에 다시 3개 생성 가능"
 ↓
프리미엄 혜택 목록 표시
 ↓
[사용자 선택]
Option 1: "프리미엄 알아보기"
  ↓
  프리미엄 구독 화면 이동

Option 2: "나중에"
  ↓
  일기 목록으로 돌아감
  ↓
  내일 자정에 카운터 자동 리셋
```

**UX 포인트:**
- 완료 메시지로 성취감 부여
- 명확한 리셋 시간 안내
- Soft Sell (부드러운 프리미엄 제안)

### 시나리오 E: 프리미엄 사용자

```
[사용자 행동]
일기 작성 화면 진입
 ↓
일기 내용 입력
 ↓
"일기 생성" 버튼 클릭
 ↓
[시스템 처리]
프리미엄 상태 확인 ✅
 ↓
광고 없이 바로 이미지 생성
 ↓
일기 생성 완료
```

**UX 포인트:**
- 광고 전혀 없음 (프리미엄 가치 명확)
- 빠른 생성 경험
- 무제한 사용 만족도

---

## 5. UI/UX 디자인 상세

### 5.1 컬러 팔레트

```dart
// 무료 사용자 관련 색상
static const Color freeUserPrimary = Color(0xFF667EEA);     // 파란색
static const Color freeUserSecondary = Color(0xFF764BA2);   // 보라색
static const Color freeUserAccent = Color(0xFF4299E1);      // 밝은 파란색

// 광고 관련 색상
static const Color adIndicator = Color(0xFFED8936);         // 오렌지
static const Color adSuccess = Color(0xFF48BB78);           // 녹색
static const Color adWarning = Color(0xFFF6AD55);           // 연한 오렌지

// 프리미엄 관련 색상
static const Color premiumGold = Color(0xFFF59E0B);         // 금색
static const Color premiumAmber = Color(0xFFD97706);        // 앰버
```

### 5.2 애니메이션 상세

#### 광고 시청 완료 애니메이션

```dart
void _showAdCompletionAnimation() {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => WillPopScope(
      onWillPop: () async => false,
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 800),
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: Opacity(
                opacity: value,
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 80,
                        color: Colors.green.shade400,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        '광고 시청 완료!',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '일기 생성을 시작합니다...',
                        style: TextStyle(
                          fontSize: 15,
                          color: Color(0xFF718096),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
          onEnd: () {
            Navigator.pop(context);
            // 일기 생성 시작
          },
        ),
      ),
    ),
  );
}
```

#### 진행 바 애니메이션

```dart
AnimatedContainer(
  duration: const Duration(milliseconds: 300),
  height: 8,
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(4),
    gradient: LinearGradient(
      colors: _dailyAdCount >= 3
          ? [Colors.orange.shade300, Colors.red.shade400]
          : [Colors.blue.shade300, Colors.purple.shade400],
    ),
  ),
  width: MediaQuery.of(context).size.width * (_dailyAdCount / 3),
)
```

---

## 6. 구현 단계별 가이드

### Phase 1: 기초 인프라 구축

**작업 목록:**

1. ✅ SharedPreferences 키 상수 정의
2. ✅ 일일 카운터 리셋 로직 구현
3. ✅ DatabaseService에 getAllDiaries() 메서드 확인

**코드 위치:**
- `lib/constants/storage_keys.dart` (신규 생성)
- `lib/services/free_user_service.dart` (신규 생성)

**예상 소요 시간**: 30분

### Phase 2: 다이얼로그 UI 구현

**작업 목록:**

1. ✅ `_showAdExplanationDialog()` 구현
2. ✅ `_showDailyLimitDialog()` 구현
3. ✅ `_showAdFailedDialog()` 구현
4. ✅ `_showAdCompletionAnimation()` 구현

**코드 위치:**
- `lib/screens/diary_create_screen.dart` (수정)

**예상 소요 시간**: 1시간

### Phase 3: 일기 생성 플로우 수정

**작업 목록:**

1. ✅ `_generateDiary()` 메서드 전면 수정
2. ✅ 프리미엄 체크 우선 처리
3. ✅ 5개 무료 체크 로직
4. ✅ 일일 광고 카운터 체크 및 증가
5. ✅ AdService 연동

**코드 위치:**
- `lib/screens/diary_create_screen.dart:_generateDiary()` (수정)

**예상 소요 시간**: 1시간

### Phase 4: 일기 목록 화면 진행 상황 표시

**작업 목록:**

1. ✅ `_buildDailyProgressBanner()` 위젯 구현
2. ✅ 일일 카운터 로드 로직
3. ✅ 다음 리셋 시간 계산
4. ✅ 프리미엄 CTA 버튼

**코드 위치:**
- `lib/screens/diary_list_screen.dart` (수정)

**예상 소요 시간**: 1시간

### Phase 5: 프리미엄 구독 화면 업데이트

**작업 목록:**

1. ✅ 프리미엄 혜택 목록 최신화
2. ✅ "광고 제거" 항목 추가 (최상단)
3. ✅ 무제한 생성 강조

**코드 위치:**
- `lib/screens/premium_subscription_screen.dart` (수정)

**예상 소요 시간**: 30분

### Phase 6: 테스트 및 디버깅

**작업 목록:**

1. ✅ 무료 사용자 플로우 전체 테스트
2. ✅ 일일 카운터 리셋 테스트 (날짜 변경)
3. ✅ 광고 시청 완료/실패 시나리오
4. ✅ 프리미엄 전환 테스트
5. ✅ 로그 메시지 확인

**예상 소요 시간**: 1.5시간

**총 예상 소요 시간**: 5.5시간

---

## 7. 테스트 시나리오

### 7.1 무료 사용자 테스트

#### 테스트 1: 최초 5개 무료 생성

**절차:**
1. 앱 설치 또는 데이터 초기화
2. 로그인 (무료 사용자)
3. 일기 5개 작성

**기대 결과:**
- ✅ 광고 없이 5개 모두 생성
- ✅ 로그: "[무료 제한] 최초 5개 무료 생성: X/5"

#### 테스트 2: 6번째 일기 - 첫 광고

**절차:**
1. 5개 일기가 있는 상태
2. 6번째 일기 작성 시도
3. "일기 생성" 버튼 클릭

**기대 결과:**
- ✅ "축하합니다!" 다이얼로그 표시
- ✅ "광고 보기" 버튼 클릭 시 보상형 광고 표시
- ✅ 광고 시청 완료 후 일기 생성
- ✅ 일일 카운터 1/3 증가

#### 테스트 3: 7~8번째 일기

**절차:**
1. 6번째 일기 생성 완료 상태
2. 7번째, 8번째 일기 작성

**기대 결과:**
- ✅ 각각 광고 시청 다이얼로그 표시
- ✅ 일일 카운터 2/3, 3/3 증가

#### 테스트 4: 일일 제한 도달

**절차:**
1. 오늘 이미 3개 생성한 상태
2. 4번째 일기 작성 시도

**기대 결과:**
- ✅ "오늘의 무료 생성 완료!" 다이얼로그
- ✅ 리셋 시간 표시 (내일 00:00)
- ✅ 프리미엄 혜택 목록 표시
- ✅ 일기 생성 차단

#### 테스트 5: 일일 카운터 리셋

**절차:**
1. 일일 제한 도달 상태 (3/3)
2. 시스템 시간을 다음날로 변경 (또는 실제 대기)
3. 앱 재시작
4. 일기 작성 시도

**기대 결과:**
- ✅ 카운터 0/3으로 리셋
- ✅ 다시 3개 생성 가능
- ✅ 로그: "[무료 제한] 일일 카운터 리셋: 2025-10-19"

### 7.2 광고 관련 테스트

#### 테스트 6: 광고 로드 실패

**절차:**
1. 네트워크 연결 끊기 (비행기 모드)
2. 일기 생성 시도

**기대 결과:**
- ✅ 광고 로드 실패 감지
- ✅ "광고를 불러올 수 없습니다" 다이얼로그
- ✅ 일기 생성 차단 (카운터 증가 안 됨)

#### 테스트 7: 광고 시청 중단

**절차:**
1. 일기 생성 → 광고 시청
2. 광고 중간에 뒤로가기 또는 닫기

**기대 결과:**
- ✅ "광고 시청이 완료되지 않았습니다" 다이얼로그
- ✅ 일기 생성 차단
- ✅ 카운터 증가 안 됨

### 7.3 프리미엄 사용자 테스트

#### 테스트 8: 프리미엄 무제한 생성

**절차:**
1. 프리미엄으로 전환 (설정 > 프리미엄 구독)
2. 일기 10개 연속 생성

**기대 결과:**
- ✅ 광고 없이 모두 생성
- ✅ 일일 제한 없음
- ✅ 진행 상황 배너 숨김

#### 테스트 9: 무료 → 프리미엄 전환

**절차:**
1. 무료 사용자로 3개 생성 (3/3)
2. 프리미엄으로 전환
3. 일기 생성 시도

**기대 결과:**
- ✅ 제한 없이 바로 생성
- ✅ 광고 없음

### 7.4 UI/UX 테스트

#### 테스트 10: 일기 목록 진행 상황 배너

**절차:**
1. 무료 사용자로 로그인
2. 일기 목록 화면 확인

**기대 결과:**
- ✅ 진행 상황 배너 표시
- ✅ "오늘 생성: X/3개" 정확
- ✅ 리셋 시간 표시
- ✅ 진행 바 애니메이션

#### 테스트 11: 다이얼로그 디자인

**절차:**
1. 각 다이얼로그 트리거

**기대 결과:**
- ✅ 축하 다이얼로그: 긍정적 디자인
- ✅ 제한 다이얼로그: 명확한 정보
- ✅ 실패 다이얼로그: 도움이 되는 안내
- ✅ 모든 텍스트 가독성 확보

---

## 8. 성과 측정 지표

### 8.1 핵심 KPI

| 지표 | 측정 방법 | 목표 |
|------|----------|------|
| **DAU** (Daily Active Users) | Firebase Analytics | 1,000명 |
| **7일 리텐션** | 7일 후 재방문율 | 40% 이상 |
| **30일 리텐션** | 30일 후 재방문율 | 20% 이상 |
| **광고 수익** | AdMob 대시보드 | $60/일 |
| **구독 전환율** | 무료 → 프리미엄 전환 | 2% 이상 |
| **광고 완료율** | 시청 완료 / 시작 | 80% 이상 |
| **일평균 광고 시청** | 사용자당 평균 | 2회 이상 |

### 8.2 A/B 테스트 플랜

**테스트 가설:**
하이브리드 모델(광고)이 Hard Paywall(5개 제한)보다 리텐션과 수익 모두 높다.

**그룹 분할:**
- Group A (50%): Hard Paywall (현재 모델)
- Group B (50%): 하이브리드 모델 (광고)

**측정 기간**: 30일

**성공 기준:**
- Group B의 30일 리텐션 > Group A + 10%
- Group B의 총 수익 (광고 + 구독) > Group A

### 8.3 사용자 피드백 수집

**방법:**
1. 앱 내 피드백 버튼 (설정 화면)
2. 앱스토어 리뷰 모니터링
3. 광고 후 만족도 조사 (선택 사항)

**질문 예시:**
- 광고 시청 후 일기 생성에 만족하시나요? (1-5점)
- 프리미엄 구독을 고려하시나요? (예/아니오)
- 개선이 필요한 점은? (자유 응답)

---

## 9. 추가 개선 사항 (Phase 2)

### 9.1 게이미피케이션 강화

**주간 목표 시스템:**
```
이번 주 일기 작성: 5/7일
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
완료 시 보상: 무료 프리미엄 1일 체험
```

### 9.2 친구 초대 프로그램

**Referral 시스템:**
- 친구 초대 시: 양쪽 모두 광고 없이 일기 3개 생성
- 초대된 친구가 프리미엄 가입 시: 추천인에게 1개월 무료

### 9.3 시즌 이벤트

**특별 기간 무제한 무료:**
- 크리스마스, 설날 등: 24시간 광고 없이 무제한
- 앱 기념일: 전체 사용자 무료 프리미엄 1주일

### 9.4 광고 선택권 부여

**Premium Lite 옵션:**
- $2.99/월: 광고 제거만 (다른 기능은 제한)
- 사용자 선택 폭 확대

---

## 10. 결론

이 하이브리드 모델은 다음을 달성합니다:

✅ **사용자 만족**: 무료로 계속 사용 가능
✅ **수익 다각화**: 광고 + 구독 이중 수익
✅ **리텐션 증가**: 제한이 아닌 선택
✅ **프리미엄 가치**: 광고 제거의 명확한 혜택
✅ **장기 성장**: 안정적인 비즈니스 모델

**다음 단계: 즉시 구현 시작!**
