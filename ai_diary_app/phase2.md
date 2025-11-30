# Phase 2 - 향후 개선사항

## Firebase Crashlytics 텔레그램 알림 구현

### 개요
현재 Crashlytics에 리포팅되는 에러 및 API 구조 변경 알림을 텔레그램으로 자동 전달하는 기능

### 구현 방법 (추천)

**Firebase Cloud Functions + Telegram Bot 연동**

#### 필요한 것들
1. Telegram Bot 생성 (BotFather 사용)
2. Firebase Blaze 플랜 (무료 할당량 내에서 사용 가능)
3. Cloud Functions 배포

#### 아키텍처
```
Crashlytics 이벤트 발생
  → Firebase Cloud Function 트리거
  → Telegram Bot API 호출
  → 텔레그램으로 알림 수신
```

#### 예상 비용
- Firebase Cloud Functions: 무료 할당량 내 사용 가능 (월 200만 호출 무료)
- Telegram Bot API: 무료

#### 장점
- 실시간 알림
- 완전한 커스터마이징 가능
- 추가 비용 없음 (무료 할당량 내)
- 알림 포맷 자유롭게 설정 가능

#### 구현 내용
- Crashlytics 이벤트 감지 함수
- 이벤트 필터링 (심각도, 타입 등)
- 텔레그램 메시지 포맷팅
- 에러 재시도 로직

---

## 대안 방법들

### 1. 이메일 알림 (가장 간단)
- Firebase Console → Crashlytics → 설정에서 활성화
- 장점: 설정 3분이면 끝
- 단점: 이메일로만 수신

### 2. Slack 연동 (공식 지원)
- Firebase Console → Project Settings → Integrations → Slack
- 장점: 공식 지원, 설정 쉬움
- 단점: Slack 계정 필요

### 3. Zapier/Make.com (노코드)
- 장점: 코딩 불필요
- 단점: 유료 플랜 필요 (월 $20~)

---

## 우선순위
- 단기: 이메일 알림 설정 (즉시 가능)
- 중기: Cloud Functions + Telegram Bot 구현
