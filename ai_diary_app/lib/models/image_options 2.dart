import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

// 조명 옵션
enum LightingOption {
  natural('자연광', 'natural lighting, soft daylight, outdoor environment'),
  dramatic('드라마틱', 'dramatic lighting, strong shadows, cinematic mood'),
  warm('따뜻한 조명', 'warm golden hour lighting, cozy atmosphere'),
  cool('시원한 조명', 'cool blue lighting, modern clean atmosphere'),
  sunset('노을', 'golden sunset lighting, romantic warm glow'),
  night('야간', 'night scene, street lights, atmospheric darkness');

  const LightingOption(this.displayName, this.promptSuffix);
  final String displayName;
  final String promptSuffix;
}

// 분위기 옵션
enum MoodOption {
  peaceful('평화로운', 'peaceful, serene, calm atmosphere'),
  energetic('활기찬', 'energetic, vibrant, dynamic mood'),
  mysterious('신비로운', 'mysterious, enigmatic, ethereal atmosphere'),
  nostalgic('향수를 자아내는', 'nostalgic, sentimental, vintage mood'),
  dreamy('몽환적인', 'dreamy, surreal, fantastical atmosphere'),
  melancholic('우울한', 'melancholic, somber, introspective mood');

  const MoodOption(this.displayName, this.promptSuffix);
  final String displayName;
  final String promptSuffix;
}

// 색상 톤 옵션
enum ColorOption {
  vibrant('선명한', 'vibrant colors, high saturation, bold palette'),
  pastel('파스텔', 'pastel colors, soft muted tones, delicate palette'),
  monochrome('흑백', 'monochrome, black and white, grayscale'),
  sepia('세피아', 'sepia tone, vintage brown tints, aged photograph'),
  earthTone('자연색', 'earth tones, natural colors, brown and green palette'),
  neonPop('네온', 'neon colors, electric palette, cyberpunk vibes');

  const ColorOption(this.displayName, this.promptSuffix);
  final String displayName;
  final String promptSuffix;
}

// 구도 옵션
enum CompositionOption {
  closeUp('클로즈업', 'close-up shot, detailed focus, intimate framing'),
  wideAngle('와이드앵글', 'wide angle view, expansive scene, panoramic perspective'),
  birdEye('조감도', 'birds eye view, aerial perspective, top-down angle'),
  lowAngle('로우앵글', 'low angle shot, dramatic upward perspective'),
  symmetrical('대칭', 'symmetrical composition, balanced framing'),
  ruleOfThirds('삼분할', 'rule of thirds composition, dynamic balance');

  const CompositionOption(this.displayName, this.promptSuffix);
  final String displayName;
  final String promptSuffix;
}

// 고급 이미지 옵션 설정 클래스
class AdvancedImageOptions {
  final LightingOption? lighting;
  final MoodOption? mood;
  final ColorOption? color;
  final CompositionOption? composition;

  const AdvancedImageOptions({
    this.lighting,
    this.mood,
    this.color,
    this.composition,
  });

  // 프롬프트에 추가할 접미사 생성
  String generatePromptSuffix() {
    final suffixes = <String>[];

    if (lighting != null) suffixes.add(lighting!.promptSuffix);
    if (mood != null) suffixes.add(mood!.promptSuffix);
    if (color != null) suffixes.add(color!.promptSuffix);
    if (composition != null) suffixes.add(composition!.promptSuffix);

    return suffixes.isEmpty ? '' : ', ${suffixes.join(', ')}';
  }

  // 빈 옵션인지 확인
  bool get isEmpty => lighting == null && mood == null && color == null && composition == null;

  // 복사 메서드
  AdvancedImageOptions copyWith({
    LightingOption? lighting,
    MoodOption? mood,
    ColorOption? color,
    CompositionOption? composition,
  }) {
    return AdvancedImageOptions(
      lighting: lighting ?? this.lighting,
      mood: mood ?? this.mood,
      color: color ?? this.color,
      composition: composition ?? this.composition,
    );
  }

  // 맵으로 변환
  Map<String, dynamic> toMap() {
    return {
      'lighting': lighting?.name,
      'mood': mood?.name,
      'color': color?.name,
      'composition': composition?.name,
    };
  }

  // 맵에서 생성
  factory AdvancedImageOptions.fromMap(Map<String, dynamic> map) {
    return AdvancedImageOptions(
      lighting: map['lighting'] != null
          ? LightingOption.values.firstWhere((e) => e.name == map['lighting'])
          : null,
      mood: map['mood'] != null
          ? MoodOption.values.firstWhere((e) => e.name == map['mood'])
          : null,
      color: map['color'] != null
          ? ColorOption.values.firstWhere((e) => e.name == map['color'])
          : null,
      composition: map['composition'] != null
          ? CompositionOption.values.firstWhere((e) => e.name == map['composition'])
          : null,
    );
  }
}

// 고급 옵션 선택기 위젯
class AdvancedImageOptionsSelector extends StatelessWidget {
  final AdvancedImageOptions options;
  final ValueChanged<AdvancedImageOptions> onChanged;
  final bool enabled;

  const AdvancedImageOptionsSelector({
    super.key,
    required this.options,
    required this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.tune, size: 20, color: Colors.orange),
            const SizedBox(width: 8),
            Text(
              l10n.advancedOptions,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: enabled ? Colors.orange : Colors.grey,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // 조명 옵션
        _buildOptionSection(
          context,
          l10n.optionLighting,
          Icons.wb_sunny,
          LightingOption.values,
          options.lighting,
          (value) => onChanged(options.copyWith(lighting: value)),
        ),

        const SizedBox(height: 16),

        // 분위기 옵션
        _buildOptionSection(
          context,
          l10n.optionMood,
          Icons.mood,
          MoodOption.values,
          options.mood,
          (value) => onChanged(options.copyWith(mood: value)),
        ),

        const SizedBox(height: 16),

        // 색상 톤 옵션
        _buildOptionSection(
          context,
          l10n.optionColor,
          Icons.palette,
          ColorOption.values,
          options.color,
          (value) => onChanged(options.copyWith(color: value)),
        ),

        const SizedBox(height: 16),

        // 구도 옵션
        _buildOptionSection(
          context,
          l10n.optionComposition,
          Icons.camera_alt,
          CompositionOption.values,
          options.composition,
          (value) => onChanged(options.copyWith(composition: value)),
        ),
      ],
    );
  }

  Widget _buildOptionSection<T>(
    BuildContext context,
    String title,
    IconData icon,
    List<T> options,
    T? selectedValue,
    ValueChanged<T?> onChanged,
  ) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: enabled ? Colors.grey.shade600 : Colors.grey.shade400),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: enabled ? Colors.grey.shade700 : Colors.grey.shade400,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(
              color: enabled ? Colors.grey.shade300 : Colors.grey.shade200,
            ),
            borderRadius: BorderRadius.circular(8),
            color: enabled ? Colors.white : Colors.grey.withOpacity(0.1),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T?>(
              value: selectedValue,
              isExpanded: true,
              icon: Icon(
                Icons.arrow_drop_down,
                color: enabled ? Colors.grey.shade600 : Colors.grey.shade400,
              ),
              items: [
                // "선택 안함" 옵션
                DropdownMenuItem<T?>(
                  value: null,
                  child: Row(
                    children: [
                      Icon(
                        Icons.clear,
                        size: 20,
                        color: enabled ? Colors.grey.shade600 : Colors.grey.shade400,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        l10n.noSelection,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: enabled ? Colors.grey.shade800 : Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                ),
                // 옵션들
                ...options.map((option) {
                  final displayName = _getDisplayName(context, option);
                  return DropdownMenuItem<T?>(
                    value: option,
                    child: Row(
                      children: [
                        Icon(
                          _getOptionIcon(option),
                          size: 20,
                          color: enabled ? _getOptionColor(option) : Colors.grey.shade400,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          displayName,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: enabled ? Colors.grey.shade800 : Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
              onChanged: enabled ? (value) => onChanged(value) : null,
            ),
          ),
        ),
      ],
    );
  }

  String _getDisplayName(BuildContext context, dynamic option) {
    final l10n = AppLocalizations.of(context);
    if (option is LightingOption) {
      switch (option) {
        case LightingOption.natural:
          return l10n.lightingNatural;
        case LightingOption.dramatic:
          return l10n.lightingDramatic;
        case LightingOption.warm:
          return l10n.lightingWarm;
        case LightingOption.cool:
          return l10n.lightingCool;
        case LightingOption.sunset:
          return l10n.lightingSunset;
        case LightingOption.night:
          return l10n.lightingNight;
      }
    }
    if (option is MoodOption) {
      switch (option) {
        case MoodOption.peaceful:
          return l10n.moodPeaceful;
        case MoodOption.energetic:
          return l10n.moodEnergetic;
        case MoodOption.mysterious:
          return l10n.moodMysterious;
        case MoodOption.nostalgic:
          return l10n.moodNostalgic;
        case MoodOption.dreamy:
          return l10n.moodDreamy;
        case MoodOption.melancholic:
          return l10n.moodMelancholic;
      }
    }
    if (option is ColorOption) {
      switch (option) {
        case ColorOption.vibrant:
          return l10n.colorVibrant;
        case ColorOption.pastel:
          return l10n.colorPastel;
        case ColorOption.monochrome:
          return l10n.colorMonochrome;
        case ColorOption.sepia:
          return l10n.colorSepia;
        case ColorOption.earthTone:
          return l10n.colorEarthTone;
        case ColorOption.neonPop:
          return l10n.colorNeon;
      }
    }
    if (option is CompositionOption) {
      switch (option) {
        case CompositionOption.closeUp:
          return l10n.compositionCloseUp;
        case CompositionOption.wideAngle:
          return l10n.compositionWideAngle;
        case CompositionOption.birdEye:
          return l10n.compositionBirdEye;
        case CompositionOption.lowAngle:
          return l10n.compositionLowAngle;
        case CompositionOption.symmetrical:
          return l10n.compositionSymmetrical;
        case CompositionOption.ruleOfThirds:
          return l10n.compositionRuleOfThirds;
      }
    }
    return option.toString();
  }

  IconData _getOptionIcon(dynamic option) {
    if (option is LightingOption) {
      switch (option) {
        case LightingOption.natural:
          return Icons.wb_sunny;
        case LightingOption.dramatic:
          return Icons.theater_comedy;
        case LightingOption.warm:
          return Icons.wb_incandescent;
        case LightingOption.cool:
          return Icons.ac_unit;
        case LightingOption.sunset:
          return Icons.wb_shade;
        case LightingOption.night:
          return Icons.nights_stay;
      }
    }
    if (option is MoodOption) {
      switch (option) {
        case MoodOption.peaceful:
          return Icons.spa;
        case MoodOption.energetic:
          return Icons.flash_on;
        case MoodOption.mysterious:
          return Icons.psychology;
        case MoodOption.nostalgic:
          return Icons.history;
        case MoodOption.dreamy:
          return Icons.cloud;
        case MoodOption.melancholic:
          return Icons.sentiment_dissatisfied;
      }
    }
    if (option is ColorOption) {
      switch (option) {
        case ColorOption.vibrant:
          return Icons.color_lens;
        case ColorOption.pastel:
          return Icons.palette;
        case ColorOption.monochrome:
          return Icons.filter_b_and_w;
        case ColorOption.sepia:
          return Icons.photo_filter;
        case ColorOption.earthTone:
          return Icons.terrain;
        case ColorOption.neonPop:
          return Icons.electric_bolt;
      }
    }
    if (option is CompositionOption) {
      switch (option) {
        case CompositionOption.closeUp:
          return Icons.zoom_in;
        case CompositionOption.wideAngle:
          return Icons.zoom_out;
        case CompositionOption.birdEye:
          return Icons.flight;
        case CompositionOption.lowAngle:
          return Icons.arrow_upward;
        case CompositionOption.symmetrical:
          return Icons.balance;
        case CompositionOption.ruleOfThirds:
          return Icons.grid_on;
      }
    }
    return Icons.tune;
  }

  Color _getOptionColor(dynamic option) {
    if (option is LightingOption) {
      switch (option) {
        case LightingOption.natural:
          return Colors.yellow;
        case LightingOption.dramatic:
          return Colors.red;
        case LightingOption.warm:
          return Colors.orange;
        case LightingOption.cool:
          return Colors.blue;
        case LightingOption.sunset:
          return Colors.deepOrange;
        case LightingOption.night:
          return Colors.indigo;
      }
    }
    if (option is MoodOption) {
      switch (option) {
        case MoodOption.peaceful:
          return Colors.green;
        case MoodOption.energetic:
          return Colors.yellow;
        case MoodOption.mysterious:
          return Colors.purple;
        case MoodOption.nostalgic:
          return Colors.brown;
        case MoodOption.dreamy:
          return Colors.pink;
        case MoodOption.melancholic:
          return Colors.grey;
      }
    }
    if (option is ColorOption) {
      switch (option) {
        case ColorOption.vibrant:
          return Colors.red;
        case ColorOption.pastel:
          return Colors.pink;
        case ColorOption.monochrome:
          return Colors.grey;
        case ColorOption.sepia:
          return Colors.brown;
        case ColorOption.earthTone:
          return Colors.green;
        case ColorOption.neonPop:
          return Colors.cyan;
      }
    }
    if (option is CompositionOption) {
      switch (option) {
        case CompositionOption.closeUp:
          return Colors.blue;
        case CompositionOption.wideAngle:
          return Colors.green;
        case CompositionOption.birdEye:
          return Colors.orange;
        case CompositionOption.lowAngle:
          return Colors.red;
        case CompositionOption.symmetrical:
          return Colors.purple;
        case CompositionOption.ruleOfThirds:
          return Colors.teal;
      }
    }
    return Colors.orange;
  }
}