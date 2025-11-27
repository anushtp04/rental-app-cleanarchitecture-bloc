import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/car_model.dart';
import '../../core/service/supabase_auth_service.dart';

abstract class CarSupabaseDataSource {
  Future<List<CarModel>> getAllCars();
  Future<void> addCar(CarModel car);
  Future<void> updateCar(CarModel car);
  Future<void> deleteCar(String id);
}

class CarSupabaseDataSourceImpl implements CarSupabaseDataSource {
  final SupabaseClient supabase;
  final SupabaseAuthService authService;

  CarSupabaseDataSourceImpl({
    required this.supabase,
    required this.authService,
  });

  String get _userId => authService.currentUser?.id ?? '';

  @override
  Future<List<CarModel>> getAllCars() async {
    try {
      final response = await supabase
          .from('cars')
          .select()
          .eq('user_id', _userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => CarModel.fromSupabase(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get cars: $e');
    }
  }

  @override
  Future<void> addCar(CarModel car) async {
    try {
      final carData = car.toSupabase();
      carData['user_id'] = _userId;
      
      await supabase.from('cars').insert(carData);
    } catch (e) {
      throw Exception('Failed to add car: $e');
    }
  }

  @override
  Future<void> updateCar(CarModel car) async {
    try {
      await supabase
          .from('cars')
          .update(car.toSupabase())
          .eq('id', car.id)
          .eq('user_id', _userId);
    } catch (e) {
      throw Exception('Failed to update car: $e');
    }
  }

  @override
  Future<void> deleteCar(String id) async {
    try {
      await supabase
          .from('cars')
          .delete()
          .eq('id', id)
          .eq('user_id', _userId);
    } catch (e) {
      throw Exception('Failed to delete car: $e');
    }
  }
}
