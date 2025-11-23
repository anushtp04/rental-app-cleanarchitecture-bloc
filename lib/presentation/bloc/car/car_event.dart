part of 'car_bloc.dart';

abstract class CarEvent extends Equatable {
  const CarEvent();

  @override
  List<Object?> get props => [];
}

class LoadCars extends CarEvent {}

class AddCarEvent extends CarEvent {
  final Car car;

  const AddCarEvent(this.car);

  @override
  List<Object?> get props => [car];
}

class UpdateCarEvent extends CarEvent {
  final Car car;

  const UpdateCarEvent(this.car);

  @override
  List<Object?> get props => [car];
}

class DeleteCarEvent extends CarEvent {
  final String id;

  const DeleteCarEvent(this.id);

  @override
  List<Object?> get props => [id];
}
