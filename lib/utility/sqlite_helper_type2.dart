import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

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

  Future<Null> insertDatabase()async{}


}
