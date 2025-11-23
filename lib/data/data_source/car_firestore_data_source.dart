import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/car_model.dart';
import '../../../core/service/firebase_auth_service.dart';

abstract class CarFirestoreDataSource {
  Future<List<CarModel>> getAllCars();
  Future<void> addCar(CarModel car);
  Future<void> updateCar(CarModel car);
  Future<void> deleteCar(String id);
}

class CarFirestoreDataSourceImpl implements CarFirestoreDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuthService authService;

  CarFirestoreDataSourceImpl({
    required this.firestore,
    required this.authService,
  });

  String get _userId => authService.currentUser?.uid ?? '';

  CollectionReference get _carsCollection =>
      firestore.collection('users').doc(_userId).collection('cars');

  @override
  Future<List<CarModel>> getAllCars() async {
    try {
      final snapshot = await _carsCollection.get();
      return snapshot.docs
          .map((doc) => CarModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to get cars: $e');
    }
  }

  @override
  Future<void> addCar(CarModel car) async {
    try {
      await _carsCollection.doc(car.id).set(car.toFirestore());
    } catch (e) {
      throw Exception('Failed to add car: $e');
    }
  }

  @override
  Future<void> updateCar(CarModel car) async {
    try {
      await _carsCollection.doc(car.id).update(car.toFirestore());
    } catch (e) {
      throw Exception('Failed to update car: $e');
    }
  }

  @override
  Future<void> deleteCar(String id) async {
    try {
      await _carsCollection.doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete car: $e');
    }
  }
}

