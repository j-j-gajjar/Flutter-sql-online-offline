import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DataBaseHelper {
  Database? db;
  late var path;

  createDb() async {
    var databasePath = await getDatabasesPath();
    path = join(databasePath, 'database1.db');
    db = await openDatabase(path, version: 1, onCreate: (Database dataBase, int version) async {
      await dataBase.execute('''CREATE TABLE users (id INTEGER PRIMARY KEY,name TEXT,username TEXT,email TEXT)''');
    });
  }

  dropUserTable() async {
    await db!.transaction((Transaction txn) async {
      await txn.rawDelete("DELETE FROM users");
    });
  }

  putDataInDataBase(data) async {
    if (db == null) await this.createDb();
    await dropUserTable();
    await db!.transaction((txn) async {
      data.forEach((data) async => await txn.rawInsert("INSERT INTO users(name, username, email) VALUES('${data['name']}','${data['username']}','${data['email'
          '']}')"));
    });
    return 1;
  }

  getDataFromDataBase() async {
    if (db == null) await this.createDb();
    return await db!.transaction((txn) async {
      return await txn.rawQuery("SELECT * FROM users");
    });
  }
}
