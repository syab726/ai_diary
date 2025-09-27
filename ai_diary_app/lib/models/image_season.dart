import 'package:flutter/material.dart';

enum ImageSeason {
  spring('봄', '신록과 꽃이 피어나는 봄'),
  summer('여름', '푸르고 생기 넘치는 여름'),
  autumn('가을', '단풍과 따뜻한 색감의 가을'),
  winter('겨울', '하얀 설경과 차가운 겨울');

  const ImageSeason(this.displayName, this.description);

  final String displayName;
  final String description;
}

class ImageSeasonSelector extends StatelessWidget {
  final ImageSeason selectedSeason;
  final ValueChanged<ImageSeason> onSeasonChanged;

  const ImageSeasonSelector({
    super.key,
    required this.selectedSeason,
    required this.onSeasonChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.nature,
              size: 18,
              color: Colors.grey.shade600,
            ),
            const SizedBox(width: 8),
            Text(
              '계절',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<ImageSeason>(
              value: selectedSeason,
              isExpanded: true,
              icon: Icon(Icons.arrow_drop_down, color: Colors.grey.shade600),
              items: ImageSeason.values.map((season) {
                return DropdownMenuItem<ImageSeason>(
                  value: season,
                  child: Row(
                    children: [
                      Icon(
                        _getSeasonIcon(season),
                        size: 20,
                        color: _getSeasonColor(season),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              season.displayName,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              season.description,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (season) {
                if (season != null) {
                  onSeasonChanged(season);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  IconData _getSeasonIcon(ImageSeason season) {
    switch (season) {
      case ImageSeason.spring:
        return Icons.local_florist;
      case ImageSeason.summer:
        return Icons.wb_sunny;
      case ImageSeason.autumn:
        return Icons.park;
      case ImageSeason.winter:
        return Icons.ac_unit;
    }
  }

  Color _getSeasonColor(ImageSeason season) {
    switch (season) {
      case ImageSeason.spring:
        return Colors.green;
      case ImageSeason.summer:
        return Colors.orange;
      case ImageSeason.autumn:
        return Colors.brown;
      case ImageSeason.winter:
        return Colors.blue;
    }
  }
}