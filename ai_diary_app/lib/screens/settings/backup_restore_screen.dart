import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
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
        title: Text(
          AppLocalizations.of(context).backupAndRestore,
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
          // 자동 백업 섹션
          _buildSectionTitle(context, AppLocalizations.of(context).autoBackup),
          _buildAutoBackupCard(context, ref),

          const SizedBox(height: 24),

          // 로컬 백업/복원 섹션
          _buildSectionTitle(context, AppLocalizations.of(context).localBackupRestore),
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
          _buildSectionTitle(context, AppLocalizations.of(context).cloudBackupRestore),
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
              : AppLocalizations.of(dialogContext).freeUserBackupDescription),
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
                        AppLocalizations.of(dialogContext).premiumBackupDescription,
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
          dialogTitle: AppLocalizations.of(context).selectBackupLocation,
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
              SnackBar(
                content: Text(AppLocalizations.of(context).backupCanceled),
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
                  Text(AppLocalizations.of(context).premiumBackupSuccessFormat.replaceAll('{count}', '${diaries.length}')),
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
          dialogTitle: AppLocalizations.of(context).selectBackupLocation,
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
              SnackBar(
                content: Text(AppLocalizations.of(context).backupCanceled),
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
                  Text(AppLocalizations.of(context).backupSuccessFormat.replaceAll('{count}', '${diaries.length}')),
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
              child: Row(
                children: [
                  const Icon(Icons.warning, color: Colors.orange, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context).restoreWarning,
                      style: const TextStyle(fontSize: 13, color: Colors.orange),
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
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.blue, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context).cancelFileSelectionHint,
                      style: const TextStyle(fontSize: 13, color: Colors.blue),
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
            child: Text(AppLocalizations.of(dialogContext).selectFile),
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
        SnackBar(
          content: Row(
            children: [
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Text(AppLocalizations.of(context).restoring),
            ],
          ),
          duration: const Duration(seconds: 10),
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
                  Text(AppLocalizations.of(context).restoreSuccessFormat.replaceAll('{count}', '$restoredCount')),
                ],
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.info, color: Colors.white),
                  const SizedBox(width: 12),
                  Text(AppLocalizations.of(context).noRestoredDiaries),
                ],
              ),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).restoreFailedFormat.replaceAll('{error}', e.toString())),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  void _showCloudBackupDialog(BuildContext context) {
    if (kDebugMode) print('=== _showCloudBackupDialog 호출됨 ===');
    final scaffoldContext = context;  // 원래 Scaffold context 저장
    showDialog(
      context: scaffoldContext,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.cloud_upload, color: Colors.blue),
            const SizedBox(width: 8),
            Text(AppLocalizations.of(context).googleDriveBackup),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalizations.of(context).googleDriveBackupDescription),
            const SizedBox(height: 12),
            Text(AppLocalizations.of(context).includedContent, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            _buildBackupItem('📝', AppLocalizations.of(context).allDiaryContent),
            _buildBackupItem('😊', AppLocalizations.of(context).emotionAnalysisResult),
            _buildBackupItem('🖼️', AppLocalizations.of(context).generatedImagesBase64),
            _buildBackupItem('🎨', AppLocalizations.of(context).imageStyleAndSettings),
            _buildBackupItem('📸', AppLocalizations.of(context).uploadedPhotos),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, size: 16, color: Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context).existingBackupWarning,
                      style: const TextStyle(fontSize: 12, color: Colors.blue),
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
            child: Text(AppLocalizations.of(context).cancel),
          ),
          FilledButton.icon(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await _performCloudBackup(scaffoldContext);  // Scaffold context 사용
            },
            icon: const Icon(Icons.cloud_upload),
            label: Text(AppLocalizations.of(context).startBackup),
          ),
        ],
      ),
    );
  }

  Future<void> _performCloudBackup(BuildContext context) async {
    if (kDebugMode) print('=== _performCloudBackup 시작 ===');
    try {
      // 로컬 Mock 사용자 확인 (테스트 모드)
      final mockUser = AuthService.currentUser;
      final isTestMode = mockUser != null && mockUser.uid.startsWith('local-mock-');
      if (kDebugMode) print('mockUser: ${mockUser?.uid}');
      if (kDebugMode) print('isTestMode: $isTestMode');

      // Firebase 사용자 또는 로컬 Mock 사용자가 있는지 확인
      if (FirebaseAuth.instance.currentUser == null && mockUser == null) {
        if (kDebugMode) print('로그인 필요 - SnackBar 표시');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(AppLocalizations.of(context).loginRequiredMessage),
                ),
              ],
            ),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 4),
          ),
        );
        return;
      }

      // 테스트 모드인 경우 시뮬레이션
      if (isTestMode) {
        if (kDebugMode) print('테스트 모드 - 백업 시뮬레이션 시작');
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
                Text(AppLocalizations.of(context).backingUpToGoogleDrive),
              ],
            ),
            duration: const Duration(seconds: 2),
          ),
        );

        await Future.delayed(const Duration(seconds: 2));

        if (context.mounted) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(child: Text(AppLocalizations.of(context).backupCompleteTestMode)),
                ],
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        }
        return;
      }

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
              Text(AppLocalizations.of(context).backingUpToCloud),
            ],
          ),
          duration: const Duration(seconds: 30),
        ),
      );

      final success = await GoogleDriveService.uploadBackup(isPremium: true);

      if (context.mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 12),
                  Text(AppLocalizations.of(context).cloudBackupComplete),
                ],
              ),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error, color: Colors.white),
                  const SizedBox(width: 12),
                  Text(AppLocalizations.of(context).cloudBackupFailed),
                ],
              ),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).cloudBackupErrorFormat(e.toString())),
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
            title: Row(
              children: [
                const Icon(Icons.error, color: Colors.orange),
                const SizedBox(width: 8),
                Text(AppLocalizations.of(context).loginRequiredTitle),
              ],
            ),
            content: Text(AppLocalizations.of(context).cloudRestoreLoginMessage),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(AppLocalizations.of(context).ok),
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
            title: Row(
              children: [
                const Icon(Icons.cloud_download, color: Colors.green),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    AppLocalizations.of(context).testRestoreTitle,
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppLocalizations.of(context).testModeRestoreSimulation),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context).realEnvironmentGoogleDriveRestore,
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(AppLocalizations.of(context).cancel),
              ),
              FilledButton.icon(
                onPressed: () async {
                  Navigator.pop(dialogContext);
                  await _performCloudRestoreSimulation(scaffoldContext);  // Scaffold context 사용
                },
                icon: const Icon(Icons.cloud_download),
                label: Text(AppLocalizations.of(context).startButton),
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
            title: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.orange),
                const SizedBox(width: 8),
                Text(AppLocalizations.of(context).noBackupTitle),
              ],
            ),
            content: Text(AppLocalizations.of(context).noCloudBackupMessage),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(AppLocalizations.of(context).ok),
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
          title: Row(
            children: [
              const Icon(Icons.cloud_download, color: Colors.green),
              const SizedBox(width: 8),
              Text(AppLocalizations.of(context).cloudRestoreTitle),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppLocalizations.of(context).restoreFromFirebase),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning, color: Colors.orange, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context).allDataWillBeReplaced,
                        style: const TextStyle(fontSize: 13, color: Colors.orange),
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
              child: Text(AppLocalizations.of(context).cancelButton),
            ),
            FilledButton.icon(
              onPressed: () async {
                Navigator.pop(dialogContext);
                await _performCloudRestore(scaffoldContext);  // Scaffold context 사용
              },
              icon: const Icon(Icons.cloud_download),
              label: Text(AppLocalizations.of(context).startRestoreButton),
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
        SnackBar(
          content: Row(
            children: [
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Text(AppLocalizations.of(context).restoringFromCloud),
            ],
          ),
          duration: const Duration(seconds: 30),
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
                  Text(AppLocalizations.of(context).restoreSuccessFormat.replaceAll('{count}', '$restoredCount')),
                ],
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error, color: Colors.white),
                  const SizedBox(width: 12),
                  Text(AppLocalizations.of(context).cloudRestoreFailed),
                ],
              ),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).cloudRestoreErrorFormat(e.toString())),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _performCloudRestoreSimulation(BuildContext context) async {
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
            Text(AppLocalizations.of(context).testModeRestoreSimulation),
          ],
        ),
        duration: const Duration(seconds: 2),
      ),
    );

    await Future.delayed(const Duration(seconds: 2));

    if (context.mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text(AppLocalizations.of(context).restoreCompleteTestMode)),
            ],
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _showPremiumRequiredDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.diamond, color: Colors.amber),
            const SizedBox(width: 8),
            Text(AppLocalizations.of(context).premiumOnlyFeature),
          ],
        ),
        content: Builder(
          builder: (context) => Text(AppLocalizations.of(context).cloudBackupRestorePremiumOnly),
        ),
        actions: [
          Builder(
            builder: (context) => TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context).ok),
            ),
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
                    Builder(
                      builder: (context) => Text(
                        AppLocalizations.of(context).autoCloudBackup,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2D3748),
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Builder(
                      builder: (context) => Text(
                        subscription.isPremium
                            ? AppLocalizations.of(context).autoBackupEveryFiveMinutes
                            : AppLocalizations.of(context).premiumOnlyFeature,
                        style: const TextStyle(
                          color: Color(0xFF718096),
                          fontSize: 13,
                        ),
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
                                value ? AppLocalizations.of(context).autoBackupEnabled : AppLocalizations.of(context).autoBackupDisabled,
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
                      Builder(
                        builder: (context) => Text(
                          autoBackupState.isBackingUp
                              ? AppLocalizations.of(context).backingUp
                              : AppLocalizations.of(context).backupComplete,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: autoBackupState.isBackingUp
                                ? Colors.blue
                                : Colors.green,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (autoBackupState.lastBackupTime != null) ...[
                    const SizedBox(height: 6),
                    Builder(
                      builder: (context) => Text(
                        AppLocalizations.of(context).lastBackupTimeFormat(
                          DateFormat('yyyy-MM-dd HH:mm').format(autoBackupState.lastBackupTime!)
                        ),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF718096),
                        ),
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
                          child: Builder(
                            builder: (context) => Text(
                              AppLocalizations.of(context).errorFormat(autoBackupState.lastError!),
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.red,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
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
              onTap: () => showPremiumRequiredDialog(context, featureName: AppLocalizations.of(context).autoCloudBackupFeature),
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
                      child: Builder(
                        builder: (context) => Text(
                          AppLocalizations.of(context).upgradeForAutoBackup,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.amber.shade700,
                          ),
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
                : () => showPremiumRequiredDialog(context, featureName: AppLocalizations.of(context).cloudBackupFeature),
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
                    child: Builder(
                      builder: (context) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context).cloudBackupFeature,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2D3748),
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            subscription.isPremium
                                ? AppLocalizations.of(context).cloudBackupToGoogleDrive
                                : AppLocalizations.of(context).premiumFeatureShort,
                            style: const TextStyle(
                              color: Color(0xFF718096),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
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
                : () => showPremiumRequiredDialog(context, featureName: AppLocalizations.of(context).cloudRestoreFeature),
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
                    child: Builder(
                      builder: (context) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context).cloudRestoreFeature,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2D3748),
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            subscription.isPremium
                                ? AppLocalizations.of(context).cloudRestoreFromGoogleDrive
                                : AppLocalizations.of(context).premiumFeatureShort,
                            style: const TextStyle(
                              color: Color(0xFF718096),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
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
              onTap: () => showPremiumRequiredDialog(context, featureName: AppLocalizations.of(context).cloudBackupRestoreFeature),
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
                      child: Builder(
                        builder: (context) => Text(
                          AppLocalizations.of(context).upgradeForCloudBackupRestore,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.amber.shade700,
                          ),
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
