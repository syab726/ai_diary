import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../l10n/app_localizations.dart';

enum FontFamily {
  notoSans('Noto Sans', 'system', '시스템 기본체', false),
  gaegu('Gaegu', 'handwriting', '개구쟁이체', true),
  dokdo('Dokdo', 'handwriting', '독도체', true),
  nanumPenScript('Nanum Pen Script', 'handwriting', '나눔손글씨 펜', true),
  blackHanSans('Black Han Sans', 'display', '검은고딕', true),
  nanumMyeongjo('Nanum Myeongjo', 'serif', '나눔명조', true),
  nanumGothic('Nanum Gothic', 'sans-serif', '나눔고딕', true),
  sunflower('Sunflower', 'display', '해바라기체', true),
  jua('Jua', 'display', '주아체', true),
  songMyung('Song Myung', 'serif', '송명체', true),
  cuteFont('Cute Font', 'display', '큐트폰트', true);

  const FontFamily(this.name, this.category, this.displayName, this.isPremium);

  final String name;
  final String category;
  final String displayName;
  final bool isPremium;

  TextStyle getTextStyle({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
  }) {
    switch (this) {
      case FontFamily.notoSans:
        return GoogleFonts.notoSans(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
        );
      case FontFamily.gaegu:
        return GoogleFonts.gaegu(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
        );
      case FontFamily.dokdo:
        return GoogleFonts.dokdo(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
        );
      case FontFamily.nanumPenScript:
        return GoogleFonts.nanumPenScript(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
        );
      case FontFamily.blackHanSans:
        return GoogleFonts.blackHanSans(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
        );
      case FontFamily.nanumMyeongjo:
        return GoogleFonts.nanumMyeongjo(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
        );
      case FontFamily.nanumGothic:
        return GoogleFonts.nanumGothic(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
        );
      case FontFamily.sunflower:
        return GoogleFonts.sunflower(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
        );
      case FontFamily.jua:
        return GoogleFonts.jua(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
        );
      case FontFamily.songMyung:
        return GoogleFonts.songMyung(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
        );
      case FontFamily.cuteFont:
        return GoogleFonts.cuteFont(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
        );
    }
  }

  TextTheme getTextTheme({double fontSizeMultiplier = 1.0}) {
    final baseTextTheme = GoogleFonts.getTextTheme(name);

    return TextTheme(
      bodyLarge: getTextStyle(
        fontSize: (baseTextTheme.bodyLarge?.fontSize ?? 16) * fontSizeMultiplier,
      ),
      bodyMedium: getTextStyle(
        fontSize: (baseTextTheme.bodyMedium?.fontSize ?? 14) * fontSizeMultiplier,
      ),
      bodySmall: getTextStyle(
        fontSize: (baseTextTheme.bodySmall?.fontSize ?? 12) * fontSizeMultiplier,
      ),
      headlineLarge: getTextStyle(
        fontSize: (baseTextTheme.headlineLarge?.fontSize ?? 32) * fontSizeMultiplier,
      ),
      headlineMedium: getTextStyle(
        fontSize: (baseTextTheme.headlineMedium?.fontSize ?? 28) * fontSizeMultiplier,
      ),
      headlineSmall: getTextStyle(
        fontSize: (baseTextTheme.headlineSmall?.fontSize ?? 24) * fontSizeMultiplier,
      ),
      titleLarge: getTextStyle(
        fontSize: (baseTextTheme.titleLarge?.fontSize ?? 22) * fontSizeMultiplier,
      ),
      titleMedium: getTextStyle(
        fontSize: (baseTextTheme.titleMedium?.fontSize ?? 16) * fontSizeMultiplier,
      ),
      titleSmall: getTextStyle(
        fontSize: (baseTextTheme.titleSmall?.fontSize ?? 14) * fontSizeMultiplier,
      ),
      labelLarge: getTextStyle(
        fontSize: (baseTextTheme.labelLarge?.fontSize ?? 14) * fontSizeMultiplier,
      ),
      labelMedium: getTextStyle(
        fontSize: (baseTextTheme.labelMedium?.fontSize ?? 12) * fontSizeMultiplier,
      ),
      labelSmall: getTextStyle(
        fontSize: (baseTextTheme.labelSmall?.fontSize ?? 11) * fontSizeMultiplier,
      ),
    );
  }
}

class FontFamilySelector extends StatelessWidget {
  final FontFamily selectedFont;
  final ValueChanged<FontFamily> onFontChanged;
  final bool isPremium;

  const FontFamilySelector({
    super.key,
    required this.selectedFont,
    required this.onFontChanged,
    this.isPremium = false,
  });

  @override
  Widget build(BuildContext context) {
    final availableFonts = isPremium
        ? FontFamily.values
        : [FontFamily.notoSans]; // 무료 사용자는 기본체만

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.font_download,
              size: 18,
              color: Colors.grey.shade600,
            ),
            const SizedBox(width: 8),
            Text(
              '글꼴',
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
            child: DropdownButton<FontFamily>(
              value: selectedFont,
              isExpanded: true,
              icon: Icon(
                Icons.arrow_drop_down,
                color: Colors.grey.shade600,
              ),
              items: availableFonts.map((font) {
                return DropdownMenuItem<FontFamily>(
                  value: font,
                  child: Row(
                    children: [
                      Icon(
                        Icons.text_fields,
                        size: 20,
                        color: font.isPremium
                            ? (isPremium ? Colors.amber : Colors.grey.shade400)
                            : Colors.grey.shade600,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              font.displayName,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade800,
                              ),
                            ),
                            Text(
                              '오늘 하루도 즐거운 일기를 써보세요',
                              style: font.getTextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (font.isPremium && !isPremium)
                        Container(
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
                    ],
                  ),
                );
              }).toList(),
              onChanged: (font) {
                if (font != null) {
                  if (font.isPremium && !isPremium) {
                    _showPremiumDialog(context);
                  } else {
                    onFontChanged(font);
                  }
                }
              },
            ),
          ),
        ),

        // 무료 사용자를 위한 프리미엄 글꼴 미리보기 버튼
        if (!isPremium) ...[
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showPremiumFontsDialog(context),
              icon: const Icon(Icons.font_download, size: 20),
              label: const Text('프리미엄 글꼴 보기'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF667EEA),
                side: const BorderSide(color: Color(0xFF667EEA)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ],
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
            const Text('프리미엄 전용 글꼴'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '이 글꼴은 프리미엄 구독자만 사용할 수 있어요.',
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
                  const Text('• 10가지 프리미엄 글꼴'),
                  const Text('• 6가지 프리미엄 스타일'),
                  const Text('• 무제한 이미지 생성'),
                  const Text('• 수정 시 이미지도 재생성 (일기당 1회)'),
                  const Text('• 고급 이미지 옵션 (조명, 분위기, 색상, 구도)'),
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

  void _showPremiumFontsDialog(BuildContext context) {
    final allPremiumFonts = FontFamily.values.where((font) => font.isPremium).toList();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(Icons.font_download, color: Colors.amber, size: 28),
            const SizedBox(width: 8),
            const Text('프리미엄 글꼴'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '프리미엄으로 업그레이드하면 다양한 글꼴을 사용할 수 있어요!',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: allPremiumFonts.length,
                  itemBuilder: (context, index) {
                    final font = allPremiumFonts[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    font.displayName,
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '오늘 하루도 즐거운 일기를 써보세요',
                                    style: font.getTextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.amber,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Icon(
                                Icons.lock,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
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
              backgroundColor: Colors.amber,
            ),
            child: const Text('구독하기'),
          ),
        ],
      ),
    );
  }
}