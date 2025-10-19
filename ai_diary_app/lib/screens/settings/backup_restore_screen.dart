import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/subscription_provider.dart';
import '../../providers/auto_backup_provider.dart';
import '../../services/database_service.dart';
import '../../services/google_drive_service.dart';
import '../../services/auth_service.dart';
import '../../widgets/settings_tile.dart';
import '../../widgets/premium_dialog.dart';

class BackupRestoreScreen extends ConsumerWidget {
  const BackupRestoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscription = ref.watch(subscriptionProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '백업 및 복원',
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
          // 자동 백업 섹션
          _buildSectionTitle(context, '자동 백업'),
          _buildAutoBackupCard(context, ref),

          const SizedBox(height: 24),

          // 로컬 백업/복원 섹션
          _buildSectionTitle(context, '로컬 백업/복원'),
          SettingsTile(
            icon: Icons.backup,
            title: AppLocalizations.of(context).dataBackup,
            subtitle: AppLocalizations.of(context).dataBackupSubtitle,
            onTap: () => _showBackupDialog(context, ref),
          ),
          SettingsTile(
            icon: Icons.restore,
            title: AppLocalizations.of(context).dataRestore,
            subtitle: AppLocalizations.of(context).dataRestoreSubtitle,
            onTap: () => _showRestoreDialog(context),
          ),

          const SizedBox(height: 24),

          // 클라우드 백업/복원 섹션
          _buildSectionTitle(context, '클라우드 백업/복원'),
          _buildCloudBackupRestoreCard(context, ref),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: const Color(0xFF4A5568),
        ),
      ),
    );
  }

  Future<void> _showBackupDialog(BuildContext context, WidgetRef ref) async {
    final subscription = ref.read(subscriptionProvider);
    final scaffoldContext = context;  // 원래 Scaffold context 저장

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(AppLocalizations.of(dialogContext).dataBackupTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(subscription.isPremium
              ? AppLocalizations.of(dialogContext).backupDescription
              : '무료 사용자는 일기 제목, 내용, 날짜를 JSON 형식으로 백업할 수 있습니다.'),
            const SizedBox(height: 12),
            Text(AppLocalizations.of(dialogContext).backupIncludes, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            _buildBackupItem('📝', AppLocalizations.of(dialogContext).backupDiaryContent),
            _buildBackupItem('📅', AppLocalizations.of(dialogContext).backupDateTime),
            if (subscription.isPremium) ...[
              _buildBackupItem('😊', AppLocalizations.of(dialogContext).backupEmotionAnalysis),
              _buildBackupItem('🖼️', AppLocalizations.of(dialogContext).backupGeneratedImages),
              _buildBackupItem('🎨', AppLocalizations.of(dialogContext).backupImageStyle),
            ] else ...[
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.amber),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lock, color: Colors.amber, size: 16),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '프리미엄: 감정 분석, 생성 이미지, AI 프롬프트 포함',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.amber.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(AppLocalizations.of(dialogContext).cancel),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await _performBackup(scaffoldContext, ref);  // Scaffold context 사용
            },
            child: Text(AppLocalizations.of(dialogContext).backupStart),
          ),
        ],
      ),
    );
  }

  Widget _buildBackupItem(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }

  Future<void> _performBackup(BuildContext context, WidgetRef ref) async {
    try {
      final subscription = ref.read(subscriptionProvider);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Text(AppLocalizations.of(context).backingUp),
            ],
          ),
          duration: const Duration(seconds: 3),
        ),
      );

      final diaries = await DatabaseService.getAllDiaries();
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      if (subscription.isPremium) {
        // DatabaseService의 표준 exportToJson 사용
        final jsonString = await DatabaseService.exportToJson(isPremium: true);
        final bytes = utf8.encode(jsonString);

        // FilePicker를 사용하여 저장 위치 선택
        final String? outputPath = await FilePicker.platform.saveFile(
          dialogTitle: '백업 파일 저장 위치 선택',
          fileName: 'ai_diary_premium_backup_$timestamp.json',
          type: FileType.custom,
          allowedExtensions: ['json'],
          bytes: Uint8List.fromList(bytes),
        );

        if (outputPath == null) {
          // 사용자가 취소함
          if (context.mounted) {
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('백업이 취소되었습니다'),
                backgroundColor: Colors.orange,
              ),
            );
          }
          return;
        }

        // 프리미엄 백업 성공
        if (context.mounted) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 12),
                  Text('${diaries.length}개 일기가 완전히 백업되었습니다'),
                ],
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        }
        return;
      } else {
        // 무료 사용자도 JSON 형식으로 백업 (프리미엄 필드 제외)
        final jsonString = await DatabaseService.exportToJson(isPremium: false);
        final bytes = utf8.encode(jsonString);

        // FilePicker를 사용하여 저장 위치 선택
        final String? outputPath = await FilePicker.platform.saveFile(
          dialogTitle: '백업 파일 저장 위치 선택',
          fileName: 'ai_diary_backup_$timestamp.json',
          type: FileType.custom,
          allowedExtensions: ['json'],
          bytes: Uint8List.fromList(bytes),
        );

        if (outputPath == null) {
          // 사용자가 취소함
          if (context.mounted) {
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('백업이 취소되었습니다'),
                backgroundColor: Colors.orange,
              ),
            );
          }
          return;
        }

        // 무료 사용자 백업 성공
        if (context.mounted) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 12),
                  Text('${diaries.length}개 일기가 백업되었습니다'),
                ],
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        }
        return;
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).backupFailed(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showRestoreDialog(BuildContext context) {
    final scaffoldContext = context;  // 원래 Scaffold context 저장

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(AppLocalizations.of(dialogContext).dataRestoreTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalizations.of(dialogContext).restoreDescription),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning, color: Colors.orange, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '현재 저장된 데이터는 모두 삭제되고\n백업 파일로 대체됩니다',
                      style: TextStyle(fontSize: 13, color: Colors.orange),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '파일 선택 화면에서 뒤로가기 버튼으로\n언제든지 취소할 수 있습니다',
                      style: TextStyle(fontSize: 13, color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(AppLocalizations.of(dialogContext).cancel),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await _performRestore(scaffoldContext);  // Scaffold context 사용
            },
            child: const Text('파일 선택'),
          ),
        ],
      ),
    );
  }

  Future<void> _performRestore(BuildContext context) async {
    try {
      // 파일 선택
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json', 'txt'],
      );

      if (result == null) {
        // 사용자가 파일 선택을 취소함
        return;
      }

      final file = File(result.files.single.path!);
      final jsonString = await file.readAsString();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              ),
              SizedBox(width: 12),
              Text('복원 중...'),
            ],
          ),
          duration: Duration(seconds: 10),
        ),
      );

      // JSON에서 데이터 복원
      final restoredCount = await DatabaseService.importFromJson(jsonString);

      if (context.mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();

        if (restoredCount > 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 12),
                  Text('$restoredCount개 일기가 복원되었습니다'),
                ],
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.info, color: Colors.white),
                  SizedBox(width: 12),
                  Text('복원된 일기가 없습니다'),
                ],
              ),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('복원 실패: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  void _showCloudBackupDialog(BuildContext context) {
    print('=== _showCloudBackupDialog 호출됨 ===');
    final scaffoldContext = context;  // 원래 Scaffold context 저장
    showDialog(
      context: scaffoldContext,
      builder: (dialogContext) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.cloud_upload, color: Colors.blue),
            SizedBox(width: 8),
            Text('Google Drive 백업'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Google Drive에 일기 데이터를 안전하게 백업합니다.'),
            const SizedBox(height: 12),
            const Text('포함 내용:', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            _buildBackupItem('📝', '모든 일기 내용'),
            _buildBackupItem('😊', '감정 분석 결과'),
            _buildBackupItem('🖼️', '생성된 이미지 (base64)'),
            _buildBackupItem('🎨', '이미지 스타일 및 설정'),
            _buildBackupItem('📸', '업로드한 사진들'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: Colors.blue),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '기존 백업이 있다면 덮어쓰기됩니다',
                      style: TextStyle(fontSize: 12, color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('취소'),
          ),
          FilledButton.icon(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await _performCloudBackup(scaffoldContext);  // Scaffold context 사용
            },
            icon: const Icon(Icons.cloud_upload),
            label: const Text('백업 시작'),
          ),
        ],
      ),
    );
  }

  Future<void> _performCloudBackup(BuildContext context) async {
    print('=== _performCloudBackup 시작 ===');
    try {
      // 로컬 Mock 사용자 확인 (테스트 모드)
      final mockUser = AuthService.currentUser;
      final isTestMode = mockUser != null && mockUser.uid.startsWith('local-mock-');
      print('mockUser: ${mockUser?.uid}');
      print('isTestMode: $isTestMode');

      // Firebase 사용자 또는 로컬 Mock 사용자가 있는지 확인
      if (FirebaseAuth.instance.currentUser == null && mockUser == null) {
        print('로그인 필요 - SnackBar 표시');

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                SizedBox(width: 12),
                Expanded(
                  child: Text('로그인이 필요합니다.\n먼저 앱에 로그인해주세요.'),
                ),
              ],
            ),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 4),
          ),
        );
        return;
      }

      // 테스트 모드인 경우 시뮬레이션
      if (isTestMode) {
        print('테스트 모드 - 백업 시뮬레이션 시작');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                ),
                SizedBox(width: 12),
                Text('Google Drive 백업 중...'),
              ],
            ),
            duration: Duration(seconds: 2),
          ),
        );

        await Future.delayed(const Duration(seconds: 2));

        if (context.mounted) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 12),
                  Expanded(child: Text('백업 완료 (테스트 모드)')),
                ],
              ),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
        }
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              ),
              SizedBox(width: 12),
              Text('클라우드에 백업 중...'),
            ],
          ),
          duration: Duration(seconds: 30),
        ),
      );

      final success = await GoogleDriveService.uploadBackup(isPremium: true);

      if (context.mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 12),
                  Text('클라우드 백업이 완료되었습니다'),
                ],
              ),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.error, color: Colors.white),
                  SizedBox(width: 12),
                  Text('클라우드 백업에 실패했습니다'),
                ],
              ),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('클라우드 백업 오류: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  void _showCloudRestoreDialog(BuildContext context) async {
    final scaffoldContext = context;  // 원래 Scaffold context 저장

    // 로컬 Mock 사용자 확인 (테스트 모드)
    final mockUser = AuthService.currentUser;
    final isTestMode = mockUser != null && mockUser.uid.startsWith('local-mock-');

    // Firebase 사용자 또는 로컬 Mock 사용자가 있는지 확인
    if (FirebaseAuth.instance.currentUser == null && mockUser == null) {
      if (scaffoldContext.mounted) {
        showDialog(
          context: scaffoldContext,
          builder: (dialogContext) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.error, color: Colors.orange),
                SizedBox(width: 8),
                Text('로그인 필요'),
              ],
            ),
            content: const Text('클라우드 복원을 사용하려면 먼저 앱에 로그인해주세요.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('확인'),
              ),
            ],
          ),
        );
      }
      return;
    }

    // 테스트 모드인 경우 시뮬레이션
    if (isTestMode) {
      if (scaffoldContext.mounted) {
        showDialog(
          context: scaffoldContext,
          builder: (dialogContext) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.cloud_download, color: Colors.green),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '[테스트] 복원',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
            content: const SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('테스트 모드에서 복원을 시뮬레이션합니다.'),
                  SizedBox(height: 8),
                  Text(
                    '실제 환경에서는 Google Drive에서 복원합니다.',
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('취소'),
              ),
              FilledButton.icon(
                onPressed: () async {
                  Navigator.pop(dialogContext);
                  await _performCloudRestoreSimulation(scaffoldContext);  // Scaffold context 사용
                },
                icon: const Icon(Icons.cloud_download),
                label: const Text('시작'),
                style: FilledButton.styleFrom(backgroundColor: Colors.green),
              ),
            ],
          ),
        );
      }
      return;
    }

    final hasBackup = await GoogleDriveService.hasBackup();

    if (!hasBackup) {
      if (scaffoldContext.mounted) {
        showDialog(
          context: scaffoldContext,
          builder: (dialogContext) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.orange),
                SizedBox(width: 8),
                Text('백업 없음'),
              ],
            ),
            content: const Text('클라우드에 저장된 백업이 없습니다.\n먼저 백업을 생성해주세요.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('확인'),
              ),
            ],
          ),
        );
      }
      return;
    }

    if (scaffoldContext.mounted) {
      showDialog(
        context: scaffoldContext,
        builder: (dialogContext) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.cloud_download, color: Colors.green),
              SizedBox(width: 8),
              Text('클라우드 복원'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Firebase에서 일기 데이터를 복원합니다.'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning, color: Colors.orange, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '현재 저장된 데이터는 모두 삭제되고\n클라우드 백업 데이터로 대체됩니다',
                        style: TextStyle(fontSize: 13, color: Colors.orange),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('취소'),
            ),
            FilledButton.icon(
              onPressed: () async {
                Navigator.pop(dialogContext);
                await _performCloudRestore(scaffoldContext);  // Scaffold context 사용
              },
              icon: const Icon(Icons.cloud_download),
              label: const Text('복원 시작'),
              style: FilledButton.styleFrom(backgroundColor: Colors.green),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _performCloudRestore(BuildContext context) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              ),
              SizedBox(width: 12),
              Text('클라우드에서 복원 중...'),
            ],
          ),
          duration: Duration(seconds: 30),
        ),
      );

      final restoredCount = await GoogleDriveService.downloadAndRestoreBackup();

      if (context.mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();

        if (restoredCount > 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 12),
                  Text('$restoredCount개 일기가 복원되었습니다'),
                ],
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.error, color: Colors.white),
                  SizedBox(width: 12),
                  Text('클라우드 복원에 실패했습니다'),
                ],
              ),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('클라우드 복원 오류: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _performCloudRestoreSimulation(BuildContext context) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            ),
            SizedBox(width: 12),
            Text('[테스트 모드] 클라우드 복원 시뮬레이션 중...'),
          ],
        ),
        duration: Duration(seconds: 2),
      ),
    );

    await Future.delayed(const Duration(seconds: 2));

    if (context.mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Expanded(child: Text('복원 완료 (테스트 모드)')),
            ],
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  void _showPremiumRequiredDialog(BuildContext context) {
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
        content: const Text('클라우드 백업/복원은 프리미엄 사용자만 사용할 수 있습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  /// 자동 백업 카드
  Widget _buildAutoBackupCard(BuildContext context, WidgetRef ref) {
    final autoBackupState = ref.watch(autoBackupProvider);
    final subscription = ref.watch(subscriptionProvider);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 자동 백업 스위치
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF667EEA).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.cloud_sync,
                  color: Color(0xFF667EEA),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '자동 클라우드 백업',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2D3748),
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subscription.isPremium
                          ? '5분마다 자동으로 백업합니다'
                          : '프리미엄 전용 기능',
                      style: const TextStyle(
                        color: Color(0xFF718096),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: autoBackupState.isEnabled,
                onChanged: subscription.isPremium
                    ? (value) async {
                        await ref.read(autoBackupProvider.notifier).setEnabled(value);

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                value ? '자동 백업이 활성화되었습니다' : '자동 백업이 비활성화되었습니다',
                              ),
                              backgroundColor: value ? Colors.green : Colors.orange,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      }
                    : null,
                activeColor: const Color(0xFF667EEA),
              ),
            ],
          ),

          // 프리미엄 사용자인 경우 백업 상태 표시
          if (subscription.isPremium && autoBackupState.isEnabled) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.blue.withOpacity(0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        autoBackupState.isBackingUp
                            ? Icons.sync
                            : Icons.check_circle,
                        size: 16,
                        color: autoBackupState.isBackingUp
                            ? Colors.blue
                            : Colors.green,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        autoBackupState.isBackingUp
                            ? '백업 중...'
                            : '백업 완료',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: autoBackupState.isBackingUp
                              ? Colors.blue
                              : Colors.green,
                        ),
                      ),
                    ],
                  ),
                  if (autoBackupState.lastBackupTime != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      '마지막 백업: ${DateFormat('yyyy-MM-dd HH:mm').format(autoBackupState.lastBackupTime!)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF718096),
                      ),
                    ),
                  ],
                  if (autoBackupState.lastError != null) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.error_outline, size: 14, color: Colors.red),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '오류: ${autoBackupState.lastError}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.red,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],

          // 무료 사용자 안내
          if (!subscription.isPremium) ...[
            const SizedBox(height: 12),
            InkWell(
              onTap: () => showPremiumRequiredDialog(context, featureName: '자동 클라우드 백업'),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.amber,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lock, size: 16, color: Colors.amber),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '프리미엄으로 업그레이드하여 자동 백업 기능을 사용하세요',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.amber.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 클라우드 백업/복원 카드
  Widget _buildCloudBackupRestoreCard(BuildContext context, WidgetRef ref) {
    final subscription = ref.watch(subscriptionProvider);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 클라우드 백업
          InkWell(
            onTap: subscription.isPremium
                ? () => _showCloudBackupDialog(context)
                : () => showPremiumRequiredDialog(context, featureName: '클라우드 백업'),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.cloud_upload,
                      color: Colors.blue,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '클라우드 백업',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2D3748),
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subscription.isPremium
                              ? 'Google Drive에 일기를 백업합니다'
                              : '프리미엄 전용 기능',
                          style: const TextStyle(
                            color: Color(0xFF718096),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: const Color(0xFF9CA3AF),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 클라우드 복원
          InkWell(
            onTap: subscription.isPremium
                ? () => _showCloudRestoreDialog(context)
                : () => showPremiumRequiredDialog(context, featureName: '클라우드 복원'),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.cloud_download,
                      color: Colors.green,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '클라우드 복원',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2D3748),
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subscription.isPremium
                              ? 'Google Drive에서 일기를 복원합니다'
                              : '프리미엄 전용 기능',
                          style: const TextStyle(
                            color: Color(0xFF718096),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: const Color(0xFF9CA3AF),
                  ),
                ],
              ),
            ),
          ),

          // 무료 사용자 안내 (공통)
          if (!subscription.isPremium) ...[
            const SizedBox(height: 12),
            InkWell(
              onTap: () => showPremiumRequiredDialog(context, featureName: '클라우드 백업/복원'),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.amber,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lock, size: 16, color: Colors.amber),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '프리미엄으로 업그레이드하여 클라우드 백업/복원 기능을 사용하세요',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.amber.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
