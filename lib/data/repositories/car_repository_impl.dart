import '../../domain/entities/car.dart';
import '../../domain/repositories/car_repository.dart';
import '../data_source/car_supabase_data_source.dart';
import '../models/car_model.dart';

class CarRepositoryImpl implements CarRepository {
  final CarSupabaseDataSource supabaseDataSource;

  CarRepositoryImpl(this.supabaseDataSource);

  @override
  Future<List<Car>> getAllCars() async {
    final carModels = await supabaseDataSource.getAllCars();
    return carModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<void> addCar(Car car) async {
    await supabaseDataSource.addCar(CarModel.fromEntity(car));
  }

  @override
  Future<void> updateCar(Car car) async {
    await supabaseDataSource.updateCar(CarModel.fromEntity(car));
  }

  @override
  Future<void> deleteCar(String id) async {
    await supabaseDataSource.deleteCar(id);
  }
}
