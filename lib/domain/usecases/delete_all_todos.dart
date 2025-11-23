import '../repositories/todo_repository.dart';

class DeleteAllTodos {
  final TodoRepository repository;

  DeleteAllTodos(this.repository);

  Future<void> call() async {
    return await repository.deleteAllTodos();
  }
}

