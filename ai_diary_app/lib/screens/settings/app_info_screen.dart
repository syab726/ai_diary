import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../l10n/app_localizations.dart';

class AppInfoScreen extends ConsumerStatefulWidget {
  const AppInfoScreen({super.key});

  @override
  ConsumerState<AppInfoScreen> createState() => _AppInfoScreenState();
}

class _AppInfoScreenState extends ConsumerState<AppInfoScreen> {
  String _version = '1.0.0';
  String _buildNumber = '1';

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _version = packageInfo.version;
      _buildNumber = packageInfo.buildNumber;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppLocalizations.of(context).appInfo,
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
          _buildSettingsTile(
            icon: Icons.info,
            title: AppLocalizations.of(context).appVersion,
            subtitle: '${AppLocalizations.of(context).appName} v$_version (Build $_buildNumber)',
            onTap: () => _showAboutDialog(context),
          ),
          _buildSettingsTile(
            icon: Icons.privacy_tip,
            title: AppLocalizations.of(context).privacyPolicy,
            subtitle: AppLocalizations.of(context).privacyPolicySubtitle,
            onTap: () => _showPrivacyDialog(context),
          ),
          _buildSettingsTile(
            icon: Icons.description,
            title: AppLocalizations.of(context).termsOfService,
            subtitle: AppLocalizations.of(context).termsSubtitle,
            onTap: () => _showTermsDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF667EEA).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF667EEA),
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D3748),
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

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: AppLocalizations.of(context).appName,
      applicationVersion: _version,
      applicationIcon: const Icon(Icons.auto_stories, size: 64),
      children: [
        Text(AppLocalizations.of(context).appDescription),
      ],
    );
  }

  void _showPrivacyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).privacyPolicyTitle),
        content: SingleChildScrollView(
          child: Text(AppLocalizations.of(context).privacyPolicyContent),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context).ok),
          ),
        ],
      ),
    );
  }

  void _showTermsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).termsTitle),
        content: SingleChildScrollView(
          child: Text(AppLocalizations.of(context).termsContent),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context).ok),
          ),
        ],
      ),
    );
  }
}
