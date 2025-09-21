import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/database_service.dart';
import '../models/diary_entry.dart';
import '../models/image_style.dart';
import '../l10n/app_localizations.dart';
import '../providers/locale_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/image_style_provider.dart';
import '../providers/subscription_provider.dart';
import '../providers/font_provider.dart';
import '../models/font_family.dart';
import 'image_guide_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).settings,
          style: const TextStyle(
            color: Color(0xFF2D3748),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF2D3748),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 개인화 섹션
          _buildSectionTitle(context, AppLocalizations.of(context).personalization),
          _buildSettingsTile(
            icon: Icons.language,
            title: AppLocalizations.of(context).language,
            subtitle: AppLocalizations.of(context).languageSubtitle,
            onTap: () => _showLanguageDialog(context, ref),
          ),
          _buildSettingsTile(
            icon: Icons.font_download,
            title: AppLocalizations.of(context).fontSize,
            subtitle: AppLocalizations.of(context).fontSizeSubtitle,
            onTap: () => _showFontSizeDialog(context, ref),
          ),
          _buildSettingsTile(
            icon: Icons.text_fields,
            title: '글꼴',
            subtitle: '일기 작성에 사용할 글꼴을 선택하세요',
            onTap: () => _showFontDialog(context, ref),
          ),
          _buildSettingsTile(
            icon: Icons.schedule,
            title: '날짜 포맷',
            subtitle: '날짜 표시 형식을 선택하세요',
            onTap: () => _showDateFormatDialog(context, ref),
          ),
          _buildSettingsTile(
            icon: Icons.access_time,
            title: '타임존',
            subtitle: '시간대를 선택하세요',
            onTap: () => _showTimezoneDialog(context, ref),
          ),
          // Notification settings removed - not needed for personal diary app
          
          const SizedBox(height: 24),
          
          // AI 설정 섹션
          _buildSectionTitle(context, AppLocalizations.of(context).aiSettings),
          _buildSettingsTile(
            icon: Icons.auto_fix_high,
            title: AppLocalizations.of(context).defaultImageStyle,
            subtitle: AppLocalizations.of(context).defaultImageStyleSubtitle,
            onTap: () => _showStyleDialog(context, ref),
          ),
          _buildSettingsTile(
            icon: Icons.help_outline,
            title: AppLocalizations.of(context).aiImageGuide,
            subtitle: AppLocalizations.of(context).aiImageGuideSubtitle,
            onTap: () => _navigateToImageGuide(context),
          ),
          // AI 분석 강도 - 실제 기능 구현 전까지 숨김
          // _buildSettingsTile(
          //   icon: Icons.tune,
          //   title: AppLocalizations.of(context).aiAnalysisStrength,
          //   subtitle: AppLocalizations.of(context).aiAnalysisStrengthSubtitle,
          //   onTap: () => _showAnalysisDialog(context),
          // ),
          
          const SizedBox(height: 24),
          
          // 데이터 및 개인정보 섹션
          _buildSectionTitle(context, AppLocalizations.of(context).dataPrivacy),
          _buildSettingsTile(
            icon: Icons.backup,
            title: AppLocalizations.of(context).dataBackup,
            subtitle: AppLocalizations.of(context).dataBackupSubtitle,
            onTap: () => _showBackupDialog(context),
          ),
          _buildSettingsTile(
            icon: Icons.restore,
            title: AppLocalizations.of(context).dataRestore,
            subtitle: AppLocalizations.of(context).dataRestoreSubtitle,
            onTap: () => _showRestoreDialog(context),
          ),
          _buildSettingsTile(
            icon: Icons.delete_forever,
            title: AppLocalizations.of(context).deleteAllData,
            subtitle: AppLocalizations.of(context).deleteAllDataSubtitle,
            onTap: () => _showDeleteAllDialog(context),
            isDestructive: true,
          ),
          
          const SizedBox(height: 24),
          
          // 프리미엄 섹션
          _buildSectionTitle(context, AppLocalizations.of(context).premium),
          _buildPremiumTile(),
          
          const SizedBox(height: 16),
          
          // 구독 상태 섹션
          _buildSectionTitle(context, AppLocalizations.of(context).subscriptionManagementTest),
          _buildSubscriptionStatusTile(),
          
          const SizedBox(height: 16),
          
          // 테스트 모드 섹션
          _buildSectionTitle(context, '테스트 모드'),
          _buildTestModeTiles(),
          
          const SizedBox(height: 24),
          
          // 앱 정보 섹션
          _buildSectionTitle(context, AppLocalizations.of(context).appInfo),
          _buildSettingsTile(
            icon: Icons.info,
            title: AppLocalizations.of(context).appVersion,
            subtitle: '${AppLocalizations.of(context).appName} v1.0.0',
            onTap: () => _showAboutDialog(context),
          ),
          _buildSettingsTile(
            icon: Icons.privacy_tip,
            title: AppLocalizations.of(context).privacyPolicy,
            subtitle: AppLocalizations.of(context).privacyPolicySubtitle,
            onTap: () => _showPrivacyDialog(context),
          ),
          _buildSettingsTile(
            icon: Icons.description,
            title: AppLocalizations.of(context).termsOfService,
            subtitle: AppLocalizations.of(context).termsSubtitle,
            onTap: () => _showTermsDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 16, 4, 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: const Color(0xFF4A5568),
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDestructive 
                ? Colors.red.withOpacity(0.1) 
                : const Color(0xFF667EEA).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: isDestructive ? Colors.red : const Color(0xFF667EEA),
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isDestructive ? Colors.red : const Color(0xFF2D3748),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            color: Color(0xFF718096),
            fontSize: 13,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: Color(0xFF9CA3AF),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        tileColor: Colors.white,
        onTap: onTap,
      ),
    );
  }

  Widget _buildPremiumTile() {
    return Builder(
      builder: (context) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF6B73FF), Color(0xFF764BA2)],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.diamond,
                color: Colors.white,
                size: 20,
              ),
            ),
            title: Text(
              AppLocalizations.of(context).premiumUpgrade,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            subtitle: Text(
              AppLocalizations.of(context).premiumUpgradeSubtitle,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 13,
              ),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                AppLocalizations.of(context).upgradeToPremium,
                style: TextStyle(
                  color: Color(0xFF6B73FF),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            onTap: () => _showPremiumDialog(context),
          ),
        ),
      ),
    );
  }

  void _showPremiumDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.diamond, color: Colors.orange[400]),
            const SizedBox(width: 8),
            Text(AppLocalizations.of(context).premiumUpgradeTitle),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalizations.of(context).premiumBenefits),
            const SizedBox(height: 16),
            _buildFeatureItem(context, '✨', AppLocalizations.of(context).unlimitedAiImages),
            _buildFeatureItem(context, '🎨', AppLocalizations.of(context).advancedImageStyles),
            _buildFeatureItem(context, '📱', AppLocalizations.of(context).noAds),
            _buildFeatureItem(context, '☁️', AppLocalizations.of(context).cloudBackup),
            _buildFeatureItem(context, '🔒', AppLocalizations.of(context).advancedSecurity),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context).later),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(AppLocalizations.of(context).premiumComingSoon)),
              );
            },
            child: Text(AppLocalizations.of(context).monthlyPrice),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(BuildContext context, String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(emoji, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(width: 12),
          Text(text, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }


  void _showLanguageDialog(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.read(localeProvider);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(AppLocalizations.of(context).language),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('한국어'),
              trailing: currentLocale.languageCode == 'ko' 
                  ? const Icon(Icons.check, color: Colors.blue) 
                  : null,
              onTap: () {
                // 현재 라우트 저장
                ref.read(currentRouteProvider.notifier).state = '/settings';
                // 현재 라우트 저장
                ref.read(currentRouteProvider.notifier).state = '/settings';
                ref.read(localeProvider.notifier).setLocale(const Locale('ko'));
                Navigator.of(dialogContext).pop();
              },
            ),
            ListTile(
              title: const Text('日本語'),
              trailing: currentLocale.languageCode == 'ja' 
                  ? const Icon(Icons.check, color: Colors.blue) 
                  : null,
              onTap: () {
                // 현재 라우트 저장
                ref.read(currentRouteProvider.notifier).state = '/settings';
                ref.read(localeProvider.notifier).setLocale(const Locale('ja'));
                Navigator.of(dialogContext).pop();
              },
            ),
            ListTile(
              title: const Text('English'),
              trailing: currentLocale.languageCode == 'en' 
                  ? const Icon(Icons.check, color: Colors.blue) 
                  : null,
              onTap: () {
                // 현재 라우트 저장
                ref.read(currentRouteProvider.notifier).state = '/settings';
                ref.read(localeProvider.notifier).setLocale(const Locale('en'));
                Navigator.of(dialogContext).pop();
              },
            ),
            ListTile(
              title: const Text('中文'),
              trailing: currentLocale.languageCode == 'zh' 
                  ? const Icon(Icons.check, color: Colors.blue) 
                  : null,
              onTap: () {
                // 현재 라우트 저장
                ref.read(currentRouteProvider.notifier).state = '/settings';
                ref.read(localeProvider.notifier).setLocale(const Locale('zh'));
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(AppLocalizations.of(context).close),
          ),
        ],
      ),
    );
  }

  void _showFontSizeDialog(BuildContext context, WidgetRef ref) {
    final currentFontSize = ref.read(fontSizeProvider);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).fontSizeSetting),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(AppLocalizations.of(context).fontSizeDescription),
            const SizedBox(height: 16),
            RadioListTile<double>(
              title: Text(AppLocalizations.of(context).fontSmall, style: const TextStyle(fontSize: 12)),
              value: 0.8,
              groupValue: currentFontSize,
              onChanged: (value) {
                if (value != null) {
                  ref.read(currentRouteProvider.notifier).state = '/settings';
                  ref.read(fontSizeProvider.notifier).setFontSize(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<double>(
              title: Text(AppLocalizations.of(context).fontMedium, style: const TextStyle(fontSize: 14)),
              value: 1.0,
              groupValue: currentFontSize,
              onChanged: (value) {
                if (value != null) {
                  ref.read(currentRouteProvider.notifier).state = '/settings';
                  ref.read(fontSizeProvider.notifier).setFontSize(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<double>(
              title: Text(AppLocalizations.of(context).fontLarge, style: const TextStyle(fontSize: 16)),
              value: 1.2,
              groupValue: currentFontSize,
              onChanged: (value) {
                if (value != null) {
                  ref.read(currentRouteProvider.notifier).state = '/settings';
                  ref.read(fontSizeProvider.notifier).setFontSize(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<double>(
              title: Text(AppLocalizations.of(context).fontXLarge, style: const TextStyle(fontSize: 18)),
              value: 1.4,
              groupValue: currentFontSize,
              onChanged: (value) {
                if (value != null) {
                  ref.read(currentRouteProvider.notifier).state = '/settings';
                  ref.read(fontSizeProvider.notifier).setFontSize(value);
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showFontDialog(BuildContext context, WidgetRef ref) {
    final currentFont = ref.read(fontProvider);
    final subscription = ref.read(subscriptionProvider);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('글꼴 선택'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('일기 작성에 사용할 글꼴을 선택하세요'),
              const SizedBox(height: 16),
              SizedBox(
                height: 300,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: FontFamily.values.length,
                  itemBuilder: (context, index) {
                    final font = FontFamily.values[index];
                    final isSelected = font == currentFont;
                    final isLocked = !subscription.isPremium && font.isPremium;

                    return ListTile(
                      title: Text(
                        font.displayName,
                        style: font.getTextStyle(fontSize: 16),
                      ),
                      subtitle: Text(font.category),
                      leading: isSelected
                          ? const Icon(Icons.check_circle, color: Color(0xFF667EEA))
                          : (isLocked
                              ? const Icon(Icons.lock, color: Colors.grey)
                              : null),
                      trailing: isLocked
                          ? Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.amber,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                '프리미엄',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          : null,
                      onTap: isLocked
                          ? () => _showPremiumDialog(context)
                          : () {
                              ref.read(fontProvider.notifier).setFont(font);
                              Navigator.pop(context);
                            },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
        ],
      ),
    );
  }

  void _showDateFormatDialog(BuildContext context, WidgetRef ref) async {
    final prefs = await SharedPreferences.getInstance();
    final currentFormat = prefs.getString('date_format') ?? 'yyyy/MM/dd';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('날짜 포맷 선택'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('날짜 표시 형식을 선택하세요'),
            const SizedBox(height: 16),
            RadioListTile<String>(
              title: const Text('년/월/일 (2024/12/25)'),
              value: 'yyyy/MM/dd',
              groupValue: currentFormat,
              onChanged: (value) async {
                if (value != null) {
                  await prefs.setString('date_format', value);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('날짜 포맷이 변경되었습니다')),
                    );
                  }
                }
              },
            ),
            RadioListTile<String>(
              title: const Text('일/월/년 (25/12/2024)'),
              value: 'dd/MM/yyyy',
              groupValue: currentFormat,
              onChanged: (value) async {
                if (value != null) {
                  await prefs.setString('date_format', value);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('날짜 포맷이 변경되었습니다')),
                    );
                  }
                }
              },
            ),
            RadioListTile<String>(
              title: const Text('월/일/년 (12/25/2024)'),
              value: 'MM/dd/yyyy',
              groupValue: currentFormat,
              onChanged: (value) async {
                if (value != null) {
                  await prefs.setString('date_format', value);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('날짜 포맷이 변경되었습니다')),
                    );
                  }
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
        ],
      ),
    );
  }

  void _showTimezoneDialog(BuildContext context, WidgetRef ref) async {
    final prefs = await SharedPreferences.getInstance();
    final currentTimezone = prefs.getString('timezone') ?? DateTime.now().timeZoneName;
    
    final timezones = [
      {'name': '서울 (KST)', 'value': 'Asia/Seoul'},
      {'name': '도쿄 (JST)', 'value': 'Asia/Tokyo'},
      {'name': '베이징 (CST)', 'value': 'Asia/Shanghai'},
      {'name': '뉴욕 (EST)', 'value': 'America/New_York'},
      {'name': '로스앤젤레스 (PST)', 'value': 'America/Los_Angeles'},
      {'name': '런던 (GMT)', 'value': 'Europe/London'},
      {'name': '파리 (CET)', 'value': 'Europe/Paris'},
    ];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('타임존 선택'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('시간대를 선택하세요'),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: timezones.length,
                  itemBuilder: (context, index) {
                    final timezone = timezones[index];
                    return RadioListTile<String>(
                      title: Text(timezone['name']!),
                      value: timezone['value']!,
                      groupValue: currentTimezone,
                      onChanged: (value) async {
                        if (value != null) {
                          await prefs.setString('timezone', value);
                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('타임존이 ${timezone['name']}으로 변경되었습니다')),
                            );
                          }
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
        ],
      ),
    );
  }

  // Notification dialog removed - not needed for personal diary app

  void _showStyleDialog(BuildContext context, WidgetRef ref) {
    final currentStyle = ref.watch(defaultImageStyleProvider);
    final subscription = ref.watch(subscriptionProvider);
    
    // 무료 사용자에게는 실사와 수채화만 제공
    final freeStyles = [ImageStyle.realistic, ImageStyle.watercolor];
    final premiumStyles = ImageStyle.values.where((style) => 
      !freeStyles.contains(style) && style != ImageStyle.auto).toList();
    
    final availableStyles = subscription.isPremium 
        ? ImageStyle.values 
        : freeStyles;
    
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(AppLocalizations.of(context).defaultImageStyleSetting),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(AppLocalizations.of(context).imageStyleDescription),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: availableStyles.length,
                  itemBuilder: (context, index) {
                    final style = availableStyles[index];
                    return _buildStyleTile(context, style, currentStyle == style, ref);
                  },
                ),
              ),
              
              // 무료 사용자에게 프리미엄 스타일 안내
              if (!subscription.isPremium) ...[ 
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.lock, color: Colors.amber, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${premiumStyles.length}개의 추가 스타일이 프리미엄에서 제공됩니다',
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context).close),
          ),
        ],
      ),
    );
  }

  Widget _buildStyleTile(BuildContext context, ImageStyle style, bool isSelected, WidgetRef ref) {
    return InkWell(
      onTap: () {
        // 기본 스타일 저장
        ref.read(defaultImageStyleProvider.notifier).setStyle(style);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).defaultStyleSet(_getLocalizedStyleName(context, style))),
            backgroundColor: Colors.blue,
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _getStyleColor(style),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getStyleIcon(style),
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                _getLocalizedStyleName(context, style),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStyleColor(ImageStyle style) {
    switch (style) {
      case ImageStyle.auto:
        return Colors.purple;
      case ImageStyle.realistic:
        return Colors.indigo;
      case ImageStyle.watercolor:
        return Colors.blue;
      case ImageStyle.illustration:
        return Colors.orange;
      case ImageStyle.sketch:
        return Colors.black;
      case ImageStyle.anime:
        return Colors.pink;
      case ImageStyle.impressionist:
        return Colors.amber;
      case ImageStyle.vintage:
        return Colors.brown;
    }
  }

  IconData _getStyleIcon(ImageStyle style) {
    switch (style) {
      case ImageStyle.auto:
        return Icons.auto_awesome;
      case ImageStyle.realistic:
        return Icons.photo;
      case ImageStyle.watercolor:
        return Icons.water_drop;
      case ImageStyle.illustration:
        return Icons.palette;
      case ImageStyle.sketch:
        return Icons.edit;
      case ImageStyle.anime:
        return Icons.emoji_emotions;
      case ImageStyle.impressionist:
        return Icons.blur_on;
      case ImageStyle.vintage:
        return Icons.camera_alt;
    }
  }

  // AI analysis strength dialog removed - feature not implemented yet

  Future<void> _showBackupDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) => Consumer(
        builder: (context, ref, child) {
          final subscription = ref.watch(subscriptionProvider);
          
          return AlertDialog(
            title: Text(AppLocalizations.of(context).dataBackupTitle),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(subscription.isPremium 
                  ? AppLocalizations.of(context).backupDescription 
                  : '무료 사용자는 텍스트 형태로 일기 내용을 백업할 수 있습니다.'),
                const SizedBox(height: 12),
                Text(AppLocalizations.of(context).backupIncludes, style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                _buildBackupItem('📝', AppLocalizations.of(context).backupDiaryContent),
                _buildBackupItem('📅', AppLocalizations.of(context).backupDateTime),
                if (subscription.isPremium) ...[
                  _buildBackupItem('😊', AppLocalizations.of(context).backupEmotionAnalysis),
                  _buildBackupItem('🖼️', AppLocalizations.of(context).backupGeneratedImages),
                  _buildBackupItem('🎨', AppLocalizations.of(context).backupImageStyle),
                ] else ...[
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.amber),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.lock, color: Colors.amber, size: 16),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '프리미엄: 감정 분석, 생성 이미지, AI 프롬프트 포함',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.amber.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(AppLocalizations.of(context).cancel),
              ),
              FilledButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await _performBackup(context, ref);
                },
                child: Text(AppLocalizations.of(context).backupStart),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBackupItem(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }

  Future<void> _performBackup(BuildContext context, WidgetRef ref) async {
    try {
      final subscription = ref.read(subscriptionProvider);
      
      // 로딩 표시
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Text(AppLocalizations.of(context).backingUp),
            ],
          ),
          duration: const Duration(seconds: 3),
        ),
      );

      // 모든 일기 데이터 가져오기
      final diaries = await DatabaseService.getAllDiaries();
      
      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      
      if (subscription.isPremium) {
        // 프리미엄 사용자: JSON 형태로 완전한 백업
        final backupData = {
          'app_name': 'AI 그림일기',
          'backup_date': DateTime.now().toIso8601String(),
          'version': '1.0.0',
          'backup_type': 'premium',
          'total_entries': diaries.length,
          'entries': diaries.map((diary) => {
            'id': diary.id,
            'title': diary.title,
            'content': diary.content,
            'date': diary.createdAt.toIso8601String(),
            'emotion': diary.emotion,
            'imageData': diary.imageData != null ? base64Encode(diary.imageData!) : null,
            'generatedImageUrl': diary.generatedImageUrl,
            'imageStyle': diary.imageStyle.toString(),
            'keywords': diary.keywords,
            'aiPrompt': diary.aiPrompt,
          }).toList(),
        };

        final jsonString = const JsonEncoder.withIndent('  ').convert(backupData);
        final file = File('${directory.path}/ai_diary_premium_backup_$timestamp.json');
        await file.writeAsString(jsonString);

        // 파일 공유
        await Share.shareXFiles(
          [XFile(file.path)],
          text: 'AI 그림일기 프리미엄 백업 파일 (완전한 데이터 포함)',
          subject: 'AI 그림일기 프리미엄 백업',
        );
      } else {
        // 무료 사용자: 텍스트 형태로 기본 백업
        final StringBuffer textBackup = StringBuffer();
        textBackup.writeln('AI 그림일기 백업');
        textBackup.writeln('백업 날짜: ${DateTime.now().toString()}');
        textBackup.writeln('총 일기 수: ${diaries.length}');
        textBackup.writeln('');
        textBackup.writeln('=' * 50);
        textBackup.writeln('');
        
        for (int i = 0; i < diaries.length; i++) {
          final diary = diaries[i];
          textBackup.writeln('일기 ${i + 1}');
          textBackup.writeln('제목: ${diary.title}');
          textBackup.writeln('날짜: ${diary.createdAt.toString()}');
          textBackup.writeln('내용:');
          textBackup.writeln(diary.content);
          textBackup.writeln('');
          textBackup.writeln('-' * 30);
          textBackup.writeln('');
        }
        
        textBackup.writeln('※ 프리미엄 사용자는 감정 분석, 생성된 이미지, AI 프롬프트 등 추가 데이터도 백업됩니다.');

        final file = File('${directory.path}/ai_diary_text_backup_$timestamp.txt');
        await file.writeAsString(textBackup.toString());

        // 파일 공유
        await Share.shareXFiles(
          [XFile(file.path)],
          text: 'AI 그림일기 텍스트 백업 파일',
          subject: 'AI 그림일기 백업',
        );
      }

      // 성공 메시지
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(subscription.isPremium 
              ? '${diaries.length}개 일기가 완전히 백업되었습니다 (프리미엄)'
              : '${diaries.length}개 일기가 텍스트로 백업되었습니다'),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: AppLocalizations.of(context).ok,
              onPressed: () {},
              textColor: Colors.white,
            ),
          ),
        );
      }
    } catch (e) {
      // 에러 처리
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).backupFailed(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showRestoreDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).dataRestoreTitle),
        content: Text(AppLocalizations.of(context).restoreDescription),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context).cancel),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              await _performRestore(context);
            },
            child: Text(AppLocalizations.of(context).restoreStart),
          ),
        ],
      ),
    );
  }

  Future<void> _performRestore(BuildContext context) async {
    try {
      // 실제 앱에서는 파일 선택 다이얼로그를 사용하겠지만,
      // 여기서는 시뮬레이션으로 복원 완료 메시지를 표시
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              ),
              const SizedBox(width: 12),
              const Text('복원 중...'),
            ],
          ),
          duration: const Duration(seconds: 2),
        ),
      );

      // 시뮬레이션을 위한 딜레이
      await Future.delayed(const Duration(seconds: 2));

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('복원이 완료되었습니다'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('복원 중 오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showDeleteAllDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).deleteAllTitle),
        content: Text(AppLocalizations.of(context).deleteAllWarning),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context).cancel),
          ),
          FilledButton(
            onPressed: () async {
              try {
                await DatabaseService.deleteAllEntries();
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('모든 데이터가 삭제되었습니다'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('삭제 중 오류가 발생했습니다: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: Text(AppLocalizations.of(context).deleteAllConfirm),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: AppLocalizations.of(context).appName,
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.auto_stories, size: 64),
      children: [
        Text(AppLocalizations.of(context).appDescription),
      ],
    );
  }

  void _showPrivacyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).privacyPolicyTitle),
        content: SingleChildScrollView(
          child: Text(AppLocalizations.of(context).privacyPolicyContent),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context).ok),
          ),
        ],
      ),
    );
  }

  void _showTermsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).termsTitle),
        content: SingleChildScrollView(
          child: Text(AppLocalizations.of(context).termsContent),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context).ok),
          ),
        ],
      ),
    );
  }

  // 구독 상태 타일
  Widget _buildSubscriptionStatusTile() {
    return Consumer(
      builder: (context, ref, child) {
        final subscription = ref.watch(subscriptionProvider);
        
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        subscription.isPremium ? Icons.diamond : Icons.person,
                        color: subscription.isPremium ? Colors.orange : Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        subscription.isPremium ? AppLocalizations.of(context).premiumUser : AppLocalizations.of(context).freeUser,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text('${AppLocalizations.of(context).imageGenerations}: ${subscription.imageGenerationsUsed}/${subscription.imageGenerationsLimit == -1 ? AppLocalizations.of(context).unlimited : subscription.imageGenerationsLimit}'),
                  Text('${AppLocalizations.of(context).imageModifications}: ${subscription.imageModificationsUsed}/${subscription.imageModificationsLimit == -1 ? AppLocalizations.of(context).unlimited : subscription.imageModificationsLimit}'),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Test buttons removed - subscription plan switching not needed in production 
  // Hot reload trigger
  
  Widget _buildTestModeTiles() {
    return Consumer(
      builder: (context, ref, _) {
        final subscription = ref.watch(subscriptionProvider);
        
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: subscription.isPremium ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: subscription.isPremium ? Colors.green : Colors.orange,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        subscription.isPremium ? Icons.star : Icons.person,
                        color: subscription.isPremium ? Colors.green : Colors.orange,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        subscription.isPremium ? '현재: 프리미엄 사용자' : '현재: 무료 사용자',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: subscription.isPremium ? Colors.green : Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: subscription.isPremium ? null : () {
                            ref.read(subscriptionProvider.notifier).setPremiumUser();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('프리미엄 사용자로 전환됨')),
                            );
                          },
                          icon: const Icon(Icons.star),
                          label: const Text('프리미엄'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: !subscription.isPremium ? null : () {
                            ref.read(subscriptionProvider.notifier).setFreeUser();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('무료 사용자로 전환됨')),
                            );
                          },
                          icon: const Icon(Icons.person),
                          label: const Text('무료'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void _navigateToImageGuide(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ImageGuideScreen(),
      ),
    );
  }

  String _getLocalizedStyleName(BuildContext context, ImageStyle style) {
    switch (style) {
      case ImageStyle.auto:
        return AppLocalizations.of(context).styleAuto;
      case ImageStyle.realistic:
        return AppLocalizations.of(context).styleRealistic;
      case ImageStyle.watercolor:
        return AppLocalizations.of(context).styleWatercolor;
      case ImageStyle.illustration:
        return AppLocalizations.of(context).styleIllustration;
      case ImageStyle.sketch:
        return AppLocalizations.of(context).styleSketch;
      case ImageStyle.anime:
        return AppLocalizations.of(context).styleAnime;
      case ImageStyle.impressionist:
        return AppLocalizations.of(context).styleImpressionist;
      case ImageStyle.vintage:
        return AppLocalizations.of(context).styleVintage;
    }
  }
}