
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../utils.dart' as utils;
import 'AppointmentsModel.dart';

class AppointmentsDBWorker {

  AppointmentsDBWorker._();
  static final AppointmentsDBWorker db = AppointmentsDBWorker._();

  Database _db;

  Future get database async {
    if(_db == null){
      _db = await init();
    }
    return _db;
  }

  Future<Database> init() async{
    String path = join(utils.docsDir.path, "appointments.db");
    Database db = await openDatabase(
        path, version: 1, onOpen: (db) {},
        onCreate: (Database pDb, int pVersion) async {
          await pDb.execute(
              "CREATE TABLE IF NOT EXISTS appointments("
                  "id INTEGER PRIMARY KEY,"
                  "title text,"
                  "description text,"
                  "apptDate text,"
                  "apptTime text"
                  ")"
          );
        }
    );
    return db;
  }

  Appointments appointmentsFromMap(Map pMap){
    Appointments task = new Appointments();
    task.id = pMap["id"];
    task.title = pMap["title"];
    task.description = pMap["description"];
    task.apptDate = pMap["apptDate"];
    task.apptTime = pMap["apptTime"];
    return task;
  }

  Map<String, dynamic> appointmentsToMap(Appointments pAppoint){
    Map<String, dynamic> pMap = Map<String, dynamic>();
    pMap["id"] = pAppoint.id;
    pMap["title"] = pAppoint.title;
    pMap["description"] = pAppoint.description;
    pMap["apptDate"] = pAppoint.apptDate;
    pMap["apptTime"] = pAppoint.apptTime;
    return pMap;
  }

  Future create(Appointments pAppoint) async{
    Database db = await database;
    var val = await db.rawQuery("SELECT MAX(id)+1 AS id FROM appointments");
    int id = val.first["id"];
    if (id == null) {
      id = 1;
    }

    return await db.rawInsert("insert into appointments (id, title, description, apptDate, apptTime) "
        "values (?, ?, ?, ?, ?)",
        [id, pAppoint.title, pAppoint.description, pAppoint.apptDate, pAppoint.apptTime]);
  }

  Future<Appointments> get(int id) async {
    Database db = await database;
    var res = await db.query("appointments", where: "id = ?", whereArgs: [id]);
    return appointmentsFromMap(res.first);
  }

  Future<List> getAll() async {
    Database db = await database;
    var res = await db.query("appointments");
    var resList = res.isNotEmpty ? res.map((e) => appointmentsFromMap(e)).toList() : [];
    return resList;
  }

  Future update(Appointments pAppoint) async{
    Database db = await database;
    return await db.update("appointments", appointmentsToMap(pAppoint),
        where: "id = ?", whereArgs: [pAppoint.id]);
  }

  Future delete(int id) async{
    Database db = await database;
    return await db.delete("appointments", where: "id = ?", whereArgs: [id]);
  }

}
