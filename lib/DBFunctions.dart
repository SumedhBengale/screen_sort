// ignore: file_names
import 'globals.dart';

Future<List<Map>> getData() async {
  list = await database.rawQuery('SELECT * FROM collections');
  print(list.length);
  return list;
}

void createCollection(String name) async {
  await database.transaction((txn) async {
    int id1 = await txn
        .rawInsert('INSERT INTO collections(collection_name) VALUES("$name")');
    print('inserted1: $id1');
  });

  await database
      .execute('CREATE TABLE $name (id INTEGER PRIMARY KEY, file TEXT)');
}

void deleteCollection(tableName) async {
  await database.delete('collections',
      where: 'collection_name = ?', whereArgs: [tableName]);

  await database.execute('DROP TABLE $tableName');
  print("Delete");
  await getData();
}

void insertImage(String collection) async {
  List x = await database.rawQuery('SELECT file from temp');
  print(x);
  var path = x[0]['file'];
  print("PATH");
  print(path);
  if (path != "") {
    await database.rawInsert('INSERT INTO $collection(file) VALUES("$path")');
  }
  path = '';
  await database.rawDelete('DELETE FROM temp');
}

void insertThisImage(String collection, String path) async {
  await database.rawInsert('INSERT INTO $collection(file) VALUES("$path")');
  print("Inserted");
}

Future<String> tableExists(tableName) async {
  try {
    List x = await database.rawQuery("SELECT * FROM $tableName");
    return ("Table Exists");
  } catch (SqfliteDatabaseException) {
    return ("Table does not Exist");
  }
}
