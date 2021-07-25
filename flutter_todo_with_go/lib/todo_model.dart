import 'dart:convert';

class Todo {
  String index;
  String task;
  String name;

  Todo({required this.index, required this.task, required this.name});

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      index: json["index"],
      task: json["task"],
      name: json["name"],
    );
  }

  Map<String, dynamic> toJson() => {
        "index": index,
        "task": task,
        "name": name,
      };
}

String todoToJson(Todo todo) {
  final jsonData = todo.toJson();
  return json.encode(jsonData);
}
