import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:reminder_application/Models/capsule_model.dart';

class DBHelper {
  static Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await initDb();
    return _db!;
  }

  initDb() async {
    String path = join(await getDatabasesPath(), "time_capsule.db");
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  void _onCreate(Database db, int version) async {

    await db.execute('''
      CREATE TABLE capsules(
        id TEXT PRIMARY KEY, 
        userId TEXT, 
        title TEXT, 
        description TEXT, 
        openDate TEXT, 
        tag TEXT, 
        memoryCount INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE search_history(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        query TEXT UNIQUE,
        timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    ''');
  }

  Future<List<CapsuleModel>> getUserCapsules(String userId) async {
    final dbClient = await db;
    final List<Map<String, dynamic>> maps = await dbClient.query(
      'capsules',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'openDate ASC',
    );

    return List.generate(maps.length, (i) => CapsuleModel.fromMap(maps[i]));
  }


  Future<void> saveSearchQuery(String query) async {
    final dbClient = await db;
    await dbClient.insert(
        'search_history',
        {'query': query},
        conflictAlgorithm: ConflictAlgorithm.replace
    );
  }

  Future<List<String>> getRecentSearches() async {
    final dbClient = await db;
    final List<Map<String, dynamic>> maps = await dbClient.query(
        'search_history',
        orderBy: 'timestamp DESC',
        limit: 5
    );
    return List.generate(maps.length, (i) => maps[i]['query']);
  }
}