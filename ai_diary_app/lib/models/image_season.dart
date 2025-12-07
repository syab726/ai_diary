import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

enum ImageSeason {
  spring,
  summer,
  autumn,
  winter;

  // AI 프롬프트용 영어 displayName (ai_service.dart에서 사용)
  String get displayName {
    switch (this) {
      case ImageSeason.spring:
        return 'spring';
      case ImageSeason.summer:
        return 'summer';
      case ImageSeason.autumn:
        return 'autumn';
      case ImageSeason.winter:
        return 'winter';
    }
  }

  String getLocalizedName(AppLocalizations l10n) {
    switch (this) {
      case ImageSeason.spring:
        return l10n.seasonSpring;
      case ImageSeason.summer:
        return l10n.seasonSummer;
      case ImageSeason.autumn:
        return l10n.seasonAutumn;
      case ImageSeason.winter:
        return l10n.seasonWinter;
    }
  }

  String getLocalizedDescription(AppLocalizations l10n) {
    switch (this) {
      case ImageSeason.spring:
        return l10n.seasonSpringDesc;
      case ImageSeason.summer:
        return l10n.seasonSummerDesc;
      case ImageSeason.autumn:
        return l10n.seasonAutumnDesc;
      case ImageSeason.winter:
        return l10n.seasonWinterDesc;
    }
  }
}

class ImageSeasonSelector extends StatelessWidget {
  final ImageSeason selectedSeason;
  final ValueChanged<ImageSeason> onSeasonChanged;
  final bool enabled;

  const ImageSeasonSelector({
    super.key,
    required this.selectedSeason,
    required this.onSeasonChanged,
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
              Icons.nature,
              size: 18,
              color: enabled ? Colors.grey.shade600 : Colors.grey.shade400,
            ),
            const SizedBox(width: 8),
            Text(
              l10n.optionSeason,
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
            child: DropdownButton<ImageSeason>(
              value: selectedSeason,
              isExpanded: true,
              icon: Icon(
                Icons.arrow_drop_down,
                color: enabled ? Colors.grey.shade600 : Colors.grey.shade400,
              ),
              items: ImageSeason.values.map((season) {
                return DropdownMenuItem<ImageSeason>(
                  value: season,
                  child: Row(
                    children: [
                      Icon(
                        _getSeasonIcon(season),
                        size: 20,
                        color: enabled ? _getSeasonColor(season) : Colors.grey.shade400,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              season.getLocalizedName(l10n),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: enabled ? Colors.grey.shade800 : Colors.grey.shade400,
                              ),
                            ),
                            Text(
                              season.getLocalizedDescription(l10n),
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
              onChanged: enabled ? (season) {
                if (season != null) {
                  onSeasonChanged(season);
                }
              } : null,
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