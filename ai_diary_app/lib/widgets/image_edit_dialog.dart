import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/image_style.dart';
import '../models/image_options.dart';
import '../providers/subscription_provider.dart';
import '../providers/image_style_provider.dart';

class ImageEditDialog extends ConsumerStatefulWidget {
  final String currentContent;
  final Function(ImageStyle style, AdvancedImageOptions options) onConfirm;

  const ImageEditDialog({
    super.key,
    required this.currentContent,
    required this.onConfirm,
  });

  @override
  ConsumerState<ImageEditDialog> createState() => _ImageEditDialogState();
}

class _ImageEditDialogState extends ConsumerState<ImageEditDialog> {
  late ImageStyle _selectedStyle;
  AdvancedImageOptions _advancedOptions = const AdvancedImageOptions();

  @override
  void initState() {
    super.initState();
    _selectedStyle = ref.read(defaultImageStyleProvider);
  }

  @override
  Widget build(BuildContext context) {
    final subscription = ref.watch(subscriptionProvider);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 제목과 닫기 버튼
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '그림 스타일 및 옵션 선택',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 안내 메시지
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '그림은 일기당 1회만 수정 가능합니다',
                      style: TextStyle(
                        color: Colors.orange.shade700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 스크롤 가능한 내용
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 이미지 스타일 선택
                    ImageStyleSelector(
                      selectedStyle: _selectedStyle,
                      onStyleChanged: (style) {
                        setState(() {
                          _selectedStyle = style;
                        });
                      },
                      isPremium: subscription.isPremium,
                    ),
                    const SizedBox(height: 20),

                    // 고급 옵션 (프리미엄 사용자만)
                    if (subscription.isPremium) ...[
                      AdvancedImageOptionsSelector(
                        options: _advancedOptions,
                        onChanged: (options) {
                          setState(() {
                            _advancedOptions = options;
                          });
                        },
                        enabled: true,
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 하단 버튼들
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: Colors.grey),
                    ),
                    child: const Text('취소'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      widget.onConfirm(_selectedStyle, _advancedOptions);
                      Navigator.of(context).pop();
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF667EEA),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('그림 재생성'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}