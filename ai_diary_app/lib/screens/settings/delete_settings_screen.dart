import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import '../../l10n/app_localizations.dart';
import '../../services/database_service.dart';

class DeleteSettingsScreen extends ConsumerWidget {
  const DeleteSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '데이터 삭제',
          style: TextStyle(
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
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.warning, color: Colors.red.shade700),
                    const SizedBox(width: 8),
                    Text(
                      '주의사항',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade700,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '• 모든 일기가 영구적으로 삭제됩니다\n• 삭제된 데이터는 복구할 수 없습니다\n• 삭제 전에 반드시 백업을 권장합니다',
                  style: TextStyle(
                    color: Colors.red.shade900,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildSettingsTile(
            icon: Icons.cleaning_services,
            title: '캐시 삭제',
            subtitle: '저장된 이미지 캐시를 삭제하여 저장 공간 확보',
            onTap: () => _showClearCacheDialog(context),
            isDestructive: false,
          ),
          _buildSettingsTile(
            icon: Icons.delete_forever,
            title: AppLocalizations.of(context).deleteAllData,
            subtitle: AppLocalizations.of(context).deleteAllDataSubtitle,
            onTap: () => _showDeleteAllDialog(context),
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  // 캐시 크기 계산
  Future<String> _calculateCacheSize() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final imagesDir = Directory(path.join(directory.path, 'diary_images'));

      if (!await imagesDir.exists()) {
        return '0 MB';
      }

      int totalBytes = 0;
      await for (final entity in imagesDir.list(recursive: true)) {
        if (entity is File) {
          totalBytes += await entity.length();
        }
      }

      final megaBytes = totalBytes / (1024 * 1024);
      return '${megaBytes.toStringAsFixed(2)} MB';
    } catch (e) {
      return '계산 실패';
    }
  }

  // 캐시 삭제
  Future<bool> _clearCache() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final imagesDir = Directory(path.join(directory.path, 'diary_images'));

      if (!await imagesDir.exists()) {
        return true; // 이미 없으면 성공으로 간주
      }

      // 디렉토리 내 모든 파일 삭제
      await for (final entity in imagesDir.list(recursive: false)) {
        if (entity is File) {
          await entity.delete();
        }
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  void _showClearCacheDialog(BuildContext context) async {
    final cacheSize = await _calculateCacheSize();

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('캐시 삭제'),
        content: Text(
          '이미지 캐시를 삭제하시겠습니까?\n\n'
          '현재 캐시 크기: $cacheSize\n\n'
          '참고: 일기 데이터는 삭제되지 않으며,\n'
          '필요 시 이미지가 다시 생성됩니다.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context); // 다이얼로그 닫기

              // 진행 상태 표시
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('캐시 삭제 중...'),
                  duration: Duration(seconds: 1),
                ),
              );

              final success = await _clearCache();

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? '캐시가 성공적으로 삭제되었습니다'
                          : '캐시 삭제 중 오류가 발생했습니다',
                    ),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            child: const Text('삭제'),
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

  void _showDeleteAllDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).deleteAllTitle),
        content: Text(AppLocalizations.of(context).deleteAllWarning),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context).cancel),
          ),
          FilledButton(
            onPressed: () async {
              try {
                await DatabaseService.deleteAllEntries();
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('모든 데이터가 삭제되었습니다'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('삭제 중 오류가 발생했습니다: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: Text(AppLocalizations.of(context).deleteAllConfirm),
          ),
        ],
      ),
    );
  }
}
