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
            title: '효과적인 프롬프트 작성법',
            icon: Icons.edit,
            content: [
              _buildTipItem(
                '구체적으로 묘사하기',
                '예: "행복한 고양이" 보다 "햇살 속에서 웃고 있는 털이 부드러운 주황색 고양이"',
                Colors.blue,
              ),
              _buildTipItem(
                '감정과 분위기 표현',
                '예: "따뜻한", "평화로운", "신비로운", "로맨틱한" 등의 형용사 활용',
                Colors.green,
              ),
              _buildTipItem(
                '배경과 환경 설명',
                '예: "벚꽃이 피는 공원에서", "일몰이 아름다운 바다 앞에서"',
                Colors.orange,
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // 스타일별 가이드
          _buildGuideCard(
            context,
            title: '이미지 스타일별 활용법',
            icon: Icons.palette,
            content: [
              // 무료 사용자용 스타일 (실사, 수채화)
              _buildStyleExample(
                context,
                ImageStyle.realistic,
                '실사 스타일',
                '실제 사진과 같은 사실적인 이미지\n생생한 기억을 재현하고 싶을 때',
                '예: "실제 사진처럼 생생한 일몰 풍경"',
              ),
              _buildStyleExample(
                context,
                ImageStyle.watercolor,
                '수채화 스타일',
                '부드럽고 따뜻한 느낌의 수채화\n감성적인 일기를 표현할 때',
                '예: "수채화 스타일로 그린 따뜻한 카페 풍경"',
              ),
              
              // 프리미엄 사용자만 볼 수 있는 스타일들
              if (subscription.isPremium) ...[
                _buildStyleExample(
                  context,
                  ImageStyle.illustration,
                  '일러스트레이션',
                  '현대적이고 세련된 일러스트 스타일\n트렌디한 느낌을 원할 때',
                  '예: "모던한 일러스트 스타일의 도시 풍경"',
                ),
                _buildStyleExample(
                  context,
                  ImageStyle.anime,
                  '애니메이션',
                  '귀엽고 친근한 애니메이션 스타일\n재미있는 일상을 표현할 때',
                  '예: "귀여운 애니메이션 스타일의 강아지가 뛰어노는 모습"',
                ),
                _buildStyleExample(
                  context,
                  ImageStyle.sketch,
                  '스케치',
                  '단순하고 깔끔한 스케치 스타일\n집중하고 싶은 요소가 있을 때',
                  '예: "심플한 선으로 표현한 나무 한 그루"',
                ),
                _buildStyleExample(
                  context,
                  ImageStyle.impressionist,
                  '인상주의',
                  '모네 스타일의 인상주의 회화\n예술적이고 클래식한 느낌',
                  '예: "인상주의 화가의 붓터치로 표현한 연못"',
                ),
                _buildStyleExample(
                  context,
                  ImageStyle.vintage,
                  '빈티지',
                  '옛날 사진 같은 레트로 느낌\n노스탤지어를 불러일으킬 때',
                  '예: "세피아 톤의 빈티지한 거리 풍경"',
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
                            '프리미엄 스타일',
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
                        '프리미엄으로 업그레이드하시면 일러스트, 애니메이션, 스케치, 인상주의, 빈티지 스타일을 추가로 사용할 수 있습니다.',
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
            title: '고급 활용 팁',
            icon: Icons.tips_and_updates,
            content: [
              _buildAdvancedTip(
                '키워드 조합하기',
                '여러 키워드를 조합하여 더 구체적인 이미지를 생성하세요.',
                '감정 + 장소 + 시간 + 스타일\n예: "평화로운 + 호수가 + 저녁 + 수채화"',
                Icons.merge_type,
              ),
              _buildAdvancedTip(
                '분위기 단어 활용',
                '이미지의 전체적인 톤을 결정하는 단어들을 사용하세요.',
                '• 밝고 경쾌한: bright, cheerful, vibrant\n• 차분하고 평화로운: serene, peaceful, calm\n• 몽환적인: dreamy, ethereal, mystical',
                Icons.mood,
              ),
              _buildAdvancedTip(
                '시간과 날씨 표현',
                '특정 시간대나 날씨를 명시하면 더 생생한 이미지가 만들어집니다.',
                '• 시간: 새벽, 아침, 정오, 황혼, 밤\n• 날씨: 맑은 날, 비 오는 날, 눈 내리는 날',
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
                        '고급 옵션 효과 비교',
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
                    '프리미엄 고급 옵션을 사용하면 이미지의 품질과 표현력이 크게 향상됩니다.\n각 옵션별로 어떤 차이가 있는지 직접 비교해보세요!',
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
                              '이 고급 옵션들은 프리미엄 사용자만 사용할 수 있습니다',
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
                    '배경 스타일',
                    '배경sample_1.png',
                    '배경sample_2.png',
                    '기본 배경',
                    '고급 배경 옵션',
                    '단순한 배경에서 환상적이고 세밀한 배경으로 변화합니다.',
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // 색감 조정 비교
                  _buildImageComparison(
                    context,
                    '색감 조정',
                    '색감sample_1.png',
                    '색감sample_2.png',
                    '기본 색감',
                    '고급 색감 옵션',
                    '자연스럽고 생동감 있는 색상으로 변화합니다.',
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // 앵글 비교
                  _buildImageComparison(
                    context,
                    '시점과 구도',
                    '앵글sample_1.png',
                    '앵글sample_2.png',
                    '기본 앵글',
                    '고급 앵글 옵션',
                    '더 창의적이고 역동적인 시점으로 변화합니다.',
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // 조명 효과 비교
                  _buildImageComparison(
                    context,
                    '조명 효과',
                    '조명sample_1.png',
                    '조명sample_2.png',
                    '기본 조명',
                    '고급 조명 옵션',
                    '드라마틱한 조명 효과가 적용됩니다.',
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
                              '프리미엄으로 업그레이드',
                              style: GoogleFonts.notoSans(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '설정 > 테스트 모드에서 전환 가능',
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
                                '탭해서 설정으로 이동',
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
                  '주의사항',
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
              '• 저작권이 있는 특정 캐릭터나 브랜드 로고는 생성되지 않을 수 있습니다.\n\n• 부적절한 내용이나 폭력적인 내용은 생성되지 않습니다.',
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

  Widget _buildComparisonExample(
    String title,
    String beforeImage,
    String afterImage,
    String beforeLabel,
    String afterLabel, [
    String? description,
  ]) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
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
          if (description != null) ...[
            Text(
              description,
              style: GoogleFonts.notoSans(
                fontSize: 13,
                color: const Color(0xFF718096),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
          ] else
            const SizedBox(height: 4),
          Row(
            children: [
              // Before 이미지
              Expanded(
                child: Column(
                  children: [
                    Container(
                      height: 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFFE2E8F0),
                          width: 1,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          'assets/images/$beforeImage',
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[200],
                              child: const Center(
                                child: Icon(
                                  Icons.image_not_supported,
                                  color: Colors.grey,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      beforeLabel,
                      style: GoogleFonts.notoSans(
                        fontSize: 12,
                        color: const Color(0xFF718096),
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Arrow
              Column(
                children: [
                  const SizedBox(height: 60),
                  Icon(
                    Icons.arrow_forward,
                    color: const Color(0xFF6B73FF),
                    size: 24,
                  ),
                ],
              ),
              const SizedBox(width: 16),
              // After 이미지
              Expanded(
                child: Column(
                  children: [
                    Container(
                      height: 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFF6B73FF),
                          width: 2,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          'assets/images/$afterImage',
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[200],
                              child: const Center(
                                child: Icon(
                                  Icons.image_not_supported,
                                  color: Colors.grey,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      afterLabel,
                      style: GoogleFonts.notoSans(
                        fontSize: 12,
                        color: const Color(0xFF6B73FF),
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
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
                          Text(
                            beforeLabel,
                            style: GoogleFonts.notoSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF718096),
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
                          Text(
                            afterLabel,
                            style: GoogleFonts.notoSans(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF6B73FF),
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
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.image_not_supported,
                                size: 50,
                                color: Colors.grey,
                              ),
                              Text(
                                '이미지를 불러올 수 없습니다',
                                style: TextStyle(color: Colors.grey),
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

  Widget _buildPremiumFeature(String title, String description) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.amber.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.substring(0, 2), // 이모지 부분
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.substring(3), // 이모지 이후 부분
                  style: GoogleFonts.notoSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2D3748),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.notoSans(
                    fontSize: 13,
                    color: const Color(0xFF718096),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}