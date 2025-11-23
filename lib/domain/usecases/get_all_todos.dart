import '../entities/todo.dart';
import '../repositories/todo_repository.dart';

class GetAllTodos {
  final TodoRepository repository;

  GetAllTodos(this.repository);

  Future<List<Todo>> call() async {
    return await repository.getAllTodos();
  }
}

