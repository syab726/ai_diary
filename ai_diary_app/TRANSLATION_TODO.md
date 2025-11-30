# 번역 작업 필요 목록

## 발견 날짜: 2025-10-26

하드코딩된 한국어 문자열을 다국어 지원 (AppLocalizations)으로 변경해야 함

---

## 1. 연간 리포트 화면 (annual_report_screen.dart)

### 높은 우선순위
- "연간 리포트" → annualReport
- "리포트 재생성" → regenerateReport
- "일기를 작성하면 연말에 멋진 리포트를 받을 수 있어요" → writeToGetYearEndReport
- "연도 선택" → selectYear
- "취소" → cancel (이미 있는지 확인 필요)

### 리포트 섹션
- "한 해 요약" → yearSummary
- "작성한 일기" → diariesWritten
- "기록한 날" → daysRecorded
- "작성 비율" → writingRatio
- "월평균" → monthlyAverage
- "감정 분포" → emotionDistribution
- "자주 쓴 키워드" → frequentKeywords
- "베스트 일기" → bestDiary
- "월별 활동" → monthlyActivity
- "가장 활발했던 달: {month}월 ({count}개)" → mostActiveMonthFormat
- "작성 패턴" → writingPattern
- "가장 많이 쓴 요일" → mostWrittenWeekday
- "자주 쓰는 시간대" → frequentTimeSlot

### 에러 메시지
- "리포트가 새로 생성되었습니다" → reportRegeneratedSuccess
- "리포트 생성 중 오류가 발생했습니다: {error}" → reportGenerationErrorFormat

---

## 2. 설정 화면 (settings/)

### personalization_settings_screen.dart
- "개인화" → personalization (이미 있는지 확인)
- "글꼴" → font
- "일기 작성에 사용할 글꼴을 선택하세요" → selectFontDescription
- "날짜 포맷" → dateFormat
- "날짜 표시 형식을 선택하세요" → selectDateFormatDescription
- "타임존" → timezone
- "시간대를 선택하세요" → selectTimezoneDescription
- "글꼴 선택" → selectFont
- "프리미엄 전용 글꼴" → premiumOnlyFont
- "날짜 포맷 선택" → selectDateFormat
- "년/월/일 (2024/12/25)" → dateFormatYMD
- "일/월/년 (25/12/2024)" → dateFormatDMY
- "월/일/년 (12/25/2024)" → dateFormatMDY
- "날짜 포맷이 변경되었습니다" → dateFormatChanged
- "타임존 선택" → selectTimezone
- "타임존이 {name}으로 변경되었습니다" → timezoneChangedFormat

### 타임존 리스트 (다국어 필요)
- "서울 (KST)" → timezoneSeoul
- "도쿄 (JST)" → timezoneTokyo
- "베이징 (CST)" → timezoneBeijing
- "뉴욕 (EST)" → timezoneNewYork
- "로스앤젤레스 (PST)" → timezoneLosAngeles
- "런던 (GMT)" → timezoneLondon
- "파리 (CET)" → timezoneParis

### delete_settings_screen.dart
- "데이터 삭제" → deleteData
- "주의사항" → caution
- "• 모든 일기가 영구적으로 삭제됩니다..." → dataDeleteWarning (전체 텍스트)
- "캐시 삭제" → deleteCache
- "저장된 이미지 캐시를 삭제하여 저장 공간 확보" → deleteCacheDescription
- "계산 실패" → calculationFailed
- "이미지 캐시를 삭제하시겠습니까?" → deleteCacheConfirmation
- "현재 캐시 크기: {size}" → currentCacheSizeFormat
- "캐시 삭제 중..." → deletingCache
- "캐시가 성공적으로 삭제되었습니다" → cacheDeletedSuccess
- "캐시 삭제 중 오류가 발생했습니다" → cacheDeleteError
- "모든 데이터가 삭제되었습니다" → allDataDeleted
- "삭제 중 오류가 발생했습니다: {error}" → deleteErrorFormat

### ai_settings_screen.dart
- "고급설정 자동설정" → autoAdvancedSettings
- "프리미엄 전용 기능" → premiumOnlyFeature
- "시간, 날씨, 계절 옵션을 자동으로 설정합니다" → autoAdvancedSettingsDescription
- "고급설정 자동설정이 활성화되었습니다" → autoAdvancedSettingsEnabled
- "고급설정 자동설정이 비활성화되었습니다" → autoAdvancedSettingsDisabled

### backup_restore_screen.dart (매우 많음)
- "백업 및 복원" → backupAndRestore
- "자동 백업" → autoBackup
- "로컬 백업/복원" → localBackupRestore
- "클라우드 백업/복원" → cloudBackupRestore
- "클라우드 백업" → cloudBackup
- "클라우드 복원" → cloudRestore
- "무료 사용자는 일기 제목, 내용, 날짜를 JSON 형식으로 백업할 수 있습니다." → freeUserBackupDescription
- "프리미엄: 감정 분석, 생성 이미지, AI 프롬프트 포함" → premiumBackupDescription
- "백업 파일 저장 위치 선택" → selectBackupLocation
- "백업이 취소되었습니다" → backupCanceled
- "현재 저장된 데이터는 모두 삭제되고\n백업 파일로 대체됩니다" → restoreWarning
- "파일 선택" → selectFile
- "복원 중..." → restoring
- "복원된 일기가 없습니다" → noRestoredDiaries
- "복원 실패: {error}" → restoreFailedFormat
- "포함 내용:" → includedContent
- "모든 일기 내용" → allDiaryContent
- "감정 분석 결과" → emotionAnalysisResult
- "생성된 이미지 (base64)" → generatedImagesBase64
- "이미지 스타일 및 설정" → imageStyleAndSettings
- "업로드한 사진들" → uploadedPhotos
- "기존 백업이 있다면 덮어쓰기됩니다" → existingBackupWarning
- "백업 시작" → startBackup
- "로그인이 필요합니다.\n먼저 앱에 로그인해주세요." → loginRequiredForBackup
- "백업 완료 (테스트 모드)" → backupCompleteTestMode
- "클라우드에 백업 중..." → backingUpToCloud
- "클라우드 백업이 완료되었습니다" → cloudBackupCompleted
- "클라우드 백업에 실패했습니다" → cloudBackupFailed
- "클라우드 백업 오류: {error}" → cloudBackupErrorFormat
- "로그인 필요" → loginRequired
- "클라우드 복원을 사용하려면 먼저 앱에 로그인해주세요." → loginRequiredForRestore
- "확인" → confirm
- "백업 없음" → noBackup
- "클라우드에 저장된 백업이 없습니다.\n먼저 백업을 생성해주세요." → noCloudBackupFound
- "클라우드 복원" → cloudRestore
- "복원 시작" → startRestore
- "클라우드에서 복원 중..." → restoringFromCloud
- "클라우드 복원에 실패했습니다" → cloudRestoreFailed
- "클라우드 복원 오류: {error}" → cloudRestoreErrorFormat
- "프리미엄 전용 기능" → premiumOnlyFeature (중복)
- "클라우드 백업/복원은 프리미엄 사용자만 사용할 수 있습니다." → cloudBackupPremiumOnly
- "자동 클라우드 백업" → autoCloudBackup
- "백업 중..." → backingUp
- "백업 완료" → backupComplete
- "마지막 백업: {datetime}" → lastBackupFormat
- "오류: {error}" → errorFormat
- "프리미엄으로 업그레이드하여 자동 백업 기능을 사용하세요" → upgradeToPremiumForAutoBackup
- "프리미엄으로 업그레이드하여 클라우드 백업/복원 기능을 사용하세요" → upgradeToPremiumForCloudBackup

---

## 3. 설정 메인 화면 (settings_screen.dart)

- "언어, 글꼴, 날짜 포맷 설정" → personalizationSubtitle
- "이미지 스타일, AI 가이드 설정" → aiSettingsSubtitle
- "백업 및 복원" → backupAndRestore (중복)
- "데이터 백업 및 클라우드 동기화" → backupDescription
- "데이터 삭제" → deleteData (중복)
- "모든 일기 데이터 삭제" → deleteDataDescription
- "프리미엄 업그레이드" → premiumUpgrade
- "광고 없이 무제한으로 사용하세요" → premiumDescription
- "프리미엄으로 무제한 생성" → unlimitedWithPremium
- "테스트 모드" → testMode
- "현재: 프리미엄 사용자" → currentPremiumUser
- "현재: 무료 사용자" → currentFreeUser
- "프리미엄 사용자로 전환됨" → switchedToPremium
- "무료 사용자로 전환됨" → switchedToFree
- "프리미엄" → premium
- "무료" → free
- "로그아웃 (로그인 화면으로)" → logoutToLoginScreen
- "로그아웃" → logout
- "로그인 화면으로 돌아가시겠습니까?" → returnToLoginConfirmation

---

## 작업 우선순위

### 긴급 (사용자 노출 높음)
1. 설정 화면 메인 메뉴 (settings_screen.dart)
2. 개인화 설정 (personalization_settings_screen.dart)
3. 백업/복원 기본 문구 (backup_restore_screen.dart)

### 높음
4. 삭제 설정 (delete_settings_screen.dart)
5. AI 설정 (ai_settings_screen.dart)
6. 연간 리포트 기본 문구 (annual_report_screen.dart)

### 중간
7. 백업/복원 고급 기능 문구
8. 연간 리포트 상세 문구
9. 타임존 리스트

---

## 작업 진행 방법

1. app_localizations.dart에 키 추가
2. 한국어, 일본어, 영어, 중국어 번역 추가
3. 각 파일에서 하드코딩된 문자열을 AppLocalizations 호출로 변경
4. 테스트 (각 언어별로 확인)

---

## 참고사항

- SnackBar 메시지들도 모두 번역 필요
- Dialog 제목 및 내용도 번역 필요
- 테스트 모드 관련 문구는 우선순위 낮음 (개발자용)
- 에러 메시지는 포맷 문자열 사용 (예: {error}, {count}, {name})
