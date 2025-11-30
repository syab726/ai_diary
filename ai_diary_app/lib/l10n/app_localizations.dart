import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'ko': {
      'app_title': 'ArtDiary AI',
      'settings': '설정',
      'personalization': '개인화',
      'theme': '테마',
      'theme_subtitle': '앱 테마를 변경하세요',
      'language': '언어',
      'language_subtitle': '앱 언어를 변경하세요',
      'font_size': '폰트 크기',
      'font_size_subtitle': '일기 텍스트 크기를 조절하세요',
      'notifications': '알림 설정',
      'notifications_subtitle': '일기 작성 리마인더 설정',
      'ai_settings': 'AI 설정',
      'default_image_style': '기본 이미지 스타일',
      'default_image_style_subtitle': '새 일기의 기본 이미지 스타일',
      'ai_analysis_strength': 'AI 분석 강도',
      'ai_analysis_strength_subtitle': '감정 및 키워드 분석 정확도',
      'ai_image_guide': 'AI 이미지 가이드',
      'ai_image_guide_subtitle': '효과적인 프롬프트 작성법과 팁',
      'data_privacy': '데이터 및 개인정보',
      'data_backup': '데이터 백업',
      'data_backup_subtitle': '일기 데이터를 백업하세요',
      'data_restore': '데이터 복원',
      'data_restore_subtitle': '백업된 일기 데이터를 복원하세요',
      'delete_all_data': '모든 데이터 삭제',
      'delete_all_data_subtitle': '모든 일기 데이터를 삭제합니다',
      'premium': '프리미엄',
      'premium_upgrade': '프리미엄 업그레이드',
      'premium_upgrade_subtitle': '무제한 이미지 생성 • 고급 스타일 • 광고 제거',
      'app_info': '앱 정보',
      'app_version': '앱 버전',
      'privacy_policy': '개인정보 처리방침',
      'terms_of_service': '이용약관',
      'cancel': '취소',
      'confirm': '확인',
      'close': '닫기',
      'save': '저장',
      'back': '뒤로',
      // Calendar screen
      'refresh': '새로고침',
      'today': '오늘',
      'no_diary_on_date': '이 날에는 작성한 일기가 없습니다',
      'write_diary': '일기 작성하기',
      'cannot_load_calendar': '달력을 불러올 수 없습니다',
      'cannot_load_diary': '일기를 불러올 수 없습니다',
      'tags_count': '개 태그',
      // Diary create screen
      'new_diary': '새 일기 작성',
      'edit_diary': '일기 수정',
      'title': '제목',
      'title_hint': '오늘의 제목을 입력하세요',
      'diary_content': '일기 내용',
      'diary_content_hint': '오늘 있었던 일과 감정을 자유롭게 적어보세요.\nAI가 당신의 이야기를 아름다운 그림으로 그려줄 거예요.',
      'please_enter_title': '제목을 입력해주세요',
      'please_enter_content': '일기 내용을 입력해주세요',
      'content_too_short': '더 자세한 내용을 적어주세요 (최소 10자)',
      'image_style': '이미지 스타일',
      'ai_drawing_complete': '저장 완료! AI가 그린 그림',
      'ai_drawing': 'AI가 그린 그림',
      'generate_image': '이미지 생성',
      'generating_image': 'AI가 {style}로\n당신의 이야기를 그림으로 그리고 있습니다...',
      'please_wait': '잠시만 기다려주세요',
      'saving': '저장 중...',
      'saved_successfully': '저장 완료',
      'diary_saved': '일기가 저장되었습니다',
      'diary_updated': '일기가 수정되었습니다',
      'image_generation_error': '이미지 생성 중 오류가 발생했습니다: {error}',
      'save_error': '저장 중 오류가 발생했습니다: {error}',
      'failed_to_load_diary': '일기를 불러오는데 실패했습니다: {error}',
      'analyzing_photo': '사진 분석 중...',
      'analyzing_emotion': '감정 분석 중...',
      'extracting_keywords': '키워드 추출 중...',
      'generating_prompt': '이미지 프롬프트 생성 중...',
      'generating_ai_image_notice': 'AI 이미지 생성 중...\n\n(사용자가 많을 경우 대기 시간이 길어질 수 있습니다)',
      'diary_saved_successfully': '일기가 성공적으로 저장되었습니다!',
      'image_gallery': '이미지 갤러리',
      'photo_upload': '사진 업로드',
      'select_photo': '사진 선택',
      'my_photo': '내 사진',
      'edit_diary_only': '일기만 수정',
      'edit_image_and_diary': '그림+일기 수정',
      'photo_upload_and_gallery': '사진 업로드 및 갤러리',
      'photo_select_failed': '사진 선택 실패: {error}',
      // Login screen
      'login_title': 'ArtDiary AI',
      'login_description': 'AI가 그려주는 감동적인 그림일기',
      'login_tagline': '매일의 소중한 순간을\nAI가 아름다운 그림으로 만들어드려요',
      'start_with_google': 'Google로 시작하기',
      'continue_as_guest': 'Guest로 계속하기',
      'welcome_user': '환영합니다, {name}님!',
      'user': '사용자',
      'google_login_failed': 'Google 로그인 실패: {error}',
      'guest_login_message': 'Guest로 시작합니다 (데이터는 이 기기에만 저장됩니다)',
      'login_failed': '로그인 실패: {error}',
      // Emotions
      'emotion_happy': '행복',
      'emotion_sad': '슬픔',
      'emotion_angry': '화남',
      'emotion_excited': '흥분',
      'emotion_peaceful': '평온',
      'emotion_anxious': '불안',
      'emotion_grateful': '감사',
      'emotion_nostalgic': '그리움',
      'emotion_romantic': '로맨틱',
      'emotion_frustrated': '짜증',
      'emotion_normal': '보통',
      'all_emotions': '전체',
      'error_occurred_general': '오류가 발생했습니다',
      'retry_button': '다시 시도',
      'search_button': '검색',
      'ai_generated_image_placeholder': 'AI가 그린 이미지',
      // Premium features
      'premium_feature': '프리미엄 기능',
      'upgrade_to_premium': '프리미엄으로 업그레이드',
      'free_user_limit': '무료 사용자는 이미지 수정이 불가합니다',
      'image_modification_limit': '이미지 수정 한도를 초과했습니다',
      'regenerate_image': '이미지 다시 생성',
      'keep_existing_image': '기존 이미지 유지',
      'image_modification_dialog_title': '이미진 수정',
      'image_modification_dialog_content': '일기 내용을 수정했습니다.\n새로운 내용에 맞게 이미지를 다시 생성할까요?',
      'remaining_generations': '남은 생성 횟수: {count}개',
      'remaining_modifications': '남은 수정 횟수: {count}개',
      'unlimited': '무제한',
      // Search
      'search_hint': '검색할 내용을 입력하세요',
      'search_label': '검색',
      'no_entries': '아직 작성된 일기가 없습니다',
      'create_first_entry': '첫 번째 일기를 작성해보세요!',
      'empty_search': '검색 결과가 없습니다',
      'try_different_keyword': '다른 키워드로 검색해보세요',
      // Navigation & UI
      'diary_list': '일기 목록',
      'calendar': '캘린더',
      'diary_search': '일기 검색',
      'start_with_ai_diary': 'AI가 그림을 그려주는 특별한 일기를 시작해보세요',
      'calendar_load_error': '달력을 불러올 수 없습니다',
      // Settings dialog content
      'theme_selection': '테마 선택',
      'light_theme': '라이트 테마',
      'dark_theme': '다크 테마',
      'system_theme': '시스템 설정',
      'font_size_setting': '폰트 크기 설정',
      'font_size_description': '일기 텍스트의 크기를 선택하세요',
      'font_small': '작게',
      'font_medium': '보통',
      'font_large': '크게',
      'font_xlarge': '매우 크게',
      'font_size_changed': '폰트 크기가 "{size}"로 설정되었습니다.',
      'notification_settings': '알림 설정',
      'notification_description': '일기 작성을 놓치지 않도록 알림을 받으세요.',
      'daily_reminder': '일일 리마인더',
      'daily_reminder_time': '매일 저녁 9시에 알림',
      'weekly_summary': '주간 요약',
      'weekly_summary_time': '매주 일요일 오전 10시',
      'notification_enabled': '알림이 활성화되었습니다.',
      'notification_disabled': '알림이 비활성화되었습니다.',
      'weekly_notification_enabled': '주간 요약 알림이 활성화되었습니다.',
      'weekly_notification_disabled': '주간 요약 알림이 비활성화되었습니다.',
      'premium_upgrade_title': '프리미엄 업그레이드',
      'premium_benefits': '프리미엄으로 업그레이드하면:',
      'unlimited_ai_images': '무제한 AI 이미지 생성',
      'advanced_image_styles': '50+ 고급 이미지 스타일',
      'no_ads': '광고 완전 제거',
      'cloud_backup': '클라우드 자동 백업',
      'advanced_security': '고급 보안 기능',
      'later': '나중에',
      'monthly_price': '월 ₩4,900',
      'premium_coming_soon': '프리미엄 구독은 곧 제공될 예정입니다!',
      'default_image_style_setting': '기본 이미지 스타일 설정',
      'image_style_description': '새 일기 작성 시 기본으로 선택될 이미지 스타일을 설정하세요.',
      'default_style_set': '기본 스타일이 "{style}"으로 설정되었습니다.',
      'data_backup_title': '데이터 백업',
      'backup_description': '모든 일기 데이터를 JSON 파일로 백업합니다.',
      'backup_includes': '포함 내용:',
      'backup_diary_content': '일기 제목 및 내용',
      'backup_date_time': '작성 날짜 및 시간',
      'backup_emotion_analysis': '감정 분석 결과',
      'backup_generated_images': '생성된 이미지 (Base64)',
      'backup_image_style': '이미지 스타일 정보',
      'backup_start': '백업 시작',
      'backing_up': '백업 중...',
      'ok': '확인',
      'last_backup_time_format': '마지막 백업: {time}',
      'error_format': '오류: {error}',
      'auto_cloud_backup_feature': '자동 클라우드 백업',
      'upgrade_for_auto_backup': '프리미엄으로 업그레이드하여 자동 백업 기능을 사용하세요',
      'cloud_backup_feature': '클라우드 백업',
      'cloud_backup_to_google_drive': 'Google Drive에 일기를 백업합니다',
      'premium_feature_short': '프리미엄 전용 기능',
      'cloud_restore_feature': '클라우드 복원',
      'cloud_restore_from_google_drive': 'Google Drive에서 일기를 복원합니다',
      'cloud_backup_restore_feature': '클라우드 백업/복원',
      'upgrade_for_cloud_backup_restore': '프리미엄으로 업그레이드하여 클라우드 백업/복원 기능을 사용하세요',
      'backup_complete': '백업 완료',
      'backup_completed': '백업 완료! 총 {count}개의 일기가 백업되었습니다.',
      'backup_failed': '백업 실패: {error}',
      'last_backup_time': '마지막 백업: {time}',
      'error_occurred': '오류: {error}',
      'auto_cloud_backup': '자동 클라우드 백업',
      'simple_cloud_backup': '클라우드 백업',
      'simple_cloud_restore': '클라우드 복원',
      'cloud_backup_and_restore': '클라우드 백업/복원',
      'upgrade_for_cloud_features': '프리미엄으로 업그레이드하여 클라우드 백업/복원 기능을 사용하세요',
      'data_restore_title': '데이터 복원',
      'restore_description': '백업된 일기 데이터를 복원합니다.',
      'restore_start': '복원 시작',
      'delete_all_title': '모든 데이터 삭제',
      'delete_all_warning': '정말로 모든 일기 데이터를 삭제하시겠습니까?\n이 작업은 되돌릴 수 없습니다.',

      // Delete settings screen
      'warning_notice': '주의사항',
      'delete_warning_message': '• 모든 일기가 영구적으로 삭제됩니다\n• 삭제된 데이터는 복구할 수 없습니다\n• 삭제 전에 반드시 백업을 권장합니다',
      'clear_cache': '캐시 삭제',
      'clear_cache_description': '저장된 이미지 캐시를 삭제하여 저장 공간 확보',
      'cache_zero': '0 MB',
      'calculation_failed': '계산 실패',
      'clear_cache_confirm_message': '이미지 캐시를 삭제하시겠습니까?\n\n현재 캐시 크기: {size}\n\n참고: 일기 데이터는 삭제되지 않으며,\n필요 시 이미지가 다시 생성됩니다.',
      'clearing_cache': '캐시 삭제 중...',
      'cache_deleted_success': '캐시가 성공적으로 삭제되었습니다',
      'cache_delete_error': '캐시 삭제 중 오류가 발생했습니다',
      'delete_button': '삭제',
      'all_data_deleted': '모든 데이터가 삭제되었습니다',
      'delete_error_format': '삭제 중 오류가 발생했습니다: {error}',
      'delete_all_confirm': '모든 데이터 삭제',
      'app_info_subtitle': '앱 버전, 개인정보처리방침',
      'app_name': 'ArtDiary AI',
      'app_description': 'AI가 그려주는 특별한 그림일기 앱',
      'privacy_policy_title': '개인정보 처리방침',
      'privacy_policy_content': '''ArtDiary AI 개인정보 처리방침
최종 업데이트: 2025년 1월
1. 수집하는 정보
• 일기 내용 및 제목
• AI 생성 이미지
• 감정 분석 데이터
• 기기 식별 정보 (익명)
2. 정보 사용 목적
• 일기 작성 및 관리 서비스 제공
• AI 이미지 생성 및 감정 분석
• 앱 성능 개선 및 오류 수정
• 사용자 경험 향상
3. 정보 저장 및 보안
• 모든 데이터는 기기 내부에 안전하게 저장됩니다
• 클라우드 백업은 사용자 선택 시에만 활성화됩니다
• 데이터 암호화 및 보안 조치를 적용합니다
4. 제3자 제공
• 사용자 동의 없이 제3자에게 정보를 제공하지 않습니다
• AI 서비스 제공을 위해 Google Gemini API를 사용합니다
• 광고 표시를 위해 Google AdMob을 사용합니다
5. 사용자 권리
• 언제든지 데이터 삭제 요청 가능
• 개인정보 열람 및 수정 권한
• 서비스 이용 동의 철회 가능
6. 문의
개인정보 관련 문의사항은 앱 내 문의 기능을 이용해 주세요.
본 방침은 관련 법령 및 서비스 정책 변경에 따라 수정될 수 있습니다.''',
      'terms_title': '이용약관',
      'terms_content': '''ArtDiary AI 서비스 이용약관
최종 업데이트: 2025년 1월
1. 서비스 이용
• 본 앱은 AI 기반 그림일기 작성 서비스입니다
• 만 14세 이상 사용자를 대상으로 합니다
• 불법적이거나 부적절한 콘텐츠 작성을 금지합니다
2. 사용자 의무
• 정확한 정보 제공
• 타인의 권리 침해 금지
• 서비스 악용 또는 남용 금지
• 관련 법규 준수
3. 서비스 제공
• AI 이미지 생성 기능
• 일기 작성 및 관리 기능
• 감정 분석 및 통계 기능
• 무료 및 프리미엄 서비스
4. 프리미엄 서비스
• 월간 또는 연간 구독 제공
• 무제한 AI 이미지 생성
• 고급 기능 및 글꼴 사용
• 광고 제거
5. 서비스 중단 및 변경
• 시스템 점검 시 일시 중단 가능
• 사전 공지 후 서비스 내용 변경 가능
• 불가피한 경우 즉시 중단 가능
6. 면책 조항
• AI 생성 콘텐츠의 품질 보장 불가
• 사용자 기기 문제로 인한 데이터 손실 책임 없음
• 네트워크 장애로 인한 서비스 중단 책임 없음
7. 지적 재산권
• 사용자가 작성한 일기 내용은 사용자에게 귀속됨
• AI 생성 이미지의 사용권은 사용자에게 있음
• 앱 디자인 및 코드의 저작권은 개발자에게 있음
8. 계약 해지
• 사용자는 언제든지 서비스 이용을 중단할 수 있습니다
• 약관 위반 시 서비스 이용이 제한될 수 있습니다
본 약관은 대한민국 법률에 따라 규율되고 해석됩니다.''',
      'privacy_policy_subtitle': '개인정보 처리방침을 확인하세요',
      'terms_subtitle': '서비스 이용약관을 확인하세요',
      // Subscription management
      'subscription_management_test': '구독 관리 (테스트)',
      'premium_user': '프리미엄 사용자',
      'free_user': '무료 사용자',
      'image_generations': '이미지 생성',
      'image_modifications': '이미지 수정',
      'set_to_free': '무료 사용자로 설정되었습니다',
      'set_to_premium': '프리미엄으로 설정되었습니다',
      'set_free_plan': '무료로 설정',
      'set_premium_plan': '프리미엄으로 설정',
      // Image styles
      'style_auto': '자동 선택',
      'style_realistic': '실사 스타일',
      'style_watercolor': '수채화 스타일',
      'style_illustration': '일러스트 스타일',
      'style_sketch': '스케치 스타일',
      'style_anime': '애니메이션 스타일',
      'style_impressionist': '인상주의',
      'style_vintage': '빈티지 스타일',
      
      // Advanced options
      'advanced_options': '고급 옵션',
      'lighting': '조명',
      'mood': '분위기', 
      'color': '색상',
      'composition': '구도',
      'none': '없음',
      'clear_all_options': '자동선택으로',

      // AI Prompts
      'ai_emotion_analysis_prompt': '''다음 일기 내용의 주요 감정을 분석해주세요.
가능한 감정: happy, sad, angry, excited, peaceful, anxious, grateful, nostalgic, romantic, frustrated
하나의 감정만 답변해주세요.
일기 내용: {content}''',
      'ai_photo_analysis_prompt': '''이 사진들을 분석해서 다음 정보를 추출해주세요:
- 전체적인 분위기와 느낌
- 주요 색감과 톤
- 시간대 (아침, 낮, 저녁, 밤)
- 장소와 환경 (실내/실외, 도시/자연 등)
- 주요 피사체나 오브젝트
2-3문장으로 간결하게 요약해주세요.''',
      'ai_image_prompt_base': '''다음 일기 내용을 바탕으로 이미지 생성 프롬프트를 만들어주세요.
스타일: {style}
감정적이고 아름다운 이미지가 되도록 작성해주세요.
일기 내용: {content}
주요 감정: {emotion}
키워드: {keywords}
{advanced}
프롬프트는 영어로 작성하고, 일기의 감정과 내용을 잘 표현하는 따뜻하고 감성적인 이미지가 되도록 해주세요.
구체적인 시각적 요소, 색감, 분위기를 포함해서 작성해주세요.''',
      'ai_advanced_option_prefix': '고급 옵션: {options}',
      'ai_auto_settings_prompt': '''다음 일기 내용을 분석해서 이미지 생성에 적합한 설정들을 추천해주세요.
JSON 형태로 답변해주세요:
{{
  "lighting": "natural|dramatic|warm|cool|sunset|night 중 하나",
  "mood": "peaceful|energetic|romantic|mysterious|joyful|melancholic 중 하나",
  "color": "vibrant|pastel|monochrome|warm|cool|earthy 중 하나",
  "composition": "centered|rule_of_thirds|symmetrical|dynamic|minimalist 중 하나"
}}
일기 내용: {content}
일기의 분위기, 감정, 시간대, 날씨, 상황 등을 종합적으로 고려해서 가장 적합한 설정을 선택해주세요.''',
      'ai_emotion_insight_system': '''당신은 친절하고 공감 능력이 뛰어난 심리 상담 전문가입니다.
사용자의 {period} 일기 데이터를 분석하여 감정 패턴과 인사이트를 제공해주세요.
일기 데이터:
{diaries}
다음 지침을 따라 인사이트를 작성해주세요:
1. 3-4문장으로 간결하게 작성
2. 긍정적이고 공감적인 어조 사용
3. 감정 패턴이나 변화에 대한 관찰 포함
4. 실용적인 조언이나 격려의 메시지 포함
5. 따뜻하고 친근한 말투 사용
인사이트만 출력하고 다른 설명은 필요 없습니다.''',
      'ai_default_insight': '이번 {period}에는 다양한 감정을 경험하셨네요. 자신의 감정을 인식하고 기록하는 것만으로도 큰 의미가 있습니다.',
      'ai_fallback_insight': '이번 기간 동안의 감정 여정을 함께 기록해주셔서 감사합니다.',
      // Settings screen
      'personalization_subtitle': '언어, 글꼴, 날짜 포맷 설정',
      'ai_settings_subtitle': '이미지 스타일, AI 가이드 설정',
      'backup_and_restore': '백업 및 복원',
      'delete_data': '데이터 삭제',
      'delete_data_description': '모든 일기 데이터 삭제',
      'premium_upgrade_description': '광고 없이 무제한으로 사용하세요',
      'unlimited_with_premium': '프리미엄으로 무제한 생성',
      'test_mode': '테스트 모드',
      'current_premium_user': '현재: 프리미엄 사용자',
      'current_free_user': '현재: 무료 사용자',
      'switched_to_premium': '프리미엄 사용자로 전환됨',
      'switched_to_free': '무료 사용자로 전환됨',
      'free': '무료',
      'logout_to_login_screen': '로그아웃 (로그인 화면으로)',
      'logout': '로그아웃',
      'return_to_login_confirmation': '로그인 화면으로 돌아가시겠습니까?',
      // Personalization settings screen
      'font': '글꼴',
      'select_font_description': '일기 작성에 사용할 글꼴을 선택하세요',
      'date_format': '날짜 포맷',
      'select_date_format_description': '날짜 표시 형식을 선택하세요',
      'timezone': '타임존',
      'select_timezone_description': '시간대를 선택하세요',
      'select_font': '글꼴 선택',
      'premium_only_font': '프리미엄 전용 글꼴',
      'select_date_format': '날짜 포맷 선택',
      'date_format_ymd': '년/월/일 (2024/12/25)',
      'date_format_dmy': '일/월/년 (25/12/2024)',
      'date_format_mdy': '월/일/년 (12/25/2024)',
      'date_format_changed': '날짜 포맷이 변경되었습니다',
      'select_timezone': '타임존 선택',
      'timezone_changed_format': '타임존이 {name}으로 변경되었습니다',
      'timezone_seoul': '서울 (KST)',
      'timezone_tokyo': '도쿄 (JST)',
      'timezone_beijing': '베이징 (CST)',
      'timezone_new_york': '뉴욕 (EST)',
      'timezone_los_angeles': '로스앤젤레스 (PST)',
      'timezone_london': '런던 (GMT)',
      'timezone_paris': '파리 (CET)',

      // AI settings screen
      'auto_advanced_settings': '고급설정 자동설정',
      'premium_only_feature': '프리미엄 전용 기능',
      'auto_advanced_settings_description': '시간, 날씨, 계절 옵션을 자동으로 설정합니다',
      'auto_advanced_settings_enabled': '고급설정 자동설정이 활성화되었습니다',
      'auto_advanced_settings_disabled': '고급설정 자동설정이 비활성화되었습니다',
      'premium_styles_available_format': '{count}개의 추가 스타일이 프리미엄에서 제공됩니다',

      // Backup and restore screen
      'auto_backup': '자동 백업',
      'local_backup_restore': '로컬 백업/복원',
      'cloud_backup_restore': '클라우드 백업/복원',
      'free_user_backup_description': '무료 사용자는 일기 제목, 내용, 날짜를 JSON 형식으로 백업할 수 있습니다.',
      'premium_backup_description': '프리미엄: 감정 분석, 생성 이미지, AI 프롬프트 포함',
      'select_backup_location': '백업 파일 저장 위치 선택',
      'backup_canceled': '백업이 취소되었습니다',
      'restore_warning': '현재 저장된 데이터는 모두 삭제되고\n백업 파일로 대체됩니다',
      'select_file': '파일 선택',
      'restoring': '복원 중...',
      'no_restored_diaries': '복원된 일기가 없습니다',
      'restore_failed_format': '복원 실패: {error}',
      'included_content': '포함 내용:',
      'all_diary_content': '모든 일기 내용',
      'emotion_analysis_result': '감정 분석 결과',
      'generated_images_base64': '생성된 이미지 (base64)',
      'image_style_and_settings': '이미지 스타일 및 설정',
      'uploaded_photos': '업로드한 사진들',
      'existing_backup_warning': '기존 백업이 있다면 덮어쓰기됩니다',
      'premium_backup_success_format': '{count}개 일기가 완전히 백업되었습니다',
      'backup_success_format': '{count}개 일기가 백업되었습니다',
      'cancel_file_selection_hint': '파일 선택 화면에서 뒤로가기 버튼으로\n언제든지 취소할 수 있습니다',
      'restore_success_format': '{count}개 일기가 복원되었습니다',
      'google_drive_backup': 'Google Drive 백업',
      'google_drive_backup_description': 'Google Drive에 일기 데이터를 안전하게 백업합니다.',
      'start_backup': '백업 시작',
      'login_required_message': '로그인이 필요합니다.\n먼저 앱에 로그인해주세요.',
      'backing_up_to_google_drive': 'Google Drive 백업 중...',
      'backup_complete_test_mode': '백업 완료 (테스트 모드)',
      'backing_up_to_cloud': '클라우드에 백업 중...',
      'cloud_backup_complete': '클라우드 백업이 완료되었습니다',
      'cloud_backup_failed': '클라우드 백업에 실패했습니다',
      'cloud_backup_error_format': '클라우드 백업 오류: {error}',
      'login_required_title': '로그인 필요',
      'cloud_restore_login_message': '클라우드 복원을 사용하려면 먼저 앱에 로그인해주세요.',
      'test_restore_title': '[테스트] 복원',
      'test_mode_restore_simulation': '테스트 모드에서 복원을 시뮬레이션합니다.',
      'real_environment_google_drive_restore': '실제 환경에서는 Google Drive에서 복원합니다.',
      'start_button': '시작',
      'no_backup_title': '백업 없음',
      'no_cloud_backup_message': '클라우드에 저장된 백업이 없습니다.\n먼저 백업을 생성해주세요.',
      'cloud_restore_title': '클라우드 복원',
      'restore_from_firebase': 'Firebase에서 일기 데이터를 복원합니다.',
      'all_data_will_be_replaced': '현재 저장된 데이터는 모두 삭제되고\n클라우드 백업 데이터로 대체됩니다',
      'cancel_button': '취소',
      'start_restore_button': '복원 시작',
      'restoring_from_cloud': '클라우드에서 복원 중...',
      'cloud_restore_failed': '클라우드 복원에 실패했습니다',
      'cloud_restore_error_format': '클라우드 복원 오류: {error}',
      'restore_complete_test_mode': '복원 완료 (테스트 모드)',
      'cloud_backup_restore_premium_only': '클라우드 백업/복원은 프리미엄 사용자만 사용할 수 있습니다.',
      'auto_backup_every_5_minutes': '5분마다 자동으로 백업합니다',
      'auto_backup_enabled': '자동 백업이 활성화되었습니다',
      'auto_backup_disabled': '자동 백업이 비활성화되었습니다',
      // Diary detail screen
      'error_loading_diary': '일기를 불러오는 중 오류가 발생했습니다',
      'diary_detail_title': '일기 상세',
      'diary_not_found': '일기를 찾을 수 없습니다',
      'written_label': '작성:',
      'last_modified_label': '마지막 수정:',
      'no_ai_image_available': 'AI가 그린 이미지가 없습니다',
      'todays_emotion_label': '오늘의 감정:',
      'written_date_label': '작성일:',
      'hashtag_ai_diary': '#AI그림일기 #감정일기',
      'delete_diary_title': '일기 삭제',
      'delete_diary_confirmation': '정말로 이 일기를 삭제하시겠습니까?\n삭제된 일기는 복구할 수 없습니다.',
      'diary_deleted_success': '일기가 삭제되었습니다',
      'diary_delete_error': '삭제 중 오류가 발생했습니다',
      'delete_failed': '삭제 실패',
      'generating': '생성 중...',
      'regeneration_complete': '재생성 완료',
      'edit': '수정',
      'create_ai_diary_button': 'AI 일기 생성',
      'ai_generated_badge': 'AI 생성',
      'user_photo_badge': '내 사진',

      // Common buttons and dialogs
      'delete': '삭제',
      'retry': '다시 시도',
      'search': '검색',
      'ai_drawn_image': 'AI가 그린 이미지',

      // Emotion names
      'emotion_all': '전체',

      // Progress messages
      'photo_mood_analyzing': '사진 분위기 분석 중...',
      'photo_analyzing': '사진 분석 중...',

      // Diary create/edit
      'create_new_diary': '새 일기 작성',
      'title_label': '제목',
      'content_label': '내용',
      'max_3_photos': '최대 3장',
      '1_photo': '1장',
      'please_select_photo': '사진을 선택해보세요',
      'max_3_photos_upload': '최대 3장까지 업로드 가능',
      'free_version_1_photo_only': '무료 버전: 1장만 선택 가능',
      'load_failed': '로드 실패',
      'save_failed': '저장 실패',
      'generated_image': '생성된 이미지',
      'cannot_load_image': '이미지를 불러올 수 없습니다',
      'image_regenerated_success': '그림이 재생성되어 저장되었습니다',
      'image_regeneration_failed': '그림 재생성 실패',
      'really_delete_diary': '정말로 이 일기를 삭제하시겠습니까?',

      // Diary list
      'ad_free_unlimited': '광고 없이 무제한으로 일기를 작성하세요',
      'upgrade_to_premium_unlimited': '프리미엄으로 무제한 생성',

      // Premium dialog
      'feature_requires_premium': '은(는) 프리미엄 사용자만 사용할 수 있습니다.',
      'this_feature_requires_premium': '이 기능은 프리미엄 사용자만 사용할 수 있습니다.',

      // Emotion stats
      'emotion_stats': '감정 통계',
      'weekly': '주별',
      'monthly': '월별',
      'yearly': '연간',
      'no_diaries_in_period': '이 기간에 작성된 일기가 없습니다.',
      'weekly_emotion_insight': '주간 감정 인사이트',
      'monthly_emotion_insight': '월간 감정 인사이트',
      'main_emotion': '주요 감정',
      'diary_frequency': '일기 작성 빈도',
      'emotion_diversity': '감정 다양성',
      'times_recorded': '번 기록됨',
      'diaries_count': '편',
      'daily_avg': '하루 평균',
      'diverse_emotions': '다양한 감정을 경험하셨네요',
      'types': '가지',

      // Premium subscription
      'make_diary_special': '당신의 일기를 더욱 특별하게',
      'premium_features': '프리미엄 기능',
      'ad_removal': '광고 제거',
      'ad_removal_desc': '모든 광고 없이\n쾌적한 일기 작성 경험',
      'premium_fonts': '프리미엄 글꼴',
      'premium_fonts_desc': '10가지 아름다운 한글 글꼴\n개구쟁이체, 독도체, 나눔손글씨 펜 등',
      'premium_art_styles': '프리미엄 아트 스타일',
      'premium_art_styles_desc': '6가지 추가 스타일\n일러스트, 스케치, 애니메이션, 인상파, 빈티지',
      'advanced_image_options': '고급 이미지 옵션',
      'advanced_image_options_desc': '조명, 분위기, 색상, 구도 등\n세밀한 이미지 생성 설정',
      'time_weather_season_settings': '시간대/날씨/계절 설정',
      'time_weather_season_settings_desc': '아침, 저녁, 비오는 날, 봄 등\n상황에 맞는 이미지 생성',
      'photo_upload_max_3': '사진 업로드 (최대 3장)',
      'photo_upload_max_3_desc': '내 사진을 바탕으로\nAI 이미지 생성 가능',
      'cloud_backup_auto': '클라우드 백업 & 자동 백업',
      'cloud_backup_auto_desc': 'Google Drive 자동 백업\n소중한 일기를 안전하게 보관',
      'unlimited_image_generation': '무제한 이미지 생성',
      'unlimited_image_generation_desc': '하루 3개 제한 없이\n무제한으로 일기 생성 가능',
      'subscription_options': '구독 옵션',
      'monthly_subscription': '월간 구독',
      'yearly_subscription': '연간 구독',
      'lifetime_subscription': '평생 구독',
      'all_premium_features': '모든 프리미엄 기능',
      'cancel_anytime': '언제든지 취소 가능',
      'lifetime_access': '평생 사용 가능',
      'one_time_payment': '단 한 번의 결제',
      'best_value': '최고의 가치',
      'popular': '인기',
      'currently_subscribed': '현재 구독 중',
      'subscribe': '구독하기',
      'subscription_footer': '• 구독은 언제든지 취소할 수 있습니다\n• 취소 시 다음 결제일까지 프리미엄 기능을 사용할 수 있습니다\n• 자동 갱신은 결제일 24시간 전에 취소할 수 있습니다',
      'already_premium': '이미 프리미엄 사용자입니다',
      'test_mode_message': '구독을 진행하시겠습니까?\n\n테스트 모드에서는 실제 결제 없이 프리미엄 기능을 바로 사용할 수 있습니다.',
      'subscription_completed': '구독이 완료되었습니다!',
      'subscribe_test': '구독하기 (테스트)',

      // Date formats
      'date_format_full': 'yyyy년 M월 d일 EEEE',
      'date_format_month': 'yyyy년 M월',
    },
    'ja': {
      // Search
      // Navigation & UI
      // Settings dialog content

      // Delete settings screen
      // Subscription management
      // Image styles
      
      // Advanced options

      // AI Prompts
      // Settings screen
      // Personalization settings screen
      // AI settings screen

      // Backup and restore screen
      // Diary detail screen
    },
    'en': {
      'app_title': 'ArtDiary AI',
      'settings': 'Settings',
      'personalization': 'Personalization',
      'theme': 'Theme',
      'theme_subtitle': 'Change app theme',
      'language': 'Language',
      'language_subtitle': 'Change app language',
      'font_size': 'Font Size',
      'font_size_subtitle': 'Adjust diary text size',
      'notifications': 'Notifications',
      'notifications_subtitle': 'Set diary writing reminders',
      'ai_settings': 'AI Settings',
      'default_image_style': 'Default Image Style',
      'default_image_style_subtitle': 'Default image style for new diary',
      'ai_analysis_strength': 'AI Analysis Strength',
      'ai_analysis_strength_subtitle': 'Emotion and keyword analysis accuracy',
      'ai_image_guide': 'AI Image Guide',
      'ai_image_guide_subtitle': 'Effective prompt writing tips and tricks',
      'data_privacy': 'Data & Privacy',
      'data_backup': 'Data Backup',
      'data_backup_subtitle': 'Backup your diary data',
      'data_restore': 'Data Restore',
      'data_restore_subtitle': 'Restore backed up diary data',
      'delete_all_data': 'Delete All Data',
      'delete_all_data_subtitle': 'Delete all diary data',
      'premium': 'Premium',
      'premium_upgrade': 'Premium Upgrade',
      'premium_upgrade_subtitle': 'Unlimited images • Premium styles • Ad-free',
      'app_info': 'App Information',
      'app_version': 'App Version',
      'privacy_policy': 'Privacy Policy',
      'terms_of_service': 'Terms of Service',
      'cancel': 'Cancel',
      'confirm': 'OK',
      'close': 'Close',
      'save': 'Save',
      'back': 'Back',
      // Calendar screen
      'refresh': 'Refresh',
      'today': 'Today',
      'no_diary_on_date': 'No diary written on this date',
      'write_diary': 'Write Diary',
      'cannot_load_calendar': 'Cannot load calendar',
      'cannot_load_diary': 'Cannot load diary',
      'tags_count': ' tags',
      // Diary create screen
      'new_diary': 'New Diary',
      'edit_diary': 'Edit Diary',
      'title': 'Title',
      'title_hint': 'Enter today\'s title',
      'diary_content': 'Diary Content',
      'diary_content_hint': 'Write freely about what happened today and your feelings.\nAI will turn your story into a beautiful picture.',
      'please_enter_title': 'Please enter a title',
      'please_enter_content': 'Please enter diary content',
      'content_too_short': 'Please write more details (minimum 10 characters)',
      'image_style': 'Image Style',
      'ai_drawing_complete': 'Saved! AI Drawing',
      'ai_drawing': 'AI Drawing',
      'generate_image': 'Generate Image',
      'generating_image': 'AI is drawing your story\nin {style} style...',
      'please_wait': 'Please wait',
      'saving': 'Saving...',
      'saved_successfully': 'Saved Successfully',
      'diary_saved': 'Diary has been saved',
      'diary_updated': 'Diary has been updated',
      'image_generation_error': 'Error occurred while generating image: {error}',
      'save_error': 'Error occurred while saving: {error}',
      'failed_to_load_diary': 'Failed to load diary: {error}',
      'analyzing_photo': 'Analyzing photo...',
      'analyzing_emotion': 'Analyzing emotion...',
      'extracting_keywords': 'Extracting keywords...',
      'generating_prompt': 'Generating image prompt...',
      'generating_ai_image_notice': 'Generating AI image...\n\n(Wait time may be longer when there are many users)',
      'diary_saved_successfully': 'Diary saved successfully!',
      'image_gallery': 'Image Gallery',
      'photo_upload': 'Photo Upload',
      'select_photo': 'Select Photo',
      'my_photo': 'My Photo',
      'edit_diary_only': 'Edit Diary Only',
      'edit_image_and_diary': 'Edit Image + Diary',
      'photo_upload_and_gallery': 'Photo Upload & Gallery',
      'photo_select_failed': 'Photo selection failed: {error}',
      // Login screen
      'login_title': 'ArtDiary AI',
      'login_description': 'AI-powered emotional diary with beautiful artwork',
      'login_tagline': 'Transform your precious moments\ninto beautiful artwork with AI',
      'start_with_google': 'Start with Google',
      'continue_as_guest': 'Continue as Guest',
      'welcome_user': 'Welcome, {name}!',
      'user': 'User',
      'google_login_failed': 'Google login failed: {error}',
      'guest_login_message': 'Starting as Guest (data will only be saved on this device)',
      'login_failed': 'Login failed: {error}',
      // Emotions
      'emotion_happy': 'Happy',
      'emotion_sad': 'Sad',
      'emotion_angry': 'Angry',
      'emotion_excited': 'Excited',
      'emotion_peaceful': 'Peaceful',
      'emotion_anxious': 'Anxious',
      'emotion_grateful': 'Grateful',
      'emotion_nostalgic': 'Nostalgic',
      'emotion_romantic': 'Romantic',
      'emotion_frustrated': 'Frustrated',
      'emotion_normal': 'Normal',
      'all_emotions': 'All',
      'error_occurred_general': 'An error occurred',
      'retry_button': 'Retry',
      'search_button': 'Search',
      'ai_generated_image_placeholder': 'AI Generated Image',
      // Premium features
      'premium_feature': 'Premium Feature',
      'upgrade_to_premium': 'Upgrade to Premium',
      'free_user_limit': 'Free users cannot modify images',
      'image_modification_limit': 'Image modification limit exceeded',
      'regenerate_image': 'Regenerate Image',
      'keep_existing_image': 'Keep Existing Image',
      'image_modification_dialog_title': 'Image Modification',
      'image_modification_dialog_content': 'You have modified the diary content.\nWould you like to regenerate the image to match the new content?',
      'remaining_generations': 'Remaining generations: {count}',
      'remaining_modifications': 'Remaining modifications: {count}',
      'unlimited': 'Unlimited',
      // Search
      'search_hint': 'Enter content to search',
      'search_label': 'Search',
      'no_entries': 'No diary entries yet',
      'create_first_entry': 'Create your first diary entry!',
      'empty_search': 'No search results found',
      'try_different_keyword': 'Try searching with different keywords',
      // Navigation & UI
      'diary_list': 'Diary List',
      'calendar': 'Calendar',
      'diary_search': 'Diary Search',
      'start_with_ai_diary': 'Start your special diary with AI-generated pictures',
      'calendar_load_error': 'Failed to load calendar',
      // Settings dialog content
      'theme_selection': 'Theme Selection',
      'light_theme': 'Light Theme',
      'dark_theme': 'Dark Theme',
      'system_theme': 'System Settings',
      'font_size_setting': 'Font Size Settings',
      'font_size_description': 'Select the size of diary text',
      'font_small': 'Small',
      'font_medium': 'Medium',
      'font_large': 'Large',
      'font_xlarge': 'Extra Large',
      'font_size_changed': 'Font size has been set to "{size}".',
      'notification_settings': 'Notification Settings',
      'notification_description': 'Get notifications so you don\'t miss writing your diary.',
      'daily_reminder': 'Daily Reminder',
      'daily_reminder_time': 'Daily notification at 9 PM',
      'weekly_summary': 'Weekly Summary',
      'weekly_summary_time': 'Every Sunday at 10 AM',
      'notification_enabled': 'Notifications have been enabled.',
      'notification_disabled': 'Notifications have been disabled.',
      'weekly_notification_enabled': 'Weekly summary notifications have been enabled.',
      'weekly_notification_disabled': 'Weekly summary notifications have been disabled.',
      'premium_upgrade_title': 'Premium Upgrade',
      'premium_benefits': 'Upgrade to Premium for:',
      'unlimited_ai_images': 'Unlimited AI Image Generation',
      'advanced_image_styles': '50+ Advanced Image Styles',
      'no_ads': 'Complete Ad Removal',
      'cloud_backup': 'Automatic Cloud Backup',
      'advanced_security': 'Advanced Security Features',
      'later': 'Later',
      'monthly_price': 'Monthly ₩4,900',
      'premium_coming_soon': 'Premium subscription coming soon!',
      'default_image_style_setting': 'Default Image Style Settings',
      'image_style_description': 'Set the default image style for new diary entries.',
      'default_style_set': 'Default style has been set to "{style}".',
      'data_backup_title': 'Data Backup',
      'backup_description': 'Backup all diary data as a JSON file.',
      'backup_includes': 'Includes:',
      'backup_diary_content': 'Diary titles and content',
      'backup_date_time': 'Creation dates and times',
      'backup_emotion_analysis': 'Emotion analysis results',
      'backup_generated_images': 'Generated images (Base64)',
      'backup_image_style': 'Image style information',
      'backup_start': 'Start Backup',
      'backing_up': 'Backing up...',
      'ok': 'OK',
      'last_backup_time_format': 'Last backup: {time}',
      'error_format': 'Error: {error}',
      'auto_cloud_backup_feature': 'Auto Cloud Backup',
      'upgrade_for_auto_backup': 'Upgrade to premium for auto backup feature',
      'cloud_backup_feature': 'Cloud Backup',
      'cloud_backup_to_google_drive': 'Backup your diary to Google Drive',
      'premium_feature_short': 'Premium only feature',
      'cloud_restore_feature': 'Cloud Restore',
      'cloud_restore_from_google_drive': 'Restore your diary from Google Drive',
      'cloud_backup_restore_feature': 'Cloud Backup/Restore',
      'upgrade_for_cloud_backup_restore': 'Upgrade to premium for cloud backup/restore features',
      'backup_complete': 'Backup complete',
      'backup_completed': 'Backup complete! {count} diary entries have been backed up.',
      'backup_failed': 'Backup failed: {error}',
      'last_backup_time': 'Last backup: {time}',
      'error_occurred': 'Error: {error}',
      'auto_cloud_backup': 'Auto Cloud Backup',
      'simple_cloud_backup': 'Cloud Backup',
      'simple_cloud_restore': 'Cloud Restore',
      'cloud_backup_and_restore': 'Cloud Backup/Restore',
      'upgrade_for_cloud_features': 'Upgrade to premium for cloud backup/restore features',
      'data_restore_title': 'Data Restore',
      'restore_description': 'Restore backed up diary data.',
      'restore_start': 'Start Restore',
      'delete_all_title': 'Delete All Data',
      'delete_all_warning': 'Are you sure you want to delete all diary data?\nThis action cannot be undone.',
      'delete_all_confirm': 'Delete All Data',

      // Delete settings screen
      'warning_notice': 'Warning Notice',
      'delete_warning_message': '• All diary entries will be permanently deleted\n• Deleted data cannot be recovered\n• We strongly recommend backing up before deletion',
      'clear_cache': 'Clear Cache',
      'clear_cache_description': 'Delete stored image cache to free up storage space',
      'cache_zero': '0 MB',
      'calculation_failed': 'Calculation Failed',
      'clear_cache_confirm_message': 'Would you like to delete the image cache?\n\nCurrent cache size: {size}\n\nNote: Diary data will not be deleted,\nand images will be regenerated when needed.',
      'clearing_cache': 'Clearing cache...',
      'cache_deleted_success': 'Cache successfully deleted',
      'cache_delete_error': 'An error occurred while deleting cache',
      'delete_button': 'Delete',
      'all_data_deleted': 'All data has been deleted',
      'delete_error_format': 'An error occurred during deletion: {error}',
      'app_info_subtitle': 'App version, Privacy policy',
      'app_name': 'ArtDiary AI',
      'app_description': 'Special picture diary app drawn by AI',
      'privacy_policy_title': 'Privacy Policy',
      'privacy_policy_content': '''ArtDiary AI Privacy Policy

Last Updated: January 2025

1. Information We Collect
• Diary content and titles
• AI-generated images
• Emotion analysis data
• Device identification information (anonymous)

2. Purpose of Information Use
• Providing diary creation and management services
• AI image generation and emotion analysis
• App performance improvement and bug fixes
• User experience enhancement

3. Information Storage and Security
• All data is securely stored on your device
• Cloud backup is only activated when selected by users
• Data encryption and security measures are applied

4. Third-Party Disclosure
• We do not provide information to third parties without user consent
• Google Gemini API is used for AI services
• Google AdMob is used for advertising

5. User Rights
• Request data deletion at any time
• Right to view and modify personal information
• Ability to withdraw service usage consent

6. Contact
For inquiries regarding personal information, please use the in-app contact feature.

This policy may be amended in accordance with relevant laws and service policy changes.''',
      'terms_title': 'Terms of Service',
      'terms_content': '''ArtDiary AI Terms of Service

Last Updated: January 2025

1. Service Usage
• This app is an AI-based picture diary service
• Intended for users aged 14 and above
• Creation of illegal or inappropriate content is prohibited

2. User Obligations
• Providing accurate information
• Prohibition of infringing others\' rights
• Prohibition of service abuse or misuse
• Compliance with applicable laws

3. Service Provision
• AI image generation feature
• Diary creation and management features
• Emotion analysis and statistics features
• Free and premium services

4. Premium Services
• Monthly or annual subscription offerings
• Unlimited AI image generation
• Advanced features and font usage
• Ad removal

5. Service Interruption and Changes
• Service may be temporarily suspended during system maintenance
• Service content may be changed after prior notice
• May be immediately suspended in unavoidable circumstances

6. Disclaimer
• Quality of AI-generated content is not guaranteed
• No liability for data loss due to user device issues
• No liability for service interruption due to network failures

7. Intellectual Property Rights
• Diary content created by users belongs to the users
• Usage rights of AI-generated images belong to the users
• Copyrights of app design and code belong to the developer

8. Termination
• Users may discontinue service usage at any time
• Service usage may be restricted in case of terms violation

These terms are governed by and interpreted in accordance with the laws of the Republic of Korea.''',
      'privacy_policy_subtitle': 'Review the privacy policy',
      'terms_subtitle': 'Review the terms of service',
      // Subscription management
      'subscription_management_test': 'Subscription Management (Test)',
      'premium_user': 'Premium User',
      'free_user': 'Free User',
      'image_generations': 'Image Generations',
      'image_modifications': 'Image Modifications',
      'set_to_free': 'Set to free user',
      'set_to_premium': 'Set to premium',
      'set_free_plan': 'Set to Free',
      'set_premium_plan': 'Set to Premium',
      // Image styles
      'style_auto': 'Auto Select',
      'style_realistic': 'Realistic Style',
      'style_watercolor': 'Watercolor Style',
      'style_illustration': 'Illustration Style',
      'style_sketch': 'Sketch Style',
      'style_anime': 'Animation Style',
      'style_impressionist': 'Impressionist',
      'style_vintage': 'Vintage Style',
      
      // Advanced options
      'advanced_options': 'Advanced Options',
      'lighting': 'Lighting',
      'mood': 'Mood',
      'color': 'Color',
      'composition': 'Composition',
      'none': 'None',
      'clear_all_options': 'Auto Select',

      // AI Prompts
      'ai_emotion_analysis_prompt': '''Please analyze the main emotion of the following diary entry.
Possible emotions: happy, sad, angry, excited, peaceful, anxious, grateful, nostalgic, romantic, frustrated
Please respond with only one emotion.

Diary content: {content}''',
      'ai_photo_analysis_prompt': '''Please analyze these photos and extract the following information:
- Overall mood and feeling
- Main colors and tones
- Time of day (morning, afternoon, evening, night)
- Location and environment (indoor/outdoor, urban/nature, etc.)
- Main subjects or objects

Please summarize in 2-3 sentences.''',
      'ai_image_prompt_base': '''Please create an image generation prompt based on the following diary entry.
Style: {style}
Create an emotional and beautiful image.

Diary content: {content}
Main emotion: {emotion}
Keywords: {keywords}
{advanced}

Write the prompt in English, creating a warm and emotional image that expresses the diary's emotion and content well.
Include specific visual elements, colors, and atmosphere.''',
      'ai_advanced_option_prefix': 'Advanced options: {options}',
      'ai_auto_settings_prompt': '''Please analyze the following diary entry and recommend suitable settings for image generation.
Respond in JSON format:

{{
  "lighting": "one of: natural|dramatic|warm|cool|sunset|night",
  "mood": "one of: peaceful|energetic|romantic|mysterious|joyful|melancholic",
  "color": "one of: vibrant|pastel|monochrome|warm|cool|earthy",
  "composition": "one of: centered|rule_of_thirds|symmetrical|dynamic|minimalist"
}}

Diary content: {content}

Please select the most appropriate settings by comprehensively considering the diary's mood, emotion, time of day, weather, and situation.''',
      'ai_emotion_insight_system': '''You are a kind and empathetic counseling psychologist.
Please analyze the user's {period} diary data and provide emotional patterns and insights.

Diary data:
{diaries}

Please write insights following these guidelines:
1. Write concisely in 3-4 sentences
2. Use a positive and empathetic tone
3. Include observations about emotional patterns or changes
4. Include practical advice or encouraging messages
5. Use a warm and friendly tone

Output only the insights, no other explanations needed.''',
      'ai_default_insight': 'You have experienced various emotions this {period}. Recognizing and recording your emotions is meaningful in itself.',
      'ai_fallback_insight': 'Thank you for recording your emotional journey during this period.',
      // Settings screen
      'personalization_subtitle': 'Language, font, and date format settings',
      'ai_settings_subtitle': 'Image style and AI guide settings',
      'backup_and_restore': 'Backup & Restore',
      'delete_data': 'Delete Data',
      'delete_data_description': 'Delete all diary data',
      'premium_upgrade_description': 'Unlimited access without ads',
      'unlimited_with_premium': 'Unlimited with Premium',
      'test_mode': 'Test Mode',
      'current_premium_user': 'Current: Premium User',
      'current_free_user': 'Current: Free User',
      'switched_to_premium': 'Switched to Premium User',
      'switched_to_free': 'Switched to Free User',
      'free': 'Free',
      'logout_to_login_screen': 'Logout (Return to Login Screen)',
      'logout': 'Logout',
      'return_to_login_confirmation': 'Return to login screen?',
      // Personalization settings screen
      'font': 'Font',
      'select_font_description': 'Select the font for diary writing',
      'date_format': 'Date Format',
      'select_date_format_description': 'Select date display format',
      'timezone': 'Timezone',
      'select_timezone_description': 'Select timezone',
      'select_font': 'Select Font',
      'premium_only_font': 'Premium Only Font',
      'select_date_format': 'Select Date Format',
      'date_format_ymd': 'Year/Month/Day (2024/12/25)',
      'date_format_dmy': 'Day/Month/Year (25/12/2024)',
      'date_format_mdy': 'Month/Day/Year (12/25/2024)',
      'date_format_changed': 'Date format changed',
      'select_timezone': 'Select Timezone',
      'timezone_changed_format': 'Timezone changed to {name}',
      'timezone_seoul': 'Seoul (KST)',
      'timezone_tokyo': 'Tokyo (JST)',
      'timezone_beijing': 'Beijing (CST)',
      'timezone_new_york': 'New York (EST)',
      'timezone_los_angeles': 'Los Angeles (PST)',
      'timezone_london': 'London (GMT)',
      'timezone_paris': 'Paris (CET)',
      // AI settings screen
      'auto_advanced_settings': 'Auto Advanced Settings',
      'premium_only_feature': 'Premium Only Feature',
      'auto_advanced_settings_description': 'Automatically sets time, weather, and season options',
      'auto_advanced_settings_enabled': 'Auto Advanced Settings enabled',
      'auto_advanced_settings_disabled': 'Auto Advanced Settings disabled',
      'premium_styles_available_format': '{count} additional styles are available in Premium',

      // Backup and restore screen
      'auto_backup': 'Auto Backup',
      'local_backup_restore': 'Local Backup/Restore',
      'cloud_backup_restore': 'Cloud Backup/Restore',
      'free_user_backup_description': 'Free users can backup diary titles, content, and dates in JSON format.',
      'premium_backup_description': 'Premium: Includes emotion analysis, generated images, AI prompts',
      'select_backup_location': 'Select backup file save location',
      'backup_canceled': 'Backup canceled',
      'restore_warning': 'All currently saved data will be deleted\nand replaced with the backup file',
      'select_file': 'Select file',
      'restoring': 'Restoring...',
      'no_restored_diaries': 'No diaries restored',
      'restore_failed_format': 'Restore failed: {error}',
      'included_content': 'Included content:',
      'all_diary_content': 'All diary content',
      'emotion_analysis_result': 'Emotion analysis result',
      'generated_images_base64': 'Generated images (base64)',
      'image_style_and_settings': 'Image style and settings',
      'uploaded_photos': 'Uploaded photos',
      'existing_backup_warning': 'Existing backup will be overwritten',
      'premium_backup_success_format': '{count} diaries fully backed up',
      'backup_success_format': '{count} diaries backed up',
      'cancel_file_selection_hint': 'You can cancel anytime using the\nback button on the file selection screen',
      'restore_success_format': '{count} diaries restored',
      'google_drive_backup': 'Google Drive Backup',
      'google_drive_backup_description': 'Safely backup your diary data to Google Drive.',
      'start_backup': 'Start Backup',
      'login_required_message': 'Login required.\nPlease log in to the app first.',
      'backing_up_to_google_drive': 'Backing up to Google Drive...',
      'backup_complete_test_mode': 'Backup Complete (Test Mode)',
      'backing_up_to_cloud': 'Backing up to cloud...',
      'cloud_backup_complete': 'Cloud backup completed',
      'cloud_backup_failed': 'Cloud backup failed',
      'cloud_backup_error_format': 'Cloud backup error: {error}',
      'login_required_title': 'Login Required',
      'cloud_restore_login_message': 'Please log in to the app first to use cloud restore.',
      'test_restore_title': '[Test] Restore',
      'test_mode_restore_simulation': 'Simulating restore in test mode.',
      'real_environment_google_drive_restore': 'In real environment, restores from Google Drive.',
      'start_button': 'Start',
      'no_backup_title': 'No Backup',
      'no_cloud_backup_message': 'No backup saved to cloud.\nPlease create a backup first.',
      'cloud_restore_title': 'Cloud Restore',
      'restore_from_firebase': 'Restore diary data from Firebase.',
      'all_data_will_be_replaced': 'All currently saved data will be deleted\nand replaced with cloud backup data',
      'cancel_button': 'Cancel',
      'start_restore_button': 'Start Restore',
      'restoring_from_cloud': 'Restoring from cloud...',
      'cloud_restore_failed': 'Cloud restore failed',
      'cloud_restore_error_format': 'Cloud restore error: {error}',
      'restore_complete_test_mode': 'Restore complete (Test Mode)',
      'cloud_backup_restore_premium_only': 'Cloud backup/restore is available to premium users only.',
      'auto_backup_every_5_minutes': 'Automatic backup every 5 minutes',
      'auto_backup_enabled': 'Auto backup has been enabled',
      'auto_backup_disabled': 'Auto backup has been disabled',
      // Diary detail screen
      'error_loading_diary': 'An error occurred while loading the diary',
      'diary_detail_title': 'Diary Details',
      'diary_not_found': 'Diary not found',
      'written_label': 'Written:',
      'last_modified_label': 'Last modified:',
      'no_ai_image_available': 'No AI generated image available',
      'todays_emotion_label': 'Today\'s emotion:',
      'written_date_label': 'Written date:',
      'hashtag_ai_diary': '#AIDiary #EmotionDiary',
      'delete_diary_title': 'Delete Diary',
      'delete_diary_confirmation': 'Are you sure you want to delete this diary?\nDeleted diaries cannot be recovered.',
      'diary_deleted_success': 'Diary has been deleted',
      'diary_delete_error': 'An error occurred during deletion',
      'delete_failed': 'Delete Failed',
      'generating': 'Generating...',
      'regeneration_complete': 'Regeneration Complete',
      'edit': 'Edit',
      'create_ai_diary_button': 'Create AI Diary',
      'ai_generated_badge': 'AI Generated',
      'user_photo_badge': 'My Photo',

      // Common buttons and dialogs
      'delete': 'Delete',
      'retry': 'Retry',
      'search': 'Search',

      // Emotion names
      'emotion_all': 'All',

      // Progress messages
      'photo_mood_analyzing': 'Analyzing photo mood...',
      'photo_analyzing': 'Analyzing photo...',

      // Diary create/edit
      'create_new_diary': 'Create New Diary',
      'title_label': 'Title',
      'content_label': 'Content',
      'max_3_photos': 'Max 3',
      '1_photo': '1 Photo',
      'please_select_photo': 'Please select a photo',
      'max_3_photos_upload': 'Upload up to 3 photos',
      'free_version_1_photo_only': 'Free version: 1 photo only',
      'load_failed': 'Load Failed',
      'save_failed': 'Save Failed',
      'generated_image': 'Generated Image',
      'cannot_load_image': 'Cannot load image',
      'image_regenerated_success': 'Image regenerated and saved successfully',
      'image_regeneration_failed': 'Image regeneration failed',
      'really_delete_diary': 'Are you sure you want to delete this diary?',

      // Diary list
      'ai_drawn_image': 'AI Drawn Image',
      'ad_free_unlimited': 'Write unlimited diaries without ads',
      'upgrade_to_premium_unlimited': 'Upgrade to Premium for Unlimited',

      // Premium dialog
      'feature_requires_premium': 'is available for premium users only.',
      'this_feature_requires_premium': 'This feature is available for premium users only.',

      // Emotion stats
      'emotion_stats': 'Emotion Statistics',
      'weekly': 'Weekly',
      'monthly': 'Monthly',
      'yearly': 'Yearly',
      'no_diaries_in_period': 'No diaries written in this period.',
      'weekly_emotion_insight': 'Weekly Emotion Insight',
      'monthly_emotion_insight': 'Monthly Emotion Insight',
      'main_emotion': 'Main Emotion',
      'diary_frequency': 'Diary Frequency',
      'emotion_diversity': 'Emotion Diversity',
      'times_recorded': 'times recorded',
      'diaries_count': 'diaries',
      'daily_avg': 'Daily Average',
      'diverse_emotions': 'You experienced diverse emotions',
      'types': 'types',

      // Premium subscription
      'make_diary_special': 'Make Your Diary More Special',
      'premium_features': 'Premium Features',
      'ad_removal': 'Ad Removal',
      'ad_removal_desc': 'Enjoy a pleasant\ndiary writing experience\nwithout any ads',
      'premium_fonts': 'Premium Fonts',
      'premium_fonts_desc': '10 beautiful Korean fonts\nGaegujaengi, Dokdo, Nanum Pen, etc.',
      'premium_art_styles': 'Premium Art Styles',
      'premium_art_styles_desc': '6 additional styles\nIllustration, Sketch, Animation, Impressionist, Vintage',
      'advanced_image_options': 'Advanced Image Options',
      'advanced_image_options_desc': 'Lighting, mood, color, composition, etc.\nDetailed image generation settings',
      'time_weather_season_settings': 'Time/Weather/Season Settings',
      'time_weather_season_settings_desc': 'Morning, evening, rainy day, spring, etc.\nSituation-appropriate image generation',
      'photo_upload_max_3': 'Photo Upload (Max 3)',
      'photo_upload_max_3_desc': 'Generate AI images\nbased on your photos',
      'cloud_backup_auto': 'Cloud Backup & Auto Backup',
      'cloud_backup_auto_desc': 'Google Drive auto backup\nKeep your precious diaries safe',
      'unlimited_image_generation': 'Unlimited Image Generation',
      'unlimited_image_generation_desc': 'No daily limit of 3\nGenerate unlimited diaries',
      'subscription_options': 'Subscription Options',
      'monthly_subscription': 'Monthly Subscription',
      'yearly_subscription': 'Yearly Subscription',
      'lifetime_subscription': 'Lifetime Subscription',
      'all_premium_features': 'All Premium Features',
      'cancel_anytime': 'Cancel Anytime',
      'lifetime_access': 'Lifetime Access',
      'one_time_payment': 'One-Time Payment',
      'best_value': 'Best Value',
      'popular': 'Popular',
      'currently_subscribed': 'Currently Subscribed',
      'subscribe': 'Subscribe',
      'subscription_footer': '• You can cancel your subscription at any time\n• After cancellation, you can use premium features until the next billing date\n• Auto-renewal can be canceled 24 hours before the billing date',
      'already_premium': 'You are already a premium user',
      'test_mode_message': 'Would you like to proceed with the subscription?\n\nIn test mode, you can use premium features immediately without actual payment.',
      'subscription_completed': 'Subscription completed!',
      'subscribe_test': 'Subscribe (Test)',

      // Date formats
      'date_format_full': 'MMMM d, yyyy EEEE',
      'date_format_month': 'MMMM yyyy',
      'confirm_delete_diary': 'Are you sure you want to delete this diary?',
      'delete_diary': 'Delete Diary',
      'diary_deleted': 'Diary has been deleted',
      'free_version1_photo_only': 'Free version: 1 photo only',
      'max3_photos': 'Up to 3 Photos',
      'max3_photos_upload': 'Upload up to 3 photos',
      'onboarding_next': 'Next',
      'onboarding_page1_desc': 'AI turns your diary into art',
      'onboarding_page1_title': 'Welcome',
      'onboarding_page2_desc': 'AI analyzes your diary and identifies emotions',
      'onboarding_page2_title': 'Emotion Analysis',
      'onboarding_page3_desc': 'Decorate your diary with 12 art styles',
      'onboarding_page3_title': 'Various Styles',
      'onboarding_page4_desc': 'Start your AI art diary now',
      'onboarding_page4_title': 'Get Started',
      'onboarding_skip': 'Skip',
      'onboarding_start': 'Start',
      'one_photo': '1 Photo',
      'photo_upload_max3': 'Upload Up to 3 Photos',
      'photo_upload_max3_desc': 'Upload up to 3 photos per diary',
      'sample_diary_content': 'Today was a really good day',
      'sample_diary_title': 'Sample Diary',
    },
    'zh': {
      'app_title': 'ArtDiary AI',
      'settings': '设置',
      'personalization': '个性化设置',
      'theme': '主题',
      'theme_subtitle': '更改应用主题',
      'language': '语言',
      'language_subtitle': '更改应用语言',
      'font_size': '字体大小',
      'font_size_subtitle': '调整日记文本大小',
      'notifications': '通知设置',
      'notifications_subtitle': '设置日记写作提醒',
      'ai_settings': 'AI设置',
      'default_image_style': '默认图像风格',
      'default_image_style_subtitle': '新日记的默认图像风格',
      'ai_analysis_strength': 'AI分析强度',
      'ai_analysis_strength_subtitle': '情感和关键词分析准确度',
      'ai_image_guide': 'AI图像指南',
      'ai_image_guide_subtitle': '有效的提示词编写技巧和窍门',
      'data_privacy': '数据和隐私',
      'data_backup': '数据备份',
      'data_backup_subtitle': '备份您的日记数据',
      'data_restore': '数据恢复',
      'data_restore_subtitle': '恢复备份的日记数据',
      'delete_all_data': '删除所有数据',
      'delete_all_data_subtitle': '删除所有日记数据',
      'premium': '高级版',
      'premium_upgrade': '高级版升级',
      'premium_upgrade_subtitle': '无限图片 • 高级风格 • 无广告',
      'app_info': '应用信息',
      'app_version': '应用版本',
      'privacy_policy': '隐私政策',
      'terms_of_service': '服务条款',
      'cancel': '取消',
      'confirm': '确认',
      'close': '关闭',
      'save': '保存',
      'back': '返回',
      // Calendar screen
      'refresh': '刷新',
      'today': '今天',
      'no_diary_on_date': '这一天没有写日记',
      'write_diary': '写日记',
      'cannot_load_calendar': '无法加载日历',
      'cannot_load_diary': '无法加载日记',
      'tags_count': '个标签',
      // Diary create screen
      'new_diary': '新日记',
      'edit_diary': '编辑日记',
      'title': '标题',
      'title_hint': '输入今天的标题',
      'diary_content': '日记内容',
      'diary_content_hint': '自由地写下今天发生的事情和感受。\nAI将把您的故事变成美丽的图画。',
      'please_enter_title': '请输入标题',
      'please_enter_content': '请输入日记内容',
      'content_too_short': '请写更详细的内容（至少10个字符）',
      'image_style': '图像风格',
      'ai_drawing_complete': '保存完成！AI绘制的图片',
      'ai_drawing': 'AI绘制的图片',
      'generate_image': '生成图像',
      'generating_image': 'AI正在用{style}风格\n将您的故事绘制成图片...',
      'please_wait': '请稍等',
      'saving': '保存中...',
      'saved_successfully': '保存成功',
      'diary_saved': '日记已保存',
      'diary_updated': '日记已更新',
      'image_generation_error': '生成图像时发生错误：{error}',
      'save_error': '保存时发生错误：{error}',
      'failed_to_load_diary': '日记加载失败: {error}',
      'analyzing_photo': '照片分析中...',
      'analyzing_emotion': '情感分析中...',
      'extracting_keywords': '提取关键词中...',
      'generating_prompt': '生成图像提示中...',
      'generating_ai_image_notice': 'AI图像生成中...\n\n(用户较多时等待时间可能会更长)',
      'diary_saved_successfully': '日记保存成功!',
      'image_gallery': '图片库',
      'photo_upload': '照片上传',
      'select_photo': '选择照片',
      'my_photo': '我的照片',
      'edit_diary_only': '仅编辑日记',
      'edit_image_and_diary': '编辑图片+日记',
      'photo_upload_and_gallery': '照片上传及图片库',
      'photo_select_failed': '照片选择失败: {error}',
      // Login screen
      'login_title': 'ArtDiary AI',
      'login_description': 'AI绘制的感动日记',
      'login_tagline': '让AI将您珍贵的每一刻\n变成美丽的画作',
      'start_with_google': '使用Google开始',
      'continue_as_guest': '以访客身份继续',
      'welcome_user': '欢迎，{name}!',
      'user': '用户',
      'google_login_failed': 'Google登录失败：{error}',
      'guest_login_message': '以访客模式开始（数据仅保存在此设备）',
      'login_failed': '登录失败：{error}',
      // Emotions
      'emotion_happy': '快乐',
      'emotion_sad': '悲伤',
      'emotion_angry': '愤怒',
      'emotion_excited': '兴奋',
      'emotion_peaceful': '平静',
      'emotion_anxious': '焦虑',
      'emotion_grateful': '感激',
      'emotion_nostalgic': '怀念',
      'emotion_romantic': '浪漫',
      'emotion_frustrated': '沮丧',
      'emotion_normal': '正常',
      'all_emotions': '全部',
      'error_occurred_general': '发生错误',
      'retry_button': '重试',
      'search_button': '搜索',
      'ai_generated_image_placeholder': 'AI生成的图像',
      // Premium features
      'premium_feature': '高级功能',
      'upgrade_to_premium': '升级到高级版',
      'free_user_limit': '免费用户无法修改图像',
      'image_modification_limit': '超出图像修改限制',
      'regenerate_image': '重新生成图像',
      'keep_existing_image': '保持现有图像',
      'image_modification_dialog_title': '图像修改',
      'image_modification_dialog_content': '您已修改了日记内容。\n是否重新生成图像以匹配新内容？',
      'remaining_generations': '剩余生成次数：{count}次',
      'remaining_modifications': '剩余修改次数：{count}次',
      'unlimited': '无限',
      // Search
      'search_hint': '输入搜索内容',
      'search_label': '搜索',
      'no_entries': '还没有日记条目',
      'create_first_entry': '创建您的第一篇日记吧！',
      'empty_search': '没有找到搜索结果',
      'try_different_keyword': '尝试使用其他关键词搜索',
      // Navigation & UI
      'diary_list': '日记列表',
      'calendar': '日历',
      'diary_search': '日记搜索',
      'start_with_ai_diary': '开始您的AI绘图日记之旅',
      'refresh': '刷新',
      'calendar_load_error': '无法加载日历',
      // Settings dialog content
      'theme_selection': '主题选择',
      'light_theme': '浅色主题',
      'dark_theme': '深色主题',
      'system_theme': '系统设置',
      'font_size_setting': '字体大小设置',
      'font_size_description': '选择日记文本的大小',
      'font_small': '小',
      'font_medium': '中',
      'font_large': '大',
      'font_xlarge': '特大',
      'font_size_changed': '字体大小已设置为“{size}”。',
      'notification_settings': '通知设置',
      'notification_description': '获取通知，以免错过写日记。',
      'daily_reminder': '日常提醒',
      'daily_reminder_time': '每日晚上9点通知',
      'weekly_summary': '周度总结',
      'weekly_summary_time': '每周日上午10点',
      'notification_enabled': '通知已启用。',
      'notification_disabled': '通知已禁用。',
      'weekly_notification_enabled': '周度总结通知已启用。',
      'weekly_notification_disabled': '周度总结通知已禁用。',
      'premium_upgrade_title': '高级版升级',
      'premium_benefits': '升级到高级版可以享受：',
      'unlimited_ai_images': '无限AI图像生成',
      'advanced_image_styles': '50+高级图像风格',
      'no_ads': '完全无广告',
      'cloud_backup': '自动云备份',
      'advanced_security': '高级安全功能',
      'later': '稍后',
      'monthly_price': '月付￥4,900',
      'premium_coming_soon': '高级版订阅即将推出！',
      'default_image_style_setting': '默认图像风格设置',
      'image_style_description': '设置新日记的默认图像风格。',
      'default_style_set': '默认风格已设置为“{style}”。',
      'data_backup_title': '数据备份',
      'backup_description': '将所有日记数据备份为JSON文件。',
      'backup_includes': '包含内容：',
      'backup_diary_content': '日记标题和内容',
      'backup_date_time': '创建日期和时间',
      'backup_emotion_analysis': '情感分析结果',
      'backup_generated_images': '生成的图像 (Base64)',
      'backup_image_style': '图像风格信息',
      'backup_start': '开始备份',
      'backing_up': '备份中...',
      'ok': '确认',
      'last_backup_time_format': '最后备份：{time}',
      'error_format': '错误：{error}',
      'auto_cloud_backup_feature': '自动云备份',
      'upgrade_for_auto_backup': '升级至高级版以使用自动备份功能',
      'cloud_backup_feature': '云备份',
      'cloud_backup_to_google_drive': '将日记备份到Google Drive',
      'premium_feature_short': '高级版专属功能',
      'cloud_restore_feature': '云恢复',
      'cloud_restore_from_google_drive': '从Google Drive恢复日记',
      'cloud_backup_restore_feature': '云备份/恢复',
      'upgrade_for_cloud_backup_restore': '升级至高级版以使用云备份/恢复功能',
      'backup_complete': '备份完成',
      'backup_completed': '备份完成！共备份了{count}篇日记。',
      'backup_failed': '备份失败：{error}',
      'last_backup_time': '最后备份：{time}',
      'error_occurred': '错误：{error}',
      'auto_cloud_backup': '自动云备份',
      'simple_cloud_backup': '云备份',
      'simple_cloud_restore': '云恢复',
      'cloud_backup_and_restore': '云备份/恢复',
      'upgrade_for_cloud_features': '升级至高级版以使用云备份/恢复功能',
      'data_restore_title': '数据恢复',
      'restore_description': '恢复备份的日记数据。',
      'restore_start': '开始恢复',
      'delete_all_title': '删除所有数据',
      'delete_all_warning': '您确定要删除所有日记数据吗？\n此操作不可撤销。',
      'delete_all_confirm': '删除所有数据',

      // Delete settings screen
      'warning_notice': '注意事项',
      'delete_warning_message': '• 所有日记将被永久删除\n• 已删除的数据无法恢复\n• 删除前强烈建议备份',
      'clear_cache': '清除缓存',
      'clear_cache_description': '删除已存储的图片缓存以释放存储空间',
      'cache_zero': '0 MB',
      'calculation_failed': '计算失败',
      'clear_cache_confirm_message': '您要删除图片缓存吗？\n\n当前缓存大小：{size}\n\n注意：日记数据不会被删除，\n需要时会重新生成图片。',
      'clearing_cache': '正在清除缓存...',
      'cache_deleted_success': '缓存已成功删除',
      'cache_delete_error': '删除缓存时发生错误',
      'delete_button': '删除',
      'all_data_deleted': '所有数据已删除',
      'delete_error_format': '删除过程中发生错误：{error}',
      'app_info_subtitle': '应用版本、隐私政策',
      'app_name': 'ArtDiary AI',
      'app_description': 'AI绘制的特殊图画日记应用',
      'privacy_policy_title': '隐私政策',
      'privacy_policy_content': '''ArtDiary AI 隐私政策

最后更新：2025年1月

1. 我们收集的信息
• 日记内容和标题
• AI生成的图像
• 情感分析数据
• 设备识别信息（匿名）

2. 信息使用目的
• 提供日记创建和管理服务
• AI图像生成和情感分析
• 应用性能改进和错误修复
• 用户体验提升

3. 信息存储和安全
• 所有数据安全存储在您的设备内部
• 云备份仅在用户选择时启用
• 应用数据加密和安全措施

4. 第三方披露
• 未经用户同意不向第三方提供信息
• 使用Google Gemini API提供AI服务
• 使用Google AdMob显示广告

5. 用户权利
• 随时请求删除数据
• 查看和修改个人信息的权利
• 撤回服务使用同意的能力

6. 联系方式
有关个人信息的咨询，请使用应用内联系功能。

本政策可能根据相关法律和服务政策变更进行修订。''',
      'terms_title': '服务条款',
      'terms_content': '''ArtDiary AI 服务条款

最后更新：2025年1月

1. 服务使用
• 本应用是基于AI的图画日记服务
• 面向14岁及以上用户
• 禁止创建非法或不当内容

2. 用户义务
• 提供准确信息
• 禁止侵犯他人权利
• 禁止滥用或误用服务
• 遵守适用法律

3. 服务提供
• AI图像生成功能
• 日记创建和管理功能
• 情感分析和统计功能
• 免费和高级服务

4. 高级服务
• 提供月度或年度订阅
• 无限AI图像生成
• 高级功能和字体使用
• 广告移除

5. 服务中断和变更
• 系统维护期间可能暂时中断服务
• 事先通知后可能更改服务内容
• 不可避免情况下可能立即中断

6. 免责声明
• 不保证AI生成内容的质量
• 对用户设备问题导致的数据丢失不承担责任
• 对网络故障导致的服务中断不承担责任

7. 知识产权
• 用户创建的日记内容归用户所有
• AI生成图像的使用权归用户所有
• 应用设计和代码的版权归开发者所有

8. 终止
• 用户可随时中止服务使用
• 违反条款时可能限制服务使用

本条款受大韩民国法律管辖并据此解释。''',
      'privacy_policy_subtitle': '查看隐私政策',
      'terms_subtitle': '查看服务条款',
      // Subscription management
      'subscription_management_test': '订阅管理 (测试)',
      'premium_user': '高级用户',
      'free_user': '免费用户',
      'image_generations': '图像生成',
      'image_modifications': '图像修改',
      'set_to_free': '设置为免费用户',
      'set_to_premium': '设置为高级版',
      'set_free_plan': '设置为免费',
      'set_premium_plan': '设置为高级版',
      // Image styles
      'style_auto': '自动选择',
      'style_realistic': '写实风格',
      'style_watercolor': '水彩风格',
      'style_illustration': '插画风格',
      'style_sketch': '素描风格',
      'style_anime': '动漫风格',
      'style_impressionist': '印象派',
      'style_vintage': '复古风格',
      
      // Advanced options
      'advanced_options': '高级选项',
      'lighting': '照明',
      'mood': '情绪',
      'color': '颜色',
      'composition': '构图',
      'none': '无',
      'clear_all_options': '自动选择',

      // AI Prompts
      'ai_emotion_analysis_prompt': '''请分析以下日记内容的主要情绪。
可能的情绪: happy, sad, angry, excited, peaceful, anxious, grateful, nostalgic, romantic, frustrated
请只回答一种情绪。

日记内容: {content}''',
      'ai_photo_analysis_prompt': '''请分析这些照片并提取以下信息:
- 整体氛围和感觉
- 主要色彩和色调
- 时间段（早晨、白天、傍晚、夜晚）
- 地点和环境（室内/室外、城市/自然等）
- 主要拍摄对象或物体

请用2-3句话简要概括。''',
      'ai_image_prompt_base': '''请根据以下日记内容创建图像生成提示。
风格: {style}
创建一个情感丰富且美丽的图像。

日记内容: {content}
主要情绪: {emotion}
关键词: {keywords}
{advanced}

请用英语编写提示，创建一个温暖且富有情感的图像，能够很好地表达日记的情感和内容。
包括具体的视觉元素、色彩和氛围。''',
      'ai_advanced_option_prefix': '高级选项: {options}',
      'ai_auto_settings_prompt': '''请分析以下日记内容并推荐适合图像生成的设置。
以JSON格式回答:

{{
  "lighting": "选择一个: natural|dramatic|warm|cool|sunset|night",
  "mood": "选择一个: peaceful|energetic|romantic|mysterious|joyful|melancholic",
  "color": "选择一个: vibrant|pastel|monochrome|warm|cool|earthy",
  "composition": "选择一个: centered|rule_of_thirds|symmetrical|dynamic|minimalist"
}}

日记内容: {content}

请综合考虑日记的氛围、情绪、时间段、天气和情况，选择最合适的设置。''',
      'ai_emotion_insight_system': '''你是一位亲切且善解人意的心理咨询师。
请分析用户的{period}日记数据，提供情感模式和见解。

日记数据:
{diaries}

请按照以下指导编写见解:
1. 用3-4句话简洁地写
2. 使用积极和同理的语气
3. 包括对情感模式或变化的观察
4. 包括实用的建议或鼓励的信息
5. 使用温暖和友好的语气

只输出见解，不需要其他说明。''',
      'ai_default_insight': '在这个{period}中，您体验了各种情绪。认识并记录自己的情绪本身就很有意义。',
      'ai_fallback_insight': '感谢您记录这段时间的情感旅程。',
      // Settings screen
      'personalization_subtitle': '语言、字体和日期格式设置',
      'ai_settings_subtitle': '图像风格和AI指南设置',
      'backup_and_restore': '备份与恢复',
      'delete_data': '删除数据',
      'delete_data_description': '删除所有日记数据',
      'premium_upgrade_description': '无广告无限制使用',
      'unlimited_with_premium': '高级版无限制生成',
      'test_mode': '测试模式',
      'current_premium_user': '当前：高级用户',
      'current_free_user': '当前：免费用户',
      'switched_to_premium': '已切换到高级用户',
      'switched_to_free': '已切换到免费用户',
      'free': '免费',
      'logout_to_login_screen': '登出（返回登录页面）',
      'logout': '登出',
      'return_to_login_confirmation': '返回登录页面？',
      // Personalization settings screen
      'font': '字体',
      'select_font_description': '选择日记书写字体',
      'date_format': '日期格式',
      'select_date_format_description': '选择日期显示格式',
      'timezone': '时区',
      'select_timezone_description': '选择时区',
      'select_font': '选择字体',
      'premium_only_font': '仅限高级会员字体',
      'select_date_format': '选择日期格式',
      'date_format_ymd': '年/月/日 (2024/12/25)',
      'date_format_dmy': '日/月/年 (25/12/2024)',
      'date_format_mdy': '月/日/年 (12/25/2024)',
      'date_format_changed': '日期格式已更改',
      'select_timezone': '选择时区',
      'timezone_changed_format': '时区已更改为{name}',
      'timezone_seoul': '首尔 (KST)',
      'timezone_tokyo': '东京 (JST)',
      'timezone_beijing': '北京 (CST)',
      'timezone_new_york': '纽约 (EST)',
      'timezone_los_angeles': '洛杉矶 (PST)',
      'timezone_london': '伦敦 (GMT)',
      'timezone_paris': '巴黎 (CET)',
      // AI settings screen
      'auto_advanced_settings': '高级设置自动配置',
      'premium_only_feature': '仅限高级会员功能',
      'auto_advanced_settings_description': '自动设置时间、天气和季节选项',
      'auto_advanced_settings_enabled': '高级设置自动配置已启用',
      'auto_advanced_settings_disabled': '高级设置自动配置已禁用',
      'premium_styles_available_format': '高级版提供{count}个额外样式',

      // Backup and restore screen
      'auto_backup': '自动备份',
      'local_backup_restore': '本地备份/恢复',
      'cloud_backup_restore': '云端备份/恢复',
      'free_user_backup_description': '免费用户可以以JSON格式备份日记标题、内容和日期。',
      'premium_backup_description': '高级版：包含情感分析、生成图像、AI提示',
      'select_backup_location': '选择备份文件保存位置',
      'backup_canceled': '备份已取消',
      'restore_warning': '当前保存的数据将全部删除\n并替换为备份文件',
      'select_file': '选择文件',
      'restoring': '恢复中...',
      'no_restored_diaries': '没有恢复的日记',
      'restore_failed_format': '恢复失败: {error}',
      'included_content': '包含内容:',
      'all_diary_content': '所有日记内容',
      'emotion_analysis_result': '情感分析结果',
      'generated_images_base64': '生成的图像 (base64)',
      'image_style_and_settings': '图像样式和设置',
      'uploaded_photos': '上传的照片',
      'existing_backup_warning': '现有备份将被覆盖',
      'premium_backup_success_format': '{count}篇日记已完全备份',
      'backup_success_format': '{count}篇日记已备份',
      'cancel_file_selection_hint': '在文件选择界面可以使用\n返回按钮随时取消',
      'restore_success_format': '{count}篇日记已恢复',
      'google_drive_backup': 'Google Drive 备份',
      'google_drive_backup_description': '安全地将日记数据备份到 Google Drive。',
      'start_backup': '开始备份',
      'login_required_message': '需要登录。\n请先登录应用程序。',
      'backing_up_to_google_drive': '正在备份到 Google Drive...',
      'backup_complete_test_mode': '备份完成 (测试模式)',
      'backing_up_to_cloud': '正在备份到云端...',
      'cloud_backup_complete': '云备份已完成',
      'cloud_backup_failed': '云备份失败',
      'cloud_backup_error_format': '云备份错误: {error}',
      'login_required_title': '需要登录',
      'cloud_restore_login_message': '请先登录应用程序以使用云恢复功能。',
      'test_restore_title': '[测试] 恢复',
      'test_mode_restore_simulation': '在测试模式下模拟恢复。',
      'real_environment_google_drive_restore': '在真实环境中，从 Google Drive 恢复。',
      'start_button': '开始',
      'no_backup_title': '无备份',
      'no_cloud_backup_message': '云端没有保存的备份。\n请先创建备份。',
      'cloud_restore_title': '云恢复',
      'restore_from_firebase': '从 Firebase 恢复日记数据。',
      'all_data_will_be_replaced': '当前保存的所有数据将被删除\n并替换为云备份数据',
      'cancel_button': '取消',
      'start_restore_button': '开始恢复',
      'restoring_from_cloud': '正在从云端恢复...',
      'cloud_restore_failed': '云恢复失败',
      'cloud_restore_error_format': '云恢复错误: {error}',
      'restore_complete_test_mode': '恢复完成 (测试模式)',
      'cloud_backup_restore_premium_only': '云备份/恢复仅限高级会员使用。',
      'auto_backup_every_5_minutes': '每5分钟自动备份',
      'auto_backup_enabled': '自动备份已启用',
      'auto_backup_disabled': '自动备份已禁用',
      // Diary detail screen
      'error_loading_diary': '加载日记时出错',
      'diary_detail_title': '日记详情',
      'diary_not_found': '未找到日记',
      'written_label': '撰写：',
      'last_modified_label': '最后修改：',
      'no_ai_image_available': '没有AI生成的图片',
      'todays_emotion_label': '今天的情绪：',
      'written_date_label': '撰写日期：',
      'hashtag_ai_diary': '#AI绘画日记 #情绪日记',
      'delete_diary_title': '删除日记',
      'delete_diary_confirmation': '确定要删除这篇日记吗？\n删除的日记无法恢复。',
      'diary_deleted_success': '日记已删除',
      'diary_delete_error': '删除时出错',
      'ai_generated_badge': 'AI生成',
      'user_photo_badge': '我的照片',
    },
    'la': {
      'app_title': 'ArtDiary AI',
      'settings': 'Configuratio',
      'personalization': 'Personalizatio',
      'theme': 'Thema',
      'theme_subtitle': 'Thema applicationis mutare',
      'language': 'Lingua',
      'language_subtitle': 'Linguam applicationis mutare',
      'font_size': 'Magnitude Litterarum',
      'font_size_subtitle': 'Magnitudinem textus diarii adjustare',
      'notifications': 'Notificationes',
      'notifications_subtitle': 'Monita scripturae diarii ponere',
      'ai_settings': 'Configuratio AI',
      'default_image_style': 'Stylus Imaginis Praedefinitus',
      'default_image_style_subtitle': 'Stylus imaginis praedefinitus pro novo diario',
      'ai_analysis_strength': 'Vis Analyseos AI',
      'ai_analysis_strength_subtitle': 'Accuratio analyseos emotionum et verborum clavium',
      'data_privacy': 'Data et Privacitas',
      'data_backup': 'Copia Data',
      'data_backup_subtitle': 'Data diarii tui conservare',
      'data_restore': 'Restitutio Data',
      'data_restore_subtitle': 'Data diarii conservata restituere',
      'delete_all_data': 'Omnia Data Delere',
      'delete_all_data_subtitle': 'Omnia data diarii delere',
      'premium': 'Premium',
      'premium_upgrade': 'Promotio Premium',
      'premium_upgrade_subtitle': 'Imagines infinitae • Styli praemium • Sine publicitate',
      'app_info': 'Informatio Applicationis',
      'app_version': 'Versio Applicationis',
      'privacy_policy': 'Politica Privacitatis',
      'terms_of_service': 'Condiciones Servitii',
      'cancel': 'Tollere',
      'confirm': 'Confirmare',
      'close': 'Claudere',
      'save': 'Servare',
      'back': 'Redire',
      // Calendar screen
      'today': 'Hodie',
      'no_diary_on_date': 'Hoc die nullum diarium scriptum est',
      'write_diary': 'Diarium Scribere',
      'cannot_load_calendar': 'Calendarium caricare non potest',
      'cannot_load_diary': 'Diarium caricare non potest',
      'tags_count': ' signa',
      // Diary create screen
      'new_diary': 'Novum Diarium',
      'edit_diary': 'Diarium Corrigere',
      'title': 'Titulus',
      'title_hint': 'Titulum hodierni scribe',
      'diary_content': 'Contentum Diarii',
      'diary_content_hint': 'Libere scribe de rebus hodie gestis et sensibus tuis.\nAI tuam fabulam in pulchram picturam convertet.',
      'please_enter_title': 'Titulum scribe quaeso',
      'please_enter_content': 'Contentum diarii scribe quaeso',
      'content_too_short': 'Plura scribe quaeso (minimum 10 litterae)',
      'image_style': 'Stylus Imaginis',
      'ai_drawing_complete': 'Servatum! Pictura AI',
      'ai_drawing': 'Pictura AI',
      'generate_image': 'Imaginem Generare',
      'generating_image': 'AI tuam fabulam\nstylo {style} pingit...',
      'please_wait': 'Expecta quaeso',
      'saving': 'Servans...',
      'saved_successfully': 'Bene Servatum',
      'diary_saved': 'Diarium servatum est',
      'diary_updated': 'Diarium renovatum est',
      'image_generation_error': 'Error in imagine generanda: {error}',
      'save_error': 'Error in servando: {error}',
      'failed_to_load_diary': 'Diarium onerare non potuit: {error}',
      'analyzing_photo': 'Photographia analysi...',
      'analyzing_emotion': 'Affectus analysi...',
      'extracting_keywords': 'Verba clavis extrahens...',
      'generating_prompt': 'Promptum imaginis generans...',
      'generating_ai_image_notice': 'Imago AI generatur...\n\n(Tempus exspectationis longius esse potest cum multi usores adsunt)',
      'diary_saved_successfully': 'Diarium feliciter servatum!',
      'image_gallery': 'Galeria Imaginum',
      'photo_upload': 'Photographia Upload',
      'select_photo': 'Photographiam Eligere',
      'my_photo': 'Mea Photographia',
      'edit_diary_only': 'Diarium Tantum Corrigere',
      'edit_image_and_diary': 'Imaginem + Diarium Corrigere',
      'photo_upload_and_gallery': 'Photographia Upload et Galeria',
      'photo_select_failed': 'Photographia electio defecit: {error}',
      // Login screen
      'login_title': 'ArtDiary AI',
      'login_description': 'Diarium Artificii Intellectus cum picturis pulchris',
      'login_tagline': 'Momenta pretiosa tua\nin picturas pulchras per AI transformamus',
      'start_with_google': 'Incipere cum Google',
      'continue_as_guest': 'Continuare ut Hospes',
      'welcome_user': 'Salve, {name}!',
      'user': 'Usor',
      'google_login_failed': 'Ingressio Google fracta est: {error}',
      'guest_login_message': 'Modo Hospitis incipimus (notae in hoc instrumento solum servantur)',
      'login_failed': 'Ingressio fracta est: {error}',
      // Emotions
      'emotion_happy': 'Laetus',
      'emotion_sad': 'Tristis',
      'emotion_angry': 'Iratus',
      'emotion_excited': 'Excitatus',
      'emotion_peaceful': 'Pacificus',
      'emotion_anxious': 'Anxius',
      'emotion_grateful': 'Gratus',
      'emotion_nostalgic': 'Desiderans',
      'emotion_romantic': 'Romanticus',
      'emotion_frustrated': 'Frustratus',
      'emotion_normal': 'Normalis',
      // Premium features
      'premium_feature': 'Munus Premium',
      'upgrade_to_premium': 'Ad Premium promovere',
      'free_user_limit': 'Usuarii gratuiti imagines mutare non possunt',
      'image_modification_limit': 'Limes mutationis imaginis superatus',
      'regenerate_image': 'Imaginem Regenerare',
      'keep_existing_image': 'Imaginem Existentem Servare',
      'image_modification_dialog_title': 'Mutatio Imaginis',
      'image_modification_dialog_content': 'Contentum diarii mutavisti.\nVisne imaginem regenerare ut novo contento respondeat?',
      'remaining_generations': 'Generationes reliquae: {count}',
      'remaining_modifications': 'Mutationes reliquae: {count}',
      'unlimited': 'Infinitus',
      // Search
      'search_hint': 'Quaere contentum',
      'search_label': 'Quaere',
      'no_entries': 'Nullum diarium adhuc',
      'create_first_entry': 'Primum diarium crea!',
      'empty_search': 'Nulla inventa',
      'try_different_keyword': 'Alia verba proba',
      // Navigation & UI
      'diary_list': 'Index Diarii',
      'calendar': 'Calendarium',
      'diary_search': 'Quaerere Diarium',
      'start_with_ai_diary': 'Incipe diarium speciale cum picturis AI',
      'refresh': 'Renovare',
      'calendar_load_error': 'Calendarium onerari non potest',
      // Settings dialog content
      'theme_selection': 'Electio Thematis',
      'light_theme': 'Thema Lucidum',
      'dark_theme': 'Thema Obscurum',
      'system_theme': 'Configuratio Systematis',
      'font_size_setting': 'Configuratio Magnitudinis Litterarum',
      'font_size_description': 'Elige magnitudinem textus diarii',
      'font_small': 'Parvum',
      'font_medium': 'Medium',
      'font_large': 'Magnum',
      'font_xlarge': 'Valde Magnum',
      'font_size_changed': 'Magnitude litterarum posita est ad "{size}".',
      'notification_settings': 'Configuratio Notificationum',
      'notification_description': 'Accipe notificationes ne scripturam diarii praetermittas.',
      'daily_reminder': 'Monitor Diurnus',
      'daily_reminder_time': 'Notificatio cotidiana hora 9 vespere',
      'weekly_summary': 'Summarium Hebdomadarium',
      'weekly_summary_time': 'Omni die Dominico hora 10 matutina',
      'notification_enabled': 'Notificationes activatae sunt.',
      'notification_disabled': 'Notificationes deactivatae sunt.',
      'weekly_notification_enabled': 'Notificationes summarii hebdomadarii activatae sunt.',
      'weekly_notification_disabled': 'Notificationes summarii hebdomadarii deactivatae sunt.',
      'premium_upgrade_title': 'Promotio Premium',
      'premium_benefits': 'Promove ad Premium pro:',
      'unlimited_ai_images': 'Generatio Imaginum AI Infinita',
      'advanced_image_styles': '50+ Styli Imaginum Praestantes',
      'no_ads': 'Remotio Publicitatum Completa',
      'cloud_backup': 'Copia Automatica in Nube',
      'advanced_security': 'Munera Securitatis Praestantia',
      'later': 'Postea',
      'monthly_price': 'Menstruum ₩4,900',
      'premium_coming_soon': 'Subscriptio premium mox ventura!',
      'default_image_style_setting': 'Configuratio Styli Imaginis Praedefiniti',
      'image_style_description': 'Pone stylum imaginis praedefinitum pro novis diariis.',
      'default_style_set': 'Stylus praedefinitus positus est ad "{style}".',
      'data_backup_title': 'Copia Datorum',
      'backup_description': 'Copia omnia data diarii ut lima JSON.',
      'backup_includes': 'Includit:',
      'backup_diary_content': 'Tituli et contenta diarii',
      'backup_date_time': 'Dies et tempus creationis',
      'backup_emotion_analysis': 'Resultata analyseos emotionum',
      'backup_generated_images': 'Imagines generatae (Base64)',
      'backup_image_style': 'Informatio styli imaginis',
      'backup_start': 'Incipe Copiam',
      'backing_up': 'Copiando...',
      'ok': 'Confirma',
      'last_backup_time_format': 'Ultima copia: {time}',
      'error_format': 'Error: {error}',
      'auto_cloud_backup_feature': 'Copia Automatica in Nube',
      'upgrade_for_auto_backup': 'Promove ad premium pro functione copiae automaticae',
      'cloud_backup_feature': 'Copia in Nube',
      'cloud_backup_to_google_drive': 'Copia diarium tuum in Google Drive',
      'premium_feature_short': 'Functio premium tantum',
      'cloud_restore_feature': 'Restitutio ex Nube',
      'cloud_restore_from_google_drive': 'Restitue diarium tuum ex Google Drive',
      'cloud_backup_restore_feature': 'Copia/Restitutio in Nube',
      'upgrade_for_cloud_backup_restore': 'Promove ad premium pro functionibus copiae/restitutionis in nube',
      'backup_complete': 'Copia perfecta',
      'backup_completed': 'Copia perfecta! {count} diaria copiata sunt.',
      'backup_failed': 'Copia defecit: {error}',
      'data_restore_title': 'Restitutio Datorum',
      'restore_description': 'Restitue data diarii copiata.',
      'restore_start': 'Incipe Restitutionem',
      'delete_all_title': 'Dele Omnia Data',
      'delete_all_warning': 'Certusne es te velle delere omnia data diarii?\nHaec actio revocari non potest.',
      'delete_all_confirm': 'Dele Omnia Data',
      // Delete settings screen
      'warning_notice': 'Monitum',
      'delete_warning_message': '• Omnia diaria permanenter delebuntur\n• Data deleta recuperari non possunt\n• Ante deletionem copiam valde commendamus',
      'clear_cache': 'Cache Purgare',
      'clear_cache_description': 'Delete cache imaginum conservatarum ad spatium liberandum',
      'cache_zero': '0 MB',
      'calculation_failed': 'Calculatio Defecit',
      'clear_cache_confirm_message': 'Visne cache imaginum delere?\n\nMagnitude cache nunc: {size}\n\nNota: Data diarii non delebuntur,\net imagines re-generabuntur cum necesse sit.',
      'clearing_cache': 'Cache Purgans...',
      'cache_deleted_success': 'Cache feliciter deletum est',
      'cache_delete_error': 'Error accidit dum cache delebatur',
      'delete_button': 'Dele',
      'all_data_deleted': 'Omnia data deleta sunt',
      'delete_error_format': 'Error accidit dum deletio: {error}',
      'app_info_subtitle': 'Versio applicationis, Politica secretitudinis',
      'app_name': 'ArtDiary AI',
      'app_description': 'Diarium pictum speciale ab AI depictum',
      'privacy_policy_title': 'Politica Privacitatis',
      'privacy_policy_content': '''ArtDiary AI Politica Privacitatis

Ultima Renovatio: Ianuarius MMXXV

1. Informationes Collectae
• Contentum et titulum diarii
• Imagines ab AI generatae
• Data analyseos emotionum
• Informationes identificationis instrumenti (anonymae)

2. Propositum Usus Informationum
• Servitium creationis et administrationis diarii praebere
• Generatio imaginum AI et analysis emotionum
• Melioratio operationis applicationis et correctio errorum
• Augmentatio experientiae usoris

3. Conservatio et Securitas Informationum
• Omnia data secure in instrumento tuo conservantur
• Copia nubis solum cum usor eligit activatur
• Encryptio datarum et mensuras securitatis applicantur

4. Patefactio ad Tertios
• Informationes ad tertios sine consensu usoris non praebimus
• Google Gemini API ad servitia AI utimur
• Google AdMob ad reclamas utimur

5. Iura Usoris
• Petitionem deletionis datarum quovis tempore
• Ius inspiciendi et modificandi informationes personales
• Facultas revocandi consensum usus servitii

6. Contactus
Pro quaestionibus de informationibus personalibus, utere functione contactus in applicatione.

Haec politica secundum leges pertinentes et mutationes politicae servitii emendari potest.''',
      'terms_title': 'Condiciones Servitii',
      'terms_content': '''ArtDiary AI Condiciones Servitii

Ultima Renovatio: Ianuarius MMXXV

1. Usus Servitii
• Haec applicatio servitium diarii picti basatum in AI est
• Destinata usoribus aetatis XIV annorum et supra
• Creatio contenti illegalis vel inconvenienti prohibita est

2. Obligationes Usoris
• Praebere informationes accuratas
• Prohibitio violationis iurium aliorum
• Prohibitio abusus vel male usus servitii
• Observantia legum applicabilium

3. Praebiti Servitii
• Functio generationis imaginum AI
• Functiones creationis et administrationis diarii
• Functiones analyseos emotionum et statisticarum
• Servitia gratuita et premium

4. Servitia Premium
• Subscriptiones mensuales vel annuales offeruntur
• Generatio illimitata imaginum AI
• Usus functionum et fontium advancatarum
• Remotio reclamarum

5. Interruptio et Mutationes Servitii
• Servitium tempore manutentionis systematis temporarie suspendi potest
• Contentum servitii post notificationem praecedentem mutari potest
• In circumstantiis inevitabilibus immediate suspendi potest

6. Renuntiatio Responsibitatis
• Qualitas contenti generati ab AI non guarantitur
• Responsibilitas pro iactura datarum ex problematibus instrumenti usoris non suscipitur
• Responsibilitas pro interruptione servitii ex defectibus retis non suscipitur

7. Iura Proprietatis Intellectualis
• Contentum diarii ab usore creatum ad usorem pertinet
• Iura usus imaginum ab AI generatarum ad usorem pertinent
• Iura auctoris designationis et codicis applicationis ad developerem pertinent

8. Terminatio
• Usor quovis tempore usum servitii desistere potest
• Usus servitii in casu violationis condicionum limitari potest

Hae condiciones secundum leges Rei Publicae Coreae reguntur et interpretantur.''',
      'privacy_policy_subtitle': 'Inspice politicam privacitatis',
      'terms_subtitle': 'Inspice condiciones servitii',
      // Subscription management
      'subscription_management_test': 'Administratio Subscriptionis (Experimentum)',
      'premium_user': 'Usuario Premium',
      'free_user': 'Usuario Gratuitus',
      'image_generations': 'Generatio Imaginum',
      'image_modifications': 'Modificatio Imaginum',
      'set_to_free': 'Positum ad usuario gratuitu',
      'set_to_premium': 'Positum ad premium',
      'set_free_plan': 'Ponere Gratuitu',
      'set_premium_plan': 'Ponere Premium',
      // Image styles
      'style_auto': 'Electio Automatica',
      'style_realistic': 'Stylus Realisticus',
      'style_watercolor': 'Stylus Aquarum Coloribus',
      'style_illustration': 'Stylus Illustrationis',
      'style_sketch': 'Stylus Adumbrationis',
      'style_anime': 'Stylus Animationis',
      'style_impressionist': 'Impressionismus',
      'style_vintage': 'Stylus Antiquus',
      
      // Advanced options
      'advanced_options': 'Optiones Superiores',
      'lighting': 'Lumen',
      'mood': 'Animus',
      'color': 'Color',
      'composition': 'Compositio',
      'none': 'Nihil',
      'clear_all_options': 'Automatice Eligere',

      // AI Prompts
      'ai_emotion_analysis_prompt': '''Quaeso analyza praecipuam emotionem sequentis diarii contenti.
Emotiones possibiles: happy, sad, angry, excited, peaceful, anxious, grateful, nostalgic, romantic, frustrated
Responde tantum unam emotionem.

Contentum diarii: {content}''',
      'ai_photo_analysis_prompt': '''Quaeso analyza has photographias et extrahe sequentem informationem:
- Ambitus et sensus generalis
- Colores et toni praecipui
- Tempus diei (mane, meridie, vespere, nocte)
- Locus et ambitus (intus/foris, urbanus/naturalis, etc.)
- Subiecta vel objecta praecipua

Resume in 2-3 sententias breviter.''',
      'ai_image_prompt_base': '''Quaeso crea indicium generationis imaginis basatum in sequenti contentum diarii.
Stylus: {style}
Crea imaginem emotionalem et pulchram.

Contentum diarii: {content}
Emotio praecipua: {emotion}
Verba clavium: {keywords}
{advanced}

Scribe indicium Anglice, creando imaginem calidam et emotionalem quae emotionem et contentum diarii bene exprimit.
Include elementa visualia specifica, colores, et ambitum.''',
      'ai_advanced_option_prefix': 'Optiones superiores: {options}',
      'ai_auto_settings_prompt': '''Quaeso analyza sequentem contentum diarii et commenda configurationes idoneas pro generatione imaginis.
Responde in forma JSON:

{{
  "lighting": "unum ex: natural|dramatic|warm|cool|sunset|night",
  "mood": "unum ex: peaceful|energetic|romantic|mysterious|joyful|melancholic",
  "color": "unum ex: vibrant|pastel|monochrome|warm|cool|earthy",
  "composition": "unum ex: centered|rule_of_thirds|symmetrical|dynamic|minimalist"
}}

Contentum diarii: {content}

Quaeso elige configurationes aptissimas considerando comprehensive ambitum, emotionem, tempus diei, caelum, et situm diarii.''',
      'ai_emotion_insight_system': '''Tu es psychologus consultativus benignus et empathicus.
Quaeso analyza {period} data diarii usoris et provide patterns emotionales et perspicacitates.

Data diarii:
{diaries}

Quaeso scribe perspicacitates sequendo has directiones:
1. Scribe breviter in 3-4 sententias
2. Ute tonum positivum et empathicum
3. Include observationes de patterns emotionalibus vel mutationibus
4. Include consilium practicum vel nuntia encouragement
5. Ute tonum calidum et amicabilem

Emitte tantum perspicacitates, nulla alia explanatio necessaria.''',
      'ai_default_insight': 'In hoc {period}, varias emotiones expertus es. Recognoscere et recordare tuas emotiones ipsum magnum significatum habet.',
      'ai_fallback_insight': 'Gratias tibi ago pro recordando iter emotionale huius periodi.',
    },
  };

  String get appTitle => _localizedValues[locale.languageCode]!['app_title']!;
  String get settings => _localizedValues[locale.languageCode]!['settings']!;
  String get personalization => _localizedValues[locale.languageCode]!['personalization']!;
  String get theme => _localizedValues[locale.languageCode]!['theme']!;
  String get themeSubtitle => _localizedValues[locale.languageCode]!['theme_subtitle']!;
  String get language => _localizedValues[locale.languageCode]!['language']!;
  String get languageSubtitle => _localizedValues[locale.languageCode]!['language_subtitle']!;
  String get fontSize => _localizedValues[locale.languageCode]!['font_size']!;
  String get fontSizeSubtitle => _localizedValues[locale.languageCode]!['font_size_subtitle']!;
  String get notifications => _localizedValues[locale.languageCode]!['notifications']!;
  String get notificationsSubtitle => _localizedValues[locale.languageCode]!['notifications_subtitle']!;
  String get aiSettings => _localizedValues[locale.languageCode]!['ai_settings']!;
  String get defaultImageStyle => _localizedValues[locale.languageCode]!['default_image_style']!;
  String get defaultImageStyleSubtitle => _localizedValues[locale.languageCode]!['default_image_style_subtitle']!;
  String get aiAnalysisStrength => _localizedValues[locale.languageCode]!['ai_analysis_strength']!;
  String get aiAnalysisStrengthSubtitle => _localizedValues[locale.languageCode]!['ai_analysis_strength_subtitle']!;
  String get aiImageGuide => _localizedValues[locale.languageCode]!['ai_image_guide']!;
  String get aiImageGuideSubtitle => _localizedValues[locale.languageCode]!['ai_image_guide_subtitle']!;
  String get dataPrivacy => _localizedValues[locale.languageCode]!['data_privacy']!;
  String get dataBackup => _localizedValues[locale.languageCode]!['data_backup']!;
  String get dataBackupSubtitle => _localizedValues[locale.languageCode]!['data_backup_subtitle']!;
  String get dataRestore => _localizedValues[locale.languageCode]!['data_restore']!;
  String get dataRestoreSubtitle => _localizedValues[locale.languageCode]!['data_restore_subtitle']!;
  String get deleteAllData => _localizedValues[locale.languageCode]!['delete_all_data']!;
  String get deleteAllDataSubtitle => _localizedValues[locale.languageCode]!['delete_all_data_subtitle']!;
  String get premium => _localizedValues[locale.languageCode]!['premium']!;
  String get premiumUpgrade => _localizedValues[locale.languageCode]!['premium_upgrade']!;
  String get premiumUpgradeSubtitle => _localizedValues[locale.languageCode]!['premium_upgrade_subtitle']!;
  String get appInfo => _localizedValues[locale.languageCode]!['app_info']!;
  String get appVersion => _localizedValues[locale.languageCode]!['app_version']!;
  String get privacyPolicy => _localizedValues[locale.languageCode]!['privacy_policy']!;
  String get termsOfService => _localizedValues[locale.languageCode]!['terms_of_service']!;
  String get cancel => _localizedValues[locale.languageCode]!['cancel']!;
  String get confirm => _localizedValues[locale.languageCode]!['confirm']!;
  String get close => _localizedValues[locale.languageCode]!['close']!;
  String get save => _localizedValues[locale.languageCode]!['save']!;
  String get back => _localizedValues[locale.languageCode]!['back']!;
  
  // Calendar screen
  String get refresh => _localizedValues[locale.languageCode]!['refresh']!;
  String get today => _localizedValues[locale.languageCode]!['today']!;
  String get noDiaryOnDate => _localizedValues[locale.languageCode]!['no_diary_on_date']!;
  String get writeDiary => _localizedValues[locale.languageCode]!['write_diary']!;
  String get cannotLoadCalendar => _localizedValues[locale.languageCode]!['cannot_load_calendar']!;
  String get cannotLoadDiary => _localizedValues[locale.languageCode]!['cannot_load_diary']!;
  String get tagsCount => _localizedValues[locale.languageCode]!['tags_count']!;
  
  // Diary create screen
  String get newDiary => _localizedValues[locale.languageCode]!['new_diary']!;
  String get editDiary => _localizedValues[locale.languageCode]!['edit_diary']!;
  String get title => _localizedValues[locale.languageCode]!['title']!;
  String get titleHint => _localizedValues[locale.languageCode]!['title_hint']!;
  String get diaryContent => _localizedValues[locale.languageCode]!['diary_content']!;
  String get diaryContentHint => _localizedValues[locale.languageCode]!['diary_content_hint']!;
  String get pleaseEnterTitle => _localizedValues[locale.languageCode]!['please_enter_title']!;
  String get pleaseEnterContent => _localizedValues[locale.languageCode]!['please_enter_content']!;
  String get contentTooShort => _localizedValues[locale.languageCode]!['content_too_short']!;
  String get imageStyle => _localizedValues[locale.languageCode]!['image_style']!;
  String get aiDrawingComplete => _localizedValues[locale.languageCode]!['ai_drawing_complete']!;
  String get aiDrawing => _localizedValues[locale.languageCode]!['ai_drawing']!;
  String get generateImage => _localizedValues[locale.languageCode]!['generate_image']!;
  String generatingImage(String style) => _localizedValues[locale.languageCode]!['generating_image']!.replaceAll('{style}', style);
  String get pleaseWait => _localizedValues[locale.languageCode]!['please_wait']!;
  String get saving => _localizedValues[locale.languageCode]!['saving']!;
  String get savedSuccessfully => _localizedValues[locale.languageCode]!['saved_successfully']!;
  String get diarySaved => _localizedValues[locale.languageCode]!['diary_saved']!;
  String get diaryUpdated => _localizedValues[locale.languageCode]!['diary_updated']!;
  String imageGenerationError(String error) => _localizedValues[locale.languageCode]!['image_generation_error']!.replaceAll('{error}', error);
  String saveError(String error) => _localizedValues[locale.languageCode]!['save_error']!.replaceAll('{error}', error);
  String failedToLoadDiary(String error) => _localizedValues[locale.languageCode]!['failed_to_load_diary']!.replaceAll('{error}', error);
  String get analyzingPhoto => _localizedValues[locale.languageCode]!['analyzing_photo']!;
  String get analyzingEmotion => _localizedValues[locale.languageCode]!['analyzing_emotion']!;
  String get extractingKeywords => _localizedValues[locale.languageCode]!['extracting_keywords']!;
  String get generatingPrompt => _localizedValues[locale.languageCode]!['generating_prompt']!;
  String get generatingAiImageNotice => _localizedValues[locale.languageCode]!['generating_ai_image_notice']!;
  String get diarySavedSuccessfully => _localizedValues[locale.languageCode]!['diary_saved_successfully']!;

  // Login screen
  String get loginTitle => _localizedValues[locale.languageCode]!['login_title']!;
  String get loginDescription => _localizedValues[locale.languageCode]!['login_description']!;
  String get loginTagline => _localizedValues[locale.languageCode]!['login_tagline']!;
  String get startWithGoogle => _localizedValues[locale.languageCode]!['start_with_google']!;
  String get continueAsGuest => _localizedValues[locale.languageCode]!['continue_as_guest']!;
  String welcomeUser(String name) => _localizedValues[locale.languageCode]!['welcome_user']!.replaceAll('{name}', name);
  String get user => _localizedValues[locale.languageCode]!['user']!;
  String googleLoginFailed(String error) => _localizedValues[locale.languageCode]!['google_login_failed']!.replaceAll('{error}', error);
  String get guestLoginMessage => _localizedValues[locale.languageCode]!['guest_login_message']!;
  String loginFailed(String error) => _localizedValues[locale.languageCode]!['login_failed']!.replaceAll('{error}', error);
  
  // Emotions
  String get emotionHappy => _localizedValues[locale.languageCode]!['emotion_happy']!;
  String get emotionSad => _localizedValues[locale.languageCode]!['emotion_sad']!;
  String get emotionAngry => _localizedValues[locale.languageCode]!['emotion_angry']!;
  String get emotionExcited => _localizedValues[locale.languageCode]!['emotion_excited']!;
  String get emotionPeaceful => _localizedValues[locale.languageCode]!['emotion_peaceful']!;
  String get emotionAnxious => _localizedValues[locale.languageCode]!['emotion_anxious']!;
  String get emotionGrateful => _localizedValues[locale.languageCode]!['emotion_grateful']!;
  String get emotionNostalgic => _localizedValues[locale.languageCode]!['emotion_nostalgic']!;
  String get emotionRomantic => _localizedValues[locale.languageCode]!['emotion_romantic']!;
  String get emotionFrustrated => _localizedValues[locale.languageCode]!['emotion_frustrated']!;
  String get emotionNormal => _localizedValues[locale.languageCode]!['emotion_normal']!;
  String get allEmotions => _localizedValues[locale.languageCode]!['all_emotions']!;
  String get errorOccurredGeneral => _localizedValues[locale.languageCode]!['error_occurred_general']!;
  String get retryButton => _localizedValues[locale.languageCode]!['retry_button']!;
  String get searchButton => _localizedValues[locale.languageCode]!['search_button']!;
  String get aiGeneratedImagePlaceholder => _localizedValues[locale.languageCode]!['ai_generated_image_placeholder']!;

  String getEmotionText(String emotion) {
    switch (emotion.toLowerCase()) {
      case 'happy': return emotionHappy;
      case 'sad': return emotionSad;
      case 'angry': return emotionAngry;
      case 'excited': return emotionExcited;
      case 'peaceful': return emotionPeaceful;
      case 'anxious': return emotionAnxious;
      case 'grateful': return emotionGrateful;
      case 'nostalgic': return emotionNostalgic;
      case 'romantic': return emotionRomantic;
      case 'frustrated': return emotionFrustrated;
      default: return emotionNormal;
    }
  }
  
  // Premium features
  String get premiumFeature => _localizedValues[locale.languageCode]!['premium_feature']!;
  String get upgradeToPremium => _localizedValues[locale.languageCode]!['upgrade_to_premium']!;
  String get freeUserLimit => _localizedValues[locale.languageCode]!['free_user_limit']!;
  String get imageModificationLimit => _localizedValues[locale.languageCode]!['image_modification_limit']!;
  String get regenerateImage => _localizedValues[locale.languageCode]!['regenerate_image']!;
  String get keepExistingImage => _localizedValues[locale.languageCode]!['keep_existing_image']!;
  String get imageModificationDialogTitle => _localizedValues[locale.languageCode]!['image_modification_dialog_title']!;
  String get imageModificationDialogContent => _localizedValues[locale.languageCode]!['image_modification_dialog_content']!;
  String remainingGenerations(String count) => _localizedValues[locale.languageCode]!['remaining_generations']!.replaceAll('{count}', count);
  String remainingModifications(String count) => _localizedValues[locale.languageCode]!['remaining_modifications']!.replaceAll('{count}', count);
  String get unlimited => _localizedValues[locale.languageCode]!['unlimited']!;
  
  // Search
  String get searchHint => _localizedValues[locale.languageCode]!['search_hint']!;
  String get searchLabel => _localizedValues[locale.languageCode]!['search_label']!;
  String get noEntries => _localizedValues[locale.languageCode]!['no_entries']!;
  String get createFirstEntry => _localizedValues[locale.languageCode]!['create_first_entry']!;
  String get emptySearch => _localizedValues[locale.languageCode]!['empty_search']!;
  String get tryDifferentKeyword => _localizedValues[locale.languageCode]!['try_different_keyword']!;
  
  // Navigation & UI
  String get diaryList => _localizedValues[locale.languageCode]!['diary_list']!;
  String get calendar => _localizedValues[locale.languageCode]!['calendar']!;
  String get diarySearch => _localizedValues[locale.languageCode]!['diary_search']!;
  String get startWithAiDiary => _localizedValues[locale.languageCode]!['start_with_ai_diary']!;
  String? get calendarLoadError => _localizedValues[locale.languageCode]?['calendar_load_error'];
  
  // Settings dialog getters
  String get themeSelection => _localizedValues[locale.languageCode]!['theme_selection']!;
  String get lightTheme => _localizedValues[locale.languageCode]!['light_theme']!;
  String get darkTheme => _localizedValues[locale.languageCode]!['dark_theme']!;
  String get systemTheme => _localizedValues[locale.languageCode]!['system_theme']!;
  String get fontSizeSetting => _localizedValues[locale.languageCode]!['font_size_setting']!;
  String get fontSizeDescription => _localizedValues[locale.languageCode]!['font_size_description']!;
  String get fontSmall => _localizedValues[locale.languageCode]!['font_small']!;
  String get fontMedium => _localizedValues[locale.languageCode]!['font_medium']!;
  String get fontLarge => _localizedValues[locale.languageCode]!['font_large']!;
  String get fontXLarge => _localizedValues[locale.languageCode]!['font_xlarge']!;
  String fontSizeChanged(String size) => _localizedValues[locale.languageCode]!['font_size_changed']!.replaceAll('{size}', size);
  String get notificationSettings => _localizedValues[locale.languageCode]!['notification_settings']!;
  String get notificationDescription => _localizedValues[locale.languageCode]!['notification_description']!;
  String get dailyReminder => _localizedValues[locale.languageCode]!['daily_reminder']!;
  String get dailyReminderTime => _localizedValues[locale.languageCode]!['daily_reminder_time']!;
  String get weeklySummary => _localizedValues[locale.languageCode]!['weekly_summary']!;
  String get weeklySummaryTime => _localizedValues[locale.languageCode]!['weekly_summary_time']!;
  String get notificationEnabled => _localizedValues[locale.languageCode]!['notification_enabled']!;
  String get notificationDisabled => _localizedValues[locale.languageCode]!['notification_disabled']!;
  String get weeklyNotificationEnabled => _localizedValues[locale.languageCode]!['weekly_notification_enabled']!;
  String get weeklyNotificationDisabled => _localizedValues[locale.languageCode]!['weekly_notification_disabled']!;
  String get premiumUpgradeTitle => _localizedValues[locale.languageCode]!['premium_upgrade_title']!;
  String get premiumBenefits => _localizedValues[locale.languageCode]!['premium_benefits']!;
  String get unlimitedAiImages => _localizedValues[locale.languageCode]!['unlimited_ai_images']!;
  String get advancedImageStyles => _localizedValues[locale.languageCode]!['advanced_image_styles']!;
  String get noAds => _localizedValues[locale.languageCode]!['no_ads']!;
  String get cloudBackup => _localizedValues[locale.languageCode]!['cloud_backup']!;
  String get advancedSecurity => _localizedValues[locale.languageCode]!['advanced_security']!;
  String get later => _localizedValues[locale.languageCode]!['later']!;
  String get monthlyPrice => _localizedValues[locale.languageCode]!['monthly_price']!;
  String get premiumComingSoon => _localizedValues[locale.languageCode]!['premium_coming_soon']!;
  String get defaultImageStyleSetting => _localizedValues[locale.languageCode]!['default_image_style_setting']!;
  String get imageStyleDescription => _localizedValues[locale.languageCode]!['image_style_description']!;
  String defaultStyleSet(String style) => _localizedValues[locale.languageCode]!['default_style_set']!.replaceAll('{style}', style);
  String get dataBackupTitle => _localizedValues[locale.languageCode]!['data_backup_title']!;
  String get backupDescription => _localizedValues[locale.languageCode]!['backup_description']!;
  String get backupIncludes => _localizedValues[locale.languageCode]!['backup_includes']!;
  String get backupDiaryContent => _localizedValues[locale.languageCode]!['backup_diary_content']!;
  String get backupDateTime => _localizedValues[locale.languageCode]!['backup_date_time']!;
  String get backupEmotionAnalysis => _localizedValues[locale.languageCode]!['backup_emotion_analysis']!;
  String get backupGeneratedImages => _localizedValues[locale.languageCode]!['backup_generated_images']!;
  String get backupImageStyle => _localizedValues[locale.languageCode]!['backup_image_style']!;
  String get backupStart => _localizedValues[locale.languageCode]!['backup_start']!;
  String get backingUp => _localizedValues[locale.languageCode]!['backing_up']!;
  String get backupComplete => _localizedValues[locale.languageCode]!['backup_complete']!;
  String backupCompleted(String count) => _localizedValues[locale.languageCode]!['backup_completed']!.replaceAll('{count}', count);
  String backupFailed(String error) => _localizedValues[locale.languageCode]!['backup_failed']!.replaceAll('{error}', error);
  String get dataRestoreTitle => _localizedValues[locale.languageCode]!['data_restore_title']!;
  String get restoreDescription => _localizedValues[locale.languageCode]!['restore_description']!;
  String get restoreStart => _localizedValues[locale.languageCode]!['restore_start']!;
  String get deleteAllTitle => _localizedValues[locale.languageCode]!['delete_all_title']!;
  String get deleteAllWarning => _localizedValues[locale.languageCode]!['delete_all_warning']!;
  String get deleteAllConfirm => _localizedValues[locale.languageCode]!['delete_all_confirm']!;
  String get appName => _localizedValues[locale.languageCode]!['app_name']!;
  String get appDescription => _localizedValues[locale.languageCode]!['app_description']!;
  String get privacyPolicyTitle => _localizedValues[locale.languageCode]!['privacy_policy_title']!;
  String get privacyPolicyContent => _localizedValues[locale.languageCode]!['privacy_policy_content']!;
  String get termsTitle => _localizedValues[locale.languageCode]!['terms_title']!;
  String get termsContent => _localizedValues[locale.languageCode]!['terms_content']!;
  String get privacyPolicySubtitle => _localizedValues[locale.languageCode]!['privacy_policy_subtitle']!;
  String get termsSubtitle => _localizedValues[locale.languageCode]!['terms_subtitle']!;
  String get ok => _localizedValues[locale.languageCode]!['ok']!;
  
  // Subscription management getters
  String get subscriptionManagementTest => _localizedValues[locale.languageCode]!['subscription_management_test']!;
  String get premiumUser => _localizedValues[locale.languageCode]!['premium_user']!;
  String get freeUser => _localizedValues[locale.languageCode]!['free_user']!;
  String get imageGenerations => _localizedValues[locale.languageCode]!['image_generations']!;
  String get imageModifications => _localizedValues[locale.languageCode]!['image_modifications']!;
  String get setToFree => _localizedValues[locale.languageCode]!['set_to_free']!;
  String get setToPremium => _localizedValues[locale.languageCode]!['set_to_premium']!;
  String get setFreePlan => _localizedValues[locale.languageCode]!['set_free_plan']!;
  String get setPremiumPlan => _localizedValues[locale.languageCode]!['set_premium_plan']!;
  
  // Image style getters
  String get styleAuto => _localizedValues[locale.languageCode]!['style_auto']!;
  String get styleRealistic => _localizedValues[locale.languageCode]!['style_realistic']!;
  String get styleWatercolor => _localizedValues[locale.languageCode]!['style_watercolor']!;
  String get styleIllustration => _localizedValues[locale.languageCode]!['style_illustration']!;
  String get styleSketch => _localizedValues[locale.languageCode]!['style_sketch']!;
  String get styleAnime => _localizedValues[locale.languageCode]!['style_anime']!;
  String get styleImpressionist => _localizedValues[locale.languageCode]!['style_impressionist']!;
  String get styleVintage => _localizedValues[locale.languageCode]!['style_vintage']!;
  
  // Advanced options getters
  String get advancedOptions => _localizedValues[locale.languageCode]!['advanced_options']!;
  String get lighting => _localizedValues[locale.languageCode]!['lighting']!;
  String get mood => _localizedValues[locale.languageCode]!['mood']!;
  String get color => _localizedValues[locale.languageCode]!['color']!;
  String get composition => _localizedValues[locale.languageCode]!['composition']!;
  String get none => _localizedValues[locale.languageCode]!['none']!;
  String get clearAllOptions => _localizedValues[locale.languageCode]!['clear_all_options']!;

  // AI Prompts
  String aiEmotionAnalysisPrompt(String content) {
    return _localizedValues[locale.languageCode]!['ai_emotion_analysis_prompt']!
        .replaceAll('{content}', content);
  }

  String get aiPhotoAnalysisPrompt => _localizedValues[locale.languageCode]!['ai_photo_analysis_prompt']!;

  String aiImagePromptBase({
    required String style,
    required String content,
    required String emotion,
    required String keywords,
    String advanced = '',
  }) {
    return _localizedValues[locale.languageCode]!['ai_image_prompt_base']!
        .replaceAll('{style}', style)
        .replaceAll('{content}', content)
        .replaceAll('{emotion}', emotion)
        .replaceAll('{keywords}', keywords)
        .replaceAll('{advanced}', advanced);
  }

  String aiAdvancedOptionPrefix(String options) {
    return _localizedValues[locale.languageCode]!['ai_advanced_option_prefix']!
        .replaceAll('{options}', options);
  }

  String aiAutoSettingsPrompt(String content) {
    return _localizedValues[locale.languageCode]!['ai_auto_settings_prompt']!
        .replaceAll('{content}', content);
  }

  String aiEmotionInsightSystem({
    required String period,
    required String diaries,
  }) {
    return _localizedValues[locale.languageCode]!['ai_emotion_insight_system']!
        .replaceAll('{period}', period)
        .replaceAll('{diaries}', diaries);
  }

  String aiDefaultInsight(String period) {
    return _localizedValues[locale.languageCode]!['ai_default_insight']!
        .replaceAll('{period}', period);
  }

  String get aiFallbackInsight => _localizedValues[locale.languageCode]!['ai_fallback_insight']!;

  // Settings screen getters
  String get personalizationSubtitle => _localizedValues[locale.languageCode]!['personalization_subtitle']!;
  String get aiSettingsSubtitle => _localizedValues[locale.languageCode]!['ai_settings_subtitle']!;
  String get backupAndRestore => _localizedValues[locale.languageCode]!['backup_and_restore']!;
  String get deleteData => _localizedValues[locale.languageCode]!['delete_data']!;
  String get deleteDataDescription => _localizedValues[locale.languageCode]!['delete_data_description']!;
  String get premiumUpgradeDescription => _localizedValues[locale.languageCode]!['premium_upgrade_description']!;
  String get unlimitedWithPremium => _localizedValues[locale.languageCode]!['unlimited_with_premium']!;
  String get testMode => _localizedValues[locale.languageCode]!['test_mode']!;
  String get currentPremiumUser => _localizedValues[locale.languageCode]!['current_premium_user']!;
  String get currentFreeUser => _localizedValues[locale.languageCode]!['current_free_user']!;
  String get switchedToPremium => _localizedValues[locale.languageCode]!['switched_to_premium']!;
  String get switchedToFree => _localizedValues[locale.languageCode]!['switched_to_free']!;
  String get free => _localizedValues[locale.languageCode]!['free']!;
  String get logoutToLoginScreen => _localizedValues[locale.languageCode]!['logout_to_login_screen']!;
  String get logout => _localizedValues[locale.languageCode]!['logout']!;
  String get returnToLoginConfirmation => _localizedValues[locale.languageCode]!['return_to_login_confirmation']!;
  // Personalization settings screen
  String get font => _localizedValues[locale.languageCode]!['font']!;
  String get selectFontDescription => _localizedValues[locale.languageCode]!['select_font_description']!;
  String get dateFormat => _localizedValues[locale.languageCode]!['date_format']!;
  String get selectDateFormatDescription => _localizedValues[locale.languageCode]!['select_date_format_description']!;
  String get timezone => _localizedValues[locale.languageCode]!['timezone']!;
  String get selectTimezoneDescription => _localizedValues[locale.languageCode]!['select_timezone_description']!;
  String get selectFont => _localizedValues[locale.languageCode]!['select_font']!;
  String get premiumOnlyFont => _localizedValues[locale.languageCode]!['premium_only_font']!;
  String get selectDateFormat => _localizedValues[locale.languageCode]!['select_date_format']!;
  String get dateFormatYmd => _localizedValues[locale.languageCode]!['date_format_ymd']!;
  String get dateFormatDmy => _localizedValues[locale.languageCode]!['date_format_dmy']!;
  String get dateFormatMdy => _localizedValues[locale.languageCode]!['date_format_mdy']!;
  String get dateFormatChanged => _localizedValues[locale.languageCode]!['date_format_changed']!;
  String get selectTimezone => _localizedValues[locale.languageCode]!['select_timezone']!;
  String get timezoneChangedFormat => _localizedValues[locale.languageCode]!['timezone_changed_format']!;
  String get timezoneSeoul => _localizedValues[locale.languageCode]!['timezone_seoul']!;
  String get timezoneTokyo => _localizedValues[locale.languageCode]!['timezone_tokyo']!;
  String get timezoneBeijing => _localizedValues[locale.languageCode]!['timezone_beijing']!;
  String get timezoneNewYork => _localizedValues[locale.languageCode]!['timezone_new_york']!;
  String get timezoneLosAngeles => _localizedValues[locale.languageCode]!['timezone_los_angeles']!;
  String get timezoneLondon => _localizedValues[locale.languageCode]!['timezone_london']!;
  String get timezoneParis => _localizedValues[locale.languageCode]!['timezone_paris']!;

  // AI settings screen
  String get autoAdvancedSettings => _localizedValues[locale.languageCode]!['auto_advanced_settings']!;
  String get autoAdvancedSettingsDescription => _localizedValues[locale.languageCode]!['auto_advanced_settings_description']!;
  String get autoAdvancedSettingsEnabled => _localizedValues[locale.languageCode]!['auto_advanced_settings_enabled']!;
  String get autoAdvancedSettingsDisabled => _localizedValues[locale.languageCode]!['auto_advanced_settings_disabled']!;
  String get premiumStylesAvailableFormat => _localizedValues[locale.languageCode]!['premium_styles_available_format']!;

  // Backup and restore screen
  String get autoBackup => _localizedValues[locale.languageCode]!['auto_backup']!;
  String get localBackupRestore => _localizedValues[locale.languageCode]!['local_backup_restore']!;
  String get cloudBackupRestore => _localizedValues[locale.languageCode]!['cloud_backup_restore']!;
  String get freeUserBackupDescription => _localizedValues[locale.languageCode]!['free_user_backup_description']!;
  String get premiumBackupDescription => _localizedValues[locale.languageCode]!['premium_backup_description']!;
  String get selectBackupLocation => _localizedValues[locale.languageCode]!['select_backup_location']!;
  String get backupCanceled => _localizedValues[locale.languageCode]!['backup_canceled']!;
  String get restoreWarning => _localizedValues[locale.languageCode]!['restore_warning']!;
  String get selectFile => _localizedValues[locale.languageCode]!['select_file']!;
  String get restoring => _localizedValues[locale.languageCode]!['restoring']!;
  String get noRestoredDiaries => _localizedValues[locale.languageCode]!['no_restored_diaries']!;
  String get restoreFailedFormat => _localizedValues[locale.languageCode]!['restore_failed_format']!;
  String get includedContent => _localizedValues[locale.languageCode]!['included_content']!;
  String get allDiaryContent => _localizedValues[locale.languageCode]!['all_diary_content']!;
  String get emotionAnalysisResult => _localizedValues[locale.languageCode]!['emotion_analysis_result']!;
  String get generatedImagesBase64 => _localizedValues[locale.languageCode]!['generated_images_base64']!;
  String get imageStyleAndSettings => _localizedValues[locale.languageCode]!['image_style_and_settings']!;
  String get uploadedPhotos => _localizedValues[locale.languageCode]!['uploaded_photos']!;
  String get existingBackupWarning => _localizedValues[locale.languageCode]!['existing_backup_warning']!;
  String get premiumBackupSuccessFormat => _localizedValues[locale.languageCode]!['premium_backup_success_format']!;
  String get backupSuccessFormat => _localizedValues[locale.languageCode]!['backup_success_format']!;
  String get cancelFileSelectionHint => _localizedValues[locale.languageCode]!['cancel_file_selection_hint']!;
  String get restoreSuccessFormat => _localizedValues[locale.languageCode]!['restore_success_format']!;
  String get googleDriveBackup => _localizedValues[locale.languageCode]!['google_drive_backup']!;
  String get googleDriveBackupDescription => _localizedValues[locale.languageCode]!['google_drive_backup_description']!;
  String get startBackup => _localizedValues[locale.languageCode]!['start_backup']!;
  String get loginRequiredMessage => _localizedValues[locale.languageCode]!['login_required_message']!;
  String get backingUpToGoogleDrive => _localizedValues[locale.languageCode]!['backing_up_to_google_drive']!;
  String get backupCompleteTestMode => _localizedValues[locale.languageCode]!['backup_complete_test_mode']!;
  String get backingUpToCloud => _localizedValues[locale.languageCode]!['backing_up_to_cloud']!;
  String get cloudBackupComplete => _localizedValues[locale.languageCode]!['cloud_backup_complete']!;
  String get cloudBackupFailed => _localizedValues[locale.languageCode]!['cloud_backup_failed']!;
  String cloudBackupErrorFormat(String error) => _localizedValues[locale.languageCode]!['cloud_backup_error_format']!.replaceAll('{error}', error);
  String get loginRequiredTitle => _localizedValues[locale.languageCode]!['login_required_title']!;
  String get cloudRestoreLoginMessage => _localizedValues[locale.languageCode]!['cloud_restore_login_message']!;
  String get testRestoreTitle => _localizedValues[locale.languageCode]!['test_restore_title']!;
  String get testModeRestoreSimulation => _localizedValues[locale.languageCode]!['test_mode_restore_simulation']!;
  String get realEnvironmentGoogleDriveRestore => _localizedValues[locale.languageCode]!['real_environment_google_drive_restore']!;
  String get startButton => _localizedValues[locale.languageCode]!['start_button']!;
  String get noBackupTitle => _localizedValues[locale.languageCode]!['no_backup_title']!;
  String get noCloudBackupMessage => _localizedValues[locale.languageCode]!['no_cloud_backup_message']!;
  String get premiumOnlyFeature => _localizedValues[locale.languageCode]!['premium_only_feature']!;
  String get cloudRestoreTitle => _localizedValues[locale.languageCode]!['cloud_restore_title']!;
  String get restoreFromFirebase => _localizedValues[locale.languageCode]!['restore_from_firebase']!;
  String get allDataWillBeReplaced => _localizedValues[locale.languageCode]!['all_data_will_be_replaced']!;
  String get cancelButton => _localizedValues[locale.languageCode]!['cancel_button']!;
  String get startRestoreButton => _localizedValues[locale.languageCode]!['start_restore_button']!;
  String get restoringFromCloud => _localizedValues[locale.languageCode]!['restoring_from_cloud']!;
  String get cloudRestoreFailed => _localizedValues[locale.languageCode]!['cloud_restore_failed']!;
  String cloudRestoreErrorFormat(String error) => _localizedValues[locale.languageCode]!['cloud_restore_error_format']!.replaceAll('{error}', error);
  String get restoreCompleteTestMode => _localizedValues[locale.languageCode]!['restore_complete_test_mode']!;
  String get cloudBackupRestorePremiumOnly => _localizedValues[locale.languageCode]!['cloud_backup_restore_premium_only']!;
  String get autoCloudBackup => _localizedValues[locale.languageCode]!['auto_cloud_backup']!;
  String get autoBackupEveryFiveMinutes => _localizedValues[locale.languageCode]!['auto_backup_every_5_minutes']!;
  String get autoBackupEnabled => _localizedValues[locale.languageCode]!['auto_backup_enabled']!;
  String get autoBackupDisabled => _localizedValues[locale.languageCode]!['auto_backup_disabled']!;
  String lastBackupTimeFormat(String time) => _localizedValues[locale.languageCode]!['last_backup_time_format']!.replaceAll('{time}', time);
  String errorFormat(String error) => _localizedValues[locale.languageCode]!['error_format']!.replaceAll('{error}', error);
  String get autoCloudBackupFeature => _localizedValues[locale.languageCode]!['auto_cloud_backup_feature']!;
  String get upgradeForAutoBackup => _localizedValues[locale.languageCode]!['upgrade_for_auto_backup']!;
  String get cloudBackupFeature => _localizedValues[locale.languageCode]!['cloud_backup_feature']!;
  String get cloudBackupToGoogleDrive => _localizedValues[locale.languageCode]!['cloud_backup_to_google_drive']!;
  String get premiumFeatureShort => _localizedValues[locale.languageCode]!['premium_feature_short']!;
  String get cloudRestoreFeature => _localizedValues[locale.languageCode]!['cloud_restore_feature']!;
  String get cloudRestoreFromGoogleDrive => _localizedValues[locale.languageCode]!['cloud_restore_from_google_drive']!;
  String get cloudBackupRestoreFeature => _localizedValues[locale.languageCode]!['cloud_backup_restore_feature']!;
  String get upgradeForCloudBackupRestore => _localizedValues[locale.languageCode]!['upgrade_for_cloud_backup_restore']!;
  // Delete settings screen getters
  String get warningNotice => _localizedValues[locale.languageCode]!['warning_notice']!;
  String get deleteWarningMessage => _localizedValues[locale.languageCode]!['delete_warning_message']!;
  String get clearCache => _localizedValues[locale.languageCode]!['clear_cache']!;
  String get clearCacheDescription => _localizedValues[locale.languageCode]!['clear_cache_description']!;
  String get cacheZero => _localizedValues[locale.languageCode]!['cache_zero']!;
  String get calculationFailed => _localizedValues[locale.languageCode]!['calculation_failed']!;
  String get clearCacheConfirmMessage => _localizedValues[locale.languageCode]!['clear_cache_confirm_message']!;
  String get clearingCache => _localizedValues[locale.languageCode]!['clearing_cache']!;
  String get cacheDeletedSuccess => _localizedValues[locale.languageCode]!['cache_deleted_success']!;
  String get cacheDeleteError => _localizedValues[locale.languageCode]!['cache_delete_error']!;
  String get deleteButton => _localizedValues[locale.languageCode]!['delete_button']!;
  String get allDataDeleted => _localizedValues[locale.languageCode]!['all_data_deleted']!;
  String get deleteErrorFormat => _localizedValues[locale.languageCode]!['delete_error_format']!;
  String get appInfoSubtitle => _localizedValues[locale.languageCode]!['app_info_subtitle']!;

  // Diary detail screen
  String get errorLoadingDiary => _localizedValues[locale.languageCode]!['error_loading_diary']!;
  String get diaryDetailTitle => _localizedValues[locale.languageCode]!['diary_detail_title']!;
  String get diaryNotFound => _localizedValues[locale.languageCode]!['diary_not_found']!;
  String get writtenLabel => _localizedValues[locale.languageCode]!['written_label']!;
  String get lastModifiedLabel => _localizedValues[locale.languageCode]!['last_modified_label']!;
  String get noAiImageAvailable => _localizedValues[locale.languageCode]!['no_ai_image_available']!;
  String get todaysEmotionLabel => _localizedValues[locale.languageCode]!['todays_emotion_label']!;
  String get writtenDateLabel => _localizedValues[locale.languageCode]!['written_date_label']!;
  String get hashtagAiDiary => _localizedValues[locale.languageCode]!['hashtag_ai_diary']!;
  String get deleteDiaryTitle => _localizedValues[locale.languageCode]!['delete_diary_title']!;
  String get deleteDiaryConfirmation => _localizedValues[locale.languageCode]!['delete_diary_confirmation']!;
  String get diaryDeletedSuccess => _localizedValues[locale.languageCode]!['diary_deleted_success']!;
  String get diaryDeleteError => _localizedValues[locale.languageCode]!['diary_delete_error']!;
  String get aiGeneratedBadge => _localizedValues[locale.languageCode]!['ai_generated_badge']!;
  String get userPhotoBadge => _localizedValues[locale.languageCode]!['user_photo_badge']!;

  String get testModeMessage => _localizedValues[locale.languageCode]!['test_mode_message']!;
  String get subscriptionCompleted => _localizedValues[locale.languageCode]!['subscription_completed']!;
  String get subscribeTest => _localizedValues[locale.languageCode]!['subscribe_test']!;

  // Date formats
  String get dateFormatFull => _localizedValues[locale.languageCode]!['date_format_full']!;
  String get adFreeUnlimited => _localizedValues[locale.languageCode]!['ad_free_unlimited']!;
  String get adRemoval => _localizedValues[locale.languageCode]!['ad_removal']!;
  String get adRemovalDesc => _localizedValues[locale.languageCode]!['ad_removal_desc']!;
  String get advancedImageOptions => _localizedValues[locale.languageCode]!['advanced_image_options']!;
  String get advancedImageOptionsDesc => _localizedValues[locale.languageCode]!['advanced_image_options_desc']!;
  String get aiDrawnImage => _localizedValues[locale.languageCode]!['ai_drawn_image']!;
  String get allPremiumFeatures => _localizedValues[locale.languageCode]!['all_premium_features']!;
  String get alreadyPremium => _localizedValues[locale.languageCode]!['already_premium']!;
  String get bestValue => _localizedValues[locale.languageCode]!['best_value']!;
  String get cancelAnytime => _localizedValues[locale.languageCode]!['cancel_anytime']!;
  String get cloudBackupAuto => _localizedValues[locale.languageCode]!['cloud_backup_auto']!;
  String get cloudBackupAutoDesc => _localizedValues[locale.languageCode]!['cloud_backup_auto_desc']!;
  String get confirmDeleteDiary => _localizedValues[locale.languageCode]!['confirm_delete_diary']!;
  String get contentLabel => _localizedValues[locale.languageCode]!['content_label']!;
  String get createAiDiaryButton => _localizedValues[locale.languageCode]!['create_ai_diary_button']!;
  String get createNewDiary => _localizedValues[locale.languageCode]!['create_new_diary']!;
  String get currentlySubscribed => _localizedValues[locale.languageCode]!['currently_subscribed']!;
  String get delete => _localizedValues[locale.languageCode]!['delete']!;
  String get deleteDiary => _localizedValues[locale.languageCode]!['delete_diary']!;
  String get deleteFailed => _localizedValues[locale.languageCode]!['delete_failed']!;
  String get diaryDeleted => _localizedValues[locale.languageCode]!['diary_deleted']!;
  String get edit => _localizedValues[locale.languageCode]!['edit']!;
  String get editDiaryOnly => _localizedValues[locale.languageCode]!['edit_diary_only']!;
  String get editImageAndDiary => _localizedValues[locale.languageCode]!['edit_image_and_diary']!;
  String get emotionAll => _localizedValues[locale.languageCode]!['emotion_all']!;
  String get emotionStats => _localizedValues[locale.languageCode]!['emotion_stats']!;
  String get errorOccurred => _localizedValues[locale.languageCode]!['error_occurred']!;
  String get freeVersion1PhotoOnly => _localizedValues[locale.languageCode]!['free_version1_photo_only']!;
  String get generating => _localizedValues[locale.languageCode]!['generating']!;
  String get imageGallery => _localizedValues[locale.languageCode]!['image_gallery']!;
  String get lifetimeAccess => _localizedValues[locale.languageCode]!['lifetime_access']!;
  String get lifetimeSubscription => _localizedValues[locale.languageCode]!['lifetime_subscription']!;
  String get makeDiarySpecial => _localizedValues[locale.languageCode]!['make_diary_special']!;
  String get max3Photos => _localizedValues[locale.languageCode]!['max3_photos']!;
  String get max3PhotosUpload => _localizedValues[locale.languageCode]!['max3_photos_upload']!;
  String get monthly => _localizedValues[locale.languageCode]!['monthly']!;
  String get monthlySubscription => _localizedValues[locale.languageCode]!['monthly_subscription']!;
  String get myPhoto => _localizedValues[locale.languageCode]!['my_photo']!;
  String get onboardingNext => _localizedValues[locale.languageCode]!['onboarding_next']!;
  String get onboardingPage1Desc => _localizedValues[locale.languageCode]!['onboarding_page1_desc']!;
  String get onboardingPage1Title => _localizedValues[locale.languageCode]!['onboarding_page1_title']!;
  String get onboardingPage2Desc => _localizedValues[locale.languageCode]!['onboarding_page2_desc']!;
  String get onboardingPage2Title => _localizedValues[locale.languageCode]!['onboarding_page2_title']!;
  String get onboardingPage3Desc => _localizedValues[locale.languageCode]!['onboarding_page3_desc']!;
  String get onboardingPage3Title => _localizedValues[locale.languageCode]!['onboarding_page3_title']!;
  String get onboardingPage4Desc => _localizedValues[locale.languageCode]!['onboarding_page4_desc']!;
  String get onboardingPage4Title => _localizedValues[locale.languageCode]!['onboarding_page4_title']!;
  String get onboardingSkip => _localizedValues[locale.languageCode]!['onboarding_skip']!;
  String get onboardingStart => _localizedValues[locale.languageCode]!['onboarding_start']!;
  String get onePhoto => _localizedValues[locale.languageCode]!['one_photo']!;
  String get oneTimePayment => _localizedValues[locale.languageCode]!['one_time_payment']!;
  String get photoUpload => _localizedValues[locale.languageCode]!['photo_upload']!;
  String get photoUploadMax3 => _localizedValues[locale.languageCode]!['photo_upload_max3']!;
  String get photoUploadMax3Desc => _localizedValues[locale.languageCode]!['photo_upload_max3_desc']!;
  String get pleaseSelectPhoto => _localizedValues[locale.languageCode]!['please_select_photo']!;
  String get premiumArtStyles => _localizedValues[locale.languageCode]!['premium_art_styles']!;
  String get premiumArtStylesDesc => _localizedValues[locale.languageCode]!['premium_art_styles_desc']!;
  String get premiumFeatures => _localizedValues[locale.languageCode]!['premium_features']!;
  String get premiumFonts => _localizedValues[locale.languageCode]!['premium_fonts']!;
  String get premiumFontsDesc => _localizedValues[locale.languageCode]!['premium_fonts_desc']!;
  String get regenerationComplete => _localizedValues[locale.languageCode]!['regeneration_complete']!;
  String get retry => _localizedValues[locale.languageCode]!['retry']!;
  String get sampleDiaryContent => _localizedValues[locale.languageCode]!['sample_diary_content']!;
  String get sampleDiaryTitle => _localizedValues[locale.languageCode]!['sample_diary_title']!;
  String get search => _localizedValues[locale.languageCode]!['search']!;
  String get selectPhoto => _localizedValues[locale.languageCode]!['select_photo']!;
  String get subscribe => _localizedValues[locale.languageCode]!['subscribe']!;
  String get subscriptionFooter => _localizedValues[locale.languageCode]!['subscription_footer']!;
  String get subscriptionOptions => _localizedValues[locale.languageCode]!['subscription_options']!;
  String get timeWeatherSeasonSettings => _localizedValues[locale.languageCode]!['time_weather_season_settings']!;
  String get timeWeatherSeasonSettingsDesc => _localizedValues[locale.languageCode]!['time_weather_season_settings_desc']!;
  String get titleLabel => _localizedValues[locale.languageCode]!['title_label']!;
  String get unlimitedImageGeneration => _localizedValues[locale.languageCode]!['unlimited_image_generation']!;
  String get unlimitedImageGenerationDesc => _localizedValues[locale.languageCode]!['unlimited_image_generation_desc']!;
  String get upgradeToPremiumUnlimited => _localizedValues[locale.languageCode]!['upgrade_to_premium_unlimited']!;
  String get weekly => _localizedValues[locale.languageCode]!['weekly']!;
  String get yearly => _localizedValues[locale.languageCode]!['yearly']!;
  String get yearlySubscription => _localizedValues[locale.languageCode]!['yearly_subscription']!;

  // Premium subscription & onboarding
  String get dateFormatMonth => _localizedValues[locale.languageCode]!['date_format_month']!;

  // Emotion name helper method
  String getEmotionName(String? emotion) {
    switch (emotion) {
      case 'happy': return emotionHappy;
      case 'sad': return emotionSad;
      case 'angry': return emotionAngry;
      case 'excited': return emotionExcited;
      case 'peaceful': return emotionPeaceful;
      case 'anxious': return emotionAnxious;
      case 'grateful': return emotionGrateful;
      case 'nostalgic': return emotionNostalgic;
      case 'romantic': return emotionRomantic;
      case 'frustrated': return emotionFrustrated;
      default: return emotionNormal;
    }
  }

  String getImageStyleName(String styleKey) {
    switch (styleKey.toLowerCase()) {
      case 'auto': return styleAuto;
      case 'realistic': return styleRealistic;
      case 'watercolor': return styleWatercolor;
      case 'illustration': return styleIllustration;
      case 'sketch': return styleSketch;
      case 'anime': return styleAnime;
      case 'impressionist': return styleImpressionist;
      case 'vintage': return styleVintage;
      default: return styleRealistic;
    }
  }

  static Future<void> setLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('locale', locale.languageCode);
  }

  static Future<Locale> getSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguage = prefs.getString('locale');

    // 저장된 언어가 있으면 해당 언어 사용
    if (savedLanguage != null) {
      return Locale(savedLanguage);
    }

    // 저장된 언어가 없으면 기기 언어 감지
    final systemLocale = PlatformDispatcher.instance.locale;
    final supportedLanguages = ['ko', 'ja', 'en', 'zh'];

    // 기기 언어가 지원하는 언어 목록에 있으면 해당 언어 사용
    if (supportedLanguages.contains(systemLocale.languageCode)) {
      return systemLocale;
    }

    // 지원하지 않는 언어면 영어로 폴백
    return const Locale('en');
  }
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['ko', 'ja', 'en', 'zh', 'la'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}