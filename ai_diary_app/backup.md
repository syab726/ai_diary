# 데이터 백업 기능 개선 계획

## 📋 현재 문제점

### ❌ 치명적 문제
1. **자동 백업 기능 미구현** - 프리미엄 사용자에게 약속한 핵심 기능 누락
2. **이미지 데이터 백업 실패** - imageData가 DB 조회에서 제외되어 항상 null
3. **불완전한 백업 데이터** - imageTime, imageWeather, imageSeason, fontFamily, updatedAt 누락

## 🎯 구현 목표 (하이브리드 방식)

### 무료 사용자
- ✅ **수동 백업**: 텍스트 형식 (제목, 날짜, 내용만)
- ✅ **로컬 저장**: 앱 내부 저장소에만 저장
- ❌ 자동 백업 없음
- ❌ 클라우드 백업 없음
- ❌ 이미지 백업 없음

### 프리미엄 사용자 (하이브리드)
- ✅ **수동 백업**: JSON 형식 완전한 백업 (모든 데이터 + 이미지)
- ✅ **자동 백업**: 주기적 자동 백업 (매일/매주/매월 선택 가능)
- ✅ **로컬 백업**: 앱 내부 저장소에 즉시 저장 (빠른 백업)
- ✅ **클라우드 백업**: Firebase Storage에 자동 업로드 (안전한 보관)
- ✅ **이중 보관**: 로컬 + 클라우드 동시 저장으로 안전성 극대화
- ✅ **백업 복원**: 로컬 또는 클라우드에서 선택하여 복원
- ✅ **기기 간 동기화**: 다른 기기에서도 클라우드 백업 접근 가능

## 🔧 상세 구현 계획

### 1. DatabaseService 수정
**파일:** `lib/services/database_service.dart`

#### 문제:
```dart
// 현재 코드 (100-109번 라인)
final List<Map<String, dynamic>> maps = await db.query(
  tableName,
  columns: [
    'id', 'title', 'content', 'createdAt', 'updatedAt',
    'generatedImageUrl', 'emotion', 'keywords', 'aiPrompt',
    'imageStyle', 'hasBeenRegenerated', 'fontFamily', 'imageTime', 'imageWeather', 'imageSeason'
  ],  // imageData 누락!
  orderBy: 'createdAt DESC',
);
```

#### 해결책:
```dart
// 백업용 메서드 추가
static Future<List<DiaryEntry>> getAllDiariesForBackup() async {
  final db = await database;
  final List<Map<String, dynamic>> maps = await db.query(
    tableName,
    // 모든 컬럼 포함 (imageData 포함)
    orderBy: 'createdAt DESC',
  );

  return List.generate(maps.length, (i) {
    return DiaryEntry.fromMap(maps[i]);
  });
}
```

### 2. 백업 데이터 완성도 개선
**파일:** `lib/screens/settings_screen.dart`

#### 현재 프리미엄 백업 (1230-1241번 라인):
```dart
'entries': diaries.map((diary) => {
  'id': diary.id,
  'title': diary.title,
  'content': diary.content,
  'date': diary.createdAt.toIso8601String(),
  'emotion': diary.emotion,
  'imageData': diary.imageData != null ? base64Encode(diary.imageData!) : null,
  'generatedImageUrl': diary.generatedImageUrl,
  'imageStyle': diary.imageStyle.toString(),
  'keywords': diary.keywords,
  'aiPrompt': diary.aiPrompt,
}).toList(),
```

#### 개선된 프리미엄 백업:
```dart
'entries': diaries.map((diary) => {
  'id': diary.id,
  'title': diary.title,
  'content': diary.content,
  'createdAt': diary.createdAt.toIso8601String(),
  'updatedAt': diary.updatedAt?.toIso8601String(),  // ✅ 추가
  'emotion': diary.emotion,
  'imageData': diary.imageData != null ? base64Encode(diary.imageData!) : null,
  'generatedImageUrl': diary.generatedImageUrl,
  'imageStyle': diary.imageStyle.name,
  'keywords': diary.keywords,
  'aiPrompt': diary.aiPrompt,
  'hasBeenRegenerated': diary.hasBeenRegenerated,  // ✅ 추가
  'fontFamily': diary.fontFamily?.name,  // ✅ 추가
  'imageTime': diary.imageTime?.name,  // ✅ 추가
  'imageWeather': diary.imageWeather?.name,  // ✅ 추가
  'imageSeason': diary.imageSeason?.name,  // ✅ 추가
}).toList(),
```

### 3. 자동 백업 서비스 구현 (하이브리드 방식)
**새 파일:** `lib/services/backup_service.dart`

#### 핵심 개념:
하이브리드 백업은 **로컬 우선, 클라우드 병행** 전략을 사용합니다.

**작동 순서:**
1. 로컬에 먼저 백업 (즉시 완료, 오프라인 가능)
2. 프리미엄이면 백그라운드에서 클라우드 업로드 (WiFi 권장)
3. 복원 시 로컬 먼저 확인, 없으면 클라우드에서 다운로드

#### 저장 위치:

**무료 사용자 (로컬만):**
```dart
// 수동 백업 텍스트
final directory = await getApplicationDocumentsDirectory();
경로: ${directory.path}/backups/free/manual_backup_{timestamp}.txt
```

**프리미엄 사용자 (하이브리드):**
```dart
// 로컬 저장소
final directory = await getApplicationDocumentsDirectory();
로컬 경로: ${directory.path}/backups/premium/auto_backup_{timestamp}.json

// Firebase Storage (클라우드)
final userId = FirebaseAuth.instance.currentUser!.uid;
클라우드 경로: gs://{project-id}.appspot.com/backups/{userId}/backup_{timestamp}.json

// 예시:
// 로컬: /data/user/0/com.aidiary.app/app_flutter/backups/premium/auto_backup_1696789012345.json
// 클라우드: gs://ai-diary-app.appspot.com/backups/abc123/backup_1696789012345.json
```

#### 주요 메서드 상세:

```dart
class BackupService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // ========== 1. 자동 백업 실행 (하이브리드) ==========
  static Future<BackupResult> performAutoBackup({
    required bool isPremium,
  }) async {
    try {
      // Step 1: 데이터 수집
      final diaries = await DatabaseService.getAllDiariesForBackup();

      // Step 2: 백업 데이터 생성
      final backupData = _createBackupData(diaries, isPremium);

      // Step 3: 로컬 저장 (무료/프리미엄 모두)
      final localFile = await _saveToLocal(backupData, isPremium);

      // Step 4: 클라우드 업로드 (프리미엄만)
      String? cloudUrl;
      if (isPremium) {
        cloudUrl = await _uploadToCloud(localFile);
      }

      return BackupResult(
        success: true,
        localPath: localFile.path,
        cloudUrl: cloudUrl,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      return BackupResult(success: false, error: e.toString());
    }
  }

  // ========== 2. 로컬 저장 ==========
  static Future<File> _saveToLocal(Map<String, dynamic> data, bool isPremium) async {
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    final backupDir = Directory('${directory.path}/backups/${isPremium ? 'premium' : 'free'}');
    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
    }

    final fileName = isPremium
      ? 'auto_backup_$timestamp.json'
      : 'manual_backup_$timestamp.txt';

    final file = File('${backupDir.path}/$fileName');

    if (isPremium) {
      // JSON 저장
      final jsonString = const JsonEncoder.withIndent('  ').convert(data);
      await file.writeAsString(jsonString);
    } else {
      // 텍스트 저장
      await file.writeAsString(data['text_content']);
    }

    return file;
  }

  // ========== 3. 클라우드 업로드 (프리미엄만) ==========
  static Future<String?> _uploadToCloud(File localFile) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      final fileName = path.basename(localFile.path);
      final ref = _storage.ref().child('backups/$userId/$fileName');

      // 업로드 (WiFi 권장)
      final uploadTask = ref.putFile(
        localFile,
        SettableMetadata(
          contentType: 'application/json',
          customMetadata: {
            'device': Platform.operatingSystem,
            'app_version': '1.0.0',
          },
        ),
      );

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      print('클라우드 업로드 실패: $e');
      return null; // 로컬 백업은 성공했으므로 null 반환
    }
  }

  // ========== 4. 백업 스케줄링 (workmanager) ==========
  static Future<void> scheduleAutoBackup(BackupFrequency frequency) async {
    await Workmanager().cancelAll(); // 기존 스케줄 취소

    Duration interval;
    switch (frequency) {
      case BackupFrequency.daily:
        interval = const Duration(hours: 24);
        break;
      case BackupFrequency.weekly:
        interval = const Duration(days: 7);
        break;
      case BackupFrequency.monthly:
        interval = const Duration(days: 30);
        break;
      default:
        return; // manual은 스케줄 안 함
    }

    await Workmanager().registerPeriodicTask(
      'auto-backup-task',
      'autoBackup',
      frequency: interval,
      constraints: Constraints(
        networkType: NetworkType.connected, // 네트워크 필요 (클라우드 업로드용)
        requiresBatteryNotLow: true,
      ),
    );
  }

  // ========== 5. 백업 목록 조회 (로컬 + 클라우드) ==========
  static Future<List<BackupFile>> getBackupHistory({
    required bool isPremium,
  }) async {
    List<BackupFile> backups = [];

    // 로컬 백업 조회
    final localBackups = await _getLocalBackups(isPremium);
    backups.addAll(localBackups);

    // 프리미엄이면 클라우드 백업도 조회
    if (isPremium) {
      final cloudBackups = await _getCloudBackups();
      backups.addAll(cloudBackups);
    }

    // 시간순 정렬 (최신순)
    backups.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return backups;
  }

  // ========== 6. 로컬 백업 목록 ==========
  static Future<List<BackupFile>> _getLocalBackups(bool isPremium) async {
    final directory = await getApplicationDocumentsDirectory();
    final backupDir = Directory('${directory.path}/backups/${isPremium ? 'premium' : 'free'}');

    if (!await backupDir.exists()) return [];

    final files = await backupDir.list().toList();
    return files.whereType<File>().map((file) {
      final fileName = path.basename(file.path);
      final timestamp = _extractTimestampFromFileName(fileName);

      return BackupFile(
        id: fileName,
        path: file.path,
        timestamp: timestamp,
        type: BackupType.local,
        size: file.lengthSync(),
      );
    }).toList();
  }

  // ========== 7. 클라우드 백업 목록 ==========
  static Future<List<BackupFile>> _getCloudBackups() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return [];

    try {
      final ref = _storage.ref().child('backups/$userId');
      final result = await ref.listAll();

      List<BackupFile> cloudBackups = [];
      for (var item in result.items) {
        final metadata = await item.getMetadata();
        final downloadUrl = await item.getDownloadURL();

        cloudBackups.add(BackupFile(
          id: item.name,
          path: downloadUrl,
          timestamp: metadata.timeCreated ?? DateTime.now(),
          type: BackupType.cloud,
          size: metadata.size ?? 0,
        ));
      }

      return cloudBackups;
    } catch (e) {
      print('클라우드 백업 목록 조회 실패: $e');
      return [];
    }
  }

  // ========== 8. 백업 복원 (하이브리드) ==========
  static Future<void> restoreFromBackup(BackupFile backup) async {
    Map<String, dynamic> data;

    if (backup.type == BackupType.local) {
      // 로컬에서 복원
      final file = File(backup.path);
      final content = await file.readAsString();
      data = jsonDecode(content);
    } else {
      // 클라우드에서 다운로드 후 복원
      final response = await http.get(Uri.parse(backup.path));
      data = jsonDecode(response.body);
    }

    // 데이터베이스에 복원
    await _restoreData(data);
  }

  // ========== 9. 오래된 백업 정리 ==========
  static Future<void> cleanOldBackups({
    required bool isPremium,
    int keepLast = 10, // 최근 10개 유지
  }) async {
    // 로컬 백업 정리
    final localBackups = await _getLocalBackups(isPremium);
    if (localBackups.length > keepLast) {
      final toDelete = localBackups.skip(keepLast);
      for (var backup in toDelete) {
        final file = File(backup.path);
        if (await file.exists()) {
          await file.delete();
        }
      }
    }

    // 프리미엄: 클라우드 백업 정리 (선택사항)
    if (isPremium) {
      final cloudBackups = await _getCloudBackups();
      if (cloudBackups.length > keepLast) {
        final userId = _auth.currentUser?.uid;
        final toDelete = cloudBackups.skip(keepLast);

        for (var backup in toDelete) {
          final ref = _storage.ref().child('backups/$userId/${backup.id}');
          await ref.delete();
        }
      }
    }
  }

  // ========== 10. 백업 데이터 생성 ==========
  static Map<String, dynamic> _createBackupData(
    List<DiaryEntry> diaries,
    bool isPremium,
  ) {
    if (!isPremium) {
      // 무료: 텍스트만
      final buffer = StringBuffer();
      buffer.writeln('AI 그림일기 백업');
      buffer.writeln('날짜: ${DateTime.now()}');
      buffer.writeln('총 일기: ${diaries.length}개\n');

      for (var diary in diaries) {
        buffer.writeln('제목: ${diary.title}');
        buffer.writeln('날짜: ${diary.createdAt}');
        buffer.writeln('내용:\n${diary.content}\n');
        buffer.writeln('---\n');
      }

      return {'text_content': buffer.toString()};
    } else {
      // 프리미엄: 완전한 JSON
      return {
        'app_name': 'ArtDiary AI',
        'backup_date': DateTime.now().toIso8601String(),
        'version': '1.0.0',
        'backup_type': 'premium',
        'total_entries': diaries.length,
        'entries': diaries.map((diary) => {
          'id': diary.id,
          'title': diary.title,
          'content': diary.content,
          'createdAt': diary.createdAt.toIso8601String(),
          'updatedAt': diary.updatedAt?.toIso8601String(),
          'emotion': diary.emotion,
          'imageData': diary.imageData != null ? base64Encode(diary.imageData!) : null,
          'generatedImageUrl': diary.generatedImageUrl,
          'imageStyle': diary.imageStyle.name,
          'keywords': diary.keywords,
          'aiPrompt': diary.aiPrompt,
          'hasBeenRegenerated': diary.hasBeenRegenerated,
          'fontFamily': diary.fontFamily?.name,
          'imageTime': diary.imageTime?.name,
          'imageWeather': diary.imageWeather?.name,
          'imageSeason': diary.imageSeason?.name,
        }).toList(),
      };
    }
  }
}

// ========== 백업 결과 모델 ==========
class BackupResult {
  final bool success;
  final String? localPath;
  final String? cloudUrl;
  final DateTime? timestamp;
  final String? error;

  BackupResult({
    required this.success,
    this.localPath,
    this.cloudUrl,
    this.timestamp,
    this.error,
  });
}

// ========== 백업 파일 모델 ==========
class BackupFile {
  final String id;
  final String path; // 로컬 경로 or 클라우드 URL
  final DateTime timestamp;
  final BackupType type;
  final int size;

  BackupFile({
    required this.id,
    required this.path,
    required this.timestamp,
    required this.type,
    required this.size,
  });
}

enum BackupType {
  local,   // 로컬 저장소
  cloud,   // Firebase Storage
}
```

### 4. 백업 설정 Provider
**새 파일:** `lib/providers/backup_settings_provider.dart`

```dart
enum BackupFrequency {
  daily,    // 매일
  weekly,   // 매주
  monthly,  // 매월
  manual,   // 수동만
}

class BackupSettings {
  final BackupFrequency frequency;
  final bool autoBackupEnabled;
  final bool cloudBackupEnabled;
  final DateTime? lastBackupTime;

  BackupSettings({
    this.frequency = BackupFrequency.weekly,
    this.autoBackupEnabled = false,
    this.cloudBackupEnabled = false,
    this.lastBackupTime,
  });
}

final backupSettingsProvider = StateNotifierProvider<BackupSettingsNotifier, BackupSettings>(...);
```

### 5. 백업 복원 기능
**파일:** `lib/screens/settings_screen.dart`

#### 새로운 기능:
- 백업 파일 목록 표시
- 로컬/클라우드 백업 선택
- 미리보기 기능
- 복원 확인 다이얼로그
- 진행 상태 표시

### 6. UI 개선
**파일:** `lib/screens/settings_screen.dart`

#### 프리미엄 사용자 설정 화면 추가:
```
[데이터 백업]
├── 수동 백업
├── 자동 백업 설정
│   ├── 백업 주기 선택 (매일/매주/매월)
│   ├── 클라우드 백업 활성화
│   └── 마지막 백업: 2025-10-06 20:30
├── 백업 복원
│   ├── 로컬 백업 (10개)
│   └── 클라우드 백업 (15개)
└── 백업 관리
    ├── 백업 파일 정리
    └── 저장 공간 확인
```

## 📦 필요한 패키지

```yaml
dependencies:
  # 자동 백업 스케줄링
  workmanager: ^0.5.2

  # Firebase Storage (클라우드 백업)
  firebase_storage: ^11.7.0

  # 파일 경로
  path_provider: ^2.1.2

  # 이미 있는 패키지
  firebase_core: (이미 설치됨)
  share_plus: (이미 설치됨)
```

## 🔄 구현 순서

### Phase 1: 기존 백업 수정 (우선순위: 높음)
1. ✅ DatabaseService에 `getAllDiariesForBackup()` 메서드 추가
2. ✅ 프리미엄 백업 데이터 완성도 개선
3. ✅ 테스트: 이미지 데이터 포함 여부 확인

### Phase 2: 로컬 자동 백업 (우선순위: 높음)
1. ✅ BackupService 기본 구조 생성
2. ✅ 로컬 저장소에 자동 백업 저장 로직
3. ✅ workmanager로 주기적 백업 스케줄링
4. ✅ 백업 설정 Provider 생성
5. ✅ UI에 자동 백업 설정 추가

### Phase 3: 클라우드 백업 (우선순위: 중간)
1. ✅ Firebase Storage 설정
2. ✅ 클라우드 업로드 로직
3. ✅ 프리미엄 사용자만 클라우드 백업 활성화
4. ✅ 업로드 진행 상태 표시

### Phase 4: 백업 복원 (우선순위: 중간)
1. ✅ 백업 파일 목록 조회
2. ✅ 백업 파일 미리보기
3. ✅ 복원 로직 구현
4. ✅ 복원 UI 추가

### Phase 5: 최적화 (우선순위: 낮음)
1. ✅ 오래된 백업 파일 자동 정리
2. ✅ 백업 압축 (gzip)
3. ✅ 백업 암호화 (선택사항)
4. ✅ 백업 통계 표시

## ⚠️ 주의사항

### Firebase Storage 설정
1. Firebase 콘솔에서 Storage 활성화
2. 보안 규칙 설정:
```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /backups/{userId}/{allPaths=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

### 개인정보 보호
- 백업 파일 암호화 고려
- 클라우드 업로드 시 SSL 사용
- 사용자 동의 필요

### 성능 고려사항
- 백업은 백그라운드에서 수행
- 대용량 이미지는 압축 고려
- 네트워크 상태 확인 후 클라우드 업로드

## 📝 테스트 체크리스트

- [ ] 무료 사용자 텍스트 백업
- [ ] 프리미엄 사용자 JSON 백업 (모든 필드 포함)
- [ ] 이미지 데이터 백업/복원
- [ ] 로컬 자동 백업 (매일/매주/매월)
- [ ] 클라우드 백업 업로드
- [ ] 백업 파일 목록 조회
- [ ] 백업 복원
- [ ] 앱 삭제 후 재설치 시 클라우드에서 복원
- [ ] 기기 변경 시 데이터 마이그레이션
- [ ] 오래된 백업 파일 정리

## 🚀 출시 전 최종 확인

- [ ] Firebase Storage 요금제 확인
- [ ] 백업 파일 크기 제한 설정
- [ ] 에러 핸들링 완성도
- [ ] 사용자 가이드 작성
- [ ] 프리미엄 유도 문구 추가
