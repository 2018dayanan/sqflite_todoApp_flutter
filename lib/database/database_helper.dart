import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'package:todoapp/models/task_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._();
  DatabaseHelper._();

  static Database? _db;

//Step 1 : check if the database already exists ? if yes , return database, no init database
  Future<Database?> get db async {
    if (_db != null) {
      return _db;
    }
    print("dataabase is being initialized");
    _db = await _initDB('tasks.db');
    print("database initialized!! : $_db");
    return _db;
  }

//init database function, this function exectues only when the _db is null;
  Future<Database?> _initDB(String fileName) async {
//step 2 :get the database file path
    final dbPath = await getDatabasesPath(); //[ this comes from sqflite]
    final path = join(dbPath, fileName); // this comes from path package

    //step3 : open databse

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  //Step 4 : this function will create the databsase with tables and version name
  Future _createDB(Database db, int version) async {
    db.execute('''CREATE TABLE tasks(
          ${TaskFields.date} TEXT NOT NULL,
         ${TaskFields.id} INTEGER PRIMARY KEY,
          ${TaskFields.description} TEXT, 
          ${TaskFields.isDone} BOOLEAN NOT NULL, 
          ${TaskFields.priority} TEXT NOT NULL,
           ${TaskFields.title} TEXT NOT NULL)''');
  }

//This function closes the database
  Future close() async {
    final db = await instance.db;
    await db!.close();
  }

//CRUD Operations
//This function will create the database with values
  create(Task task) async {
    final db = await instance.db; //this will get the instance of the database

    //this line here will make sure tothat the data is inserted in the taskTables and aslo it makes sure that the values that gets passes in is converted to json as the sqflite accepts json data
    await db!.insert("tasks", task.toJson());
  }

  //this function will read the data with the specific id

  Future<Task> readData(int id) async {
    final db = await instance.db;
    final maps = await db!.query(taskTable,
        columns: TaskFields.allFields,
        where:
            '${TaskFields.id} = ?', // we can specify the [id] here insted of having to write ? and whereArgs, but writing in that way will not prevent our app from sql injection
        whereArgs: [id]);

    if (maps.isNotEmpty) {
//once we have data here in json format so we need to convert the data back to map form so we can use it easily

      return Task.fromJson(maps
          .first); //this line here converts the maps the json it gets from the local databse into map with the help of the method in task model
    } else {
      //if we didn't get any data we just throw an exception letting user to know that something went wrong
      throw Exception('ID $id not Found!');
    }
  }

//this fuction here will get all the data that we have in the database
  Future<List<Task>> readAllTasks() async {
    List<Task> _tasks = [];
    final oderby =
        '${TaskFields.date} ASC'; //this is optional [ use it if you have to order data]

    final db = await instance.db; //init the data
    final result = await db!.query("tasks",
        orderBy:
            oderby); //gets all the data we have in json and store in the pointer ' result '
    result.forEach((element) {
      var _task = Task.fromJson(element);
      _tasks.add(_task);
    }); //once we have the json data we need to convert it back to list
    return _tasks;
  }

//this function updates the task
  Future<int> updateTask(Task task) async {
    final db = await instance.db; //init database
    return db!.update(
      "tasks", task.toJson(), //converting task object to json
      where: "${TaskFields.id} = ?",
      whereArgs: [task.id], //this line just checks which one to update
    );
  }

//this function here will delte the data once by identify the data that we want to delete with id
  Future<int> deleteTask(int id) async {
    final db = await instance.db; //init database
    return db!.delete(
      "tasks", //table from where we want to delete data
      where:
          '${TaskFields.id} = ?', //querying the data with id that is passed in as argument
      whereArgs: [id],
    );
  }
}
