import '../../domain/entities/car.dart';
import '../../domain/repositories/car_repository.dart';
import '../data_source/car_firestore_data_source.dart';
import '../models/car_model.dart';

class CarRepositoryImpl implements CarRepository {
  final CarFirestoreDataSource firestoreDataSource;

  CarRepositoryImpl(this.firestoreDataSource);

  @override
  Future<List<Car>> getAllCars() async {
    final carModels = await firestoreDataSource.getAllCars();
    return carModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<void> addCar(Car car) async {
    await firestoreDataSource.addCar(CarModel.fromEntity(car));
  }

  @override
  Future<void> updateCar(Car car) async {
    await firestoreDataSource.updateCar(CarModel.fromEntity(car));
  }

  @override
  Future<void> deleteCar(String id) async {
    await firestoreDataSource.deleteCar(id);
  }
}
