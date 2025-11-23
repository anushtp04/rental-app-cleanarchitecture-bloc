import '../entities/todo.dart';
import '../repositories/todo_repository.dart';

class UpdateTodo {
  final TodoRepository repository;

  UpdateTodo(this.repository);

  Future<Todo> call(Todo todo) async {
    return await repository.updateTodo(todo);
  }
}

