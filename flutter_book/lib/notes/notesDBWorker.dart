
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../utils.dart' as utils;
import 'notesModel.dart';

class NotesDbWorker {

  NotesDbWorker._();
  static final NotesDbWorker db = NotesDbWorker._();

  Database _db;

  Future get database async {
    if(_db == null){
      _db = await init();
    }
    return _db;
  }

  Future<Database> init() async{
    String path = join(utils.docsDir.path, "notes.db");
    Database db = await openDatabase(
        path, version: 1, onOpen: (db) {},
        onCreate: (Database pDb, int pVersion) async {
          await pDb.execute(
              "CREATE TABLE IF NOT EXISTS notes("
              "id INTEGER PRIMARY KEY,"
              "title text,"
              "content text,"
              "color text"
              ")"
          );
        }
    );
    return db;
  }

  // we need some functions to convert from a Dart map to a Note and vice-versa
  Note noteFromMap(Map pMap){
    Note note = new Note();
    note.id = pMap["id"];
    note.title = pMap["title"];
    note.content = pMap["content"];
    note.color = pMap["color"];
    return note;
  }

  Map<String, dynamic> noteToMap(Note pNote){
    Map<String, dynamic> pMap = Map<String, dynamic>();
    pMap["id"] = pNote.id;
    pMap["title"] = pNote.title;
    pMap["content"] = pNote.content;
    pMap["color"] = pNote.color;
    return pMap;
  }

  Future create(Note pNote) async{
    Database db = await database;
    var val = await db.rawQuery("SELECT MAX(id)+1 AS id FROM notes");
    int id = val.first["id"];
    if (id == null) {
      id = 1;
    }

    return await db.rawInsert("insert into notes (id, title, content, color) "
    "values (?, ?, ?, ?)",
    [id, pNote.title, pNote.content, pNote.color]);
  }

  Future<Note> get(int id) async {
    Database db = await database;
    var res = await db.query("notes", where: "id = ?", whereArgs: [id]);
    return noteFromMap(res.first);
  }

  Future<List> getAll() async {
    Database db = await database;
    var res = await db.query("notes");
    var resList = res.isNotEmpty ? res.map((e) => noteFromMap(e)).toList() : [];
    return resList;
  }

}
