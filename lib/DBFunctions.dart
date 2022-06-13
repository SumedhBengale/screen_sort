// ignore: file_names
import 'globals.dart';

Future<void> getData() async {
  list = await database.rawQuery('SELECT * FROM collections');
  print(list.length);
}

void createCollection(String name) async {
  await database.transaction((txn) async {
    int id1 = await txn
        .rawInsert('INSERT INTO collections(collection_name) VALUES("$name")');
    print('inserted1: $id1');
  });

  await database
      .execute('CREATE TABLE $name (id INTEGER PRIMARY KEY, image_name TEXT)');
}

void deleteTable(tableName) async {
  await database.delete('collections',
      where: 'collection_name = ?', whereArgs: [tableName]);

  await database.execute('DROP TABLE $tableName');
  print("Delete");
  await getData();
}

Future<String> tableExists(tableName) async {
  try {
    List x = await database.rawQuery("SELECT * FROM $tableName");
    return ("Table Exists");
  } catch (SqfliteDatabaseException) {
    return ("Table does not Exist");
  }
}
