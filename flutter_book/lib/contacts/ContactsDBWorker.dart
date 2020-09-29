
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../utils.dart' as utils;
import 'ContactsModel.dart';

class ContactsDBWorker {

  ContactsDBWorker._();
  static final ContactsDBWorker db = ContactsDBWorker._();

  Database _db;

  Future get database async {
    if(_db == null){
      _db = await init();
    }
    return _db;
  }

  Future<Database> init() async{
    String path = join(utils.docsDir.path, "contacts.db");
    Database db = await openDatabase(
        path, version: 1, onOpen: (db) {},
        onCreate: (Database pDb, int pVersion) async {
          await pDb.execute(
              "CREATE TABLE IF NOT EXISTS contacts("
                  "id INTEGER PRIMARY KEY,"
                  "name text,"
                  "phone text,"
                  "birthday text"
                  ")"
          );
        }
    );
    return db;
  }

  Contact appointmentsFromMap(Map pMap){
    Contact contact = new Contact();
    contact.id = pMap["id"];
    contact.name = pMap["name"];
    contact.phone = pMap["phone"];
    contact.birthday = pMap["birthday"];
    return contact;
  }

  Map<String, dynamic> appointmentsToMap(Contact pContact){
    Map<String, dynamic> pMap = Map<String, dynamic>();
    pMap["id"] = pContact.id;
    pMap["name"] = pContact.name;
    pMap["phone"] = pContact.phone;
    pMap["birthday"] = pContact.birthday;
    return pMap;
  }

  Future create(Contact pContact) async{
    Database db = await database;
    var val = await db.rawQuery("SELECT MAX(id)+1 AS id FROM contacts");
    int id = val.first["id"];
    if (id == null) {
      id = 1;
    }

    return await db.rawInsert("insert into contacts (id, name, phone, birthday) "
        "values (?, ?, ?, ?)",
        [id, pContact.name, pContact.phone, pContact.birthday]);
  }

  Future<Contact> get(int id) async {
    Database db = await database;
    var res = await db.query("contacts", where: "id = ?", whereArgs: [id]);
    return appointmentsFromMap(res.first);
  }

  Future<List> getAll() async {
    Database db = await database;
    var res = await db.query("contacts");
    var resList = res.isNotEmpty ? res.map((e) => appointmentsFromMap(e)).toList() : [];
    return resList;
  }

  Future update(Contact pContact) async{
    Database db = await database;
    return await db.update("contacts", appointmentsToMap(pContact),
        where: "id = ?", whereArgs: [pContact.id]);
  }

  Future delete(int id) async{
    Database db = await database;
    return await db.delete("contacts", where: "id = ?", whereArgs: [id]);
  }

}
