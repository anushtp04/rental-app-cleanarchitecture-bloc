import '../repositories/car_repository.dart';
import '../entities/car.dart';

class GetAllCars {
  final CarRepository repository;

  GetAllCars(this.repository);

  Future<List<Car>> call() async {
    return await repository.getAllCars();
  }
}

class AddCar {
  final CarRepository repository;

  AddCar(this.repository);

  Future<void> call(Car car) async {
    await repository.addCar(car);
  }
}

class UpdateCar {
  final CarRepository repository;

  UpdateCar(this.repository);

  Future<void> call(Car car) async {
    await repository.updateCar(car);
  }
}

class DeleteCar {
  final CarRepository repository;

  DeleteCar(this.repository);

  Future<void> call(String id) async {
    await repository.deleteCar(id);
  }
}
