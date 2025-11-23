import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/rental_model.dart';
import '../../../core/service/firebase_auth_service.dart';

abstract class RentalFirestoreDataSource {
  Future<List<RentalModel>> getAllRentals();
  Future<RentalModel> getRentalById(String id);
  Future<void> cacheRental(RentalModel rental);
  Future<void> updateCachedRental(RentalModel rental);
  Future<void> deleteRental(String id);
  Future<void> deleteAllRentals();
  Future<List<RentalModel>> filterRentals({
    DateTime? fromDate,
    DateTime? toDate,
    String? vehicleNumber,
    String? ownerName,
  });
}

class RentalFirestoreDataSourceImpl implements RentalFirestoreDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuthService authService;

  RentalFirestoreDataSourceImpl({
    required this.firestore,
    required this.authService,
  });

  String get _userId => authService.currentUser?.uid ?? '';

  CollectionReference get _rentalsCollection =>
      firestore.collection('users').doc(_userId).collection('rentals');

  @override
  Future<List<RentalModel>> getAllRentals() async {
    try {
      final snapshot = await _rentalsCollection.orderBy('createdAt', descending: true).get();
      return snapshot.docs
          .map((doc) => RentalModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to get rentals: $e');
    }
  }

  @override
  Future<RentalModel> getRentalById(String id) async {
    try {
      final doc = await _rentalsCollection.doc(id).get();
      if (doc.exists) {
        return RentalModel.fromFirestore(doc.data()! as Map<String, dynamic>, doc.id);
      } else {
        throw Exception('Rental not found');
      }
    } catch (e) {
      throw Exception('Failed to get rental: $e');
    }
  }

  @override
  Future<void> cacheRental(RentalModel rental) async {
    try {
      await _rentalsCollection.doc(rental.id).set(rental.toFirestore());
    } catch (e) {
      throw Exception('Failed to add rental: $e');
    }
  }

  @override
  Future<void> updateCachedRental(RentalModel rental) async {
    try {
      await _rentalsCollection.doc(rental.id).update(rental.toFirestore());
    } catch (e) {
      throw Exception('Failed to update rental: $e');
    }
  }

  @override
  Future<void> deleteRental(String id) async {
    try {
      await _rentalsCollection.doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete rental: $e');
    }
  }

  @override
  Future<void> deleteAllRentals() async {
    try {
      final snapshot = await _rentalsCollection.get();
      final batch = firestore.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to delete all rentals: $e');
    }
  }

  @override
  Future<List<RentalModel>> filterRentals({
    DateTime? fromDate,
    DateTime? toDate,
    String? vehicleNumber,
    String? ownerName,
  }) async {
    try {
      Query query = _rentalsCollection;

      if (fromDate != null) {
        query = query.where('rentFromDate', isGreaterThanOrEqualTo: Timestamp.fromDate(fromDate));
      }

      if (toDate != null) {
        query = query.where('rentToDate', isLessThanOrEqualTo: Timestamp.fromDate(toDate));
      }

      final snapshot = await query.get();
      List<RentalModel> rentals = snapshot.docs
          .map((doc) => RentalModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
          .toList();

      // Client-side filtering for text fields
      if (vehicleNumber != null && vehicleNumber.isNotEmpty) {
        rentals = rentals.where((rental) {
          return rental.vehicleNumber.toLowerCase().contains(vehicleNumber.toLowerCase());
        }).toList();
      }

      if (ownerName != null && ownerName.isNotEmpty) {
        rentals = rentals.where((rental) {
          return rental.rentToPerson.toLowerCase().contains(ownerName.toLowerCase());
        }).toList();
      }

      return rentals;
    } catch (e) {
      throw Exception('Failed to filter rentals: $e');
    }
  }
}

