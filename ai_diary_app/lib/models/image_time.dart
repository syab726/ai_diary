import 'package:flutter/material.dart';

// 시간대/조명 옵션
enum ImageTime {
  morning('아침 햇살', '밝고 따뜻한 아침 햇살'),
  noon('한낮', '밝고 환한 낮의 햇빛'),
  golden('황금시간', '따뜻한 황금빛 조명'),
  sunset('저녁노을', '아름다운 석양과 노을'),
  night('밤의 분위기', '신비로운 밤의 조명'),
  indoor('실내조명', '따뜻한 실내 조명');

  const ImageTime(this.displayName, this.description);

  final String displayName;
  final String description;
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
              '시간대/조명',
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
                              time.displayName,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: enabled ? Colors.grey.shade800 : Colors.grey.shade400,
                              ),
                            ),
                            Text(
                              time.description,
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