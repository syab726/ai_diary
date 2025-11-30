import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/locale_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/font_provider.dart';
import '../../providers/subscription_provider.dart';
import '../../models/font_family.dart';
import '../../widgets/premium_dialog.dart';

class PersonalizationSettingsScreen extends ConsumerWidget {
  const PersonalizationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppLocalizations.of(context).personalization,
          style: const TextStyle(
            color: Color(0xFF2D3748),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF2D3748),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
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
            title: AppLocalizations.of(context).font,
            subtitle: AppLocalizations.of(context).selectFontDescription,
            onTap: () => _showFontDialog(context, ref),
          ),
          _buildSettingsTile(
            icon: Icons.schedule,
            title: AppLocalizations.of(context).dateFormat,
            subtitle: AppLocalizations.of(context).selectDateFormatDescription,
            onTap: () => _showDateFormatDialog(context, ref),
          ),
          _buildSettingsTile(
            icon: Icons.access_time,
            title: AppLocalizations.of(context).timezone,
            subtitle: AppLocalizations.of(context).selectTimezoneDescription,
            onTap: () => _showTimezoneDialog(context, ref),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF667EEA).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF667EEA),
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D3748),
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
        title: Text(AppLocalizations.of(context).selectFont),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(AppLocalizations.of(context).selectFontDescription),
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

                    return Opacity(
                      opacity: isLocked ? 0.5 : 1.0,
                      child: ListTile(
                        title: Text(
                          font.displayName,
                          style: font.getTextStyle(
                            fontSize: 16,
                          ).copyWith(
                            color: isLocked ? Colors.grey : null,
                          ),
                        ),
                        subtitle: Builder(
                          builder: (context) => Text(
                            isLocked ? AppLocalizations.of(context).premiumOnlyFont : font.category,
                            style: TextStyle(
                              color: isLocked ? Colors.grey : const Color(0xFF718096),
                              fontSize: 13,
                            ),
                          ),
                        ),
                        leading: isSelected
                            ? Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF667EEA).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.check_circle,
                                  color: Color(0xFF667EEA),
                                  size: 20,
                                ),
                              )
                            : (isLocked
                                ? Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.amber.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.lock,
                                      color: Colors.amber,
                                      size: 20,
                                    ),
                                  )
                                : null),
                        onTap: isLocked
                            ? () {
                                Navigator.pop(context);
                                showPremiumRequiredDialog(context, featureName: font.displayName);
                              }
                            : () {
                                ref.read(fontProvider.notifier).setFont(font);
                                Navigator.pop(context);
                              },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          Builder(
            builder: (context) => TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context).cancel),
            ),
          ),
        ],
      ),
    );
  }

  void _showDateFormatDialog(BuildContext context, WidgetRef ref) async {
    final prefs = await SharedPreferences.getInstance();
    final currentFormat = prefs.getString('date_format') ?? 'yyyy/MM/dd';

    if (context.mounted) {
      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(AppLocalizations.of(context).selectDateFormat),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(AppLocalizations.of(context).selectDateFormatDescription),
              const SizedBox(height: 16),
              RadioListTile<String>(
                title: Text(AppLocalizations.of(context).dateFormatYmd),
                value: 'yyyy/MM/dd',
                groupValue: currentFormat,
                onChanged: (value) async {
                  if (value != null) {
                    await prefs.setString('date_format', value);
                    if (context.mounted) {
                      Navigator.pop(dialogContext);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(AppLocalizations.of(context).dateFormatChanged)),
                      );
                    }
                  }
                },
              ),
              RadioListTile<String>(
                title: Text(AppLocalizations.of(context).dateFormatDmy),
                value: 'dd/MM/yyyy',
                groupValue: currentFormat,
                onChanged: (value) async {
                  if (value != null) {
                    await prefs.setString('date_format', value);
                    if (context.mounted) {
                      Navigator.pop(dialogContext);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(AppLocalizations.of(context).dateFormatChanged)),
                      );
                    }
                  }
                },
              ),
              RadioListTile<String>(
                title: Text(AppLocalizations.of(context).dateFormatMdy),
                value: 'MM/dd/yyyy',
                groupValue: currentFormat,
                onChanged: (value) async {
                  if (value != null) {
                    await prefs.setString('date_format', value);
                    if (context.mounted) {
                      Navigator.pop(dialogContext);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(AppLocalizations.of(context).dateFormatChanged)),
                      );
                    }
                  }
                },
              ),
            ],
          ),
          actions: [
            Builder(
              builder: (context) => TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(AppLocalizations.of(context).cancel),
              ),
            ),
          ],
        ),
      );
    }
  }

  void _showTimezoneDialog(BuildContext context, WidgetRef ref) async {
    final prefs = await SharedPreferences.getInstance();
    final currentTimezone = prefs.getString('timezone') ?? DateTime.now().timeZoneName;

    if (context.mounted) {
      final timezones = [
        {'name': AppLocalizations.of(context).timezoneSeoul, 'value': 'Asia/Seoul'},
        {'name': AppLocalizations.of(context).timezoneTokyo, 'value': 'Asia/Tokyo'},
        {'name': AppLocalizations.of(context).timezoneBeijing, 'value': 'Asia/Shanghai'},
        {'name': AppLocalizations.of(context).timezoneNewYork, 'value': 'America/New_York'},
        {'name': AppLocalizations.of(context).timezoneLosAngeles, 'value': 'America/Los_Angeles'},
        {'name': AppLocalizations.of(context).timezoneLondon, 'value': 'Europe/London'},
        {'name': AppLocalizations.of(context).timezoneParis, 'value': 'Europe/Paris'},
      ];

      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(AppLocalizations.of(context).selectTimezone),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(AppLocalizations.of(context).selectTimezoneDescription),
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
                              Navigator.pop(dialogContext);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    AppLocalizations.of(context).timezoneChangedFormat.replaceAll('{name}', timezone['name']!),
                                  ),
                                ),
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
            Builder(
              builder: (context) => TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(AppLocalizations.of(context).cancel),
              ),
            ),
          ],
        ),
      );
    }
  }
}
