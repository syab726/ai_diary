import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

// 시간대/조명 옵션
enum ImageTime {
  morning,
  noon,
  golden,
  sunset,
  night,
  indoor;

  // AI 프롬프트용 영어 displayName (ai_service.dart에서 사용)
  String get displayName {
    switch (this) {
      case ImageTime.morning:
        return 'morning';
      case ImageTime.noon:
        return 'noon';
      case ImageTime.golden:
        return 'golden hour';
      case ImageTime.sunset:
        return 'sunset';
      case ImageTime.night:
        return 'night';
      case ImageTime.indoor:
        return 'indoor';
    }
  }
}

// 시간대/조명 선택기 위젯
class ImageTimeSelector extends StatelessWidget {
  final ImageTime selectedTime;
  final ValueChanged<ImageTime> onTimeChanged;
  final bool enabled;

  const ImageTimeSelector({
    super.key,
    required this.selectedTime,
    required this.onTimeChanged,
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
            Icon(
              Icons.wb_sunny,
              size: 18,
              color: enabled ? Colors.grey.shade600 : Colors.grey.shade400,
            ),
            const SizedBox(width: 8),
            Text(
              l10n.optionTimeLighting,
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
            child: DropdownButton<ImageTime>(
              value: selectedTime,
              isExpanded: true,
              icon: Icon(
                Icons.arrow_drop_down,
                color: enabled ? Colors.grey.shade600 : Colors.grey.shade400,
              ),
              items: ImageTime.values.map((time) {
                return DropdownMenuItem<ImageTime>(
                  value: time,
                  child: Row(
                    children: [
                      Icon(
                        _getTimeIcon(time),
                        size: 20,
                        color: enabled ? _getTimeColor(time) : Colors.grey.shade400,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _getTimeDisplayName(l10n, time),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: enabled ? Colors.grey.shade800 : Colors.grey.shade400,
                              ),
                            ),
                            Text(
                              _getTimeDescription(l10n, time),
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
              onChanged: enabled ? (time) {
                if (time != null) {
                  onTimeChanged(time);
                }
              } : null,
            ),
          ),
        ),
      ],
    );
  }

  String _getTimeDisplayName(AppLocalizations l10n, ImageTime time) {
    switch (time) {
      case ImageTime.morning:
        return l10n.timeMorning;
      case ImageTime.noon:
        return l10n.timeNoon;
      case ImageTime.golden:
        return l10n.timeGolden;
      case ImageTime.sunset:
        return l10n.timeSunset;
      case ImageTime.night:
        return l10n.timeNight;
      case ImageTime.indoor:
        return l10n.timeIndoor;
    }
  }

  String _getTimeDescription(AppLocalizations l10n, ImageTime time) {
    switch (time) {
      case ImageTime.morning:
        return l10n.timeMorningDesc;
      case ImageTime.noon:
        return l10n.timeNoonDesc;
      case ImageTime.golden:
        return l10n.timeGoldenDesc;
      case ImageTime.sunset:
        return l10n.timeSunsetDesc;
      case ImageTime.night:
        return l10n.timeNightDesc;
      case ImageTime.indoor:
        return l10n.timeIndoorDesc;
    }
  }

  IconData _getTimeIcon(ImageTime time) {
    switch (time) {
      case ImageTime.morning:
        return Icons.wb_sunny;
      case ImageTime.noon:
        return Icons.light_mode;
      case ImageTime.golden:
        return Icons.wb_twilight;
      case ImageTime.sunset:
        return Icons.wb_shade;
      case ImageTime.night:
        return Icons.nights_stay;
      case ImageTime.indoor:
        return Icons.lightbulb;
    }
  }

  Color _getTimeColor(ImageTime time) {
    switch (time) {
      case ImageTime.morning:
        return Colors.orange;
      case ImageTime.noon:
        return Colors.yellow.shade700;
      case ImageTime.golden:
        return Colors.amber;
      case ImageTime.sunset:
        return Colors.deepOrange;
      case ImageTime.night:
        return Colors.indigo;
      case ImageTime.indoor:
        return Colors.grey.shade600;
    }
  }
}