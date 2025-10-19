import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/image_style_provider.dart';
import '../../providers/auto_advanced_settings_provider.dart';
import '../../providers/subscription_provider.dart';
import '../../models/image_style.dart';
import '../../widgets/premium_dialog.dart';
import '../image_guide_screen.dart';

class AiSettingsScreen extends ConsumerWidget {
  const AiSettingsScreen({super.key});

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
          AppLocalizations.of(context).aiSettings,
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
          _buildAutoAdvancedSettingsTile(context, ref),
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

  void _showStyleDialog(BuildContext context, WidgetRef ref) {
    final currentStyle = ref.watch(defaultImageStyleProvider);
    final subscription = ref.watch(subscriptionProvider);

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

  void _navigateToImageGuide(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ImageGuideScreen(),
      ),
    );
  }

  Widget _buildAutoAdvancedSettingsTile(BuildContext context, WidgetRef ref) {
    final autoAdvancedSettings = ref.watch(autoAdvancedSettingsProvider);
    final subscription = ref.watch(subscriptionProvider);
    final isLocked = !subscription.isPremium;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Opacity(
        opacity: isLocked ? 0.5 : 1.0,
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (isLocked ? Colors.amber : const Color(0xFF667EEA)).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isLocked ? Icons.lock : Icons.settings_suggest,
              color: isLocked ? Colors.amber : const Color(0xFF667EEA),
              size: 20,
            ),
          ),
          title: Text(
            '고급설정 자동설정',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isLocked ? Colors.grey : const Color(0xFF2D3748),
            ),
          ),
          subtitle: Text(
            isLocked ? '프리미엄 전용 기능' : '시간, 날씨, 계절 옵션을 자동으로 설정합니다',
            style: TextStyle(
              color: isLocked ? Colors.grey : const Color(0xFF718096),
              fontSize: 13,
            ),
          ),
          trailing: subscription.isPremium
            ? Switch(
                value: autoAdvancedSettings,
                onChanged: (value) {
                  ref.read(autoAdvancedSettingsProvider.notifier).setAutoAdvancedSettings(value);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(value ? '고급설정 자동설정이 활성화되었습니다' : '고급설정 자동설정이 비활성화되었습니다'),
                      backgroundColor: value ? Colors.green : Colors.orange,
                    ),
                  );
                },
                activeColor: const Color(0xFF667EEA),
              )
            : Icon(
                Icons.chevron_right,
                color: isLocked ? Colors.grey : const Color(0xFF9CA3AF),
              ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          tileColor: Colors.white,
          onTap: subscription.isPremium
            ? () {
                ref.read(autoAdvancedSettingsProvider.notifier).toggle();
              }
            : () => showPremiumRequiredDialog(context, featureName: '고급설정 자동설정'),
        ),
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
