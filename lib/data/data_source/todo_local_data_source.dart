import 'package:hive_flutter/hive_flutter.dart';
import '../models/todo_model.dart';

abstract class TodoLocalDataSource {
  Future<List<TodoModel>> getAllTodos();
  Future<TodoModel> getTodoById(String id);
  Future<void> cacheTodo(TodoModel todo);
  Future<void> updateCachedTodo(TodoModel todo);
  Future<void> deleteTodo(String id);
  Future<void> deleteAllTodos();
}

class TodoLocalDataSourceImpl implements TodoLocalDataSource {
  final Box<TodoModel> todoBox;

  TodoLocalDataSourceImpl(this.todoBox);

  @override
  Future<List<TodoModel>> getAllTodos() async {
    return todoBox.values.toList();
  }

  @override
  Future<TodoModel> getTodoById(String id) async {
    final todo = todoBox.get(id);
    if (todo != null) {
      return todo;
    } else {
      throw Exception('Todo not found');
    }
  }

  @override
  Future<void> cacheTodo(TodoModel todo) async {
    await todoBox.put(todo.id, todo);
  }

  @override
  Future<void> updateCachedTodo(TodoModel todo) async {
    await todoBox.put(todo.id, todo);
  }

  @override
  Future<void> deleteTodo(String id) async {
    await todoBox.delete(id);
  }

  @override
  Future<void> deleteAllTodos() async {
    await todoBox.clear();
  }
}

