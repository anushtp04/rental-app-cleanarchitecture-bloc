import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/car.dart';
import '../../../domain/usecases/car_usecases.dart';

part 'car_event.dart';
part 'car_state.dart';

class CarBloc extends Bloc<CarEvent, CarState> {
  final GetAllCars getAllCars;
  final AddCar addCar;
  final UpdateCar updateCar;
  final DeleteCar deleteCar;

  CarBloc({
    required this.getAllCars,
    required this.addCar,
    required this.updateCar,
    required this.deleteCar,
  }) : super(CarInitial()) {
    on<LoadCars>(_onLoadCars);
    on<AddCarEvent>(_onAddCar);
    on<UpdateCarEvent>(_onUpdateCar);
    on<DeleteCarEvent>(_onDeleteCar);
  }

  Future<void> _onLoadCars(LoadCars event, Emitter<CarState> emit) async {
    emit(CarLoading());
    try {
      final cars = await getAllCars();
      emit(CarLoaded(cars: cars));
    } catch (e) {
      emit(CarError(message: e.toString()));
    }
  }

  Future<void> _onAddCar(AddCarEvent event, Emitter<CarState> emit) async {
    try {
      await addCar(event.car);
      final cars = await getAllCars();
      emit(CarLoaded(cars: cars));
    } catch (e) {
      emit(CarError(message: e.toString()));
    }
  }

  Future<void> _onUpdateCar(UpdateCarEvent event, Emitter<CarState> emit) async {
    try {
      await updateCar(event.car);
      final cars = await getAllCars();
      emit(CarLoaded(cars: cars));
    } catch (e) {
      emit(CarError(message: e.toString()));
    }
  }

  Future<void> _onDeleteCar(DeleteCarEvent event, Emitter<CarState> emit) async {
    try {
      await deleteCar(event.id);
      final cars = await getAllCars();
      emit(CarLoaded(cars: cars));
    } catch (e) {
      emit(CarError(message: e.toString()));
    }
  }
}
