import 'package:flutter/material.dart';

// 날씨 옵션
enum ImageWeather {
  sunny('맑은 날', '화창하고 밝은 날씨'),
  cloudy('흐린 날', '구름 낀 부드러운 날씨'),
  rainy('비 오는 날', '촉촉한 비의 분위기'),
  snowy('눈 내리는 날', '하얀 눈의 포근함');

  const ImageWeather(this.displayName, this.description);

  final String displayName;
  final String description;
}

// 날씨 선택기 위젯
class ImageWeatherSelector extends StatelessWidget {
  final ImageWeather selectedWeather;
  final ValueChanged<ImageWeather> onWeatherChanged;
  final bool enabled;

  const ImageWeatherSelector({
    super.key,
    required this.selectedWeather,
    required this.onWeatherChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.cloud,
              size: 18,
              color: enabled ? Colors.grey.shade600 : Colors.grey.shade400,
            ),
            const SizedBox(width: 8),
            Text(
              '날씨',
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
            child: DropdownButton<ImageWeather>(
              value: selectedWeather,
              isExpanded: true,
              icon: Icon(
                Icons.arrow_drop_down,
                color: enabled ? Colors.grey.shade600 : Colors.grey.shade400,
              ),
              items: ImageWeather.values.map((weather) {
                return DropdownMenuItem<ImageWeather>(
                  value: weather,
                  child: Row(
                    children: [
                      Icon(
                        _getWeatherIcon(weather),
                        size: 20,
                        color: enabled ? _getWeatherColor(weather) : Colors.grey.shade400,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              weather.displayName,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: enabled ? Colors.grey.shade800 : Colors.grey.shade400,
                              ),
                            ),
                            Text(
                              weather.description,
                              style: TextStyle(
                                fontSize: 11,
                                color: enabled ? Colors.grey.shade600 : Colors.grey.shade400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: enabled ? (weather) {
                if (weather != null) {
                  onWeatherChanged(weather);
                }
              } : null,
            ),
          ),
        ),
      ],
    );
  }

  IconData _getWeatherIcon(ImageWeather weather) {
    switch (weather) {
      case ImageWeather.sunny:
        return Icons.wb_sunny;
      case ImageWeather.cloudy:
        return Icons.cloud;
      case ImageWeather.rainy:
        return Icons.umbrella;
      case ImageWeather.snowy:
        return Icons.ac_unit;
    }
  }

  Color _getWeatherColor(ImageWeather weather) {
    switch (weather) {
      case ImageWeather.sunny:
        return Colors.orange;
      case ImageWeather.cloudy:
        return Colors.grey.shade600;
      case ImageWeather.rainy:
        return Colors.blue;
      case ImageWeather.snowy:
        return Colors.lightBlue;
    }
  }
}