import '../entities/rental.dart';

abstract class RentalRepository {
  Future<List<Rental>> getAllRentals();
  Future<Rental> getRentalById(String id);
  Future<Rental> createRental(Rental rental);
  Future<Rental> updateRental(Rental rental);
  Future<void> deleteRental(String id);
  Future<void> deleteAllRentals();
  Future<List<Rental>> filterRentals({
    DateTime? fromDate,
    DateTime? toDate,
    String? vehicleNumber,
    String? ownerName,
  });
}

