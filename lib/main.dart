import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:todoapp/database/database_helper.dart';
import 'package:todoapp/screens/add_task.dart';

import 'models/task_model.dart';

final DateFormat dateFormatter = DateFormat('MMM dd, yyyy');
final DatabaseHelper dbHelp = DatabaseHelper.instance;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyTodoApp(),
    );
  }
}

class MyTodoApp extends StatefulWidget {
  @override
  _MyTodoAppState createState() => _MyTodoAppState();
}

class _MyTodoAppState extends State<MyTodoApp> {
  Future<List<Task>>? _tasks;

  @override
  void initState() {
    super.initState();
    print("hello");
    getData();
  }

  @override
  void dispose() {
    getData();
    super.dispose();
  }

  getData() {
    var _task = dbHelp.readAllTasks();
    setState(() {
      _tasks = _task;
    });
  }

  _deleteTask(int id) {
    //TODO delete a task
    _snackBarDisplayingMessage("Deleting $id....");
  }

  _snackBarDisplayingMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      duration: Duration(seconds: 1),
    ));
  }

  _sendToAddTask() {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AddTask(
            add: true,
          ),
        ));
  }

  var testData = [
    {"id": 1, "title": "", "description": "", "priority": ""}
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: _sendToAddTask,
          child: Icon(Icons.add),
        ),
        appBar: AppBar(
          backgroundColor: Colors.blue[900],
          title: Text("Todo App"),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: _sendToAddTask,
              icon: Icon(Icons.add),
            )
          ],
        ),
        drawer: Drawer(
          //TODO : implement more features in here
          child: Center(
            child: Text("New features of the app will be here"),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        body: FutureBuilder<List>(
          future: _tasks,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              int i = 0;
              return ListView(
                children: snapshot.data!.map<Widget>((e) {
                  return Text(" Task ${++i}");
                }).toList(),
              );
            }
            return Text("Loading...");
          },
        ));
  }
}
