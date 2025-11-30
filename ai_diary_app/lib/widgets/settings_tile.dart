import 'package:flutter/material.dart';
import 'premium_dialog.dart';

/// 설정 화면용 공통 ListTile 위젯
/// 프리미엄 전용 기능 지원
class SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isPremiumOnly;
  final bool isPremium;

  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isPremiumOnly = false,
    this.isPremium = true,
  });

  @override
  Widget build(BuildContext context) {
    final isLocked = isPremiumOnly && !isPremium;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Opacity(
        opacity: isLocked ? 0.5 : 1.0,
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (isLocked ? Colors.amber : const Color(0xFF667EEA)).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isLocked ? Icons.lock : icon,
              color: isLocked ? Colors.amber : const Color(0xFF667EEA),
              size: 20,
            ),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isLocked ? Colors.grey : const Color(0xFF2D3748),
            ),
          ),
          subtitle: Text(
            isLocked ? '프리미엄 전용 기능' : subtitle,
            style: TextStyle(
              color: isLocked ? Colors.grey : const Color(0xFF718096),
              fontSize: 13,
            ),
          ),
          trailing: Icon(
            Icons.chevron_right,
            color: isLocked ? Colors.grey : const Color(0xFF9CA3AF),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          tileColor: Colors.white,
          onTap: isLocked
              ? () => showPremiumRequiredDialog(context, featureName: title)
              : onTap,
        ),
      ),
    );
  }
}
