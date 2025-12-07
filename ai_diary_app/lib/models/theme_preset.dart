import 'package:flutter/material.dart';
import 'image_style.dart';
import 'image_options.dart';
import 'image_time.dart';
import 'image_weather.dart';
import '../l10n/app_localizations.dart';

// 테마 프리셋 모델
class ThemePreset {
  final String id;
  final String name;
  final String description;
  final ImageStyle style;
  final AdvancedImageOptions? advancedOptions;
  final ImageTime? time;
  final ImageWeather? weather;
  final IconData icon;
  final Color primaryColor;
  final bool isPremium;

  const ThemePreset({
    required this.id,
    required this.name,
    required this.description,
    required this.style,
    this.advancedOptions,
    this.time,
    this.weather,
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
      'time': time?.name,
      'weather': weather?.name,
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
      time: map['time'] != null ? ImageTime.values.firstWhere((e) => e.name == map['time']) : null,
      weather: map['weather'] != null ? ImageWeather.values.firstWhere((e) => e.name == map['weather']) : null,
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
      time: ImageTime.golden,
      weather: ImageWeather.sunny,
      icon: Icons.nature,
      primaryColor: Colors.green,
      isPremium: false,
    ),
    ThemePreset(
      id: 'dreamy',
      name: '몽환적인',
      description: '수채화 스타일로 꿈 같은 분위기를 연출하세요',
      style: ImageStyle.watercolor,
      time: ImageTime.sunset,
      weather: ImageWeather.cloudy,
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
      time: ImageTime.golden,
      weather: ImageWeather.cloudy,
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
      time: ImageTime.morning,
      weather: ImageWeather.sunny,
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
      time: ImageTime.noon,
      weather: ImageWeather.sunny,
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
      time: ImageTime.night,
      weather: ImageWeather.snowy,
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
      time: ImageTime.golden,
      weather: ImageWeather.cloudy,
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
      time: ImageTime.night,
      weather: ImageWeather.snowy,
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
    final l10n = AppLocalizations.of(context);
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
              l10n.optionThemePreset,
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
          ...ThemePresets.presets.map((preset) => _buildPresetCard(context, preset, true)),
        ] else ...[
          // 무료 사용자는 기존대로 구분 표시
          if (freePresets.isNotEmpty) ...[
            _buildSectionTitle(l10n.freePresets),
            const SizedBox(height: 8),
            ...freePresets.map((preset) => _buildPresetCard(context, preset, true)),
            const SizedBox(height: 16),
          ],

          if (premiumPresets.isNotEmpty) ...[
            _buildSectionTitle(l10n.premiumPresets),
            const SizedBox(height: 8),
            ...premiumPresets.map((preset) => _buildPresetCard(context, preset, false)),
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

  String _getPresetName(AppLocalizations l10n, String presetId) {
    switch (presetId) {
      case 'natural':
        return l10n.presetNatural;
      case 'dreamy':
        return l10n.presetDreamy;
      case 'vintage_nostalgia':
        return l10n.presetVintageNostalgia;
      case 'anime_fantasy':
        return l10n.presetAnimeFantasy;
      case 'impressionist_garden':
        return l10n.presetImpressionistGarden;
      case 'pixel_retro':
        return l10n.presetPixelRetro;
      case 'paper_craft':
        return l10n.presetPaperCraft;
      case 'child_innocent':
        return l10n.presetChildInnocent;
      default:
        return presetId;
    }
  }

  String _getPresetDescription(AppLocalizations l10n, String presetId) {
    switch (presetId) {
      case 'natural':
        return l10n.presetNaturalDesc;
      case 'dreamy':
        return l10n.presetDreamyDesc;
      case 'vintage_nostalgia':
        return l10n.presetVintageNostalgiaDesc;
      case 'anime_fantasy':
        return l10n.presetAnimeFantasyDesc;
      case 'impressionist_garden':
        return l10n.presetImpressionistGardenDesc;
      case 'pixel_retro':
        return l10n.presetPixelRetroDesc;
      case 'paper_craft':
        return l10n.presetPaperCraftDesc;
      case 'child_innocent':
        return l10n.presetChildInnocentDesc;
      default:
        return '';
    }
  }

  Widget _buildPresetCard(BuildContext context, ThemePreset preset, bool enabled) {
    final l10n = AppLocalizations.of(context);
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
                            _getPresetName(l10n, preset.id),
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
                      _getPresetDescription(l10n, preset.id),
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