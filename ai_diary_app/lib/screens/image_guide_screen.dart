import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../l10n/app_localizations.dart';
import '../models/image_style.dart';
import '../providers/subscription_provider.dart';

class ImageGuideScreen extends ConsumerWidget {
  const ImageGuideScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscription = ref.watch(subscriptionProvider);
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).aiImageGuide,
          style: GoogleFonts.notoSans(
            color: const Color(0xFF2D3748),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF2D3748),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 기본 가이드
          _buildGuideCard(
            context,
            title: AppLocalizations.of(context).imageGuideEffectivePrompt,
            icon: Icons.edit,
            content: [
              _buildTipItem(
                AppLocalizations.of(context).imageGuideDescribeDetail,
                AppLocalizations.of(context).imageGuideDescribeDetailExample,
                Colors.blue,
              ),
              _buildTipItem(
                AppLocalizations.of(context).imageGuideEmotionMood,
                AppLocalizations.of(context).imageGuideEmotionMoodExample,
                Colors.green,
              ),
              _buildTipItem(
                AppLocalizations.of(context).imageGuideBackgroundEnv,
                AppLocalizations.of(context).imageGuideBackgroundEnvExample,
                Colors.orange,
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // 스타일별 가이드
          _buildGuideCard(
            context,
            title: AppLocalizations.of(context).imageGuideStyleUsage,
            icon: Icons.palette,
            content: [
              // 무료 사용자용 스타일 (실사, 수채화)
              _buildStyleExample(
                context,
                ImageStyle.realistic,
                AppLocalizations.of(context).imageGuideRealisticTitle,
                AppLocalizations.of(context).imageGuideRealisticDesc,
                AppLocalizations.of(context).imageGuideRealisticExample,
              ),
              _buildStyleExample(
                context,
                ImageStyle.watercolor,
                AppLocalizations.of(context).imageGuideWatercolorTitle,
                AppLocalizations.of(context).imageGuideWatercolorDesc,
                AppLocalizations.of(context).imageGuideWatercolorExample,
              ),

              // 프리미엄 사용자만 볼 수 있는 스타일들
              if (subscription.isPremium) ...[
                _buildStyleExample(
                  context,
                  ImageStyle.illustration,
                  AppLocalizations.of(context).imageGuideIllustrationTitle,
                  AppLocalizations.of(context).imageGuideIllustrationDesc,
                  AppLocalizations.of(context).imageGuideIllustrationExample,
                ),
                _buildStyleExample(
                  context,
                  ImageStyle.anime,
                  AppLocalizations.of(context).imageGuideAnimeTitle,
                  AppLocalizations.of(context).imageGuideAnimeDesc,
                  AppLocalizations.of(context).imageGuideAnimeExample,
                ),
                _buildStyleExample(
                  context,
                  ImageStyle.sketch,
                  AppLocalizations.of(context).imageGuideSketchTitle,
                  AppLocalizations.of(context).imageGuideSketchDesc,
                  AppLocalizations.of(context).imageGuideSketchExample,
                ),
                _buildStyleExample(
                  context,
                  ImageStyle.impressionist,
                  AppLocalizations.of(context).imageGuideImpressionistTitle,
                  AppLocalizations.of(context).imageGuideImpressionistDesc,
                  AppLocalizations.of(context).imageGuideImpressionistExample,
                ),
                _buildStyleExample(
                  context,
                  ImageStyle.vintage,
                  AppLocalizations.of(context).imageGuideVintageTitle,
                  AppLocalizations.of(context).imageGuideVintageDesc,
                  AppLocalizations.of(context).imageGuideVintageExample,
                ),
              ] else ...[
                // 무료 사용자에게 프리미엄 스타일 안내
                Container(
                  margin: const EdgeInsets.only(top: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.amber),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            AppLocalizations.of(context).imageGuidePremiumStyles,
                            style: GoogleFonts.notoSans(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppLocalizations.of(context).imageGuidePremiumStylesDesc,
                        style: GoogleFonts.notoSans(
                          fontSize: 14,
                          color: Colors.amber.shade700,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          
          const SizedBox(height: 20),
          
          // 고급 팁
          _buildGuideCard(
            context,
            title: AppLocalizations.of(context).imageGuideAdvancedTips,
            icon: Icons.tips_and_updates,
            content: [
              _buildAdvancedTip(
                AppLocalizations.of(context).imageGuideCombineKeywords,
                AppLocalizations.of(context).imageGuideCombineKeywordsDesc,
                AppLocalizations.of(context).imageGuideCombineKeywordsExample,
                Icons.merge_type,
              ),
              _buildAdvancedTip(
                AppLocalizations.of(context).imageGuideMoodWords,
                AppLocalizations.of(context).imageGuideMoodWordsDesc,
                AppLocalizations.of(context).imageGuideMoodWordsExample,
                Icons.mood,
              ),
              _buildAdvancedTip(
                AppLocalizations.of(context).imageGuideTimeWeather,
                AppLocalizations.of(context).imageGuideTimeWeatherDesc,
                AppLocalizations.of(context).imageGuideTimeWeatherExample,
                Icons.wb_sunny,
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // 고급 옵션 Before/After 비교 (모든 사용자가 볼 수 있음)
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.compare, color: const Color(0xFF6B73FF), size: 24),
                      const SizedBox(width: 12),
                      Text(
                        AppLocalizations.of(context).imageGuideAdvancedOptionsCompare,
                        style: GoogleFonts.notoSans(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2D3748),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context).imageGuideAdvancedOptionsDesc,
                    style: GoogleFonts.notoSans(
                      fontSize: 14,
                      color: const Color(0xFF4A5568),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // 무료 사용자에게만 프리미엄 안내 표시
                  if (!subscription.isPremium)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6B73FF).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFF6B73FF).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.star,
                            color: const Color(0xFF6B73FF),
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              AppLocalizations.of(context).imageGuidePremiumOnlyOptions,
                              style: GoogleFonts.notoSans(
                                fontSize: 12,
                                color: const Color(0xFF6B73FF),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 24),
                  
                  // 배경 스타일 비교
                  _buildImageComparison(
                    context,
                    AppLocalizations.of(context).imageGuideBackgroundStyle,
                    '배경sample_1.png',
                    '배경sample_2.png',
                    AppLocalizations.of(context).imageGuideBasicBackground,
                    AppLocalizations.of(context).imageGuideAdvancedBackground,
                    AppLocalizations.of(context).imageGuideBackgroundChangeDesc,
                  ),

                  const SizedBox(height: 24),

                  // 색감 조정 비교
                  _buildImageComparison(
                    context,
                    AppLocalizations.of(context).imageGuideColorAdjustment,
                    '색감sample_1.png',
                    '색감sample_2.png',
                    AppLocalizations.of(context).imageGuideBasicColor,
                    AppLocalizations.of(context).imageGuideAdvancedColor,
                    AppLocalizations.of(context).imageGuideColorChangeDesc,
                  ),

                  const SizedBox(height: 24),

                  // 앵글 비교
                  _buildImageComparison(
                    context,
                    AppLocalizations.of(context).imageGuideAngleComposition,
                    '앵글sample_1.png',
                    '앵글sample_2.png',
                    AppLocalizations.of(context).imageGuideBasicAngle,
                    AppLocalizations.of(context).imageGuideAdvancedAngle,
                    AppLocalizations.of(context).imageGuideAngleChangeDesc,
                  ),

                  const SizedBox(height: 24),

                  // 조명 효과 비교
                  _buildImageComparison(
                    context,
                    AppLocalizations.of(context).imageGuideLightingEffect,
                    '조명sample_1.png',
                    '조명sample_2.png',
                    AppLocalizations.of(context).imageGuideBasicLighting,
                    AppLocalizations.of(context).imageGuideAdvancedLighting,
                    AppLocalizations.of(context).imageGuideLightingChangeDesc,
                  ),
                  
                  // 무료 사용자에게 업그레이드 안내
                  if (!subscription.isPremium) ...[
                    const SizedBox(height: 24),
                    GestureDetector(
                      onTap: () {
                        // 설정 화면으로 이동
                        context.go('/settings');
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.amber.shade400, Colors.orange.shade400],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.orange.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.star, color: Colors.white, size: 28),
                            const SizedBox(height: 8),
                            Text(
                              AppLocalizations.of(context).imageGuideUpgradePremium,
                              style: GoogleFonts.notoSans(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              AppLocalizations.of(context).imageGuideUpgradeInSettings,
                              style: GoogleFonts.notoSans(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                AppLocalizations.of(context).imageGuideTapToSettings,
                                style: GoogleFonts.notoSans(
                                  fontSize: 11,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // 주의사항
          _buildWarningCard(context),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildGuideCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> content,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xFF6B73FF), size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.notoSans(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2D3748),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...content,
          ],
        ),
      ),
    );
  }

  Widget _buildTipItem(String title, String description, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 6, right: 12),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.notoSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2D3748),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.notoSans(
                    fontSize: 14,
                    color: const Color(0xFF718096),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStyleExample(
    BuildContext context,
    ImageStyle style,
    String name,
    String description,
    String example,
  ) {
    // 스타일에 따른 색상과 아이콘 정의
    Color getStyleColor() {
      switch (style) {
        case ImageStyle.illustration:
          return const Color(0xFF667EEA);
        case ImageStyle.realistic:
          return const Color(0xFF48BB78);
        case ImageStyle.anime:
          return const Color(0xFFED64A6);
        case ImageStyle.sketch:
          return const Color(0xFF4A5568);
        default:
          return const Color(0xFF667EEA);
      }
    }
    
    IconData getStyleIcon() {
      switch (style) {
        case ImageStyle.illustration:
          return Icons.palette;
        case ImageStyle.realistic:
          return Icons.camera_alt;
        case ImageStyle.anime:
          return Icons.face;
        case ImageStyle.sketch:
          return Icons.edit;
        default:
          return Icons.image;
      }
    }
    
    final styleColor = getStyleColor();
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: styleColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: styleColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                getStyleIcon(),
                color: styleColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                name,
                style: GoogleFonts.notoSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2D3748),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: GoogleFonts.notoSans(
              fontSize: 14,
              color: const Color(0xFF4A5568),
              height: 1.5,
            ),
            textAlign: TextAlign.justify,
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: styleColor.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Text(
              example,
              style: GoogleFonts.notoSans(
                fontSize: 13,
                color: const Color(0xFF718096),
                fontStyle: FontStyle.italic,
                height: 1.4,
              ),
              textAlign: TextAlign.left,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancedTip(
    String title,
    String description,
    String example,
    IconData icon,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF6B73FF).withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF6B73FF),
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.notoSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2D3748),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.notoSans(
                    fontSize: 14,
                    color: const Color(0xFF4A5568),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7FAFC),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: const Color(0xFFE2E8F0),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    example,
                    style: GoogleFonts.notoSans(
                      fontSize: 12,
                      color: const Color(0xFF718096),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningCard(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.orange.shade50,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning_amber, color: Colors.orange.shade700, size: 24),
                const SizedBox(width: 12),
                Text(
                  AppLocalizations.of(context).imageGuideCaution,
                  style: GoogleFonts.notoSans(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context).imageGuideCautionContent,
              style: GoogleFonts.notoSans(
                fontSize: 14,
                color: Colors.orange.shade700,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildImageComparison(
    BuildContext context,
    String title,
    String beforeImage,
    String afterImage,
    String beforeLabel,
    String afterLabel,
    String description,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.notoSans(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2D3748),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          description,
          style: GoogleFonts.notoSans(
            fontSize: 14,
            color: const Color(0xFF718096),
            height: 1.4,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            // Before 이미지
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFE2E8F0),
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF7FAFC),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.image_outlined,
                            size: 16,
                            color: Color(0xFF718096),
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              beforeLabel,
                              style: GoogleFonts.notoSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF718096),
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 140,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(10),
                          bottomRight: Radius.circular(10),
                        ),
                      ),
                      child: GestureDetector(
                        onTap: () => _showImageModal(context, 'assets/images/$beforeImage', '$beforeLabel - $title'),
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(10),
                            bottomRight: Radius.circular(10),
                          ),
                          child: Image.asset(
                            'assets/images/$beforeImage',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[200],
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.image_not_supported,
                                      color: Colors.grey,
                                      size: 32,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      beforeImage,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Arrow
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6B73FF).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_forward,
                      color: Color(0xFF6B73FF),
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
            
            // After 이미지
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF6B73FF),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6B73FF).withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6B73FF).withOpacity(0.1),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.stars,
                            size: 16,
                            color: Color(0xFF6B73FF),
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              afterLabel,
                              style: GoogleFonts.notoSans(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF6B73FF),
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 140,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(10),
                          bottomRight: Radius.circular(10),
                        ),
                      ),
                      child: GestureDetector(
                        onTap: () => _showImageModal(context, 'assets/images/$afterImage', '$afterLabel - $title'),
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(10),
                            bottomRight: Radius.circular(10),
                          ),
                          child: Image.asset(
                            'assets/images/$afterImage',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[200],
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.image_not_supported,
                                      color: Colors.grey,
                                      size: 32,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      afterImage,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showImageModal(BuildContext context, String imagePath, String title) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.8),
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(20),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 이미지
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width - 40,
                    maxHeight: MediaQuery.of(context).size.height - 150,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      imagePath,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 300,
                          height: 200,
                          color: Colors.grey[300],
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.image_not_supported,
                                size: 50,
                                color: Colors.grey,
                              ),
                              Text(
                                AppLocalizations.of(context).imageGuideCannotLoadImage,
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
                
                // 제목 (이미지 바로 아래)
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    title,
                    style: GoogleFonts.notoSans(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                
                // X 버튼 (제목 아래)
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 24,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

}