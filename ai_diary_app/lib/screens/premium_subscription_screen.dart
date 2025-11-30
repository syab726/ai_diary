import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/subscription_provider.dart';
import '../models/user_subscription.dart';
import '../l10n/app_localizations.dart';

/// 프리미엄 구독 안내 및 가입 화면
class PremiumSubscriptionScreen extends ConsumerWidget {
  const PremiumSubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscription = ref.watch(subscriptionProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'ArtDiary Premium',
          style: TextStyle(
            color: Color(0xFF2D3748),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF2D3748),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 헤더
            _buildHeader(context),

            const SizedBox(height: 24),

            // 프리미엄 기능 목록
            _buildFeaturesList(context),

            const SizedBox(height: 32),

            // 구독 옵션
            _buildSubscriptionOptions(context, ref, subscription),

            const SizedBox(height: 24),

            // 하단 안내
            _buildFooter(context),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.amber.shade400, Colors.orange.shade600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.diamond,
              size: 48,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context).makeDiarySpecial,
            style: const TextStyle(
              fontSize: 18,
              color: Color(0xFF718096),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesList(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context).premiumFeatures,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 20),
          _buildFeatureItem(
            icon: Icons.block,
            iconColor: Colors.red,
            title: AppLocalizations.of(context).adRemoval,
            description: AppLocalizations.of(context).adRemovalDesc,
          ),
          _buildFeatureItem(
            icon: Icons.text_fields,
            iconColor: Colors.purple,
            title: AppLocalizations.of(context).premiumFonts,
            description: AppLocalizations.of(context).premiumFontsDesc,
          ),
          _buildFeatureItem(
            icon: Icons.palette,
            iconColor: Colors.pink,
            title: AppLocalizations.of(context).premiumArtStyles,
            description: AppLocalizations.of(context).premiumArtStylesDesc,
          ),
          _buildFeatureItem(
            icon: Icons.auto_fix_high,
            iconColor: Colors.blue,
            title: AppLocalizations.of(context).advancedImageOptions,
            description: AppLocalizations.of(context).advancedImageOptionsDesc,
          ),
          _buildFeatureItem(
            icon: Icons.wb_sunny,
            iconColor: Colors.orange,
            title: AppLocalizations.of(context).timeWeatherSeasonSettings,
            description: AppLocalizations.of(context).timeWeatherSeasonSettingsDesc,
          ),
          _buildFeatureItem(
            icon: Icons.photo_library,
            iconColor: Colors.green,
            title: AppLocalizations.of(context).photoUploadMax3,
            description: AppLocalizations.of(context).photoUploadMax3Desc,
          ),
          _buildFeatureItem(
            icon: Icons.cloud_sync,
            iconColor: Colors.indigo,
            title: AppLocalizations.of(context).cloudBackupAuto,
            description: AppLocalizations.of(context).cloudBackupAutoDesc,
          ),
          _buildFeatureItem(
            icon: Icons.all_inclusive,
            iconColor: Colors.teal,
            title: AppLocalizations.of(context).unlimitedImageGeneration,
            description: AppLocalizations.of(context).unlimitedImageGenerationDesc,
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF718096),
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

  Widget _buildSubscriptionOptions(BuildContext context, WidgetRef ref, UserSubscription subscription) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Text(
            AppLocalizations.of(context).subscriptionOptions,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 16),

          // 월간 구독
          _buildSubscriptionCard(
            context: context,
            ref: ref,
            subscription: subscription,
            title: AppLocalizations.of(context).monthlySubscription,
            price: '\$4.99',
            period: '/ 월',
            features: [
              AppLocalizations.of(context).allPremiumFeatures,
              AppLocalizations.of(context).cancelAnytime,
            ],
            isPopular: false,
            onTap: () => _handleSubscription(context, ref, '월간'),
          ),

          const SizedBox(height: 12),

          // 연간 구독 (할인)
          _buildSubscriptionCard(
            context: context,
            ref: ref,
            subscription: subscription,
            title: AppLocalizations.of(context).yearlySubscription,
            price: '\$49.99',
            period: '/ 년',
            originalPrice: '\$59.88',
            discount: '17% 할인',
            features: [
              AppLocalizations.of(context).allPremiumFeatures,
              '월 \$4.17 (약 \$10 절약)',
              AppLocalizations.of(context).cancelAnytime,
            ],
            isPopular: true,
            onTap: () => _handleSubscription(context, ref, '연간'),
          ),

          const SizedBox(height: 12),

          // 평생 구독
          _buildSubscriptionCard(
            context: context,
            ref: ref,
            subscription: subscription,
            title: AppLocalizations.of(context).lifetimeSubscription,
            price: '\$99.99',
            period: '',
            features: [
              AppLocalizations.of(context).allPremiumFeatures,
              AppLocalizations.of(context).lifetimeAccess,
              AppLocalizations.of(context).oneTimePayment,
              AppLocalizations.of(context).bestValue,
            ],
            isPopular: false,
            badge: AppLocalizations.of(context).bestValue,
            badgeColor: Colors.purple,
            onTap: () => _handleSubscription(context, ref, '평생'),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionCard({
    required BuildContext context,
    required WidgetRef ref,
    required UserSubscription subscription,
    required String title,
    required String price,
    required String period,
    String? originalPrice,
    String? discount,
    required List<String> features,
    required bool isPopular,
    String? badge,
    Color? badgeColor,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isPopular || badge != null
            ? Border.all(
                color: badge != null ? badgeColor! : Colors.amber,
                width: 2,
              )
            : Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // 뱃지
          if (isPopular || badge != null)
            Positioned(
              top: 0,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: badge != null
                        ? [const Color(0xFFAB47BC), const Color(0xFF8E24AA)]  // 보라색 그라데이션
                        : [Colors.amber.shade400, Colors.orange.shade600],
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                ),
                child: Text(
                  badge ?? '인기',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 제목
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                ),
                const SizedBox(height: 12),

                // 가격
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      price,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                    if (period.isNotEmpty)
                      Text(
                        period,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF718096),
                        ),
                      ),
                  ],
                ),

                // 할인 정보
                if (originalPrice != null && discount != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        originalPrice,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF718096),
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          discount,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.red.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 16),

                // 기능 목록
                ...features.map((feature) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Colors.green.shade600,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              feature,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF4A5568),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),

                const SizedBox(height: 16),

                // 구독 버튼
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: badge != null
                          ? badgeColor
                          : (isPopular ? Colors.amber : const Color(0xFF667EEA)),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      subscription.isPremium ? AppLocalizations.of(context).currentlySubscribed : AppLocalizations.of(context).subscribe,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
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

  Widget _buildFooter(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          Text(
            AppLocalizations.of(context).subscriptionFooter,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF718096),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  void _handleSubscription(BuildContext context, WidgetRef ref, String type) {
    final subscription = ref.read(subscriptionProvider);

    if (subscription.isPremium) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).alreadyPremium),
          backgroundColor: Colors.green,
        ),
      );
      return;
    }

    // 테스트 모드: 즉시 프리미엄으로 전환
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.blue),
            const SizedBox(width: 8),
            Text(AppLocalizations.of(context).testMode),
          ],
        ),
        content: Text(
          AppLocalizations.of(context).testModeMessage,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(AppLocalizations.of(context).cancel),
          ),
          FilledButton(
            onPressed: () {
              ref.read(subscriptionProvider.notifier).setPremiumUser();
              Navigator.pop(dialogContext);
              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.white),
                      const SizedBox(width: 12),
                      Text(AppLocalizations.of(context).subscriptionCompleted),
                    ],
                  ),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 3),
                ),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.amber,
            ),
            child: Text(AppLocalizations.of(context).subscribeTest),
          ),
        ],
      ),
    );
  }
}
