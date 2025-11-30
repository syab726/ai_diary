import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/image_options.dart';
import '../models/image_time.dart';
import '../models/image_weather.dart';
import '../models/image_season.dart';
import '../models/perspective_options.dart';
import '../models/theme_preset.dart';
import '../providers/image_style_provider.dart';
import '../providers/theme_preset_provider.dart';
import '../screens/premium_subscription_screen.dart';

class TabbedOptionSelector extends ConsumerStatefulWidget {
  final bool isPremium;
  final AdvancedImageOptions advancedOptions;
  final ValueChanged<AdvancedImageOptions> onAdvancedOptionsChanged;
  final ImageTime selectedTime;
  final ValueChanged<ImageTime> onTimeChanged;
  final ImageWeather selectedWeather;
  final ValueChanged<ImageWeather> onWeatherChanged;
  final ImageSeason selectedSeason;
  final ValueChanged<ImageSeason> onSeasonChanged;
  final PerspectiveOptions perspectiveOptions;
  final ValueChanged<PerspectiveOptions> onPerspectiveOptionsChanged;
  final String? selectedThemePresetId;
  final ValueChanged<String?> onThemePresetChanged;
  final bool isAutoConfigEnabled;
  final ValueChanged<bool> onAutoConfigChanged;
  final VoidCallback? onAutoConfigApply;

  const TabbedOptionSelector({
    super.key,
    required this.isPremium,
    required this.advancedOptions,
    required this.onAdvancedOptionsChanged,
    required this.selectedTime,
    required this.onTimeChanged,
    required this.selectedWeather,
    required this.onWeatherChanged,
    required this.selectedSeason,
    required this.onSeasonChanged,
    required this.perspectiveOptions,
    required this.onPerspectiveOptionsChanged,
    required this.selectedThemePresetId,
    required this.onThemePresetChanged,
    required this.isAutoConfigEnabled,
    required this.onAutoConfigChanged,
    this.onAutoConfigApply,
  });

  @override
  ConsumerState<TabbedOptionSelector> createState() => _TabbedOptionSelectorState();
}

class _TabbedOptionSelectorState extends ConsumerState<TabbedOptionSelector> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 기본 설정 섹션
          _buildExpansionTile(
            key: const ValueKey('basic_settings'),
            icon: Icons.auto_awesome,
            title: '기본 설정',
            isLocked: false,
            child: _buildBasicSettingsContent(),
          ),

          const SizedBox(height: 12),

          // 이미지 설정 섹션
          _buildExpansionTile(
            key: const ValueKey('image_settings'),
            icon: Icons.tune,
            title: '이미지 설정',
            isLocked: !widget.isPremium,
            child: _buildImageSettingsContent(),
          ),

          const SizedBox(height: 12),

          // 부가 기능 섹션
          _buildExpansionTile(
            key: const ValueKey('advanced_features'),
            icon: Icons.settings,
            title: '부가 기능',
            isLocked: !widget.isPremium,
            child: _buildAdvancedFeaturesContent(),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildExpansionTile({
    required Key key,
    required IconData icon,
    required String title,
    required bool isLocked,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          key: key,
          initiallyExpanded: false,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          childrenPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isLocked ? Colors.grey.shade200 : const Color(0xFF667EEA).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: isLocked ? Colors.grey.shade400 : const Color(0xFF667EEA),
              size: 24,
            ),
          ),
          title: Row(
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isLocked ? Colors.grey.shade400 : const Color(0xFF2D3748),
                ),
              ),
              if (isLocked) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.lock, color: Colors.white, size: 12),
                      SizedBox(width: 4),
                      Text(
                        '프리미엄',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          children: [child],
        ),
      ),
    );
  }

  // 기본 설정 내용
  Widget _buildBasicSettingsContent() {
    final selectedPresetId = ref.watch(themePresetProvider);
    ref.watch(defaultImageStyleProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 테마 프리셋 섹션
        ThemePresetSelector(
          selectedPresetId: selectedPresetId,
          onPresetSelected: (preset) {
            ref.read(themePresetProvider.notifier).selectPreset(preset.id);
            ref.read(defaultImageStyleProvider.notifier).setStyle(preset.style);
            if (widget.isPremium && preset.advancedOptions != null) {
              widget.onAdvancedOptionsChanged(preset.advancedOptions!);
            }
            if (widget.isPremium && preset.time != null) {
              widget.onTimeChanged(preset.time!);
            }
            if (widget.isPremium && preset.weather != null) {
              widget.onWeatherChanged(preset.weather!);
            }
          },
          isPremium: widget.isPremium,
        ),
      ],
    );
  }

  // 이미지 설정 내용
  Widget _buildImageSettingsContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 고급옵션 자동설정 섹션 (프리미엄 전용)
        if (widget.isPremium) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Checkbox(
                      value: widget.isAutoConfigEnabled,
                      onChanged: (value) {
                        widget.onAutoConfigChanged(value ?? false);
                        if (value == true && widget.onAutoConfigApply != null) {
                          widget.onAutoConfigApply!();
                        }
                      },
                      activeColor: const Color(0xFF667EEA),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '고급옵션 자동설정',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2D3748),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '아래 네 가지 옵션을 일기 내용에 맞게 자동 설정합니다',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // 자동설정 대상 옵션들을 시각적으로 표시
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildAutoConfigIcon(Icons.wb_sunny, '조명'),
                      _buildAutoConfigIcon(Icons.mood, '분위기'),
                      _buildAutoConfigIcon(Icons.palette, '색상'),
                      _buildAutoConfigIcon(Icons.photo_size_select_large, '구도'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],

        // 고급 이미지 옵션 섹션 (조명, 분위기, 색상, 구도)
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: AdvancedImageOptionsSelector(
            options: widget.advancedOptions,
            onChanged: widget.onAdvancedOptionsChanged,
            enabled: widget.isPremium,
          ),
        ),

        const SizedBox(height: 24),

        // 구분선
        Container(
          height: 1,
          color: Colors.grey.shade300,
          margin: const EdgeInsets.symmetric(horizontal: 8),
        ),

        const SizedBox(height: 24),

        // 시간대/조명 설정 섹션
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: ImageTimeSelector(
            selectedTime: widget.selectedTime,
            onTimeChanged: widget.onTimeChanged,
            enabled: widget.isPremium,
          ),
        ),

        const SizedBox(height: 20),

        // 날씨 설정 섹션
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: ImageWeatherSelector(
            selectedWeather: widget.selectedWeather,
            onWeatherChanged: widget.onWeatherChanged,
            enabled: widget.isPremium,
          ),
        ),

        const SizedBox(height: 20),

        // 계절 설정 섹션
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: ImageSeasonSelector(
            selectedSeason: widget.selectedSeason,
            onSeasonChanged: widget.onSeasonChanged,
            enabled: widget.isPremium,
          ),
        ),
      ],
    );
  }

  // 부가 기능 내용
  Widget _buildAdvancedFeaturesContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 이미지 시점 섹션
        PerspectiveOptionsSelector(
          options: widget.perspectiveOptions,
          onChanged: widget.onPerspectiveOptionsChanged,
          enabled: widget.isPremium,
        ),
      ],
    );
  }



  Widget _buildAutoConfigIcon(IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.shade200.withOpacity(0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            icon,
            size: 24,
            color: Colors.blue.shade700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.blue.shade800,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
