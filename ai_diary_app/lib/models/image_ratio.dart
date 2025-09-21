import 'package:flutter/material.dart';

// 이미지 비율 옵션
enum ImageRatio {
  square('1:1', '정사각형', 1.0),
  portrait('3:4', '세로형', 3.0 / 4.0),
  landscape('4:3', '가로형', 4.0 / 3.0),
  wide('16:9', '와이드', 16.0 / 9.0),
  tall('9:16', '세로 긴형', 9.0 / 16.0);

  const ImageRatio(this.ratio, this.displayName, this.aspectRatio);

  final String ratio;
  final String displayName;
  final double aspectRatio;
}

// 이미지 비율 선택기 위젯
class ImageRatioSelector extends StatelessWidget {
  final ImageRatio selectedRatio;
  final ValueChanged<ImageRatio> onRatioChanged;
  final bool enabled;

  const ImageRatioSelector({
    super.key,
    required this.selectedRatio,
    required this.onRatioChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: ImageRatio.values.map((ratio) {
        final isSelected = ratio == selectedRatio;
        return _buildRatioOption(ratio, isSelected);
      }).toList(),
    );
  }

  Widget _buildRatioOption(ImageRatio ratio, bool isSelected) {
    return GestureDetector(
      onTap: enabled ? () => onRatioChanged(ratio) : null,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? (enabled ? const Color(0xFF667EEA) : Colors.grey)
                : (enabled ? Colors.grey.shade300 : Colors.grey.shade200),
            width: isSelected ? 2 : 1,
          ),
          color: isSelected
              ? (enabled ? const Color(0xFF667EEA).withOpacity(0.1) : Colors.grey.withOpacity(0.1))
              : Colors.white,
        ),
        child: Column(
          children: [
            // 비율 미리보기
            Container(
              width: 40,
              height: 40 / ratio.aspectRatio,
              decoration: BoxDecoration(
                border: Border.all(
                  color: isSelected
                      ? (enabled ? const Color(0xFF667EEA) : Colors.grey)
                      : (enabled ? Colors.grey.shade400 : Colors.grey.shade300),
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected
                      ? (enabled ? const Color(0xFF667EEA).withOpacity(0.3) : Colors.grey.withOpacity(0.3))
                      : (enabled ? Colors.grey.shade100 : Colors.grey.shade50),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              ratio.ratio,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? (enabled ? const Color(0xFF667EEA) : Colors.grey)
                    : (enabled ? Colors.grey.shade600 : Colors.grey.shade400),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              ratio.displayName,
              style: TextStyle(
                fontSize: 10,
                color: isSelected
                    ? (enabled ? const Color(0xFF667EEA) : Colors.grey)
                    : (enabled ? Colors.grey.shade500 : Colors.grey.shade400),
              ),
            ),
          ],
        ),
      ),
    );
  }
}