import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/image_style.dart';
import '../models/image_options.dart';
import '../models/image_time.dart';
import '../models/image_weather.dart';
import '../models/image_season.dart';
import '../models/perspective_options.dart';
import '../models/theme_preset.dart';
import '../providers/image_style_provider.dart';
import '../providers/theme_preset_provider.dart';

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

class _TabbedOptionSelectorState extends ConsumerState<TabbedOptionSelector>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 탭 헤더
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: TabBar(
            controller: _tabController,
            tabs: [
              _buildTab(Icons.auto_awesome, '기본 설정', 0),
              _buildTab(Icons.tune, '이미지 설정', 1),
              _buildTab(Icons.settings, '부가 기능', 2),
            ],
            labelColor: const Color(0xFF667EEA),
            unselectedLabelColor: Colors.grey,
            indicator: const BoxDecoration(),
            dividerColor: Colors.transparent,
          ),
        ),

        // 탭 내용
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildBasicSettingsTab(),
                _buildImageSettingsTab(),
                _buildAdvancedFeaturesTab(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTab(IconData icon, String label, int index) {
    final isLocked = !widget.isPremium && (index == 1 || index == 2);

    return Tab(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isLocked ? Colors.grey.shade400 : null,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isLocked ? Colors.grey.shade400 : null,
                ),
              ),
            ],
          ),
          if (isLocked)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.all(2),
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
            ),
        ],
      ),
    );
  }

  // 기본 설정 탭 (프리셋 + 스타일)
  Widget _buildBasicSettingsTab() {
    final selectedPresetId = ref.watch(themePresetProvider);
    final selectedStyle = ref.watch(defaultImageStyleProvider);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(
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

            if (!widget.isPremium) ...[
              const SizedBox(height: 20),
              _buildPremiumPromptCard(),
            ],
          ],
        ),
      ),
    );
  }

  // 이미지 설정 탭 (고급옵션 + 비율)
  Widget _buildImageSettingsTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 고급옵션 자동설정 섹션
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
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: widget.isAutoConfigEnabled && widget.isPremium
                    ? Border.all(color: Colors.blue.shade400, width: 2)
                    : null,
                color: widget.isAutoConfigEnabled && widget.isPremium
                  ? Colors.blue.shade50
                  : Colors.grey.shade50,
                boxShadow: widget.isAutoConfigEnabled && widget.isPremium
                    ? [
                        BoxShadow(
                          color: Colors.blue.shade200.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.grey.shade300.withOpacity(0.5),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
              ),
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
              ),
            ),

            if (!widget.isPremium) ...[
              const SizedBox(height: 20),
              _buildPremiumPromptCard(),
            ],
          ],
        ),
      ),
    );
  }

  // 부가 기능 탭 (시점 + 글꼴)
  Widget _buildAdvancedFeaturesTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 이미지 시점 섹션
            PerspectiveOptionsSelector(
              options: widget.perspectiveOptions,
              onChanged: widget.onPerspectiveOptionsChanged,
              enabled: true,
            ),


            if (!widget.isPremium) ...[
              const SizedBox(height: 20),
              _buildPremiumPromptCard(),
            ],
          ],
        ),
      ),
    );
  }

  // 프리미엄 안내 카드
  Widget _buildPremiumPromptCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(Icons.star, color: Colors.amber, size: 32),
          const SizedBox(height: 8),
          Text(
            '프리미엄 전용 기능',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.amber.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '고급 옵션, 비율 선택, 시드 고정, 프리미엄 글꼴 등의 기능을 사용하려면 프리미엄으로 업그레이드하세요.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 36,
            child: FilledButton(
              onPressed: () => _showPremiumDialog(context),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                '프리미엄 구독하기',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
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
            const Text('프리미엄 전용 기능'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '프리미엄으로 업그레이드하면 더 많은 기능을 사용할 수 있어요.',
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
                  const Text('• 프리미엄 글꼴'),
                  const Text('• 6가지 프리미엄 스타일'),
                  const Text('• 고급 이미지 옵션 (조명, 분위기, 색상, 구도)'),
                  const Text('• 시간대/조명 및 날씨/계절 설정'),
                  const Text('• 무제한 이미지 생성'),
                  const Text('• 수정 시 이미지도 재생성 (일기당 1회)'),
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