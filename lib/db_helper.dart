import "dart:io";
import "package:path_provider/path_provider.dart";
import "package:sqflite/sqflite.dart";
import "package:path/path.dart";

class DatabaseHelper {
  static Database? _database;
  static const String _tableName = "members";

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await initDB();
    return _database!;
  }

  Future<Database> initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "members.db");

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
          "CREATE TABLE $_tableName (id INTEGER PRIMARY KEY, name TEXT, path TEXT)",
        );
      },
    );
  }

  Future<int> insertImage(String path) async {
    final db = await database;
    return await db.insert(_tableName, {"path": path});
  }

  Future<List<Map<String, dynamic>>> getImages() async {
    final db = await database;
    return await db.query(_tableName);
  }

  Future<String?> getImageName(int id) async {
    final db = await database;
    final result = await db.query(_tableName, where: "id = ?", whereArgs: [id]);
    return result.isNotEmpty ? result.first["name"].toString() : null;
  }

  Future<String?> getImageById(int id) async {
    final db = await database;
    final result = await db.query(_tableName, where: "id = ?", whereArgs: [id]);
    return result.isNotEmpty ? result.first["path"] as String : null;
  }
}
