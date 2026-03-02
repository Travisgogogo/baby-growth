import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../constants/app_theme.dart';
import '../models/baby.dart';
import '../models/growth_record.dart';
import '../models/feed_record.dart';
import '../models/sleep_record.dart';
import '../models/diaper_record.dart';
import '../models/milestone.dart';
import '../constants/milestone_data.dart';
import '../models/photo.dart';
import '../models/illness_record.dart';
import '../models/vaccine_record.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('baby_growth.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 4,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE babies (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        birthDate TEXT NOT NULL,
        gender TEXT NOT NULL,
        birthWeight REAL,
        birthHeight REAL,
        birthHeadCircumference REAL,
        avatarPath TEXT,
        birthTime TEXT,
        birthPlace TEXT,
        gestationalAge TEXT,
        deliveryMode TEXT,
        bloodType TEXT,
        birthPhotoPath TEXT,
        handprintPath TEXT,
        footprintPath TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE growth_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        babyId INTEGER NOT NULL,
        date TEXT NOT NULL,
        weight REAL,
        height REAL,
        headCircumference REAL,
        note TEXT,
        FOREIGN KEY (babyId) REFERENCES babies (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE feed_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        babyId INTEGER NOT NULL,
        time TEXT NOT NULL,
        type TEXT NOT NULL,
        amount REAL,
        duration INTEGER,
        note TEXT,
        FOREIGN KEY (babyId) REFERENCES babies (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE sleep_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        babyId INTEGER NOT NULL,
        startTime TEXT NOT NULL,
        endTime TEXT,
        quality TEXT,
        note TEXT,
        FOREIGN KEY (babyId) REFERENCES babies (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE diaper_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        babyId INTEGER NOT NULL,
        time TEXT NOT NULL,
        type TEXT NOT NULL,
        condition TEXT,
        note TEXT,
        FOREIGN KEY (babyId) REFERENCES babies (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE milestone_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        babyId INTEGER NOT NULL,
        milestoneId TEXT NOT NULL,
        completedDate TEXT NOT NULL,
        photoPath TEXT,
        note TEXT,
        FOREIGN KEY (babyId) REFERENCES babies (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE photos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        babyId INTEGER NOT NULL,
        path TEXT NOT NULL,
        takenAt TEXT NOT NULL,
        description TEXT,
        FOREIGN KEY (babyId) REFERENCES babies (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE illness_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        babyId INTEGER NOT NULL,
        startTime TEXT NOT NULL,
        endTime TEXT,
        symptom TEXT NOT NULL,
        temperature REAL,
        description TEXT,
        treatment TEXT,
        FOREIGN KEY (babyId) REFERENCES babies (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE vaccine_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        babyId INTEGER NOT NULL,
        vaccineId TEXT NOT NULL,
        name TEXT NOT NULL,
        scheduledTime TEXT NOT NULL,
        completed INTEGER DEFAULT 0,
        completedDate TEXT,
        FOREIGN KEY (babyId) REFERENCES babies (id)
      )
    ''');
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE sleep_records (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          babyId INTEGER NOT NULL,
          startTime TEXT NOT NULL,
          endTime TEXT,
          quality TEXT,
          note TEXT,
          FOREIGN KEY (babyId) REFERENCES babies (id)
        )
      ''');

      await db.execute('''
        CREATE TABLE diaper_records (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          babyId INTEGER NOT NULL,
          time TEXT NOT NULL,
          type TEXT NOT NULL,
          condition TEXT,
          note TEXT,
          FOREIGN KEY (babyId) REFERENCES babies (id)
        )
      ''');

      await db.execute('''
        CREATE TABLE milestone_records (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          babyId INTEGER NOT NULL,
          milestoneId TEXT NOT NULL,
          completedDate TEXT NOT NULL,
          photoPath TEXT,
          note TEXT,
          FOREIGN KEY (babyId) REFERENCES babies (id)
        )
      ''');

      await db.execute('''
        CREATE TABLE photos (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          babyId INTEGER NOT NULL,
          path TEXT NOT NULL,
          takenAt TEXT NOT NULL,
          description TEXT,
          FOREIGN KEY (babyId) REFERENCES babies (id)
        )
      ''');

      await db.execute('''
        CREATE TABLE illness_records (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          babyId INTEGER NOT NULL,
          startTime TEXT NOT NULL,
          endTime TEXT,
          symptom TEXT NOT NULL,
          temperature REAL,
          description TEXT,
          treatment TEXT,
          FOREIGN KEY (babyId) REFERENCES babies (id)
        )
      ''');
    }
    
    if (oldVersion < 3) {
      // 添加宝宝头像字段
      await db.execute('ALTER TABLE babies ADD COLUMN avatarPath TEXT');
    }
    
    if (oldVersion < 4) {
      // 添加宝宝详细信息字段
      await db.execute('ALTER TABLE babies ADD COLUMN birthTime TEXT');
      await db.execute('ALTER TABLE babies ADD COLUMN birthPlace TEXT');
      await db.execute('ALTER TABLE babies ADD COLUMN gestationalAge TEXT');
      await db.execute('ALTER TABLE babies ADD COLUMN deliveryMode TEXT');
      await db.execute('ALTER TABLE babies ADD COLUMN bloodType TEXT');
      await db.execute('ALTER TABLE babies ADD COLUMN birthPhotoPath TEXT');
      await db.execute('ALTER TABLE babies ADD COLUMN handprintPath TEXT');
      await db.execute('ALTER TABLE babies ADD COLUMN footprintPath TEXT');
    }
  }

  // Baby operations
  Future<Baby?> createBaby(Baby baby) async {
    try {
      final db = await database;
      final id = await db.insert('babies', baby.toMap());
      return baby.copyWith(id: id);
    } catch (e) {
      debugPrint('创建宝宝记录失败: $e');
      return null;
    }
  }

  Future<Baby?> getBaby(int id) async {
    try {
      final db = await database;
      final maps = await db.query('babies', where: 'id = ?', whereArgs: [id]);
      if (maps.isNotEmpty) return Baby.fromMap(maps.first);
      return null;
    } catch (e) {
      debugPrint('获取宝宝记录失败: $e');
      return null;
    }
  }

  Future<List<Baby>> getAllBabies() async {
    try {
      final db = await database;
      final maps = await db.query('babies');
      return maps.map((map) => Baby.fromMap(map)).toList();
    } catch (e) {
      debugPrint('获取所有宝宝记录失败: $e');
      return [];
    }
  }

  Future<bool> updateBaby(Baby baby) async {
    try {
      final db = await database;
      await db.update(
        'babies',
        baby.toMap(),
        where: 'id = ?',
        whereArgs: [baby.id],
      );
      return true;
    } catch (e) {
      debugPrint('更新宝宝记录失败: $e');
      return false;
    }
  }

  // Growth record operations
  Future<GrowthRecord?> createGrowthRecord(GrowthRecord record) async {
    try {
      final db = await database;
      final id = await db.insert('growth_records', record.toMap());
      return record.copyWith(id: id);
    } catch (e) {
      debugPrint('创建生长记录失败: $e');
      return null;
    }
  }

  Future<List<GrowthRecord>> getGrowthRecords(int babyId) async {
    try {
      final db = await database;
      final maps = await db.query(
        'growth_records',
        where: 'babyId = ?',
        whereArgs: [babyId],
        orderBy: 'date DESC',
      );
      return maps.map((map) => GrowthRecord.fromMap(map)).toList();
    } catch (e) {
      debugPrint('获取生长记录失败: $e');
      return [];
    }
  }

  /// 按日期范围获取生长记录
  Future<List<GrowthRecord>> getGrowthRecordsByDateRange(
    int babyId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final db = await database;
      final maps = await db.query(
        'growth_records',
        where: 'babyId = ? AND date >= ? AND date <= ?',
        whereArgs: [
          babyId,
          startDate.toIso8601String(),
          endDate.toIso8601String(),
        ],
        orderBy: 'date ASC',
      );
      return maps.map((map) => GrowthRecord.fromMap(map)).toList();
    } catch (e) {
      debugPrint('按日期范围获取生长记录失败: $e');
      return [];
    }
  }

  /// 获取指定月龄范围内的生长记录
  Future<List<GrowthRecord>> getGrowthRecordsByAgeRange(
    int babyId,
    DateTime birthDate,
    int minMonths,
    int maxMonths,
  ) async {
    final startDate = birthDate.add(Duration(days: minMonths * 30));
    final endDate = birthDate.add(Duration(days: maxMonths * 30));
    return getGrowthRecordsByDateRange(babyId, startDate, endDate);
  }

  Future<bool> deleteGrowthRecord(int id) async {
    try {
      final db = await database;
      await db.delete(
        'growth_records',
        where: 'id = ?',
        whereArgs: [id],
      );
      return true;
    } catch (e) {
      debugPrint('删除生长记录失败: $e');
      return false;
    }
  }

  // Feed record operations
  Future<FeedRecord?> createFeedRecord(FeedRecord record) async {
    try {
      final db = await database;
      final id = await db.insert('feed_records', record.toMap());
      return record.copyWith(id: id);
    } catch (e) {
      debugPrint('创建喂养记录失败: $e');
      return null;
    }
  }

  Future<List<FeedRecord>> getFeedRecords(int babyId, {int limit = AppConstants.defaultQueryLimit}) async {
    try {
      final db = await database;
      final maps = await db.query(
        'feed_records',
        where: 'babyId = ?',
        whereArgs: [babyId],
        orderBy: 'time DESC',
        limit: limit,
      );
      return maps.map((map) => FeedRecord.fromMap(map)).toList();
    } catch (e) {
      debugPrint('获取喂养记录失败: $e');
      return [];
    }
  }

  Future<bool> updateFeedRecord(FeedRecord record) async {
    try {
      final db = await database;
      await db.update(
        'feed_records',
        record.toMap(),
        where: 'id = ?',
        whereArgs: [record.id],
      );
      return true;
    } catch (e) {
      debugPrint('更新喂养记录失败: $e');
      return false;
    }
  }

  Future<bool> deleteFeedRecord(int id) async {
    try {
      final db = await database;
      await db.delete(
        'feed_records',
        where: 'id = ?',
        whereArgs: [id],
      );
      return true;
    } catch (e) {
      debugPrint('删除喂养记录失败: $e');
      return false;
    }
  }

  // Sleep record operations
  Future<SleepRecord?> createSleepRecord(SleepRecord record) async {
    try {
      final db = await database;
      final id = await db.insert('sleep_records', record.toMap());
      return record.copyWith(id: id);
    } catch (e) {
      debugPrint('创建睡眠记录失败: $e');
      return null;
    }
  }

  Future<bool> updateSleepRecord(SleepRecord record) async {
    try {
      final db = await database;
      await db.update(
        'sleep_records',
        record.toMap(),
        where: 'id = ?',
        whereArgs: [record.id],
      );
      return true;
    } catch (e) {
      debugPrint('更新睡眠记录失败: $e');
      return false;
    }
  }

  Future<List<SleepRecord>> getSleepRecords(int babyId) async {
    try {
      final db = await database;
      final maps = await db.query(
        'sleep_records',
        where: 'babyId = ?',
        whereArgs: [babyId],
        orderBy: 'startTime DESC',
      );
      return maps.map((map) => SleepRecord.fromMap(map)).toList();
    } catch (e) {
      debugPrint('获取睡眠记录失败: $e');
      return [];
    }
  }

  Future<bool> deleteSleepRecord(int id) async {
    try {
      final db = await database;
      await db.delete(
        'sleep_records',
        where: 'id = ?',
        whereArgs: [id],
      );
      return true;
    } catch (e) {
      debugPrint('删除睡眠记录失败: $e');
      return false;
    }
  }

  // Diaper record operations
  Future<DiaperRecord?> createDiaperRecord(DiaperRecord record) async {
    try {
      final db = await database;
      final id = await db.insert('diaper_records', record.toMap());
      return record.copyWith(id: id);
    } catch (e) {
      debugPrint('创建换尿布记录失败: $e');
      return null;
    }
  }

  Future<bool> updateDiaperRecord(DiaperRecord record) async {
    try {
      final db = await database;
      await db.update(
        'diaper_records',
        record.toMap(),
        where: 'id = ?',
        whereArgs: [record.id],
      );
      return true;
    } catch (e) {
      debugPrint('更新换尿布记录失败: $e');
      return false;
    }
  }

  Future<List<DiaperRecord>> getDiaperRecords(int babyId) async {
    try {
      final db = await database;
      final maps = await db.query(
        'diaper_records',
        where: 'babyId = ?',
        whereArgs: [babyId],
        orderBy: 'time DESC',
      );
      return maps.map((map) => DiaperRecord.fromMap(map)).toList();
    } catch (e) {
      debugPrint('获取换尿布记录失败: $e');
      return [];
    }
  }

  Future<bool> deleteDiaperRecord(int id) async {
    try {
      final db = await database;
      await db.delete(
        'diaper_records',
        where: 'id = ?',
        whereArgs: [id],
      );
      return true;
    } catch (e) {
      debugPrint('删除换尿布记录失败: $e');
      return false;
    }
  }

  // Milestone record operations
  Future<MilestoneRecord?> createMilestoneRecord(MilestoneRecord record) async {
    try {
      final db = await database;
      final id = await db.insert('milestone_records', record.toMap());
      return record.copyWith(id: id);
    } catch (e) {
      debugPrint('创建里程碑记录失败: $e');
      return null;
    }
  }

  Future<List<MilestoneRecord>> getMilestoneRecords(int babyId) async {
    try {
      final db = await database;
      final maps = await db.query(
        'milestone_records',
        where: 'babyId = ?',
        whereArgs: [babyId],
        orderBy: 'completedDate DESC',
      );
      return maps.map((map) => MilestoneRecord.fromMap(map)).toList();
    } catch (e) {
      debugPrint('获取里程碑记录失败: $e');
      return [];
    }
  }

  Future<bool> deleteMilestoneRecord(int babyId, String milestoneId) async {
    try {
      final db = await database;
      await db.delete(
        'milestone_records',
        where: 'babyId = ? AND milestoneId = ?',
        whereArgs: [babyId, milestoneId],
      );
      return true;
    } catch (e) {
      debugPrint('删除里程碑记录失败: $e');
      return false;
    }
  }

  /// 根据ID删除里程碑记录
  Future<bool> deleteMilestoneRecordById(int id) async {
    try {
      final db = await database;
      await db.delete(
        'milestone_records',
        where: 'id = ?',
        whereArgs: [id],
      );
      return true;
    } catch (e) {
      debugPrint('删除里程碑记录失败: $e');
      return false;
    }
  }

  /// 更新里程碑记录
  Future<bool> updateMilestoneRecord(MilestoneRecord record) async {
    try {
      final db = await database;
      await db.update(
        'milestone_records',
        record.toMap(),
        where: 'id = ?',
        whereArgs: [record.id],
      );
      return true;
    } catch (e) {
      debugPrint('更新里程碑记录失败: $e');
      return false;
    }
  }

  /// 获取指定里程碑ID的记录
  Future<MilestoneRecord?> getMilestoneRecordByMilestoneId(int babyId, String milestoneId) async {
    try {
      final db = await database;
      final maps = await db.query(
        'milestone_records',
        where: 'babyId = ? AND milestoneId = ?',
        whereArgs: [babyId, milestoneId],
      );
      if (maps.isNotEmpty) {
        return MilestoneRecord.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      debugPrint('获取里程碑记录失败: $e');
      return null;
    }
  }

  /// 获取指定分类的已完成里程碑记录
  Future<List<MilestoneRecord>> getMilestoneRecordsByCategory(
    int babyId,
    MilestoneCategory category,
  ) async {
    try {
      final db = await database;
      // 获取所有已完成记录
      final allRecords = await getMilestoneRecords(babyId);
      // 过滤指定分类的记录
      return allRecords.where((record) {
        final milestone = MilestoneData.getById(record.milestoneId);
        return milestone?.category == category;
      }).toList();
    } catch (e) {
      debugPrint('获取分类里程碑记录失败: $e');
      return [];
    }
  }

  /// 获取里程碑统计信息
  Future<MilestoneStats> getMilestoneStats(
    int babyId,
    int currentMonth,
  ) async {
    try {
      final completedRecords = await getMilestoneRecords(babyId);
      final completedIds = completedRecords.map((r) => r.milestoneId).toSet();
      
      int completed = 0;
      int inProgress = 0;
      int pending = 0;

      for (final milestone in MilestoneData.allMilestones) {
        if (completedIds.contains(milestone.id)) {
          completed++;
        } else {
          final status = milestone.getProgressStatus(currentMonth);
          if (status == 1) {
            inProgress++;
          } else if (status == 0) {
            pending++;
          } else {
            // 已过时间范围但未完成
            inProgress++;
          }
        }
      }

      return MilestoneStats(
        totalCount: MilestoneData.totalCount,
        completedCount: completed,
        inProgressCount: inProgress,
        pendingCount: pending,
      );
    } catch (e) {
      debugPrint('获取里程碑统计失败: $e');
      return MilestoneStats(
        totalCount: MilestoneData.totalCount,
        completedCount: 0,
        inProgressCount: 0,
        pendingCount: MilestoneData.totalCount,
      );
    }
  }

  /// 检查指定里程碑是否已完成
  Future<bool> isMilestoneCompleted(int babyId, String milestoneId) async {
    try {
      final record = await getMilestoneRecordByMilestoneId(babyId, milestoneId);
      return record != null;
    } catch (e) {
      debugPrint('检查里程碑完成状态失败: $e');
      return false;
    }
  }

  // Photo operations
  Future<Photo?> createPhoto(Photo photo) async {
    try {
      final db = await database;
      final id = await db.insert('photos', photo.toMap());
      return photo.copyWith(id: id);
    } catch (e) {
      debugPrint('创建照片记录失败: $e');
      return null;
    }
  }

  Future<List<Photo>> getPhotos(int babyId) async {
    try {
      final db = await database;
      final maps = await db.query(
        'photos',
        where: 'babyId = ?',
        whereArgs: [babyId],
        orderBy: 'takenAt DESC',
      );
      return maps.map((map) => Photo.fromMap(map)).toList();
    } catch (e) {
      debugPrint('获取照片记录失败: $e');
      return [];
    }
  }

  // Update operations
  Future<bool> updateGrowthRecord(GrowthRecord record) async {
    try {
      final db = await database;
      await db.update(
        'growth_records',
        record.toMap(),
        where: 'id = ?',
        whereArgs: [record.id],
      );
      return true;
    } catch (e) {
      debugPrint('更新生长记录失败: $e');
      return false;
    }
  }

  // Illness record operations
  Future<IllnessRecord?> createIllnessRecord(IllnessRecord record) async {
    try {
      final db = await database;
      final id = await db.insert('illness_records', record.toMap());
      return record.copyWith(id: id);
    } catch (e) {
      debugPrint('创建疾病记录失败: $e');
      return null;
    }
  }

  Future<List<IllnessRecord>> getIllnessRecords(int babyId) async {
    try {
      final db = await database;
      final maps = await db.query(
        'illness_records',
        where: 'babyId = ?',
        whereArgs: [babyId],
        orderBy: 'startTime DESC',
      );
      return maps.map((map) => IllnessRecord.fromMap(map)).toList();
    } catch (e) {
      debugPrint('获取疾病记录失败: $e');
      return [];
    }
  }

  Future<bool> updateIllnessRecord(IllnessRecord record) async {
    try {
      final db = await database;
      await db.update(
        'illness_records',
        record.toMap(),
        where: 'id = ?',
        whereArgs: [record.id],
      );
      return true;
    } catch (e) {
      debugPrint('更新疾病记录失败: $e');
      return false;
    }
  }

  Future<bool> deleteIllnessRecord(int id) async {
    try {
      final db = await database;
      await db.delete('illness_records', where: 'id = ?', whereArgs: [id]);
      return true;
    } catch (e) {
      debugPrint('删除疾病记录失败: $e');
      return false;
    }
  }

  // Vaccine record operations
  Future<VaccineRecord?> createVaccineRecord(VaccineRecord record) async {
    try {
      final db = await database;
      final id = await db.insert('vaccine_records', record.toMap());
      return record.copyWith(id: id);
    } catch (e) {
      debugPrint('创建疫苗记录失败: $e');
      return null;
    }
  }

  Future<List<VaccineRecord>> getVaccineRecords(int babyId) async {
    try {
      final db = await database;
      final maps = await db.query(
        'vaccine_records',
        where: 'babyId = ?',
        whereArgs: [babyId],
        orderBy: 'scheduledTime ASC',
      );
      return maps.map((map) => VaccineRecord.fromMap(map)).toList();
    } catch (e) {
      debugPrint('获取疫苗记录失败: $e');
      return [];
    }
  }

  Future<bool> updateVaccineRecord(VaccineRecord record) async {
    try {
      final db = await database;
      await db.update(
        'vaccine_records',
        record.toMap(),
        where: 'id = ?',
        whereArgs: [record.id],
      );
      return true;
    } catch (e) {
      debugPrint('更新疫苗记录失败: $e');
      return false;
    }
  }

  Future<bool> deleteVaccineRecord(int id) async {
    try {
      final db = await database;
      await db.delete(
        'vaccine_records',
        where: 'id = ?',
        whereArgs: [id],
      );
      return true;
    } catch (e) {
      debugPrint('删除疫苗记录失败: $e');
      return false;
    }
  }

  Future<bool> close() async {
    try {
      if (_database != null) {
        await _database!.close();
        _database = null;  // 关键：重置为 null，下次会重新打开
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('关闭数据库失败: $e');
      return false;
    }
  }
}
