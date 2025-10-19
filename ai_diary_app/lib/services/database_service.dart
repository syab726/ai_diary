import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/diary_entry.dart';
import '../models/emotion_insight.dart';
import '../models/image_style.dart';
import '../models/font_family.dart';
import '../models/image_time.dart';
import '../models/image_weather.dart';
import '../models/image_season.dart';
import 'package:flutter/foundation.dart';

class DatabaseService {
  static Database? _database;
  static const String tableName = 'diary_entries';

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'diary_app.db');
    return await openDatabase(
      path,
      version: 7,
      onCreate: _createDb,
      onUpgrade: _upgradeDb,
    );
  }

  static Future<void> _createDb(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableName(
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT,
        generatedImageUrl TEXT,
        imageData TEXT,
        emotion TEXT,
        keywords TEXT,
        aiPrompt TEXT,
        imageStyle TEXT,
        hasBeenRegenerated INTEGER DEFAULT 0,
        fontFamily TEXT,
        imageTime TEXT,
        imageWeather TEXT,
        imageSeason TEXT,
        userPhotos TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE emotion_insights(
        id TEXT PRIMARY KEY,
        type TEXT NOT NULL,
        insightText TEXT NOT NULL,
        periodStart TEXT NOT NULL,
        periodEnd TEXT NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');
  }

  static Future<void> _upgradeDb(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE $tableName ADD COLUMN imageData TEXT');
      await db.execute('ALTER TABLE $tableName ADD COLUMN imageStyle TEXT');
      await db.execute('ALTER TABLE $tableName ADD COLUMN hasBeenRegenerated INTEGER DEFAULT 0');
    }
    if (oldVersion < 3) {
      await db.execute('ALTER TABLE $tableName ADD COLUMN fontFamily TEXT');
    }
    if (oldVersion < 4) {
      await db.execute('ALTER TABLE $tableName ADD COLUMN imageTime TEXT');
      await db.execute('ALTER TABLE $tableName ADD COLUMN imageWeather TEXT');
    }
    if (oldVersion < 5) {
      await db.execute('ALTER TABLE $tableName ADD COLUMN imageSeason TEXT');
    }
    if (oldVersion < 6) {
      await db.execute('''
        CREATE TABLE emotion_insights(
          id TEXT PRIMARY KEY,
          type TEXT NOT NULL,
          insightText TEXT NOT NULL,
          periodStart TEXT NOT NULL,
          periodEnd TEXT NOT NULL,
          createdAt TEXT NOT NULL
        )
      ''');
    }
    if (oldVersion < 7) {
      await db.execute('ALTER TABLE $tableName ADD COLUMN userPhotos TEXT');
    }
  }

  static Future<String> insertDiary(DiaryEntry diary) async {
    final db = await database;
    await db.insert(tableName, diary.toMap());
    return diary.id;  // 생성된 일기의 ID 반환
  }

  static Future<List<DiaryEntry>> getAllDiaries() async {
    if (kDebugMode) print('DatabaseService: getAllDiaries 호출됨');
    final db = await database;

    // imageData BLOB 필드를 제외하고 조회 (CursorWindow 크기 제한 방지)
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      columns: [
        'id',
        'title',
        'content',
        'createdAt',
        'updatedAt',
        'generatedImageUrl',
        // 'imageData',  // BLOB 데이터 제외
        'emotion',
        'keywords',
        'aiPrompt',
        'imageStyle',
        'hasBeenRegenerated',
        'fontFamily',
        'imageTime',
        'imageWeather',
        'imageSeason',
        'userPhotos',
      ],
      orderBy: 'createdAt DESC',
    );

    if (kDebugMode) print('DatabaseService: 가져온 일기 개수: ${maps.length}');
    for (int i = 0; i < maps.length; i++) {
      if (kDebugMode) print('DatabaseService: 일기 $i - 제목: ${maps[i]['title']}, 내용길이: ${maps[i]['content']?.length ?? 0}');
    }

    final List<DiaryEntry> diaries = List.generate(maps.length, (i) {
      return DiaryEntry.fromMap(maps[i]);
    });

    if (kDebugMode) print('DatabaseService: DiaryEntry 객체 생성 완료: ${diaries.length}개');
    return diaries;
  }

  static Future<DiaryEntry?> getDiaryById(String id) async {
    final db = await database;
    // imageData BLOB 필드를 제외하고 조회 (CursorWindow 크기 제한 방지)
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      columns: [
        'id',
        'title',
        'content',
        'createdAt',
        'updatedAt',
        'generatedImageUrl',
        // 'imageData',  // BLOB 데이터 제외
        'emotion',
        'keywords',
        'aiPrompt',
        'imageStyle',
        'hasBeenRegenerated',
        'fontFamily',
        'imageTime',
        'imageWeather',
        'imageSeason',
        'userPhotos',
      ],
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return DiaryEntry.fromMap(maps.first);
    }
    return null;
  }

  static Future<int> updateDiary(DiaryEntry diary) async {
    final db = await database;
    return await db.update(
      tableName,
      diary.toMap(),
      where: 'id = ?',
      whereArgs: [diary.id],
    );
  }

  static Future<int> deleteDiary(String id) async {
    final db = await database;
    return await db.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<List<DiaryEntry>> searchDiaries(String query) async {
    final db = await database;
    // imageData BLOB 필드를 제외하고 조회 (CursorWindow 크기 제한 방지)
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      columns: [
        'id',
        'title',
        'content',
        'createdAt',
        'updatedAt',
        'generatedImageUrl',
        // 'imageData',  // BLOB 데이터 제외
        'emotion',
        'keywords',
        'aiPrompt',
        'imageStyle',
        'hasBeenRegenerated',
        'fontFamily',
        'imageTime',
        'imageWeather',
        'imageSeason',
        'userPhotos',
      ],
      where: 'title LIKE ? OR content LIKE ? OR keywords LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
      orderBy: 'createdAt DESC',
    );

    return List.generate(maps.length, (i) {
      return DiaryEntry.fromMap(maps[i]);
    });
  }

  static Future<int> deleteAllEntries() async {
    final db = await database;
    return await db.delete(tableName);
  }

  // Emotion Insight CRUD operations
  static Future<void> insertInsight(EmotionInsight insight) async {
    final db = await database;
    await db.insert('emotion_insights', insight.toMap());
  }

  static Future<EmotionInsight?> getInsightByType(String type) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'emotion_insights',
      where: 'type = ?',
      whereArgs: [type],
      orderBy: 'createdAt DESC',
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return EmotionInsight.fromMap(maps.first);
    }
    return null;
  }

  static Future<int> deleteInsight(String id) async {
    final db = await database;
    return await db.delete(
      'emotion_insights',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // 클라우드 백업용: 데이터를 JSON 문자열로 내보내기
  static Future<String> exportToJson({bool isPremium = false}) async {
    final diaries = await getAllDiaries();

    final exportData = {
      'version': '1.0',
      'exportDate': DateTime.now().toIso8601String(),
      'diaryCount': diaries.length,
      'isPremium': isPremium,
      'diaries': diaries.map((diary) {
        final Map<String, dynamic> data = {
          'id': diary.id,
          'title': diary.title,
          'content': diary.content,
          'createdAt': diary.createdAt.toIso8601String(),
          'updatedAt': diary.updatedAt?.toIso8601String(),
          'emotion': diary.emotion,
          'keywords': diary.keywords,
          'imageStyle': diary.imageStyle.name,
          'fontFamily': diary.fontFamily.name,
          'imageTime': diary.imageTime.name,
          'imageWeather': diary.imageWeather.name,
          'imageSeason': diary.imageSeason.name,
          'userPhotos': diary.userPhotos,
        };

        // 프리미엄 사용자만 AI 생성 이미지와 프롬프트 백업
        if (isPremium) {
          data['aiPrompt'] = diary.aiPrompt;
          data['generatedImageUrl'] = diary.generatedImageUrl;
          data['imageData'] = diary.imageData != null ? base64Encode(diary.imageData!) : null;
          data['hasBeenRegenerated'] = diary.hasBeenRegenerated;
        }

        return data;
      }).toList(),
    };

    return jsonEncode(exportData);
  }

  // 클라우드 복원용: JSON 문자열에서 데이터 가져오기
  static Future<int> importFromJson(String jsonString) async {
    try {
      if (kDebugMode) print('=== 데이터 복원 시작 ===');
      final db = await database;

      if (kDebugMode) print('JSON 파싱 중...');
      final data = jsonDecode(jsonString) as Map<String, dynamic>;
      if (kDebugMode) print('백업 버전: ${data['version']}');
      if (kDebugMode) print('백업 날짜: ${data['exportDate']}');
      if (kDebugMode) print('프리미엄 여부: ${data['isPremium']}');

      final diaries = data['diaries'] as List<dynamic>;
      if (kDebugMode) print('복원할 일기 개수: ${diaries.length}');

      // 기존 데이터 모두 삭제
      if (kDebugMode) print('기존 데이터 삭제 중...');
      await db.delete(tableName);
      if (kDebugMode) print('✅ 기존 데이터 삭제 완료');

      int importedCount = 0;
      for (int i = 0; i < diaries.length; i++) {
        final diaryData = diaries[i];
        try {
          if (kDebugMode) print('\n--- 일기 ${i + 1}/${diaries.length} 복원 중 ---');
          if (kDebugMode) print('ID: ${diaryData['id']}');
          if (kDebugMode) print('제목: ${diaryData['title']}');

          if (kDebugMode) print('기본 필드 파싱 중...');
          final id = diaryData['id'] as String;
          final title = diaryData['title'] as String;
          final content = diaryData['content'] as String;
          final createdAt = DateTime.parse(diaryData['createdAt'] as String);
          final updatedAt = diaryData['updatedAt'] != null
              ? DateTime.parse(diaryData['updatedAt'] as String)
              : null;

          if (kDebugMode) print('감정/키워드 파싱 중...');
          final emotion = diaryData['emotion'] as String?;
          final keywords = (diaryData['keywords'] as List<dynamic>?)?.cast<String>() ?? [];
          if (kDebugMode) print('키워드 개수: ${keywords.length}');

          if (kDebugMode) print('AI 관련 필드 파싱 중...');
          final aiPrompt = diaryData['aiPrompt'] as String?;
          final generatedImageUrl = diaryData['generatedImageUrl'] as String?;
          final imageData = diaryData['imageData'] != null
              ? base64Decode(diaryData['imageData'] as String)
              : null;
          final hasBeenRegenerated = diaryData['hasBeenRegenerated'] == true;

          if (kDebugMode) print('스타일 필드 파싱 중...');
          final imageStyle = diaryData['imageStyle'] != null
              ? ImageStyle.values.firstWhere(
                  (style) => style.name == diaryData['imageStyle'],
                  orElse: () => ImageStyle.illustration,
                )
              : ImageStyle.illustration;
          if (kDebugMode) print('이미지 스타일: ${imageStyle.name}');

          final fontFamily = diaryData['fontFamily'] != null
              ? FontFamily.values.firstWhere(
                  (font) => font.name == diaryData['fontFamily'],
                  orElse: () => FontFamily.notoSans,
                )
              : FontFamily.notoSans;
          if (kDebugMode) print('글꼴: ${fontFamily.name}');

          if (kDebugMode) print('이미지 옵션 파싱 중...');
          final imageTime = diaryData['imageTime'] != null
              ? ImageTime.values.firstWhere(
                  (time) => time.name == diaryData['imageTime'],
                  orElse: () => ImageTime.morning,
                )
              : ImageTime.morning;
          if (kDebugMode) print('시간: ${imageTime.name}');

          final imageWeather = diaryData['imageWeather'] != null
              ? ImageWeather.values.firstWhere(
                  (weather) => weather.name == diaryData['imageWeather'],
                  orElse: () => ImageWeather.sunny,
                )
              : ImageWeather.sunny;
          if (kDebugMode) print('날씨: ${imageWeather.name}');

          final imageSeason = diaryData['imageSeason'] != null
              ? ImageSeason.values.firstWhere(
                  (season) => season.name == diaryData['imageSeason'],
                  orElse: () => ImageSeason.spring,
                )
              : ImageSeason.spring;
          if (kDebugMode) print('계절: ${imageSeason.name}');

          if (kDebugMode) print('사용자 사진 파싱 중...');
          final userPhotos = (diaryData['userPhotos'] as List<dynamic>?)?.cast<String>() ?? [];
          if (kDebugMode) print('사용자 사진 개수: ${userPhotos.length}');

          if (kDebugMode) print('DiaryEntry 객체 생성 중...');
          final diary = DiaryEntry(
            id: id,
            title: title,
            content: content,
            createdAt: createdAt,
            updatedAt: updatedAt,
            emotion: emotion,
            keywords: keywords,
            aiPrompt: aiPrompt,
            generatedImageUrl: generatedImageUrl,
            imageData: imageData,
            imageStyle: imageStyle,
            hasBeenRegenerated: hasBeenRegenerated,
            fontFamily: fontFamily,
            imageTime: imageTime,
            imageWeather: imageWeather,
            imageSeason: imageSeason,
            userPhotos: userPhotos,
          );

          if (kDebugMode) print('DB에 저장 중...');
          await db.insert(tableName, diary.toMap());
          importedCount++;
          if (kDebugMode) print('✅ 일기 ${i + 1} 복원 완료');
        } catch (e, stackTrace) {
          if (kDebugMode) print('❌ 일기 ${i + 1} 복원 실패');
          if (kDebugMode) print('에러: $e');
          if (kDebugMode) print('스택 트레이스:\n$stackTrace');
          if (kDebugMode) print('일기 데이터: ${diaryData.toString()}');
        }
      }

      if (kDebugMode) print('\n=== 복원 완료 ===');
      if (kDebugMode) print('성공: $importedCount개 / 전체: ${diaries.length}개');
      return importedCount;
    } catch (e, stackTrace) {
      if (kDebugMode) print('❌ 데이터 복원 전체 실패');
      if (kDebugMode) print('에러: $e');
      if (kDebugMode) print('스택 트레이스:\n$stackTrace');
      return 0;
    }
  }
}
