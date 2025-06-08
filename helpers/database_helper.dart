// // File: helpers/database_helper.dart
// import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';
// import '../models/soal_model.dart';
// import '../models/materi_model.dart';
// import '../models/kuis_model.dart';

// class DatabaseHelper {
//   static final DatabaseHelper _instance = DatabaseHelper._internal();
//   static Database? _database;

//   DatabaseHelper._internal();

//   factory DatabaseHelper() => _instance;

//   Future<Database> get database async {
//     if (_database != null) return _database!;
//     _database = await _initDatabase();
//     return _database!;
//   }

//   Future<Database> _initDatabase() async {
//     String path = join(await getDatabasesPath(), 'andromeda.db');
//     return await openDatabase(
//       path,
//       version: 1,
//       onCreate: _onCreate,
//     );
//   }

//   Future<void> _onCreate(Database db, int version) async {
//     // Tabel Materi
//     await db.execute('''
//       CREATE TABLE materi(
//         id TEXT PRIMARY KEY,
//         title TEXT NOT NULL,
//         description TEXT NOT NULL,
//         date TEXT NOT NULL,
//         gambar TEXT,
//         created_at TEXT,
//         updated_at TEXT
//       )
//     ''');

//     // Tabel Soal
//     await db.execute('''
//       CREATE TABLE soal(
//         id TEXT PRIMARY KEY,
//         pertanyaan TEXT NOT NULL,
//         opsiA TEXT NOT NULL,
//         opsiB TEXT NOT NULL,
//         opsiC TEXT NOT NULL,
//         opsiD TEXT NOT NULL,
//         jawabanBenar TEXT NOT NULL,
//         jenisKuis TEXT NOT NULL,
//         gambar TEXT,
//         createdAt TEXT NOT NULL,
//         created_at TEXT,
//         updated_at TEXT
//       )
//     ''');

//     // Tabel Kuis
//     await db.execute('''
//       CREATE TABLE kuis(
//         id TEXT PRIMARY KEY,
//         title TEXT NOT NULL,
//         jumlahSoal INTEGER DEFAULT 0,
//         tanggalDeadline TEXT NOT NULL,
//         createdAt TEXT NOT NULL,
//         gambar TEXT,
//         created_at TEXT,
//         updated_at TEXT
//       )
//     ''');

//     // Tabel Users
//     await db.execute('''
//       CREATE TABLE users(
//         id TEXT PRIMARY KEY,
//         username TEXT UNIQUE NOT NULL,
//         password TEXT NOT NULL,
//         name TEXT NOT NULL,
//         role TEXT DEFAULT 'user',
//         created_at TEXT,
//         updated_at TEXT
//       )
//     ''');

//     // Tabel User Answers (untuk menyimpan jawaban user)
//     await db.execute('''
//       CREATE TABLE user_answers(
//         id TEXT PRIMARY KEY,
//         user_id TEXT NOT NULL,
//         soal_id TEXT NOT NULL,
//         kuis_id TEXT,
//         jawaban TEXT NOT NULL,
//         is_correct INTEGER DEFAULT 0,
//         answered_at TEXT NOT NULL,
//         FOREIGN KEY (user_id) REFERENCES users (id),
//         FOREIGN KEY (soal_id) REFERENCES soal (id),
//         FOREIGN KEY (kuis_id) REFERENCES kuis (id)
//       )
//     ''');
//   }

//   // ==================== SOAL OPERATIONS ====================
  
//   Future<int> insertSoal(SoalModel soal) async {
//     final db = await database;
//     Map<String, dynamic> soalMap = soal.toMap();
//     soalMap['created_at'] = DateTime.now().toIso8601String();
//     soalMap['updated_at'] = DateTime.now().toIso8601String();
    
//     return await db.insert('soal', soalMap);
//   }

//   Future<List<SoalModel>> getAllSoal() async {
//     final db = await database;
//     final List<Map<String, dynamic>> maps = await db.query(
//       'soal',
//       orderBy: 'created_at DESC',
//     );

//     return List.generate(maps.length, (i) {
//       return SoalModel.fromMap(maps[i]);
//     });
//   }

//   Future<List<SoalModel>> getSoalByJenisKuis(String jenisKuis) async {
//     final db = await database;
//     final List<Map<String, dynamic>> maps = await db.query(
//       'soal',
//       where: 'jenisKuis = ?',
//       whereArgs: [jenisKuis],
//       orderBy: 'created_at DESC',
//     );

//     return List.generate(maps.length, (i) {
//       return SoalModel.fromMap(maps[i]);
//     });
//   }

//   Future<SoalModel?> getSoalById(String id) async {
//     final db = await database;
//     final List<Map<String, dynamic>> maps = await db.query(
//       'soal',
//       where: 'id = ?',
//       whereArgs: [id],
//     );

//     if (maps.isNotEmpty) {
//       return SoalModel.fromMap(maps.first);
//     }
//     return null;
//   }

//   Future<int> updateSoal(SoalModel soal) async {
//     final db = await database;
//     Map<String, dynamic> soalMap = soal.toMap();
//     soalMap['updated_at'] = DateTime.now().toIso8601String();
    
//     return await db.update(
//       'soal',
//       soalMap,
//       where: 'id = ?',
//       whereArgs: [soal.id],
//     );
//   }

//   Future<int> deleteSoal(String id) async {
//     final db = await database;
//     return await db.delete(
//       'soal',
//       where: 'id = ?',
//       whereArgs: [id],
//     );
//   }

//   // ==================== MATERI OPERATIONS ====================
  
//   Future<int> insertMateri(MateriModel materi) async {
//     final db = await database;
//     Map<String, dynamic> materiMap = materi.toMap();
//     materiMap['created_at'] = DateTime.now().toIso8601String();
//     materiMap['updated_at'] = DateTime.now().toIso8601String();
    
//     return await db.insert('materi', materiMap);
//   }

//   Future<List<MateriModel>> getAllMateri() async {
//     final db = await database;
//     final List<Map<String, dynamic>> maps = await db.query(
//       'materi',
//       orderBy: 'created_at DESC',
//     );

//     return List.generate(maps.length, (i) {
//       return MateriModel.fromMap(maps[i]);
//     });
//   }

//   Future<MateriModel?> getMateriById(String id) async {
//     final db = await database;
//     final List<Map<String, dynamic>> maps = await db.query(
//       'materi',
//       where: 'id = ?',
//       whereArgs: [id],
//     );

//     if (maps.isNotEmpty) {
//       return MateriModel.fromMap(maps.first);
//     }
//     return null;
//   }

//   Future<int> updateMateri(MateriModel materi) async {
//     final db = await database;
//     Map<String, dynamic> materiMap = materi.toMap();
//     materiMap['updated_at'] = DateTime.now().toIso8601String();
    
//     return await db.update(
//       'materi',
//       materiMap,
//       where: 'id = ?',
//       whereArgs: [materi.id],
//     );
//   }

//   Future<int> deleteMateri(String id) async {
//     final db = await database;
//     return await db.delete(
//       'materi',
//       where: 'id = ?',
//       whereArgs: [id],
//     );
//   }

//   // ==================== KUIS OPERATIONS ====================
  
//   Future<int> insertKuis(KuisModel kuis) async {
//     final db = await database;
//     Map<String, dynamic> kuisMap = {
//       'id': kuis.id,
//       'title': kuis.title,
//       'jumlahSoal': kuis.jumlahSoal,
//       'tanggalDeadline': kuis.tanggalDeadline,
//       'createdAt': kuis.createdAt,
//       'created_at': DateTime.now().toIso8601String(),
//       'updated_at': DateTime.now().toIso8601String(),
//     };
    
//     return await db.insert('kuis', kuisMap);
//   }

//   Future<List<KuisModel>> getAllKuis() async {
//     final db = await database;
//     final List<Map<String, dynamic>> maps = await db.query(
//       'kuis',
//       orderBy: 'created_at DESC',
//     );

//     return List.generate(maps.length, (i) {
//       return KuisModel(
//         id: maps[i]['id'],
//         title: maps[i]['title'],
//         jumlahSoal: maps[i]['jumlahSoal'],
//         tanggalDeadline: maps[i]['tanggalDeadline'],
//         createdAt: maps[i]['createdAt'],
//       );
//     });
//   }

//   Future<int> updateKuis(KuisModel kuis) async {
//     final db = await database;
//     Map<String, dynamic> kuisMap = {
//       'id': kuis.id,
//       'title': kuis.title,
//       'jumlahSoal': kuis.jumlahSoal,
//       'tanggalDeadline': kuis.tanggalDeadline,
//       'createdAt': kuis.createdAt,
//       'updated_at': DateTime.now().toIso8601String(),
//     };
    
//     return await db.update(
//       'kuis',
//       kuisMap,
//       where: 'id = ?',
//       whereArgs: [kuis.id],
//     );
//   }

//   Future<int> deleteKuis(String id) async {
//     final db = await database;
//     return await db.delete(
//       'kuis',
//       where: 'id = ?',
//       whereArgs