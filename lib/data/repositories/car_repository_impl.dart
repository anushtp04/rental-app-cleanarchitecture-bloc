import '../../domain/entities/car.dart';
import '../../domain/repositories/car_repository.dart';
import '../data_source/car_local_data_source.dart';
import '../models/car_model.dart';

class CarRepositoryImpl implements CarRepository {
  final CarLocalDataSource localDataSource;

  CarRepositoryImpl(this.localDataSource);

  @override
  Future<List<Car>> getAllCars() async {
    final carModels = await localDataSource.getAllCars();
    return carModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<void> addCar(Car car) async {
    await localDataSource.addCar(CarModel.fromEntity(car));
  }

  @override
  Future<void> updateCar(Car car) async {
    await localDataSource.updateCar(CarModel.fromEntity(car));
  }

  @override
  Future<void> deleteCar(String id) async {
    await localDataSource.deleteCar(id);
  }
}
