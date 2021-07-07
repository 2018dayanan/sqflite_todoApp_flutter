import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:intl/intl.dart';
import 'package:todoapp/database/database_helper.dart';
import 'package:todoapp/main.dart';
import 'package:todoapp/models/task_model.dart';

class AddTask extends StatefulWidget {
  final bool add;
  final String? title;
  final String? description;
  final DateTime? date;
  final String? priority;
  final int? id;
  AddTask({
    required this.add,
    this.title,
    this.date,
    this.description,
    this.priority,
    this.id,
  });

  @override
  _AddTaskState createState() => _AddTaskState();
}

class _AddTaskState extends State<AddTask> {
  @override
  void initState() {
    super.initState();
    setState(() {
      _dateController.text = dateFormatter.format(_date);
    });
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  String _title = "";
  String _description = "";
  String? _priority;
  DateTime _date = DateTime.now();
  final DateFormat dateFormatter = DateFormat('MMM dd, yyyy');
  final List<String> priorites = ['Urgent', 'Important', 'Optional'];

  _handleDatePicker() async {
    final DateTime? date = await showDatePicker(
        context: context,
        initialDate: _date,
        firstDate: DateTime(2020),
        lastDate: DateTime(2070));
    if (date != null && date != _date) {
      setState(() {
        _date = date;
      });
      _dateController.text = dateFormatter.format(_date);
    }
  }

  _snackBarDisplayingMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      duration: Duration(seconds: 1),
    ));
  }

  _updateTask(int id) {
    _snackBarDisplayingMessage("Upadating $id....");
  }

  _submit(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      await _snackBarDisplayingMessage("Adding your task...");
      _formKey.currentState!.save();
      Task task = Task(
          date: _date,
          description: _description,
          isDone: false,
          title: _title,
          priority: _priority!);

      await DatabaseHelper.instance.create(task);
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (ctx) => MyTodoApp()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        title: Text(
          widget.add ? "Add Task" : "Update Task",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: _formKey,
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  widget.add
                      ? SizedBox()
                      : Text(
                          " Update :${widget.title}",
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextFormField(
                      style: TextStyle(
                        fontSize: 18.0,
                      ),
                      decoration: InputDecoration(
                        labelText: "Title",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: MultiValidator([
                        RequiredValidator(
                            errorText: "this feild cannot be empty!"),
                        MinLengthValidator(3,
                            errorText:
                                "title should be at least 3 characters long!"),
                      ]),
                      initialValue: widget.add ? _title : widget.title,
                      onSaved: (val) {
                        print(val);
                        _title = val!;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextFormField(
                      maxLines: 3,
                      style: TextStyle(
                        fontSize: 18.0,
                      ),
                      decoration: InputDecoration(
                        labelText: "Description",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: MultiValidator([
                        RequiredValidator(
                            errorText: "this feild cannot be empty!"),
                        MinLengthValidator(3,
                            errorText:
                                "title should be at least 3 characters long!"),
                      ]),
                      initialValue: widget.add ? "" : widget.description,
                      onSaved: (val) {
                        print(val);
                        _description = val!;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextFormField(
                      readOnly: true,
                      controller: _dateController,
                      onTap: _handleDatePicker,
                      style: TextStyle(
                        fontSize: 18.0,
                      ),
                      decoration: InputDecoration(
                        suffixIcon:
                            Icon(Icons.date_range, color: Colors.blue[900]),
                        labelText: "Date",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: DropdownButtonFormField(
                      isDense: true,
                      items: priorites.map((String priority) {
                        return DropdownMenuItem(
                          value: priority,
                          child: Text(priority,
                              style: TextStyle(
                                color: Colors.black,
                              )),
                        );
                      }).toList(),
                      icon: Icon(Icons.arrow_circle_down),
                      iconSize: 22,
                      iconEnabledColor: Theme.of(context).primaryColor,
                      style: TextStyle(
                        fontSize: 18.0,
                      ),
                      decoration: InputDecoration(
                        labelText: "Priority",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: MultiValidator([
                        RequiredValidator(
                            errorText: "this feild cannot be empty!"),
                      ]),
                      onChanged: (value) {
                        setState(() {
                          _priority = value.toString();
                        });
                      },
                      onSaved: (val) => _priority == val,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      widget.add
                          ? _submit(context)
                          : _updateTask(int.parse("${widget.id}"));
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 50),
                      height: 60,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.blue[900],
                      ),
                      child: Center(
                          child: Text(
                        widget.add ? "Add new Task" : "Update Task",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      )),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
