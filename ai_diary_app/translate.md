# 번역 작업 체크리스트

## 작업 방법론
1. 각 화면별로 파일을 찾아 읽는다
2. 하드코딩된 한글 텍스트를 모두 찾는다
3. AppLocalizations에 해당 키가 있는지 확인한다
4. 없으면 l10n 파일에 추가하고, 있으면 해당 키로 교체한다
5. 각 작업 완료 시 체크표시한다

## 작업 리스트

### 1. 글꼴 시스템 (언어별 글꼴 제공)
- [ ] 파일: `lib/models/font_family.dart`
- [ ] 파일: `lib/screens/settings/personalization_settings_screen.dart`
- 문제: 한글 글꼴만 제공되고 있음
- 해결: 언어별로 적합한 글꼴만 노출되도록 수정
  - 한국어: 현재 글꼴 유지
  - 일본어: 일본어 지원 글꼴만
  - 영어: 영어 지원 글꼴만
  - 중국어: 중국어 지원 글꼴만

### 2. AI 이미지 설정 화면
- [ ] 파일: `lib/screens/diary_create_screen.dart` 내 이미지 설정 다이얼로그
- [ ] 파일: `lib/widgets/tabbed_option_selector.dart`
- 번역 필요 항목:
  - 이미지 스타일 선택
  - 고급 옵션
  - 조명, 분위기, 색상, 구도 등 모든 옵션 텍스트

### 3. 프리미엄 관련 모든 영역
- [ ] 파일: `lib/screens/premium_subscription_screen.dart`
- [ ] 파일: `lib/widgets/premium_dialog.dart`
- [ ] 파일: `lib/screens/settings_screen.dart` 내 프리미엄 타일
- 번역 필요 항목:
  - 프리미엄 업그레이드 문구
  - 혜택 설명
  - 가격 정보
  - 버튼 텍스트

### 4. 구글 드라이브 백업 UI 오버플로우 수정
- [ ] 파일: `lib/screens/settings/backup_restore_screen.dart`
- 문제: 언어별로 텍스트 길이가 달라 bottom overflowed 발생
- 해결: Flexible/Expanded 위젯 사용 또는 SingleChildScrollView 추가

### 5. 자동 백업 토글 네비게이션 수정
- [ ] 파일: `lib/screens/settings/backup_restore_screen.dart`
- 문제: 토글 시 일기 메인으로 이동
- 해결: 네비게이션 로직 제거, 상태만 변경하도록 수정

### 6. 일기 메인 화면
- [ ] 파일: `lib/screens/diary_list_screen.dart`
- 번역 필요 항목:
  - 뒤쪽 아이콘 글자
  - "AI가 그린 이미지" 문구
  - 년도/월 헤더
  - 기타 모든 하드코딩된 텍스트

### 7. 일기 디테일 화면
- [ ] 파일: `lib/screens/diary_detail_screen.dart`
- 번역 필요 항목:
  - 날짜 표시
  - 기분 표시
  - 키워드 표시
  - "마지막 수정" 텍스트
  - "AI생성", "내그림" 뱃지
  - 모든 버튼 및 메뉴 텍스트

### 8. 일기 수정 화면
- [ ] 파일: `lib/screens/diary_edit_screen.dart` 또는 diary_create_screen.dart의 편집 모드
- 번역 필요 항목:
  - 모든 폼 레이블
  - 힌트 텍스트
  - 버튼 텍스트
  - 에러 메시지

### 9. 일기 생성 페이지
- [ ] 파일: `lib/screens/diary_create_screen.dart`
- 번역 필요 항목:
  - 모든 입력 필드 레이블
  - 플레이스홀더 텍스트
  - 버튼 텍스트
  - 진행 상태 메시지
  - 이미지 생성 관련 모든 텍스트

## 작업 순서
1. 먼저 모든 관련 파일을 읽어서 번역되지 않은 부분 파악
2. app_localizations.dart에 필요한 키 추가
3. 각 파일을 순서대로 수정
4. 각 수정 후 빌드 테스트
5. 다음 항목으로 이동

## 주의사항
- const 위젯에서 AppLocalizations.of(context) 사용 금지
- 각 수정 시 주변 코드 문맥 충분히 파악
- 중복 코드가 있을 경우 충분한 컨텍스트로 정확한 위치 지정
