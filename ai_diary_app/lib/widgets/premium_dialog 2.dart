import 'package:flutter/material.dart';
import '../screens/premium_subscription_screen.dart';

/// 프리미엄 전용 기능 안내 다이얼로그
void showPremiumRequiredDialog(BuildContext context, {String? featureName}) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.diamond, color: Colors.amber),
          SizedBox(width: 8),
          Text('프리미엄 전용 기능'),
        ],
      ),
      content: Text(
        featureName != null
            ? '$featureName은(는) 프리미엄 사용자만 사용할 수 있습니다.'
            : '이 기능은 프리미엄 사용자만 사용할 수 있습니다.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('확인'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PremiumSubscriptionScreen(),
              ),
            );
          },
          style: FilledButton.styleFrom(
            backgroundColor: Colors.amber,
            foregroundColor: Colors.white,
          ),
          child: const Text('프리미엄 업그레이드'),
        ),
      ],
    ),
  );
}
