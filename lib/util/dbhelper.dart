import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:treasure_mapp/models/place.dart';

class DbHelper {
  final int version = 1;
  Database? db;

  List<Place> places = <Place>[];

  static final DbHelper _dbHelper = DbHelper._internal();
  DbHelper._internal();

  factory DbHelper() {
    return _dbHelper;
  }

  Future<Database> openDb() async {
    db ??= await openDatabase(
      join(await getDatabasesPath(), 'mapp.db'),
      onCreate: (db, version) {
        db.execute(
            'CREATE TABLE places(id INTEGER PRIMARY KEY, name TEXT, lat DOUBLE, long DOUBLE, image TEXT)');
      },
      version: version,
    );
    return db!;
  }

  Future insertMockData() async {
    db = await openDb();
    await db?.execute(
        'INSERT INTO places VALUES (1, "Beautiful park", 41.4219983, -110.084, "")');
    await db?.execute(
        'INSERT INTO places VALUES (2, "Best Pizza in the world", 41.9294115, -100.5268947, "")');
    await db?.execute(
        'INSERT INTO places VALUES (3, "The best icecream on earth", 41.9349061, -128.533, "")');
    List places = await db!.rawQuery('select * from places');
    print("this is inside inserMockData: ${places[0].toString()}");
  }

  Future<List<Place>> getPlaces() async {
    final List<Map<String, dynamic>> maps =
        await db?.query('places') as List<Map<String, dynamic>>;
    places = List.generate(
      maps.length,
      (index) {
        return Place(
          id: maps[index]['id'],
          name: maps[index]['name'],
          lat: maps[index]['lat'],
          long: maps[index]['long'],
          image: maps[index]['image'],
        );
      },
    );
    return places;
  }

  Future<int> insertPlace(Place place) async {
    int? id = await db?.insert('places', place.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    return id!;
  }

  Future<int> updatePlace(Place place) async {
    int? id = await db?.update('place', place.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    return id!;
  }

  Future<int> deletePlace(Place place) async {
    int? result =
        await db?.delete("places", where: "id = ?", whereArgs: [place.id]);
    return result!;
  }
}
