import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/todo.dart';
import '../../../domain/usecases/get_all_todos.dart';
import '../../../domain/usecases/create_todo.dart';
import '../../../domain/usecases/update_todo.dart';
import '../../../domain/usecases/delete_todo.dart';
import '../../../domain/usecases/delete_all_todos.dart';

part 'todo_event.dart';
part 'todo_state.dart';

class TodoBloc extends Bloc<TodoEvent, TodoState> {
  final GetAllTodos getAllTodos;
  final CreateTodo createTodo;
  final UpdateTodo updateTodo;
  final DeleteTodo deleteTodo;
  final DeleteAllTodos deleteAllTodos;

  TodoBloc({
    required this.getAllTodos,
    required this.createTodo,
    required this.updateTodo,
    required this.deleteTodo,
    required this.deleteAllTodos,
  }) : super(TodoInitial()) {
    on<LoadTodos>(_onLoadTodos);
    on<AddTodo>(_onAddTodo);
    on<UpdateTodoEvent>(_onUpdateTodo);
    on<DeleteTodoEvent>(_onDeleteTodo);
    on<DeleteAllTodosEvent>(_onDeleteAllTodos);
    on<ToggleTodoComplete>(_onToggleTodoComplete);
  }

  Future<void> _onLoadTodos(LoadTodos event, Emitter<TodoState> emit) async {
    emit(TodoLoading());
    try {
      final todos = await getAllTodos();
      emit(TodoLoaded(todos: todos));
    } catch (e) {
      emit(TodoError(message: e.toString()));
    }
  }

  Future<void> _onAddTodo(AddTodo event, Emitter<TodoState> emit) async {
    try {
      await createTodo(event.todo);
      final todos = await getAllTodos();
      emit(TodoLoaded(todos: todos));
    } catch (e) {
      emit(TodoError(message: e.toString()));
    }
  }

  Future<void> _onUpdateTodo(UpdateTodoEvent event, Emitter<TodoState> emit) async {
    try {
      await updateTodo(event.todo);
      final todos = await getAllTodos();
      emit(TodoLoaded(todos: todos));
    } catch (e) {
      emit(TodoError(message: e.toString()));
    }
  }

  Future<void> _onDeleteTodo(DeleteTodoEvent event, Emitter<TodoState> emit) async {
    try {
      await deleteTodo(event.id);
      final todos = await getAllTodos();
      emit(TodoLoaded(todos: todos));
    } catch (e) {
      emit(TodoError(message: e.toString()));
    }
  }

  Future<void> _onDeleteAllTodos(DeleteAllTodosEvent event, Emitter<TodoState> emit) async {
    try {
      await deleteAllTodos();
      emit(TodoLoaded(todos: []));
    } catch (e) {
      emit(TodoError(message: e.toString()));
    }
  }

  Future<void> _onToggleTodoComplete(ToggleTodoComplete event, Emitter<TodoState> emit) async {
    try {
      final updatedTodo = event.todo.copyWith(
        isCompleted: !event.todo.isCompleted,
        completedAt: !event.todo.isCompleted ? DateTime.now() : null,
      );
      await updateTodo(updatedTodo);
      final todos = await getAllTodos();
      emit(TodoLoaded(todos: todos));
    } catch (e) {
      emit(TodoError(message: e.toString()));
    }
  }
}

