final String taskTable = "tasks";

class TaskFields {
  static final String id = "id";
  static final String title = "title";
  static final String description = "description";
  static final String date = "date";
  static final String priority = "priority";
  static final String isDone = "isDone";
  static final allFields = [
    id,
    title,
    description,
    date,
    priority,
    isDone,
  ];
}

class Task {
  int? id;
  String title;
  String? description;
  DateTime date;
  String priority;
  bool isDone;

  Task(
      {this.id,
      required this.title,
      required this.date,
      this.description,
      this.isDone = false,
      required this.priority});

  Map<String, dynamic> toJson() => {
        TaskFields.id: id,
        TaskFields.title: title,
        TaskFields.description: description,
        TaskFields.date: date.toIso8601String(),
        TaskFields.isDone: isDone ? 1 : 0,
        TaskFields.priority: priority,
      };

  static Task fromJson(Map<String, Object?> json) => Task(
        id: json[TaskFields.id] as int?,
        priority: json[TaskFields.priority] as String,
        description: json[TaskFields.description] as String,
        title: json[TaskFields.title] as String,
        isDone: json[TaskFields.isDone] == 1 ? true : false,
        date: DateTime.parse(json[TaskFields.date] as String),
      );

  Task copy({
    int? id,
    String title = "",
    String? description,
    DateTime? date,
    String? priority,
    bool? isDone,
  }) =>
      Task(
          title: title,
          date: date!,
          priority: priority!,
          description: description,
          id: id,
          isDone: isDone!);
}
