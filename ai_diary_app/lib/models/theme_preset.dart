import 'package:flutter/material.dart';
import 'image_style.dart';
import 'image_options.dart';
import 'image_ratio.dart';

// 테마 프리셋 모델
class ThemePreset {
  final String id;
  final String name;
  final String description;
  final ImageStyle style;
  final AdvancedImageOptions? advancedOptions;
  final ImageRatio ratio;
  final IconData icon;
  final Color primaryColor;
  final bool isPremium;

  const ThemePreset({
    required this.id,
    required this.name,
    required this.description,
    required this.style,
    this.advancedOptions,
    required this.ratio,
    required this.icon,
    required this.primaryColor,
    this.isPremium = false,
  });

  // 맵으로 변환
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'style': style.name,
      'advancedOptions': advancedOptions?.toMap(),
      'ratio': ratio.name,
      'isPremium': isPremium,
    };
  }

  // 맵에서 생성
  factory ThemePreset.fromMap(Map<String, dynamic> map) {
    return ThemePreset(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      style: ImageStyle.values.firstWhere((e) => e.name == map['style']),
      advancedOptions: map['advancedOptions'] != null
          ? AdvancedImageOptions.fromMap(map['advancedOptions'])
          : null,
      ratio: ImageRatio.values.firstWhere((e) => e.name == map['ratio']),
      icon: Icons.palette, // 기본값
      primaryColor: Colors.blue, // 기본값
      isPremium: map['isPremium'] ?? false,
    );
  }
}

// 미리 정의된 테마 프리셋들
class ThemePresets {
  static const List<ThemePreset> presets = [
    // 무료 프리셋
    ThemePreset(
      id: 'natural',
      name: '자연스러운',
      description: '실사 스타일로 자연스러운 일상을 담아내세요',
      style: ImageStyle.realistic,
      ratio: ImageRatio.landscape,
      icon: Icons.nature,
      primaryColor: Colors.green,
      isPremium: false,
    ),
    ThemePreset(
      id: 'dreamy',
      name: '몽환적인',
      description: '수채화 스타일로 꿈 같은 분위기를 연출하세요',
      style: ImageStyle.watercolor,
      ratio: ImageRatio.square,
      icon: Icons.cloud,
      primaryColor: Colors.purple,
      isPremium: false,
    ),

    // 프리미엄 프리셋
    ThemePreset(
      id: 'vintage_nostalgia',
      name: '빈티지 향수',
      description: '세피아 톤과 빈티지 스타일로 추억을 되살려보세요',
      style: ImageStyle.vintage,
      advancedOptions: AdvancedImageOptions(
        lighting: LightingOption.warm,
        mood: MoodOption.nostalgic,
        color: ColorOption.sepia,
        composition: CompositionOption.symmetrical,
      ),
      ratio: ImageRatio.portrait,
      icon: Icons.camera_alt,
      primaryColor: Colors.brown,
      isPremium: true,
    ),
    ThemePreset(
      id: 'anime_fantasy',
      name: '애니메이션 판타지',
      description: '애니메이션 스타일로 판타지 세계를 그려보세요',
      style: ImageStyle.anime,
      advancedOptions: AdvancedImageOptions(
        lighting: LightingOption.dramatic,
        mood: MoodOption.dreamy,
        color: ColorOption.vibrant,
        composition: CompositionOption.ruleOfThirds,
      ),
      ratio: ImageRatio.wide,
      icon: Icons.star,
      primaryColor: Colors.pink,
      isPremium: true,
    ),
    ThemePreset(
      id: 'impressionist_garden',
      name: '인상파 정원',
      description: '인상주의 스타일로 평화로운 정원을 표현하세요',
      style: ImageStyle.impressionist,
      advancedOptions: AdvancedImageOptions(
        lighting: LightingOption.natural,
        mood: MoodOption.peaceful,
        color: ColorOption.pastel,
        composition: CompositionOption.symmetrical,
      ),
      ratio: ImageRatio.landscape,
      icon: Icons.local_florist,
      primaryColor: Colors.blue,
      isPremium: true,
    ),
    ThemePreset(
      id: 'pixel_retro',
      name: '픽셀 레트로',
      description: '8비트 픽셀아트로 레트로 게임 느낌을 만들어보세요',
      style: ImageStyle.illustration,
      advancedOptions: AdvancedImageOptions(
        lighting: LightingOption.cool,
        mood: MoodOption.energetic,
        color: ColorOption.neonPop,
        composition: CompositionOption.closeUp,
      ),
      ratio: ImageRatio.square,
      icon: Icons.videogame_asset,
      primaryColor: Colors.cyan,
      isPremium: true,
    ),
    ThemePreset(
      id: 'paper_craft',
      name: '종이공예 콜라주',
      description: '수작업 종이공예 스타일로 따뜻한 감성을 표현하세요',
      style: ImageStyle.sketch,
      advancedOptions: AdvancedImageOptions(
        lighting: LightingOption.warm,
        mood: MoodOption.peaceful,
        color: ColorOption.earthTone,
        composition: CompositionOption.symmetrical,
      ),
      ratio: ImageRatio.portrait,
      icon: Icons.content_cut,
      primaryColor: Colors.orange,
      isPremium: true,
    ),
    ThemePreset(
      id: 'child_innocent',
      name: '순수한 아이',
      description: '아이 그림 스타일로 순수하고 밝은 감성을 담아보세요',
      style: ImageStyle.anime,
      advancedOptions: AdvancedImageOptions(
        lighting: LightingOption.natural,
        mood: MoodOption.energetic,
        color: ColorOption.vibrant,
        composition: CompositionOption.closeUp,
      ),
      ratio: ImageRatio.square,
      icon: Icons.child_care,
      primaryColor: Colors.amber,
      isPremium: true,
    ),
  ];

  // 무료 프리셋만 반환
  static List<ThemePreset> get freePresets =>
      presets.where((preset) => !preset.isPremium).toList();

  // 프리미엄 프리셋만 반환
  static List<ThemePreset> get premiumPresets =>
      presets.where((preset) => preset.isPremium).toList();

  // ID로 프리셋 찾기
  static ThemePreset? findById(String id) {
    try {
      return presets.firstWhere((preset) => preset.id == id);
    } catch (e) {
      return null;
    }
  }
}

// 테마 프리셋 선택기 위젯
class ThemePresetSelector extends StatelessWidget {
  final String? selectedPresetId;
  final ValueChanged<ThemePreset> onPresetSelected;
  final bool isPremium;

  const ThemePresetSelector({
    super.key,
    this.selectedPresetId,
    required this.onPresetSelected,
    this.isPremium = false,
  });

  @override
  Widget build(BuildContext context) {
    final freePresets = ThemePresets.freePresets;
    final premiumPresets = ThemePresets.premiumPresets;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.palette,
              size: 18,
              color: Colors.grey.shade600,
            ),
            const SizedBox(width: 8),
            Text(
              '테마 프리셋',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // 모든 프리셋 (프리미엄 사용자는 구분 없이 표시)
        if (isPremium) ...[
          ...ThemePresets.presets.map((preset) => _buildPresetCard(preset, true)),
        ] else ...[
          // 무료 사용자는 기존대로 구분 표시
          if (freePresets.isNotEmpty) ...[
            _buildSectionTitle('무료 프리셋'),
            const SizedBox(height: 8),
            ...freePresets.map((preset) => _buildPresetCard(preset, true)),
            const SizedBox(height: 16),
          ],

          if (premiumPresets.isNotEmpty) ...[
            _buildSectionTitle('프리미엄 프리셋'),
            const SizedBox(height: 8),
            ...premiumPresets.map((preset) => _buildPresetCard(preset, false)),
          ],
        ],
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Colors.grey.shade600,
      ),
    );
  }

  Widget _buildPresetCard(ThemePreset preset, bool enabled) {
    final isSelected = preset.id == selectedPresetId;
    final isLocked = preset.isPremium && !isPremium;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: enabled && !isLocked ? () => onPresetSelected(preset) : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? preset.primaryColor
                  : (enabled ? Colors.grey.shade300 : Colors.grey.shade200),
              width: isSelected ? 2 : 1,
            ),
            color: isSelected
                ? preset.primaryColor.withOpacity(0.1)
                : (enabled ? Colors.white : Colors.grey.withOpacity(0.1)),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: enabled
                      ? preset.primaryColor.withOpacity(0.2)
                      : Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  preset.icon,
                  color: enabled ? preset.primaryColor : Colors.grey,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            preset.name,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: enabled ? Colors.grey.shade800 : Colors.grey.shade400,
                            ),
                          ),
                        ),
                        if (isLocked)
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.amber,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Icon(
                              Icons.lock,
                              color: Colors.white,
                              size: 12,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      preset.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: enabled ? Colors.grey.shade600 : Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}