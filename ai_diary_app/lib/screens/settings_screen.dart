import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../l10n/app_localizations.dart';
import '../providers/subscription_provider.dart';
import '../services/auth_service.dart';
import 'settings/personalization_settings_screen.dart';
import 'settings/ai_settings_screen.dart';
import 'settings/backup_restore_screen.dart';
import 'settings/delete_settings_screen.dart';
import 'settings/app_info_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(
          AppLocalizations.of(context).settings,
          style: const TextStyle(
            color: Color(0xFF2D3748),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF2D3748),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 5개 메인 메뉴 타일
          _buildMenuTile(
            context: context,
            icon: Icons.person,
            title: AppLocalizations.of(context).personalization,
            subtitle: AppLocalizations.of(context).personalizationSubtitle,
            onTap: () => _navigateToPersonalization(context),
          ),
          _buildMenuTile(
            context: context,
            icon: Icons.auto_fix_high,
            title: AppLocalizations.of(context).aiSettings,
            subtitle: AppLocalizations.of(context).aiSettingsSubtitle,
            onTap: () => _navigateToAiSettings(context),
          ),
          _buildMenuTile(
            context: context,
            icon: Icons.backup,
            title: AppLocalizations.of(context).backupAndRestore,
            subtitle: AppLocalizations.of(context).backupDescription,
            onTap: () => _navigateToBackupRestore(context),
          ),
          _buildMenuTile(
            context: context,
            icon: Icons.delete_forever,
            title: AppLocalizations.of(context).deleteData,
            subtitle: AppLocalizations.of(context).deleteDataDescription,
            onTap: () => _navigateToDelete(context),
            isDestructive: true,
          ),
          _buildMenuTile(
            context: context,
            icon: Icons.info,
            title: AppLocalizations.of(context).appInfo,
            subtitle: AppLocalizations.of(context).appInfoSubtitle,
            onTap: () => _navigateToAppInfo(context),
          ),

          const SizedBox(height: 24),

          // 프리미엄 섹션 (프리미엄 사용자가 아닐 때만 표시)
          Consumer(
            builder: (context, ref, child) {
              final subscription = ref.watch(subscriptionProvider);
              if (!subscription.isPremium) {
                return Column(
                  children: [
                    _buildSectionTitle(context, AppLocalizations.of(context).premium),
                    _buildPremiumTile(context),
                    const SizedBox(height: 16),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),

          // 구독 상태 섹션
          _buildSectionTitle(context, AppLocalizations.of(context).subscriptionManagementTest),
          _buildSubscriptionStatusTile(ref),

          const SizedBox(height: 16),

          // 테스트 모드 섹션
          _buildSectionTitle(context, AppLocalizations.of(context).testMode),
          _buildTestModeTiles(ref),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 16, 4, 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: const Color(0xFF4A5568),
        ),
      ),
    );
  }

  Widget _buildMenuTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDestructive
                ? Colors.red.withOpacity(0.1)
                : const Color(0xFF667EEA).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: isDestructive ? Colors.red : const Color(0xFF667EEA),
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isDestructive ? Colors.red : const Color(0xFF2D3748),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            color: Color(0xFF718096),
            fontSize: 13,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: Color(0xFF9CA3AF),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        tileColor: Colors.white,
        onTap: onTap,
      ),
    );
  }

  Widget _buildPremiumTile(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFF97316).withOpacity(0.9),
            const Color(0xFFEC4899).withOpacity(0.9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF97316).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.workspace_premium,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Builder(
                  builder: (context) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context).premiumUpgrade,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppLocalizations.of(context).premiumUpgradeDescription,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: Builder(
              builder: (context) => ElevatedButton.icon(
                onPressed: () => context.push('/premium-subscription'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFFF97316),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                icon: const Icon(Icons.workspace_premium, size: 20),
                label: Text(
                  AppLocalizations.of(context).unlimitedWithPremium,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionStatusTile(WidgetRef ref) {
    final subscription = ref.watch(subscriptionProvider);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    subscription.isPremium ? Icons.diamond : Icons.person,
                    color: subscription.isPremium ? Colors.orange : Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Builder(
                    builder: (context) => Text(
                      subscription.isPremium
                        ? AppLocalizations.of(context).premiumUser
                        : AppLocalizations.of(context).freeUser,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Builder(
                builder: (context) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${AppLocalizations.of(context).imageGenerations}: ${subscription.imageGenerationsUsed}/${subscription.imageGenerationsLimit == -1 ? AppLocalizations.of(context).unlimited : subscription.imageGenerationsLimit}'),
                    Text('${AppLocalizations.of(context).imageModifications}: ${subscription.imageModificationsUsed}/${subscription.imageModificationsLimit == -1 ? AppLocalizations.of(context).unlimited : subscription.imageModificationsLimit}'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTestModeTiles(WidgetRef ref) {
    final subscription = ref.watch(subscriptionProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: subscription.isPremium ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: subscription.isPremium ? Colors.green : Colors.orange,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                subscription.isPremium ? Icons.star : Icons.person,
                color: subscription.isPremium ? Colors.green : Colors.orange,
              ),
              const SizedBox(width: 8),
              Builder(
                builder: (context) => Text(
                  subscription.isPremium
                    ? AppLocalizations.of(context).currentPremiumUser
                    : AppLocalizations.of(context).currentFreeUser,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: subscription.isPremium ? Colors.green : Colors.orange,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Builder(
                  builder: (context) => ElevatedButton.icon(
                    onPressed: subscription.isPremium ? null : () {
                      ref.read(subscriptionProvider.notifier).setPremiumUser();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(AppLocalizations.of(context).switchedToPremium)),
                      );
                    },
                    icon: const Icon(Icons.star),
                    label: Text(AppLocalizations.of(context).premium),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Builder(
                  builder: (context) => ElevatedButton.icon(
                    onPressed: !subscription.isPremium ? null : () {
                      ref.read(subscriptionProvider.notifier).setFreeUser();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(AppLocalizations.of(context).switchedToFree)),
                      );
                    },
                    icon: const Icon(Icons.person),
                    label: Text(AppLocalizations.of(context).free),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Builder(
            builder: (context) => ElevatedButton.icon(
              onPressed: () => _showLogoutDialog(context),
              icon: const Icon(Icons.logout),
              label: Text(AppLocalizations.of(context).logoutToLoginScreen),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToPersonalization(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const PersonalizationSettingsScreen(),
      ),
    );
  }

  void _navigateToAiSettings(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AiSettingsScreen(),
      ),
    );
  }

  void _navigateToBackupRestore(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const BackupRestoreScreen(),
      ),
    );
  }

  void _navigateToDelete(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const DeleteSettingsScreen(),
      ),
    );
  }

  void _navigateToAppInfo(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AppInfoScreen(),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).logout),
        content: Text(AppLocalizations.of(context).returnToLoginConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context).cancel),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              // Firebase 로그아웃
              await AuthService.signOut();
              // 로그인 화면으로 이동
              if (context.mounted) {
                context.go('/login');
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text(AppLocalizations.of(context).logout),
          ),
        ],
      ),
    );
  }

  /// 일일 진행 상황 데이터 가져오기
}
