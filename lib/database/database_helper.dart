import 'dart:async';
import 'dart:io' as io;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'clowder_instance.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = new DatabaseHelper.internal();

  factory DatabaseHelper() => _instance;

  static Database _db;

  Future<Database> get db async {
    if (_db != null) return _db;
    _db = await initDb();
    return _db;
  }

  DatabaseHelper.internal();

  initDb() async {
    io.Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "main.db");
    var theDb = await openDatabase(path, version: 1, onCreate: _onCreate);
    return theDb;
  }

  void _onCreate(Database db, int version) async {
    // When creating the db, create the table;
    await db.execute(
        "CREATE TABLE ClowderInstance(id INTEGER PRIMARY KEY, url TEXT, login_token TEXT)");
  }


  Future<int> saveClowderInstance(ClowderInstance instance) async {
    var dbClient = await db;
    int res = await dbClient.insert("ClowderInstance", instance.toMap());
    return res;
  }

  Future<List<ClowderInstance>> getClowderInstance() async {
    var dbClient = await db;
    List<Map> list = await dbClient.rawQuery('SELECT * FROM ClowderInstance');
    List<ClowderInstance> instances = new List();
    for (int i = 0; i < list.length; i++) {
      var instance =
      new ClowderInstance(list[i]["url"], list[i]["login_token"]);
      instance.setClowderInstanceId(list[i]["id"]);
      instances.add(instance);
    }
    print(instances.length);
    List<ClowderInstance> defaults = ClowderInstance.getDefaultClowderInstances();
    instances.addAll(defaults);
    return instances;
  }

  Future<ClowderInstance> getClowderInstancebyURL(String url) async {
    var dbClient = await db;
    List<Map> list = await dbClient.rawQuery('SELECT * FROM ClowderInstance WHERE url = ?', [url]);
    if (list.length > 0) {
      var instance = new ClowderInstance(list[0]["url"], list[0]["login_token"]);
      return instance;
    } else {
      return null;
    }
  }

  Future<int> deleteClowderInstances(ClowderInstance instance) async {
    var dbClient = await db;

    int res =
    await dbClient.rawDelete('DELETE FROM ClowderInstance WHERE id = ?', [instance.id]);
    return res;
  }

  Future<bool> updateClowderInstance(ClowderInstance instance) async {
    var dbClient = await db;

    int res =   await dbClient.update("ClowderInstance", instance.toMap(),
        where: "id = ?", whereArgs: <int>[instance.id]);

    return res > 0 ? true : false;
  }
}
