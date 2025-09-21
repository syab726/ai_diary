import 'package:flutter/material.dart';

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.tune, size: 20, color: Colors.orange),
            const SizedBox(width: 8),
            Text(
              '고급 옵션',
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
          '조명',
          Icons.wb_sunny,
          LightingOption.values,
          options.lighting,
          (value) => onChanged(options.copyWith(lighting: value)),
        ),

        const SizedBox(height: 16),

        // 분위기 옵션
        _buildOptionSection(
          '분위기',
          Icons.mood,
          MoodOption.values,
          options.mood,
          (value) => onChanged(options.copyWith(mood: value)),
        ),

        const SizedBox(height: 16),

        // 색상 톤 옵션
        _buildOptionSection(
          '색상',
          Icons.palette,
          ColorOption.values,
          options.color,
          (value) => onChanged(options.copyWith(color: value)),
        ),

        const SizedBox(height: 16),

        // 구도 옵션
        _buildOptionSection(
          '구도',
          Icons.camera_alt,
          CompositionOption.values,
          options.composition,
          (value) => onChanged(options.copyWith(composition: value)),
        ),
      ],
    );
  }

  Widget _buildOptionSection<T>(
    String title,
    IconData icon,
    List<T> options,
    T? selectedValue,
    ValueChanged<T?> onChanged,
  ) {
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
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            // "선택 안함" 옵션
            _buildOptionChip(
              '선택 안함',
              selectedValue == null,
              enabled,
              () => enabled ? onChanged(null) : null,
            ),
            // 옵션들
            ...options.map((option) {
              final displayName = _getDisplayName(option);
              final isSelected = selectedValue == option;
              return _buildOptionChip(
                displayName,
                isSelected,
                enabled,
                () => enabled ? onChanged(option) : null,
              );
            }),
          ],
        ),
      ],
    );
  }

  String _getDisplayName(dynamic option) {
    if (option is LightingOption) return option.displayName;
    if (option is MoodOption) return option.displayName;
    if (option is ColorOption) return option.displayName;
    if (option is CompositionOption) return option.displayName;
    return option.toString();
  }

  Widget _buildOptionChip(
    String label,
    bool isSelected,
    bool isEnabled,
    VoidCallback? onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? (isEnabled ? Colors.orange.withOpacity(0.2) : Colors.grey.withOpacity(0.1))
              : Colors.transparent,
          border: Border.all(
            color: isSelected
                ? (isEnabled ? Colors.orange : Colors.grey)
                : (isEnabled ? Colors.grey.shade300 : Colors.grey.shade200),
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected
                ? (isEnabled ? Colors.orange.shade700 : Colors.grey)
                : (isEnabled ? Colors.grey.shade600 : Colors.grey.shade400),
          ),
        ),
      ),
    );
  }
}