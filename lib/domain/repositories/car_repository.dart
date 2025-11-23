import '../entities/car.dart';

abstract class CarRepository {
  Future<List<Car>> getAllCars();
  Future<void> addCar(Car car);
  Future<void> updateCar(Car car);
  Future<void> deleteCar(String id);
}
