import 'dart:convert';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'database_service.dart';

class GoogleDriveService {
  static const String _folderName = 'ArtDiary_AI_Backup';
  static const String _fileName = 'diary_backup.json';

  // Google Drive 폴더 ID 가져오기 또는 생성
  static Future<String> _getOrCreateFolder(drive.DriveApi driveApi) async {
    // 기존 폴더 검색
    final query = "name='$_folderName' and mimeType='application/vnd.google-apps.folder' and trashed=false";
    final fileList = await driveApi.files.list(
      q: query,
      spaces: 'drive',
      $fields: 'files(id, name)',
    );

    if (fileList.files != null && fileList.files!.isNotEmpty) {
      return fileList.files!.first.id!;
    }

    // 폴더가 없으면 생성
    final folder = drive.File()
      ..name = _folderName
      ..mimeType = 'application/vnd.google-apps.folder';

    final createdFolder = await driveApi.files.create(folder);
    return createdFolder.id!;
  }

  // Google Drive에 백업 업로드
  static Future<bool> uploadBackup({required bool isPremium}) async {
    try {
      print('=== Google Drive 백업 시작 ===');
      final googleSignIn = GoogleSignIn(scopes: [drive.DriveApi.driveFileScope]);

      print('Google Sign In 확인 중...');
      final account = await googleSignIn.signInSilently();

      if (account == null) {
        print('❌ Google 로그인이 필요합니다');
        return false;
      }

      print('✅ Google 계정 확인됨: ${account.email}');

      print('인증 클라이언트 가져오는 중...');
      final httpClient = (await googleSignIn.authenticatedClient())!;
      final driveApi = drive.DriveApi(httpClient);
      print('✅ Drive API 클라이언트 생성 완료');

      // 백업 폴더 가져오기 또는 생성
      print('백업 폴더 확인 중...');
      final folderId = await _getOrCreateFolder(driveApi);
      print('✅ 폴더 ID: $folderId');

      // DatabaseService의 exportToJson 사용하여 표준 포맷으로 백업
      print('백업 데이터 생성 중...');
      final jsonString = await DatabaseService.exportToJson(isPremium: isPremium);
      final bytes = utf8.encode(jsonString);
      print('✅ JSON 크기: ${bytes.length} bytes');

      // 기존 파일 검색
      print('기존 백업 파일 검색 중...');
      final query = "name='$_fileName' and '$folderId' in parents and trashed=false";
      final existingFiles = await driveApi.files.list(
        q: query,
        spaces: 'drive',
        $fields: 'files(id, name)',
      );

      // 기존 파일이 있으면 삭제
      if (existingFiles.files != null && existingFiles.files!.isNotEmpty) {
        print('기존 백업 파일 삭제 중...');
        await driveApi.files.delete(existingFiles.files!.first.id!);
        print('✅ 기존 파일 삭제 완료');
      } else {
        print('기존 백업 파일 없음');
      }

      // 새 파일 업로드
      print('새 백업 파일 생성 중...');
      final file = drive.File()
        ..name = _fileName
        ..parents = [folderId];

      final media = drive.Media(
        Stream.value(bytes),
        bytes.length,
        contentType: 'application/json',
      );

      print('파일 업로드 중...');
      await driveApi.files.create(file, uploadMedia: media);

      print('✅ Google Drive 백업 성공!');
      return true;
    } catch (e) {
      print('❌ Google Drive 백업 실패: $e');
      print('에러 타입: ${e.runtimeType}');
      print('스택 트레이스: ${StackTrace.current}');
      return false;
    }
  }

  // Google Drive에 백업이 있는지 확인
  static Future<bool> hasBackup() async {
    try {
      final googleSignIn = GoogleSignIn(scopes: [drive.DriveApi.driveFileScope]);
      final account = await googleSignIn.signInSilently();

      if (account == null) {
        return false;
      }

      final httpClient = (await googleSignIn.authenticatedClient())!;
      final driveApi = drive.DriveApi(httpClient);

      // 폴더 검색
      final folderQuery = "name='$_folderName' and mimeType='application/vnd.google-apps.folder' and trashed=false";
      final folderList = await driveApi.files.list(
        q: folderQuery,
        spaces: 'drive',
        $fields: 'files(id, name)',
      );

      if (folderList.files == null || folderList.files!.isEmpty) {
        return false;
      }

      final folderId = folderList.files!.first.id!;

      // 파일 검색
      final fileQuery = "name='$_fileName' and '$folderId' in parents and trashed=false";
      final fileList = await driveApi.files.list(
        q: fileQuery,
        spaces: 'drive',
        $fields: 'files(id, name)',
      );

      return fileList.files != null && fileList.files!.isNotEmpty;
    } catch (e) {
      print('Google Drive 백업 확인 실패: $e');
      return false;
    }
  }

  // Google Drive에서 백업 다운로드 및 복원
  static Future<int> downloadAndRestoreBackup() async {
    try {
      final googleSignIn = GoogleSignIn(scopes: [drive.DriveApi.driveFileScope]);
      final account = await googleSignIn.signInSilently();

      if (account == null) {
        print('Google 로그인이 필요합니다');
        return 0;
      }

      final httpClient = (await googleSignIn.authenticatedClient())!;
      final driveApi = drive.DriveApi(httpClient);

      // 폴더 검색
      final folderQuery = "name='$_folderName' and mimeType='application/vnd.google-apps.folder' and trashed=false";
      final folderList = await driveApi.files.list(
        q: folderQuery,
        spaces: 'drive',
        $fields: 'files(id, name)',
      );

      if (folderList.files == null || folderList.files!.isEmpty) {
        print('백업 폴더를 찾을 수 없습니다');
        return 0;
      }

      final folderId = folderList.files!.first.id!;

      // 파일 검색
      final fileQuery = "name='$_fileName' and '$folderId' in parents and trashed=false";
      final fileList = await driveApi.files.list(
        q: fileQuery,
        spaces: 'drive',
        $fields: 'files(id, name)',
      );

      if (fileList.files == null || fileList.files!.isEmpty) {
        print('백업 파일을 찾을 수 없습니다');
        return 0;
      }

      final fileId = fileList.files!.first.id!;

      // 파일 다운로드
      final media = await driveApi.files.get(
        fileId,
        downloadOptions: drive.DownloadOptions.fullMedia,
      ) as drive.Media;

      final bytes = <int>[];
      await for (final chunk in media.stream) {
        bytes.addAll(chunk);
      }

      final jsonString = utf8.decode(bytes);

      // 데이터베이스에 복원
      final restoredCount = await DatabaseService.importFromJson(jsonString);

      print('Google Drive 복원 성공: $restoredCount개');
      return restoredCount;
    } catch (e) {
      print('Google Drive 복원 실패: $e');
      return 0;
    }
  }
}
