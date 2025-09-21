import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/diary_entry.dart';

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
      version: 2,
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
        hasBeenRegenerated INTEGER DEFAULT 0
      )
    ''');
  }

  static Future<void> _upgradeDb(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE $tableName ADD COLUMN imageData TEXT');
      await db.execute('ALTER TABLE $tableName ADD COLUMN imageStyle TEXT');
      await db.execute('ALTER TABLE $tableName ADD COLUMN hasBeenRegenerated INTEGER DEFAULT 0');
    }
  }

  static Future<int> insertDiary(DiaryEntry diary) async {
    final db = await database;
    return await db.insert(tableName, diary.toMap());
  }

  static Future<List<DiaryEntry>> getAllDiaries() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      orderBy: 'createdAt DESC',
    );

    return List.generate(maps.length, (i) {
      return DiaryEntry.fromMap(maps[i]);
    });
  }

  static Future<DiaryEntry?> getDiaryById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
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
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
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
}
