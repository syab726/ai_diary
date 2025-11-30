import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/connectivity_provider.dart';

/// 오프라인 상태를 표시하는 배너 위젯
class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivityState = ref.watch(connectivityProvider);

    return connectivityState.when(
      data: (isOnline) {
        if (isOnline) {
          return const SizedBox.shrink(); // 온라인이면 아무것도 표시 안 함
        }

        // 오프라인 배너 표시
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          color: Colors.orange.shade700,
          child: Row(
            children: [
              const Icon(
                Icons.cloud_off,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '오프라인 모드 - 일기 작성은 가능하지만 AI 이미지 생성은 사용할 수 없습니다',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
