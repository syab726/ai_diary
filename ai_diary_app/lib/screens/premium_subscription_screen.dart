import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/subscription_provider.dart';
import '../models/user_subscription.dart';

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
          onPressed: () => context.go('/list'),
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
            _buildHeader(),

            const SizedBox(height: 24),

            // 프리미엄 기능 목록
            _buildFeaturesList(),

            const SizedBox(height: 32),

            // 구독 옵션
            _buildSubscriptionOptions(context, ref, subscription),

            const SizedBox(height: 24),

            // 하단 안내
            _buildFooter(),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
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
          const Text(
            '당신의 일기를 더욱 특별하게',
            style: TextStyle(
              fontSize: 18,
              color: Color(0xFF718096),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesList() {
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
          const Text(
            '프리미엄 기능',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 20),
          _buildFeatureItem(
            icon: Icons.block,
            iconColor: Colors.red,
            title: '광고 제거',
            description: '모든 광고 없이\n쾌적한 일기 작성 경험',
          ),
          _buildFeatureItem(
            icon: Icons.text_fields,
            iconColor: Colors.purple,
            title: '프리미엄 글꼴',
            description: '10가지 아름다운 한글 글꼴\n개구쟁이체, 독도체, 나눔손글씨 펜 등',
          ),
          _buildFeatureItem(
            icon: Icons.palette,
            iconColor: Colors.pink,
            title: '프리미엄 아트 스타일',
            description: '6가지 추가 스타일\n일러스트, 스케치, 애니메이션, 인상파, 빈티지',
          ),
          _buildFeatureItem(
            icon: Icons.auto_fix_high,
            iconColor: Colors.blue,
            title: '고급 이미지 옵션',
            description: '조명, 분위기, 색상, 구도 등\n세밀한 이미지 생성 설정',
          ),
          _buildFeatureItem(
            icon: Icons.wb_sunny,
            iconColor: Colors.orange,
            title: '시간대/날씨/계절 설정',
            description: '아침, 저녁, 비오는 날, 봄 등\n상황에 맞는 이미지 생성',
          ),
          _buildFeatureItem(
            icon: Icons.photo_library,
            iconColor: Colors.green,
            title: '사진 업로드 (최대 3장)',
            description: '내 사진을 바탕으로\nAI 이미지 생성 가능',
          ),
          _buildFeatureItem(
            icon: Icons.cloud_sync,
            iconColor: Colors.indigo,
            title: '클라우드 백업 & 자동 백업',
            description: 'Google Drive 자동 백업\n소중한 일기를 안전하게 보관',
          ),
          _buildFeatureItem(
            icon: Icons.all_inclusive,
            iconColor: Colors.teal,
            title: '무제한 이미지 생성',
            description: '하루 3개 제한 없이\n무제한으로 일기 생성 가능',
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
          const Text(
            '구독 옵션',
            style: TextStyle(
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
            title: '월간 구독',
            price: '\$4.99',
            period: '/ 월',
            features: [
              '모든 프리미엄 기능',
              '언제든지 취소 가능',
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
            title: '연간 구독',
            price: '\$49.99',
            period: '/ 년',
            originalPrice: '\$59.88',
            discount: '17% 할인',
            features: [
              '모든 프리미엄 기능',
              '월 \$4.17 (약 \$10 절약)',
              '언제든지 취소 가능',
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
            title: '평생 구독',
            price: '\$99.99',
            period: '',
            features: [
              '모든 프리미엄 기능',
              '평생 사용 가능',
              '단 한 번의 결제',
              '최고의 가치',
            ],
            isPopular: false,
            badge: '최고 가치',
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
                      subscription.isPremium ? '현재 구독 중' : '구독하기',
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

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          Text(
            '• 구독은 언제든지 취소할 수 있습니다\n• 취소 시 다음 결제일까지 프리미엄 기능을 사용할 수 있습니다\n• 자동 갱신은 결제일 24시간 전에 취소할 수 있습니다',
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
        const SnackBar(
          content: Text('이미 프리미엄 사용자입니다'),
          backgroundColor: Colors.green,
        ),
      );
      return;
    }

    // 테스트 모드: 즉시 프리미엄으로 전환
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.info_outline, color: Colors.blue),
            SizedBox(width: 8),
            Text('테스트 모드'),
          ],
        ),
        content: Text(
          '$type 구독을 진행하시겠습니까?\n\n테스트 모드에서는 실제 결제 없이 프리미엄 기능을 바로 사용할 수 있습니다.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('취소'),
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
                      Text('$type 구독이 완료되었습니다!'),
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
            child: const Text('구독하기 (테스트)'),
          ),
        ],
      ),
    );
  }
}
