import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

enum ImageStyle {
  auto('자동 선택', 'analyze the diary content and automatically choose the most appropriate style that matches the mood and context'),
  realistic('실사 스타일', 'ultra realistic photograph, DSLR camera quality, natural environment, soft natural lighting, documentary photography style, high detail, depth of field'),
  watercolor('수채화 스타일', 'traditional watercolor painting technique, paper texture visible, soft wet-on-wet bleeding effects, transparent layered colors, artistic brush marks, dreamy atmosphere'),
  illustration('일러스트 스타일', 'modern digital illustration, flat design, vector graphics, bold geometric shapes, contemporary art poster style, vibrant color palette, clean composition'),
  sketch('스케치 스타일', 'detailed pencil sketch on paper, crosshatching and shading technique, monochrome graphite drawing, hand-drawn illustration style'),
  anime('애니메이션 스타일', 'japanese anime style, Studio Ghibli inspired, cell shading, pastel colors, kawaii aesthetic, detailed character design, clean line art'),
  impressionist('인상주의', 'french impressionist painting style, claude monet technique, loose visible brushwork, plein air outdoor lighting, soft color transitions, peaceful garden setting'),
  vintage('빈티지 스타일', 'vintage sepia tone photograph, old film grain texture, nostalgic warm colors, antique photography style, aged paper effect');

  const ImageStyle(this.displayName, this.promptPrefix);
  
  final String displayName;
  final String promptPrefix;
}

class ImageStyleSelector extends StatelessWidget {
  final ImageStyle selectedStyle;
  final ValueChanged<ImageStyle> onStyleChanged;
  final bool isPremium;

  const ImageStyleSelector({
    super.key,
    required this.selectedStyle,
    required this.onStyleChanged,
    this.isPremium = false,
  });

  @override
  Widget build(BuildContext context) {
    // 무료 사용자에게는 실사와 수채화만 제공
    final freeStyles = [ImageStyle.realistic, ImageStyle.watercolor];
    final premiumStyles = ImageStyle.values.where((style) => 
      !freeStyles.contains(style) && style != ImageStyle.auto).toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context).imageStyle,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3748),
          ),
        ),
        const SizedBox(height: 12),
        
        // 기본 스타일들 (무료 사용자도 사용 가능)
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 4.5,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: freeStyles.length + (isPremium ? premiumStyles.length : 0),
          itemBuilder: (context, index) {
            final style = index < freeStyles.length 
                ? freeStyles[index]
                : premiumStyles[index - freeStyles.length];
            final isSelected = style == selectedStyle;
            final isLocked = !isPremium && !freeStyles.contains(style);
            
            return Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected 
                          ? const Color(0xFF667EEA) 
                          : const Color(0xFFE2E8F0),
                      width: isSelected ? 2 : 1,
                    ),
                    color: isLocked
                        ? Colors.grey.withOpacity(0.1)
                        : isSelected 
                            ? const Color(0xFF667EEA).withOpacity(0.1)
                            : Colors.white,
                  ),
                  child: InkWell(
                    onTap: isLocked 
                        ? () => _showPremiumDialog(context)
                        : () => onStyleChanged(style),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _getStyleIcon(style),
                            color: isLocked
                                ? Colors.grey
                                : isSelected 
                                    ? const Color(0xFF667EEA) 
                                    : const Color(0xFF4A5568),
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _getLocalizedStyleName(context, style),
                              style: TextStyle(
                                color: isLocked
                                    ? Colors.grey
                                    : isSelected 
                                        ? const Color(0xFF667EEA) 
                                        : const Color(0xFF4A5568),
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                fontSize: 13,
                              ),
                              textAlign: TextAlign.left,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (isLocked)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.lock,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        
        // 추가 옵션 버튼 (무료 사용자에게만 표시)
        if (!isPremium) ...[
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showPremiumStylesDialog(context),
              icon: const Icon(Icons.add, size: 20),
              label: const Text('추가 옵션'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF667EEA),
                side: const BorderSide(color: Color(0xFF667EEA)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ],
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
  
  IconData _getStyleIcon(ImageStyle style) {
    switch (style) {
      case ImageStyle.auto:
        return Icons.auto_awesome;
      case ImageStyle.realistic:
        return Icons.camera_alt;
      case ImageStyle.watercolor:
        return Icons.brush;
      case ImageStyle.illustration:
        return Icons.palette;
      case ImageStyle.sketch:
        return Icons.edit;
      case ImageStyle.anime:
        return Icons.face;
      case ImageStyle.impressionist:
        return Icons.landscape;
      case ImageStyle.vintage:
        return Icons.filter_vintage;
    }
  }
  
  void _showPremiumDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(Icons.star, color: Colors.amber, size: 28),
            const SizedBox(width: 8),
            const Text('프리미엄 전용 스타일'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '이 스타일은 프리미엄 구독자만 사용할 수 있어요.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF667EEA).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '프리미엄 혜택',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text('• 10가지 프리미엄 글꼴'),
                  const Text('• 6가지 프리미엄 스타일'),
                  const Text('• 무제한 이미지 생성'),
                  const Text('• 수정 시 이미지도 재생성 (일기당 1회)'),
                  const Text('• 고급 이미지 옵션 (조명, 분위기, 색상, 구도)'),
                  const Text('• 광고 제거'),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('나중에'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('설정 > 테스트 모드에서 프리미엄으로 전환할 수 있습니다'),
                ),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF667EEA),
            ),
            child: const Text('구독하기'),
          ),
        ],
      ),
    );
  }

  void _showPremiumStylesDialog(BuildContext context) {
    final premiumStyles = ImageStyle.values.where((style) => 
      style != ImageStyle.realistic && 
      style != ImageStyle.watercolor && 
      style != ImageStyle.auto).toList();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(Icons.star, color: Colors.amber, size: 28),
            const SizedBox(width: 8),
            const Text('프리미엄 스타일'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '프리미엄으로 업그레이드하면 다양한 스타일과 글꼴을 사용할 수 있어요!',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 4.0,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: premiumStyles.length,
                  itemBuilder: (context, index) {
                    final style = premiumStyles[index];
                    return Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _getStyleIcon(style),
                                  color: Colors.grey,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _getLocalizedStyleName(context, style),
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                    textAlign: TextAlign.left,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          right: 6,
                          top: 6,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.amber,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(
                              Icons.lock,
                              color: Colors.white,
                              size: 12,
                            ),
                          ),
                        ),
                      ],
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
            child: const Text('나중에'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('설정 > 테스트 모드에서 프리미엄으로 전환할 수 있습니다'),
                ),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.amber,
            ),
            child: const Text('구독하기'),
          ),
        ],
      ),
    );
  }
}