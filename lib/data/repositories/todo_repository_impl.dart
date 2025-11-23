import '../../domain/entities/todo.dart';
import '../../domain/repositories/todo_repository.dart';
import '../data_source/todo_local_data_source.dart';
import '../models/todo_model.dart';

class TodoRepositoryImpl implements TodoRepository {
  final TodoLocalDataSource localDataSource;

  TodoRepositoryImpl(this.localDataSource);

  @override
  Future<List<Todo>> getAllTodos() async {
    final todos = await localDataSource.getAllTodos();
    return todos.map((todo) => todo.toEntity()).toList();
  }

  @override
  Future<Todo> getTodoById(String id) async {
    final todo = await localDataSource.getTodoById(id);
    return todo.toEntity();
  }

  @override
  Future<Todo> createTodo(Todo todo) async {
    final todoModel = TodoModel.fromEntity(todo);
    await localDataSource.cacheTodo(todoModel);
    return todoModel.toEntity();
  }

  @override
  Future<Todo> updateTodo(Todo todo) async {
    final todoModel = TodoModel.fromEntity(todo);
    await localDataSource.updateCachedTodo(todoModel);
    return todoModel.toEntity();
  }

  @override
  Future<void> deleteTodo(String id) async {
    await localDataSource.deleteTodo(id);
  }

  @override
  Future<void> deleteAllTodos() async {
    await localDataSource.deleteAllTodos();
  }
}

