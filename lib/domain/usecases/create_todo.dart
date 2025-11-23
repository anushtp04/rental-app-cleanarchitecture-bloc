import '../entities/todo.dart';
import '../repositories/todo_repository.dart';

class CreateTodo {
  final TodoRepository repository;

  CreateTodo(this.repository);

  Future<Todo> call(Todo todo) async {
    return await repository.createTodo(todo);
  }
}

