import 'dart:async';
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
      'app_title': 'AI 그림일기',
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
      // Login screen
      'login_title': 'AI 그림일기에\n오신 것을 환영합니다',
      'login_subtitle': '당신의 이야기를 아름다운 그림으로',
      'continue_with_google': 'Google로 계속하기',
      'continue_with_apple': 'Apple로 계속하기',
      'continue_with_email': '이메일로 계속하기',
      'continue_as_guest': '게스트로 계속하기',
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
      'refresh': '새로고침',
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
      'backup_completed': '백업 완료! 총 {count}개의 일기가 백업되었습니다.',
      'backup_failed': '백업 실패: {error}',
      'data_restore_title': '데이터 복원',
      'restore_description': '백업된 일기 데이터를 복원합니다.',
      'restore_start': '복원 시작',
      'delete_all_title': '모든 데이터 삭제',
      'delete_all_warning': '정말로 모든 일기 데이터를 삭제하시겠습니까?\n이 작업은 되돌릴 수 없습니다.',
      'delete_all_confirm': '모든 데이터 삭제',
      'app_name': 'AI 그림일기',
      'app_description': 'AI가 그려주는 특별한 그림일기 앱',
      'privacy_policy_title': '개인정보 처리방침',
      'privacy_policy_content': '개인정보 처리방침 내용이 여기에 표시됩니다...',
      'terms_title': '이용약관',
      'terms_content': '서비스 이용약관 내용이 여기에 표시됩니다...',
      'privacy_policy_subtitle': '개인정보 처리방침을 확인하세요',
      'terms_subtitle': '서비스 이용약관을 확인하세요',
      'ok': '확인',
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
    },
    'ja': {
      'app_title': 'AI絵日記',
      'settings': '設定',
      'personalization': 'カスタマイズ',
      'theme': 'テーマ',
      'theme_subtitle': 'アプリテーマを変更',
      'language': '言語',
      'language_subtitle': 'アプリ言語を変更',
      'font_size': 'フォントサイズ',
      'font_size_subtitle': '日記テキストサイズを調節',
      'notifications': '通知設定',
      'notifications_subtitle': '日記作成リマインダー設定',
      'ai_settings': 'AI設定',
      'default_image_style': 'デフォルト画像スタイル',
      'default_image_style_subtitle': '新しい日記のデフォルト画像スタイル',
      'ai_analysis_strength': 'AI分析強度',
      'ai_analysis_strength_subtitle': '感情・キーワード分析精度',
      'ai_image_guide': 'AI画像ガイド',
      'ai_image_guide_subtitle': '効果的なプロンプト作成法とコツ',
      'data_privacy': 'データとプライバシー',
      'data_backup': 'データバックアップ',
      'data_backup_subtitle': '日記データをバックアップ',
      'data_restore': 'データ復元',
      'data_restore_subtitle': 'バックアップした日記データを復元',
      'delete_all_data': 'すべてのデータを削除',
      'delete_all_data_subtitle': 'すべての日記データを削除',
      'premium': 'プレミアム',
      'premium_upgrade': 'プレミアムアップグレード',
      'premium_upgrade_subtitle': '無制限画像 • プレミアムスタイル • 広告なし',
      'app_info': 'アプリ情報',
      'app_version': 'アプリバージョン',
      'privacy_policy': 'プライバシーポリシー',
      'terms_of_service': '利用規約',
      'cancel': 'キャンセル',
      'confirm': 'OK',
      'close': '閉じる',
      'save': '保存',
      'back': '戻る',
      'refresh': '更新',
      'today': '今日',
      'no_diary_on_date': 'この日には日記がありません',
      'write_diary': '日記を書く',
      'cannot_load_calendar': 'カレンダーを読み込めません',
      'cannot_load_diary': '日記を読み込めません',
      'tags_count': 'タグ',
      'new_diary': '新しい日記',
      'edit_diary': '日記編集',
      'title': 'タイトル',
      'title_hint': '今日のタイトルを入力',
      'diary_content': '日記内容',
      'diary_content_hint': '今日あったことや感情を自由に書いてください。\nAIがあなたの物語を美しい絵に描きます。',
      'please_enter_title': 'タイトルを入力してください',
      'please_enter_content': '日記内容を入力してください',
      'content_too_short': 'もっと詳しく書いてください（最低10文字）',
      'image_style': '画像スタイル',
      'ai_drawing_complete': '保存完了！AIが描いた絵',
      'ai_drawing': 'AIが描いた絵',
      'generate_image': '画像生成',
      'generating_image': 'AIが{style}スタイルで\nあなたの物語を絵に描いています...',
      'please_wait': 'しばらくお待ちください',
      'saving': '保存中...',
      'saved_successfully': '保存完了',
      'diary_saved': '日記が保存されました',
      'diary_updated': '日記が更新されました',
      'image_generation_error': '画像生成エラー: {error}',
      'save_error': '保存エラー: {error}',
      'login_title': 'AI絵日記へ\nようこそ',
      'login_subtitle': 'あなたの物語を美しい絵に',
      'continue_with_google': 'Googleで継続',
      'continue_with_apple': 'Appleで継続',
      'continue_with_email': 'メールで継続',
      'continue_as_guest': 'ゲストで継続',
      'emotion_happy': '幸せ',
      'emotion_sad': '悲しい',
      'emotion_angry': '怒り',
      'emotion_excited': '興奮',
      'emotion_peaceful': '平穏',
      'emotion_anxious': '不安',
      'emotion_grateful': '感謝',
      'emotion_nostalgic': '懐かしさ',
      'emotion_romantic': 'ロマンティック',
      'emotion_frustrated': 'いらいら',
      'emotion_normal': '普通',
      'premium_feature': 'プレミアム機能',
      'upgrade_to_premium': 'プレミアムにアップグレード',
      'free_user_limit': '無料ユーザーは画像修正できません',
      'image_modification_limit': '画像修正上限を超えました',
      'regenerate_image': '画像再生成',
      'keep_existing_image': '現在の画像を保持',
      'image_modification_dialog_title': '画像修正',
      'image_modification_dialog_content': '日記内容を修正しました。\n新しい内容に合わせて画像を再生成しますか？',
      'remaining_generations': '残り生成回数: {count}回',
      'remaining_modifications': '残り修正回数: {count}回',
      'unlimited': '無制限',
      // Search
      'search_hint': '検索内容を入力してください',
      'search_label': '検索',
      'no_entries': 'まだ日記が書かれていません',
      'create_first_entry': '最初の日記を書いてみましょう！',
      'empty_search': '検索結果がありません',
      'try_different_keyword': '別のキーワードで検索してみてください',
      // Navigation & UI
      'diary_list': '日記一覧',
      'calendar': 'カレンダー',
      'diary_search': '日記検索',
      'start_with_ai_diary': 'AIが絵を描いてくれる特別な日記を始めてみましょう',
      'refresh': '更新',
      'calendar_load_error': 'カレンダーを読み込めません',
      // Settings dialog content
      'theme_selection': 'テーマ選択',
      'light_theme': 'ライトテーマ',
      'dark_theme': 'ダークテーマ',
      'system_theme': 'システム設定',
      'font_size_setting': 'フォントサイズ設定',
      'font_size_description': '日記テキストのサイズを選択してください',
      'font_small': '小さく',
      'font_medium': '標準',
      'font_large': '大きく',
      'font_xlarge': '非常に大きく',
      'font_size_changed': 'フォントサイズが「{size}」に設定されました。',
      'notification_settings': '通知設定',
      'notification_description': '日記作成を見逃さないように通知を受け取ってください。',
      'daily_reminder': '日々のリマインダー',
      'daily_reminder_time': '毎日夜9時に通知',
      'weekly_summary': '週間要約',
      'weekly_summary_time': '毎週日曜日午前10時',
      'notification_enabled': '通知が有効化されました。',
      'notification_disabled': '通知が無効化されました。',
      'weekly_notification_enabled': '週間要約通知が有効化されました。',
      'weekly_notification_disabled': '週間要約通知が無効化されました。',
      'premium_upgrade_title': 'プレミアムアップグレード',
      'premium_benefits': 'プレミアムにアップグレードすると:',
      'unlimited_ai_images': '無制限AI画像生成',
      'advanced_image_styles': '50+高級画像スタイル',
      'no_ads': '広告完全除去',
      'cloud_backup': 'クラウド自動バックアップ',
      'advanced_security': '高級セキュリティ機能',
      'later': '後で',
      'monthly_price': '月額￥4,900',
      'premium_coming_soon': 'プレミアム購読は近日提供予定です！',
      'default_image_style_setting': 'デフォルト画像スタイル設定',
      'image_style_description': '新しい日記作成時にデフォルトで選択される画像スタイルを設定してください。',
      'default_style_set': 'デフォルトスタイルが「{style}」に設定されました。',
      'data_backup_title': 'データバックアップ',
      'backup_description': 'すべての日記データをJSONファイルとしてバックアップします。',
      'backup_includes': '含まれる内容:',
      'backup_diary_content': '日記タイトルおよび内容',
      'backup_date_time': '作成日時',
      'backup_emotion_analysis': '感情分析結果',
      'backup_generated_images': '生成された画像 (Base64)',
      'backup_image_style': '画像スタイル情報',
      'backup_start': 'バックアップ開始',
      'backing_up': 'バックアップ中...',
      'backup_completed': 'バックアップ完了！合計{count}件の日記がバックアップされました。',
      'backup_failed': 'バックアップ失敗: {error}',
      'data_restore_title': 'データ復元',
      'restore_description': 'バックアップされた日記データを復元します。',
      'restore_start': '復元開始',
      'delete_all_title': 'すべてのデータを削除',
      'delete_all_warning': '本当にすべての日記データを削除しますか？\nこの操作は元に戻すことができません。',
      'delete_all_confirm': 'すべてのデータを削除',
      'app_name': 'AI絵日記',
      'app_description': 'AIが描いてくれる特別な絵日記アプリ',
      'privacy_policy_title': 'プライバシーポリシー',
      'privacy_policy_content': 'プライバシーポリシーの内容がここに表示されます...',
      'terms_title': '利用規約',
      'terms_content': 'サービス利用規約の内容がここに表示されます...',
      'privacy_policy_subtitle': 'プライバシーポリシーをご確認ください',
      'terms_subtitle': 'サービス利用規約をご確認ください',
      'ok': '確認',
      // Subscription management
      'subscription_management_test': '購読管理 (テスト)',
      'premium_user': 'プレミアムユーザー',
      'free_user': '無料ユーザー',
      'image_generations': '画像生成',
      'image_modifications': '画像修正',
      'set_to_free': '無料ユーザーに設定されました',
      'set_to_premium': 'プレミアムに設定されました',
      'set_free_plan': '無料に設定',
      'set_premium_plan': 'プレミアムに設定',
      // Image styles
      'style_auto': '自動選択',
      'style_realistic': 'リアルスタイル',
      'style_watercolor': '水彩スタイル',
      'style_illustration': 'イラストスタイル',
      'style_sketch': 'スケッチスタイル',
      'style_anime': 'アニメーションスタイル',
      'style_impressionist': '印象派',
      'style_vintage': 'ビンテージスタイル',
      
      // Advanced options
      'advanced_options': '高度なオプション',
      'lighting': 'ライティング',
      'mood': 'ムード', 
      'color': 'カラー',
      'composition': '構図',
      'none': 'なし',
      'clear_all_options': '自動選択',
    },
    'en': {
      'app_title': 'AI Picture Diary',
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
      // Login screen
      'login_title': 'Welcome to\nAI Picture Diary',
      'login_subtitle': 'Turn your stories into beautiful pictures',
      'continue_with_google': 'Continue with Google',
      'continue_with_apple': 'Continue with Apple',
      'continue_with_email': 'Continue with Email',
      'continue_as_guest': 'Continue as Guest',
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
      'refresh': 'Refresh',
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
      'backup_completed': 'Backup complete! {count} diary entries have been backed up.',
      'backup_failed': 'Backup failed: {error}',
      'data_restore_title': 'Data Restore',
      'restore_description': 'Restore backed up diary data.',
      'restore_start': 'Start Restore',
      'delete_all_title': 'Delete All Data',
      'delete_all_warning': 'Are you sure you want to delete all diary data?\nThis action cannot be undone.',
      'delete_all_confirm': 'Delete All Data',
      'app_name': 'AI Picture Diary',
      'app_description': 'Special picture diary app drawn by AI',
      'privacy_policy_title': 'Privacy Policy',
      'privacy_policy_content': 'Privacy policy content will be displayed here...',
      'terms_title': 'Terms of Service',
      'terms_content': 'Terms of service content will be displayed here...',
      'privacy_policy_subtitle': 'Review the privacy policy',
      'terms_subtitle': 'Review the terms of service',
      'ok': 'OK',
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
    },
    'zh': {
      'app_title': 'AI图画日记',
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
      // Login screen
      'login_title': '欢迎使用\nAI图画日记',
      'login_subtitle': '将您的故事变成美丽的图画',
      'continue_with_google': '使用Google继续',
      'continue_with_apple': '使用Apple继续',
      'continue_with_email': '使用邮箱继续',
      'continue_as_guest': '作为访客继续',
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
      'backup_completed': '备份完成！共备份了{count}篇日记。',
      'backup_failed': '备份失败：{error}',
      'data_restore_title': '数据恢复',
      'restore_description': '恢复备份的日记数据。',
      'restore_start': '开始恢复',
      'delete_all_title': '删除所有数据',
      'delete_all_warning': '您确定要删除所有日记数据吗？\n此操作不可撤销。',
      'delete_all_confirm': '删除所有数据',
      'app_name': 'AI图画日记',
      'app_description': 'AI绘制的特殊图画日记应用',
      'privacy_policy_title': '隐私政策',
      'privacy_policy_content': '隐私政策内容将在此处显示...',
      'terms_title': '服务条款',
      'terms_content': '服务条款内容将在此处显示...',
      'privacy_policy_subtitle': '查看隐私政策',
      'terms_subtitle': '查看服务条款',
      'ok': '确定',
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
    },
    'la': {
      'app_title': 'Diarium AI Pictum',
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
      'refresh': 'Renovare',
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
      // Login screen
      'login_title': 'Salve in\nDiarium AI Pictum',
      'login_subtitle': 'Fabulas tuas in pulchras picturas converte',
      'continue_with_google': 'Cum Google pergere',
      'continue_with_apple': 'Cum Apple pergere',
      'continue_with_email': 'Cum epistula pergere',
      'continue_as_guest': 'Ut hospes pergere',
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
      'backup_completed': 'Copia perfecta! {count} diaria copiata sunt.',
      'backup_failed': 'Copia defecit: {error}',
      'data_restore_title': 'Restitutio Datorum',
      'restore_description': 'Restitue data diarii copiata.',
      'restore_start': 'Incipe Restitutionem',
      'delete_all_title': 'Dele Omnia Data',
      'delete_all_warning': 'Certusne es te velle delere omnia data diarii?\nHaec actio revocari non potest.',
      'delete_all_confirm': 'Dele Omnia Data',
      'app_name': 'Diarium AI Pictum',
      'app_description': 'Diarium pictum speciale ab AI depictum',
      'privacy_policy_title': 'Politica Privacitatis',
      'privacy_policy_content': 'Contentum politicae privacitatis hic ostendetur...',
      'terms_title': 'Condiciones Servitii',
      'terms_content': 'Contentum condicionum servitii hic ostendetur...',
      'privacy_policy_subtitle': 'Inspice politicam privacitatis',
      'terms_subtitle': 'Inspice condiciones servitii',
      'ok': 'Recte',
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
  
  // Login screen
  String get loginTitle => _localizedValues[locale.languageCode]!['login_title']!;
  String get loginSubtitle => _localizedValues[locale.languageCode]!['login_subtitle']!;
  String get continueWithGoogle => _localizedValues[locale.languageCode]!['continue_with_google']!;
  String get continueWithApple => _localizedValues[locale.languageCode]!['continue_with_apple']!;
  String get continueWithEmail => _localizedValues[locale.languageCode]!['continue_with_email']!;
  String get continueAsGuest => _localizedValues[locale.languageCode]!['continue_as_guest']!;
  
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
    final languageCode = prefs.getString('locale') ?? 'ko';
    return Locale(languageCode);
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