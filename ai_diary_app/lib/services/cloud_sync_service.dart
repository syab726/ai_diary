import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/app_logger.dart';
import 'database_service.dart';
import 'dart:convert';

/// 클라우드 동기화 서비스 (Firebase Storage & Firestore)
class CloudSyncService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// 현재 사용자 ID 가져오기
  static String? get _userId => _auth.currentUser?.uid;

  /// 마지막 동기화 시간 저장/불러오기
  static Future<DateTime?> getLastSyncTime() async {
    try {
      if (_userId == null) return null;

      final doc = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('sync')
          .doc('metadata')
          .get();

      if (doc.exists && doc.data() != null) {
        final timestamp = doc.data()!['lastSyncTime'] as Timestamp?;
        return timestamp?.toDate();
      }
      return null;
    } catch (e) {
      AppLogger.log('마지막 동기화 시간 조회 오류: $e');
      return null;
    }
  }

  static Future<void> _saveLastSyncTime() async {
    try {
      if (_userId == null) return;

      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('sync')
          .doc('metadata')
          .set({
        'lastSyncTime': FieldValue.serverTimestamp(),
        'deviceId': 'flutter_app', // 실제로는 device_info_plus로 고유 ID 생성
      }, SetOptions(merge: true));

      AppLogger.log('마지막 동기화 시간 저장 완료');
    } catch (e) {
      AppLogger.log('마지막 동기화 시간 저장 오류: $e');
    }
  }

  /// 로컬 데이터를 클라우드에 백업
  /// [isPremium]: true면 모든 데이터 백업, false면 텍스트와 사용자 사진만 백업
  static Future<bool> uploadBackup({bool isPremium = false}) async {
    try {
      if (_userId == null) {
        AppLogger.log('로그인되지 않아 클라우드 백업을 건너뜁니다');
        return false;
      }

      AppLogger.log('=== 클라우드 백업 시작 (프리미엄: $isPremium) ===');

      // 로컬 데이터를 JSON으로 내보내기 (프리미엄 여부에 따라 차등 백업)
      final jsonString = await DatabaseService.exportToJson(isPremium: isPremium);

      // Firebase Storage에 업로드
      final storageRef = _storage
          .ref()
          .child('users/$_userId/backups/diary_backup_${DateTime.now().millisecondsSinceEpoch}.json');

      final uploadTask = storageRef.putString(
        jsonString,
        metadata: SettableMetadata(contentType: 'application/json'),
      );

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      AppLogger.log('클라우드 백업 완료: $downloadUrl');

      // Firestore에 백업 메타데이터 저장
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('backups')
          .add({
        'downloadUrl': downloadUrl,
        'filePath': storageRef.fullPath,
        'createdAt': FieldValue.serverTimestamp(),
        'diaryCount': jsonDecode(jsonString)['diaryCount'],
      });

      // 마지막 동기화 시간 업데이트
      await _saveLastSyncTime();

      AppLogger.log('=== 클라우드 백업 성공 ===');
      return true;
    } catch (e) {
      AppLogger.log('클라우드 백업 오류: $e');
      return false;
    }
  }

  /// 클라우드에 백업이 존재하는지 확인
  static Future<bool> hasBackup() async {
    try {
      if (_userId == null) {
        AppLogger.log('로그인되지 않아 백업 확인 불가');
        return false;
      }

      final querySnapshot = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('backups')
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();

      final exists = querySnapshot.docs.isNotEmpty;
      AppLogger.log('백업 존재 여부: $exists');
      return exists;
    } catch (e) {
      AppLogger.log('백업 확인 오류: $e');
      return false;
    }
  }

  /// 클라우드에서 최신 백업 다운로드 및 복원
  static Future<int> downloadAndRestoreBackup() async {
    try {
      if (_userId == null) {
        AppLogger.log('로그인되지 않아 클라우드 복원을 건너뜁니다');
        throw Exception('로그인이 필요합니다');
      }

      AppLogger.log('=== 클라우드 복원 시작 ===');

      // Firestore에서 최신 백업 메타데이터 찾기 (30초 타임아웃)
      final querySnapshot = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('backups')
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get()
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception('백업 목록 조회 시간 초과 (30초)');
            },
          );

      if (querySnapshot.docs.isEmpty) {
        AppLogger.log('클라우드에 백업이 없습니다');
        throw Exception('클라우드에 백업이 없습니다');
      }

      final backupDoc = querySnapshot.docs.first;
      final downloadUrl = backupDoc.data()['downloadUrl'] as String;

      AppLogger.log('최신 백업 다운로드: $downloadUrl');

      // Firebase Storage에서 백업 파일 다운로드 (60초 타임아웃)
      final storageRef = _storage.refFromURL(downloadUrl);
      final jsonString = await storageRef.getData().timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          throw Exception('백업 파일 다운로드 시간 초과 (60초)');
        },
      ).then((data) {
        if (data == null) throw Exception('백업 파일이 비어있습니다');
        return utf8.decode(data);
      });

      AppLogger.log('백업 파일 다운로드 완료: ${jsonString.length} bytes');

      // 로컬 데이터베이스에 복원 (60초 타임아웃)
      final importedCount = await DatabaseService.importFromJson(jsonString).timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          throw Exception('데이터베이스 복원 시간 초과 (60초)');
        },
      );

      AppLogger.log('데이터베이스 복원 완료: $importedCount개');

      // 마지막 동기화 시간 업데이트
      await _saveLastSyncTime();

      AppLogger.log('=== 클라우드 복원 완료: $importedCount개 일기 추가 ===');
      return importedCount;
    } catch (e) {
      AppLogger.log('클라우드 복원 오류: $e');
      rethrow; // 오류를 다시 throw하여 호출자가 처리하도록 함
    }
  }

  /// 자동 동기화 (로컬 → 클라우드)
  /// 일기 작성/수정 후 호출
  static Future<void> autoSync({bool isPremium = false}) async {
    try {
      // 마지막 동기화로부터 5분 이상 경과 시에만 자동 백업
      final lastSync = await getLastSyncTime();
      if (lastSync != null) {
        final diff = DateTime.now().difference(lastSync);
        if (diff.inMinutes < 5) {
          AppLogger.log('마지막 동기화로부터 ${diff.inMinutes}분 경과. 자동 백업 건너뜀');
          return;
        }
      }

      AppLogger.log('자동 동기화 시작... (프리미엄: $isPremium)');
      await uploadBackup(isPremium: isPremium);
    } catch (e) {
      AppLogger.log('자동 동기화 오류: $e');
    }
  }

  /// 모든 백업 목록 가져오기
  static Future<List<Map<String, dynamic>>> getBackupList() async {
    try {
      if (_userId == null) return [];

      final querySnapshot = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('backups')
          .orderBy('createdAt', descending: true)
          .limit(10)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      AppLogger.log('백업 목록 조회 오류: $e');
      return [];
    }
  }

  /// 특정 백업 삭제
  static Future<bool> deleteBackup(String backupId, String filePath) async {
    try {
      if (_userId == null) return false;

      // Firestore 메타데이터 삭제
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('backups')
          .doc(backupId)
          .delete();

      // Storage 파일 삭제
      final storageRef = _storage.ref().child(filePath);
      await storageRef.delete();

      AppLogger.log('백업 삭제 완료: $backupId');
      return true;
    } catch (e) {
      AppLogger.log('백업 삭제 오류: $e');
      return false;
    }
  }
}
