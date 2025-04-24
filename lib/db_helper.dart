import "dart:io";
import "dart:typed_data";
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
          "CREATE TABLE $_tableName (id INTEGER PRIMARY KEY, name TEXT, path TEXT, signature BLOB)",
        );
      },
    );
  }

  // Insert a new image into the database
  Future<int> insertImage(String path) async {
    final db = await database;
    return await db.insert(_tableName, {"path": path});
  }

  // Insert a new image with name into the database
  Future<int> updateImage(String id, String path) async {
    final db = await database;
    return await db.update(
      _tableName,
      {"path": path},
      where: "id = ?",
      whereArgs: [id],
    );
  }

  // get all images from the database
  Future<List<Map<String, dynamic>>> getImages() async {
    final db = await database;
    return await db.query(_tableName);
  }

  //get all images from the database with name
  Future<String?> getImageName(int id) async {
    final db = await database;
    final result = await db.query(_tableName, where: "id = ?", whereArgs: [id]);
    return result.isNotEmpty ? result.first["name"].toString() : null;
  }

  // get image path by id
  Future<String?> getImageById(int id) async {
    final db = await database;
    final result = await db.query(_tableName, where: "id = ?", whereArgs: [id]);
    return result.isNotEmpty ? result.first["path"] as String : null;
  }

  // insert signature image into the database
  Future<int> insertSignature(Uint8List bytes) async {
    final db = await database;
    return await db.insert(_tableName, {"signature": bytes});
  }

  Future<int> updateSignature(int id, Uint8List bytes) async {
    final db = await database;
    return await db.update(
      _tableName,
      {"signature": bytes},
      where: "id = ?",
      whereArgs: [id],
    );
  }

  // get signature image by id
  Future<Uint8List?> getSignatureById(int id) async {
    final db = await database;
    final result = await db.query(_tableName, where: "id = ?", whereArgs: [id]);
    return result.isNotEmpty ? result.first["signature"] as Uint8List : null;
  }
}
