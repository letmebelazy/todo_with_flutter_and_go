import 'dart:async';
import 'todo_edit_page.dart';
import 'package:flutter/material.dart';
import 'todo_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TodoListPage extends StatefulWidget {
  const TodoListPage({Key? key}) : super(key: key);

  @override
  _TodoListPageState createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  Future<List<Todo>> _getTodoList() async {
    var url = 'http://localhost:5500/todos';
    var response = await http.get(Uri.parse(url));
    List<Todo> todoList = [];
    print('ddddd${response.body}');
    if (response.statusCode == 200) {
      todoList = json
          .decode(response.body)
          .cast<Map<String, dynamic>>()
          .map<Todo>((json) => Todo.fromJson(json))
          .toList();
    } else {
      print('Failed to get the todo list from server');
    }
    print('todoList:::${todoList[0].toString()}');
    return todoList;
  }

  Future _deleteTodo(int index) async {
    return await http.delete(Uri.parse('http://localhost:5500/todos/$index'), body: {
      'index': index.toString(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Todo List'),
      ),
      body: Container(
          child: FutureBuilder<List<Todo>>(
        future: _getTodoList(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  print(snapshot.data.runtimeType);
                  return ListTile(
                    title: Text(snapshot.data![index].task),
                    subtitle: Text(snapshot.data![index].name),
                    onLongPress: () {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text("Select 'Edit'/'Delete'"),
                              actions: [
                                TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  TodoEditPage('Edit the todo', index)));
                                    },
                                    child: Text('Edit')),
                                TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      setState(() {
                                        _deleteTodo(index);
                                      });
                                    },
                                    child: Text('Delete')),
                              ],
                            );
                          });
                    },
                  );
                });
          } else if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          } else {
            return CircularProgressIndicator();
          }
        },
      )),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => TodoEditPage('Add a new todo', 0)));
        },
      ),
    );
  }
}
