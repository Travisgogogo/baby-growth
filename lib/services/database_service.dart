import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/baby.dart';
import '../models/growth_record.dart';
import '../models/feed_record.dart';
import '../models/sleep_record.dart';
import '../models/diaper_record.dart';
import '../models/milestone_record.dart';
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
      version: 2,
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
        birthHeadCircumference REAL
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
  }

  // Baby operations
  Future<Baby> createBaby(Baby baby) async {
    final db = await database;
    final id = await db.insert('babies', baby.toMap());
    return baby.copyWith(id: id);
  }

  Future<Baby?> getBaby(int id) async {
    final db = await database;
    final maps = await db.query('babies', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) return Baby.fromMap(maps.first);
    return null;
  }

  Future<List<Baby>> getAllBabies() async {
    final db = await database;
    final maps = await db.query('babies');
    return maps.map((map) => Baby.fromMap(map)).toList();
  }

  Future<void> updateBaby(Baby baby) async {
    final db = await database;
    await db.update(
      'babies',
      baby.toMap(),
      where: 'id = ?',
      whereArgs: [baby.id],
    );
  }

  // Growth record operations
  Future<GrowthRecord> createGrowthRecord(GrowthRecord record) async {
    final db = await database;
    final id = await db.insert('growth_records', record.toMap());
    return record.copyWith(id: id);
  }

  Future<List<GrowthRecord>> getGrowthRecords(int babyId) async {
    final db = await database;
    final maps = await db.query(
      'growth_records',
      where: 'babyId = ?',
      whereArgs: [babyId],
      orderBy: 'date DESC',
    );
    return maps.map((map) => GrowthRecord.fromMap(map)).toList();
  }

  // Feed record operations
  Future<FeedRecord> createFeedRecord(FeedRecord record) async {
    final db = await database;
    final id = await db.insert('feed_records', record.toMap());
    return record.copyWith(id: id);
  }

  Future<List<FeedRecord>> getFeedRecords(int babyId, {int limit = 10}) async {
    final db = await database;
    final maps = await db.query(
      'feed_records',
      where: 'babyId = ?',
      whereArgs: [babyId],
      orderBy: 'time DESC',
      limit: limit,
    );
    return maps.map((map) => FeedRecord.fromMap(map)).toList();
  }

  // Sleep record operations
  Future<SleepRecord> createSleepRecord(SleepRecord record) async {
    final db = await database;
    final id = await db.insert('sleep_records', record.toMap());
    return record.copyWith(id: id);
  }

  Future<List<SleepRecord>> getSleepRecords(int babyId) async {
    final db = await database;
    final maps = await db.query(
      'sleep_records',
      where: 'babyId = ?',
      whereArgs: [babyId],
      orderBy: 'startTime DESC',
    );
    return maps.map((map) => SleepRecord.fromMap(map)).toList();
  }

  // Diaper record operations
  Future<DiaperRecord> createDiaperRecord(DiaperRecord record) async {
    final db = await database;
    final id = await db.insert('diaper_records', record.toMap());
    return record.copyWith(id: id);
  }

  Future<List<DiaperRecord>> getDiaperRecords(int babyId) async {
    final db = await database;
    final maps = await db.query(
      'diaper_records',
      where: 'babyId = ?',
      whereArgs: [babyId],
      orderBy: 'time DESC',
    );
    return maps.map((map) => DiaperRecord.fromMap(map)).toList();
  }

  // Milestone record operations
  Future<MilestoneRecord> createMilestoneRecord(MilestoneRecord record) async {
    final db = await database;
    final id = await db.insert('milestone_records', record.toMap());
    return record.copyWith(id: id);
  }

  Future<List<MilestoneRecord>> getMilestoneRecords(int babyId) async {
    final db = await database;
    final maps = await db.query(
      'milestone_records',
      where: 'babyId = ?',
      whereArgs: [babyId],
      orderBy: 'completedDate DESC',
    );
    return maps.map((map) => MilestoneRecord.fromMap(map)).toList();
  }

  Future<void> deleteMilestoneRecord(int babyId, String milestoneId) async {
    final db = await database;
    await db.delete(
      'milestone_records',
      where: 'babyId = ? AND milestoneId = ?',
      whereArgs: [babyId, milestoneId],
    );
  }

  // Photo operations
  Future<Photo> createPhoto(Photo photo) async {
    final db = await database;
    final id = await db.insert('photos', photo.toMap());
    return photo.copyWith(id: id);
  }

  Future<List<Photo>> getPhotos(int babyId) async {
    final db = await database;
    final maps = await db.query(
      'photos',
      where: 'babyId = ?',
      whereArgs: [babyId],
      orderBy: 'takenAt DESC',
    );
    return maps.map((map) => Photo.fromMap(map)).toList();
  }

  // Delete operations
  Future<void> deleteFeedRecord(int id) async {
    final db = await database;
    await db.delete('feed_records', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteGrowthRecord(int id) async {
    final db = await database;
    await db.delete('growth_records', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteSleepRecord(int id) async {
    final db = await database;
    await db.delete('sleep_records', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteDiaperRecord(int id) async {
    final db = await database;
    await db.delete('diaper_records', where: 'id = ?', whereArgs: [id]);
  }

  // Update operations
  Future<void> updateFeedRecord(FeedRecord record) async {
    final db = await database;
    await db.update(
      'feed_records',
      record.toMap(),
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }

  Future<void> updateGrowthRecord(GrowthRecord record) async {
    final db = await database;
    await db.update(
      'growth_records',
      record.toMap(),
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }

  // Illness record operations
  Future<IllnessRecord> createIllnessRecord(IllnessRecord record) async {
    final db = await database;
    final id = await db.insert('illness_records', record.toMap());
    return record.copyWith(id: id);
  }

  Future<List<IllnessRecord>> getIllnessRecords(int babyId) async {
    final db = await database;
    final maps = await db.query(
      'illness_records',
      where: 'babyId = ?',
      whereArgs: [babyId],
      orderBy: 'startTime DESC',
    );
    return maps.map((map) => IllnessRecord.fromMap(map)).toList();
  }

  Future<void> updateIllnessRecord(IllnessRecord record) async {
    final db = await database;
    await db.update(
      'illness_records',
      record.toMap(),
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }

  Future<void> deleteIllnessRecord(int id) async {
    final db = await database;
    await db.delete('illness_records', where: 'id = ?', whereArgs: [id]);
  }

  // Vaccine record operations
  Future<VaccineRecord> createVaccineRecord(VaccineRecord record) async {
    final db = await database;
    final id = await db.insert('vaccine_records', record.toMap());
    return record.copyWith(id: id);
  }

  Future<List<VaccineRecord>> getVaccineRecords(int babyId) async {
    final db = await database;
    final maps = await db.query(
      'vaccine_records',
      where: 'babyId = ?',
      whereArgs: [babyId],
      orderBy: 'scheduledTime ASC',
    );
    return maps.map((map) => VaccineRecord.fromMap(map)).toList();
  }

  Future<void> updateVaccineRecord(VaccineRecord record) async {
    final db = await database;
    await db.update(
      'vaccine_records',
      record.toMap(),
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }

  Future close() async {
    final db = await database;
    db.close();
  }
}
