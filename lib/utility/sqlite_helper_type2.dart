import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:ungpeaofficer/models/type2_sqlite_model.dart';

class SQLiteHelperType2 {
  final String nameDatabase = 'type2.db';
  final String nameTable = 'tableType2';
  final int version = 1;
  final String colunmId = 'id';
  final String colunmIdDoc = 'iddoc';
  final String colunmNameJob = 'namejob';
  final String colunmImage = 'image';

  SQLiteHelperType2() {
    initialDatabase();
  }

  Future<Null> initialDatabase() async {
    await openDatabase(
      join(await getDatabasesPath(), nameDatabase),
      version: version,
      onCreate: (db, version) => db.execute(
          'CREATE TABLE $nameTable ($colunmId INTEGER PRIMARY KEY, $colunmIdDoc TEXT, $colunmNameJob TEXT, $colunmImage TEXT)'),
    );
  }

  Future<Database> connectedDatabase() async {
    return await openDatabase(join(await getDatabasesPath(), nameDatabase));
  }

  Future<Null> insertDatabase(Type2SQLiteModel type2sqLiteModel) async {
    Database database = await connectedDatabase();
    try {
      database.insert(
        nameTable,
        type2sqLiteModel.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print('#### insert Database SQLit Success');
    } catch (e) {}
  }

  Future<List<Type2SQLiteModel>> readDatabase() async {
    Database database = await connectedDatabase();
    List<Type2SQLiteModel> models = [];

    List<Map<String, dynamic>> maps = await database.query(nameTable);
    for (var item in maps) {
      Type2SQLiteModel model = Type2SQLiteModel.fromMap(item);
      models.add(model);
    }
    return models;
  }

  Future<Null> deleteSQLiteById(int id) async {
    Database database = await connectedDatabase();
    try {
      await database.delete(nameTable, where: '$colunmId = $id');
    } catch (e) {}
  }

  Future<Null> deleteAll() async {
    Database database = await connectedDatabase();
    try {
      await database.delete(nameTable);
    } catch (e) {}
  }
}
