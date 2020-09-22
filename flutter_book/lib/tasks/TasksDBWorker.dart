
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../utils.dart' as utils;
import 'TasksModel.dart';

class TasksDBWorker {

  TasksDBWorker._();
  static final TasksDBWorker db = TasksDBWorker._();

  Database _db;

  Future get database async {
    if(_db == null){
      _db = await init();
    }
    return _db;
  }

  Future<Database> init() async{
    String path = join(utils.docsDir.path, "tasks.db");
    Database db = await openDatabase(
        path, version: 1, onOpen: (db) {},
        onCreate: (Database pDb, int pVersion) async {
          await pDb.execute(
              "CREATE TABLE IF NOT EXISTS tasks("
                  "id INTEGER PRIMARY KEY,"
                  "description text,"
                  "dueDate text,"
                  "completed text"
                  ")"
          );
        }
    );
    return db;
  }

  Task taskFromMap(Map pMap){
    Task task = new Task();
    task.id = pMap["id"];
    task.description = pMap["description"];
    task.dueDate = pMap["dueDate"];
    task.completed = pMap["completed"];
    return task;
  }

  Map<String, dynamic> taskToMap(Task pTask){
    Map<String, dynamic> pMap = Map<String, dynamic>();
    pMap["id"] = pTask.id;
    pMap["description"] = pTask.description;
    pMap["dueDate"] = pTask.dueDate;
    pMap["completed"] = pTask.completed;
    return pMap;
  }

  Future create(Task pTask) async{
    Database db = await database;
    var val = await db.rawQuery("SELECT MAX(id)+1 AS id FROM tasks");
    int id = val.first["id"];
    if (id == null) {
      id = 1;
    }

    return await db.rawInsert("insert into tasks (id, description, dueDate, completed) "
        "values (?, ?, ?, ?)",
        [id, pTask.description, pTask.dueDate, pTask.completed]);
  }

  Future<Task> get(int id) async {
    Database db = await database;
    var res = await db.query("tasks", where: "id = ?", whereArgs: [id]);
    return taskFromMap(res.first);
  }

  Future<List> getAll() async {
    Database db = await database;
    var res = await db.query("tasks");
    var resList = res.isNotEmpty ? res.map((e) => taskFromMap(e)).toList() : [];
    return resList;
  }

  Future update(Task pTask) async{
    Database db = await database;
    return await db.update("tasks", taskToMap(pTask),
        where: "id = ?", whereArgs: [pTask.id]);
  }

  Future delete(int id) async{
    Database db = await database;
    return await db.delete("tasks", where: "id = ?", whereArgs: [id]);
  }

}
