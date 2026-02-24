import 'package:sqflite/sqflite.dart';
 import 'package:path/path.dart';
 import '../models/baby.dart';
 import '../models/growth_record.dart';
 import '../models/feed_record.dart';

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
       version: 1,
       onCreate: _createDB,
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
   }

   // Baby operations
   Future<Baby> createBaby(Baby baby) async {
     final db = await database;
     final id = await db.insert('babies', baby.toMap());
     return baby.copyWith(id: id);
   }

   Future<Baby?> getBaby(int id) async {
     final db = await database;
     final maps = await db.query(
       'babies',
       where: 'id = ?',
       whereArgs: [id],
     );
     if (maps.isNotEmpty) {
       return Baby.fromMap(maps.first);
     }
     return null;
   }

   Future<List<Baby>> getAllBabies() async {
     final db = await database;
     final maps = await db.query('babies');
     return maps.map((map) => Baby.fromMap(map)).toList();
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

   Future close() async {
     final db = await database;
     db.close();
   }
 }