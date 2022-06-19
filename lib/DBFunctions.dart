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

  await database.execute(
      'CREATE TABLE $name (id INTEGER PRIMARY KEY, name TEXT, path TEXT, datetime TEXT)');
}

void deleteCollection(tableName) async {
  await database.delete('collections',
      where: 'collection_name = ?', whereArgs: [tableName]);

  await database.execute('DROP TABLE $tableName');
  print("Delete");
  await getData();
}

void insertImage(String collection) async {
  List x = await database.rawQuery('SELECT * from temp');
  var name = x[0]['name'];
  var path = x[0]['path'];
  var datetime = x[0]['datetime'];
  print("PATH");
  print(path);
  if (path != "") {
    await database.rawInsert(
        'INSERT INTO $collection(name,path,datetime) VALUES("$name","$path","$datetime")');
  }
  path = '';
  await database.rawDelete('DELETE FROM temp');
}

// void insertThisImage(
//     String collection, String name, String path, String datetime) async {
//   await database.rawInsert(
//       'INSERT INTO $collection(name,path,datetime) VALUES("$name","$path","$datetime")');
//   print("Inserted");
// }

void removeFromCollection(String collection, String path) async {
  await database.rawDelete('DELETE FROM $collection where path="$path"');
}

Future<String> tableExists(tableName) async {
  try {
    List x = await database.rawQuery("SELECT * FROM $tableName");
    return ("Table Exists");
  } catch (SqfliteDatabaseException) {
    return ("Table does not Exist");
  }
}
