import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TodoEditPage extends StatefulWidget {
  final String edit;
  final int todoIndex;
  TodoEditPage(this.edit, this.todoIndex);

  @override
  _TodoEditPageState createState() => _TodoEditPageState();
}

class _TodoEditPageState extends State<TodoEditPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _taskController;

  Future _addTodo() async {
    print('${_nameController.text}, ${_taskController.text}');
    final response = await http.post(Uri.parse('http://localhost:5500/todos'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"task": _taskController.text, "name": _nameController.text}));
    if (response.statusCode == 201) {
      print('Create success');
    } else {
      print(response.statusCode);
    }
  }

  Future _editTodo(int index) async {
    print('name::::::::::${_nameController.text} task:::::${_taskController.text}');
    return await http.patch(Uri.parse('http://localhost:5500/todos/$index'),
        body: jsonEncode({
          'index': index.toString(),
          'name': _nameController.text,
          'task': _taskController.text
        }));
  }

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _taskController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _taskController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.edit),
        ),
        body: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                validator: (value) {
                  if (value == null || value.length < 2) {
                    return 'You should write more than two letters';
                  }
                },
                decoration: InputDecoration(labelText: 'Writer'),
              ),
              TextFormField(
                controller: _taskController,
                validator: (value) {
                  if (value == null || value.length < 2) {
                    return 'You should write more than two letters';
                  }
                },
                decoration: InputDecoration(labelText: 'Task'),
              ),
              TextButton(
                child: Text(widget.edit.split(' ').first.toUpperCase()),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    if (widget.edit.contains('Add')) {
                      setState(() {
                        _addTodo();
                      });
                    } else {
                      setState(() {
                        _editTodo(widget.todoIndex);
                      });
                    }
                    Navigator.pop(context);
                    setState(() {});
                  }
                },
              )
            ],
          ),
        ));
  }
}
