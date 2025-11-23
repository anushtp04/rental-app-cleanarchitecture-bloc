import 'package:hive/hive.dart';
import '../models/car_model.dart';

abstract class CarLocalDataSource {
  Future<List<CarModel>> getAllCars();
  Future<void> addCar(CarModel car);
  Future<void> updateCar(CarModel car);
  Future<void> deleteCar(String id);
}

class CarLocalDataSourceImpl implements CarLocalDataSource {
  final Box<CarModel> carBox;

  CarLocalDataSourceImpl(this.carBox);

  @override
  Future<List<CarModel>> getAllCars() async {
    return carBox.values.toList();
  }

  @override
  Future<void> addCar(CarModel car) async {
    await carBox.put(car.id, car);
  }

  @override
  Future<void> updateCar(CarModel car) async {
    await carBox.put(car.id, car);
  }

  @override
  Future<void> deleteCar(String id) async {
    await carBox.delete(id);
  }
}
